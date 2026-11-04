import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/auth/data/google_auth_diagnostics.dart';
import 'package:stash_it_app/features/auth/data/google_auth_service.dart';
import 'package:stash_it_app/features/auth/data/windows_google_auth_service.dart';

import '../../../support/fake_http.dart';

class _RecordingCallbackServer extends OAuthCallbackServer {
  _RecordingCallbackServer({required super.expectedState});

  int closeCalls = 0;

  @override
  Future<void> close() async {
    if (!isRunning) return;
    closeCalls++;
    await super.close();
  }
}

class _FailingCallbackServer extends _RecordingCallbackServer {
  _FailingCallbackServer({required super.expectedState});

  @override
  Future<OAuthCallbackResult> waitForCallback({
    required Duration timeout,
  }) async {
    throw StateError('unexpected callback failure');
  }
}

Future<int> _sendCallback(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final status = response.statusCode;
    await response.drain<void>();
    return status;
  } finally {
    client.close(force: true);
  }
}

Future<void> _requestCallback(Uri uri) async {
  try {
    await _sendCallback(uri);
  } catch (_) {
    // The flow may already have closed the listener; nothing to assert here.
  }
}

String _fakeIdToken({required String email, String? name}) {
  String encode(Map<String, dynamic> value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

  return '${encode({'alg': 'none'})}.'
      '${encode({'email': email, 'name': ?name})}'
      '.signature';
}

Matcher _failureIs(GoogleAuthFailure failure) => isA<GoogleAuthException>()
    .having((error) => error.failure, 'failure', failure);

void main() {
  group('PKCE generation', () {
    test('produces a verifier and matching S256 challenge', () {
      final pair = generatePkcePair();

      expect(pair.verifier.length, inInclusiveRange(43, 128));
      expect(RegExp(r'^[A-Za-z0-9\-._~]+$').hasMatch(pair.verifier), isTrue);

      final expectedChallenge = base64UrlEncode(
        sha256.convert(ascii.encode(pair.verifier)).bytes,
      ).replaceAll('=', '');
      expect(pair.challenge, expectedChallenge);
      expect(pair.challenge, isNot(contains('=')));
    });

    test('generates distinct verifiers and states', () {
      final first = generatePkcePair();
      final second = generatePkcePair();

      expect(first.verifier, isNot(second.verifier));
      expect(generateOAuthState(), isNot(generateOAuthState()));
    });
  });

  group('authorization URL', () {
    test('requests the required scopes with S256 and the callback data', () {
      final uri = buildGoogleAuthorizationUrl(
        clientId: 'desktop-client',
        redirectUri: Uri.parse('http://127.0.0.1:43210/'),
        state: 'state-1',
        codeChallenge: 'challenge-1',
      );

      expect(uri.toString(), startsWith(googleAuthorizationEndpoint));
      final parameters = uri.queryParameters;
      expect(parameters['client_id'], 'desktop-client');
      expect(parameters['redirect_uri'], 'http://127.0.0.1:43210/');
      expect(parameters['response_type'], 'code');
      expect(parameters['scope'], 'openid email profile');
      expect(parameters['code_challenge'], 'challenge-1');
      expect(parameters['code_challenge_method'], 'S256');
      expect(parameters['state'], 'state-1');
    });
  });

  group('loopback callback server', () {
    test('binds to IPv4 loopback and accepts a valid callback', () async {
      final server = OAuthCallbackServer(expectedState: 'state-1');
      await server.start();
      addTearDown(server.close);

      expect(server.redirectUri.host, '127.0.0.1');
      expect(server.redirectUri.port, greaterThan(0));

      final result = server.waitForCallback(
        timeout: const Duration(seconds: 5),
      );
      final status = await _sendCallback(
        server.redirectUri.replace(
          queryParameters: {'code': 'auth-code', 'state': 'state-1'},
        ),
      );

      expect(status, HttpStatus.ok);
      final callback = await result;
      expect(callback, isA<OAuthAuthorizationCode>());
      expect((callback as OAuthAuthorizationCode).code, 'auth-code');
    });

    test('rejects a callback with an unexpected state', () async {
      final server = OAuthCallbackServer(expectedState: 'state-1');
      await server.start();
      addTearDown(server.close);

      final expectation = expectLater(
        server.waitForCallback(timeout: const Duration(seconds: 5)),
        throwsA(_failureIs(GoogleAuthFailure.stateMismatch)),
      );
      final status = await _sendCallback(
        server.redirectUri.replace(
          queryParameters: {'code': 'auth-code', 'state': 'wrong-state'},
        ),
      );

      expect(status, HttpStatus.badRequest);
      await expectation;
    });

    test('treats access_denied as user cancellation', () async {
      final server = OAuthCallbackServer(expectedState: 'state-1');
      await server.start();
      addTearDown(server.close);

      final result = server.waitForCallback(
        timeout: const Duration(seconds: 5),
      );
      await _sendCallback(
        server.redirectUri.replace(
          queryParameters: {'error': 'access_denied', 'state': 'state-1'},
        ),
      );

      expect(await result, isA<OAuthAuthorizationCancelled>());
    });

    test(
      'returns other OAuth errors without treating them as success',
      () async {
        final server = OAuthCallbackServer(expectedState: 'state-1');
        await server.start();
        addTearDown(server.close);

        final result = server.waitForCallback(
          timeout: const Duration(seconds: 5),
        );
        await _sendCallback(
          server.redirectUri.replace(
            queryParameters: {'error': 'invalid_request', 'state': 'state-1'},
          ),
        );

        final callback = await result;
        expect(callback, isA<OAuthAuthorizationError>());
        expect((callback as OAuthAuthorizationError).error, 'invalid_request');
      },
    );

    test('rejects a callback without a code', () async {
      final server = OAuthCallbackServer(expectedState: 'state-1');
      await server.start();
      addTearDown(server.close);

      final expectation = expectLater(
        server.waitForCallback(timeout: const Duration(seconds: 5)),
        throwsA(_failureIs(GoogleAuthFailure.callbackError)),
      );
      final status = await _sendCallback(
        server.redirectUri.replace(queryParameters: {'state': 'state-1'}),
      );

      expect(status, HttpStatus.badRequest);
      await expectation;
    });

    test('ignores unrelated browser requests', () async {
      final server = OAuthCallbackServer(expectedState: 'state-1');
      await server.start();
      addTearDown(server.close);

      final result = server.waitForCallback(
        timeout: const Duration(seconds: 5),
      );
      final ignored = await _sendCallback(
        server.redirectUri.replace(path: '/favicon.ico'),
      );
      final accepted = await _sendCallback(
        server.redirectUri.replace(
          queryParameters: {'code': 'auth-code', 'state': 'state-1'},
        ),
      );

      expect(ignored, HttpStatus.notFound);
      expect(accepted, HttpStatus.ok);
      expect(await result, isA<OAuthAuthorizationCode>());
    });

    test('times out and can be closed', () async {
      final server = OAuthCallbackServer(expectedState: 'state-1');
      await server.start();

      await expectLater(
        server.waitForCallback(timeout: const Duration(milliseconds: 100)),
        throwsA(_failureIs(GoogleAuthFailure.callbackTimeout)),
      );

      await server.close();
      expect(server.isRunning, isFalse);
      await server.close();
    });
  });

  group('WindowsGoogleAuthService', () {
    test('requires a Desktop OAuth client ID', () async {
      final service = WindowsGoogleAuthService(clientId: '');

      await expectLater(
        service.signIn(),
        throwsA(_failureIs(GoogleAuthFailure.notConfigured)),
      );
    });

    test(
      'requires the Desktop OAuth client secret before any request',
      () async {
        final adapter = FakeHttpAdapter();
        final dio = Dio()..httpClientAdapter = adapter;
        var launched = false;

        final service = WindowsGoogleAuthService(
          clientId: 'desktop-client',
          clientSecret: '',
          dio: dio,
          launchBrowser: (_) async {
            launched = true;
            return true;
          },
        );

        await expectLater(
          service.signIn(),
          throwsA(_failureIs(GoogleAuthFailure.notConfigured)),
        );

        expect(launched, isFalse);
        expect(adapter.requests, isEmpty);
      },
    );

    test('uses a five-minute callback timeout by default', () {
      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
      );

      expect(service.callbackTimeout, const Duration(minutes: 5));
    });

    test('cancel stops the wait and closes the callback server', () async {
      late _RecordingCallbackServer callbackServer;
      final browserOpened = Completer<void>();

      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
        callbackTimeout: const Duration(seconds: 5),
        launchBrowser: (_) async {
          browserOpened.complete();
          return true;
        },
        callbackServerFactory: (state) {
          callbackServer = _RecordingCallbackServer(expectedState: state);
          return callbackServer;
        },
      );

      final signIn = service.signIn();
      await browserOpened.future;
      expect(callbackServer.isRunning, isTrue);

      service.cancel();

      expect(await signIn, isNull);
      expect(callbackServer.isRunning, isFalse);
      expect(callbackServer.closeCalls, 1);
    });

    test('closes the callback server after an unexpected exception', () async {
      late _FailingCallbackServer callbackServer;

      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
        launchBrowser: (_) async => true,
        callbackServerFactory: (state) {
          callbackServer = _FailingCallbackServer(expectedState: state);
          return callbackServer;
        },
      );

      await expectLater(service.signIn(), throwsA(isA<StateError>()));

      expect(callbackServer.isRunning, isFalse);
      expect(callbackServer.closeCalls, 1);
    });

    test(
      'reports browser launch failure and closes the callback server',
      () async {
        late _RecordingCallbackServer callbackServer;
        final service = WindowsGoogleAuthService(
          clientId: 'desktop-client',
          clientSecret: 'test-desktop-secret',
          launchBrowser: (_) async => false,
          callbackServerFactory: (state) {
            callbackServer = _RecordingCallbackServer(expectedState: state);
            return callbackServer;
          },
        );

        await expectLater(
          service.signIn(),
          throwsA(_failureIs(GoogleAuthFailure.browserLaunchFailed)),
        );

        expect(callbackServer.closeCalls, 1);
        expect(callbackServer.isRunning, isFalse);
      },
    );

    test('times out and closes the callback server', () async {
      late _RecordingCallbackServer callbackServer;
      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
        launchBrowser: (_) async => true,
        callbackTimeout: const Duration(milliseconds: 100),
        callbackServerFactory: (state) {
          callbackServer = _RecordingCallbackServer(expectedState: state);
          return callbackServer;
        },
      );

      await expectLater(
        service.signIn(),
        throwsA(_failureIs(GoogleAuthFailure.callbackTimeout)),
      );

      expect(callbackServer.closeCalls, 1);
      expect(callbackServer.isRunning, isFalse);
    });

    test('closes the callback server after a validation failure', () async {
      late _RecordingCallbackServer callbackServer;

      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
        callbackTimeout: const Duration(seconds: 5),
        launchBrowser: (url) async {
          final redirectUri = Uri.parse(url.queryParameters['redirect_uri']!);
          unawaited(
            _requestCallback(
              redirectUri.replace(
                queryParameters: {'code': 'auth-code', 'state': 'wrong-state'},
              ),
            ),
          );
          return true;
        },
        callbackServerFactory: (state) {
          callbackServer = _RecordingCallbackServer(expectedState: state);
          return callbackServer;
        },
      );

      await expectLater(
        service.signIn(),
        throwsA(_failureIs(GoogleAuthFailure.stateMismatch)),
      );

      expect(callbackServer.isRunning, isFalse);
      expect(callbackServer.closeCalls, 1);
    });

    test(
      'exchanges the code with the original verifier and returns the ID token',
      () async {
        final adapter = FakeHttpAdapter();
        final idToken = _fakeIdToken(
          email: 'google@example.com',
          name: 'Google User',
        );
        adapter.onMethod('POST', '/token', body: {'id_token': idToken});
        final dio = Dio()..httpClientAdapter = adapter;

        late Uri authorizationUrl;
        final service = WindowsGoogleAuthService(
          clientId: 'desktop-client',
          clientSecret: 'test-desktop-secret',
          dio: dio,
          callbackTimeout: const Duration(seconds: 5),
          launchBrowser: (url) async {
            authorizationUrl = url;
            final redirectUri = Uri.parse(url.queryParameters['redirect_uri']!);
            final state = url.queryParameters['state']!;
            unawaited(
              _requestCallback(
                redirectUri.replace(
                  queryParameters: {'code': 'auth-code', 'state': state},
                ),
              ),
            );
            return true;
          },
        );

        final credential = await service.signIn();

        expect(credential, isNotNull);
        expect(credential!.idToken, idToken);
        expect(credential.email, 'google@example.com');
        expect(credential.displayName, 'Google User');

        final sent = adapter.lastRequestTo('/token')!;
        expect(sent.method, 'POST');
        final body = sent.body;
        final form = body is String
            ? Uri.splitQueryString(body)
            : (body! as Map).cast<String, String>();
        expect(form['grant_type'], 'authorization_code');
        expect(form['code'], 'auth-code');
        expect(form['client_id'], 'desktop-client');
        expect(form['client_secret'], 'test-desktop-secret');
        expect(
          form['redirect_uri'],
          authorizationUrl.queryParameters['redirect_uri'],
        );

        final verifier = form['code_verifier']!;
        final challenge = base64UrlEncode(
          sha256.convert(ascii.encode(verifier)).bytes,
        ).replaceAll('=', '');
        expect(challenge, authorizationUrl.queryParameters['code_challenge']);
      },
    );

    test('preserves the Google error from a failed token exchange', () async {
      final adapter = FakeHttpAdapter();
      adapter.onMethod(
        'POST',
        '/token',
        status: 400,
        body: {
          'error': 'invalid_request',
          'error_description': 'client_secret is missing',
        },
      );
      final dio = Dio()..httpClientAdapter = adapter;
      late _RecordingCallbackServer callbackServer;

      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
        dio: dio,
        callbackTimeout: const Duration(seconds: 5),
        launchBrowser: (url) async {
          final redirectUri = Uri.parse(url.queryParameters['redirect_uri']!);
          unawaited(
            _requestCallback(
              redirectUri.replace(
                queryParameters: {
                  'code': 'auth-code',
                  'state': url.queryParameters['state']!,
                },
              ),
            ),
          );
          return true;
        },
        callbackServerFactory: (state) {
          callbackServer = _RecordingCallbackServer(expectedState: state);
          return callbackServer;
        },
      );

      await expectLater(
        service.signIn(),
        throwsA(
          isA<GoogleAuthException>()
              .having(
                (error) => error.failure,
                'failure',
                GoogleAuthFailure.tokenExchangeFailed,
              )
              .having((error) => error.statusCode, 'statusCode', 400)
              .having(
                (error) => error.oauthError,
                'oauthError',
                'invalid_request',
              ),
        ),
      );

      expect(callbackServer.isRunning, isFalse);
      expect(callbackServer.closeCalls, 1);
    });

    test('distinguishes a missing ID token from a failed exchange', () async {
      final adapter = FakeHttpAdapter();
      adapter.onMethod('POST', '/token', body: {'access_token': 'unused'});
      final dio = Dio()..httpClientAdapter = adapter;

      final service = WindowsGoogleAuthService(
        clientId: 'desktop-client',
        clientSecret: 'test-desktop-secret',
        dio: dio,
        callbackTimeout: const Duration(seconds: 5),
        launchBrowser: (url) async {
          final redirectUri = Uri.parse(url.queryParameters['redirect_uri']!);
          unawaited(
            _requestCallback(
              redirectUri.replace(
                queryParameters: {
                  'code': 'auth-code',
                  'state': url.queryParameters['state']!,
                },
              ),
            ),
          );
          return true;
        },
      );

      await expectLater(
        service.signIn(),
        throwsA(_failureIs(GoogleAuthFailure.missingIdToken)),
      );
    });
  });

  group('diagnostics', () {
    test('reports only safe token-exchange detail and redacts secrets', () {
      const code = 'authorization-code-secret';
      const verifier = 'pkce-verifier-secret';
      const clientSecret = 'desktop-client-secret';
      final request = RequestOptions(path: googleTokenEndpoint);
      final error = DioException(
        requestOptions: request,
        response: Response<Map<String, dynamic>>(
          requestOptions: request,
          statusCode: 400,
          data: {
            'error': 'invalid_request',
            'error_description':
                'rejected $code and $verifier and $clientSecret',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final detail = googleTokenExchangeFailureDetail(
        error,
        secrets: [code, verifier, clientSecret],
      );

      expect(detail, contains('status=400'));
      expect(detail, contains('google_error=invalid_request'));
      expect(detail, contains('[redacted]'));
      expect(detail, isNot(contains(code)));
      expect(detail, isNot(contains(verifier)));
      expect(detail, isNot(contains(clientSecret)));
      expect(googleOAuthErrorCode(error), 'invalid_request');
    });
  });

  group('platform selection', () {
    test('uses the browser flow on Windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(googleAuthServiceProvider),
        isA<WindowsGoogleAuthService>(),
      );
    });

    test('keeps the plugin flow on Android without the Desktop secret', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(googleAuthServiceProvider);

      expect(service, isA<GoogleAuthService>());
      expect(service, isNot(isA<WindowsGoogleAuthService>()));
    });
  });
}
