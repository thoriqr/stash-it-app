import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'google_auth_diagnostics.dart';
import 'google_auth_service.dart';

/// Google's authorization endpoint for installed applications.
const String googleAuthorizationEndpoint =
    'https://accounts.google.com/o/oauth2/v2/auth';

/// Google's token endpoint.
const String googleTokenEndpoint = 'https://oauth2.googleapis.com/token';

/// OpenID Connect scopes required by the existing Google authentication flow.
const String googleDesktopScopes = 'openid email profile';

/// Build-time Desktop OAuth client secret.
///
/// Read only by the Windows implementation. Android and other platforms never
/// read or require this value.
const String googleDesktopClientSecret = String.fromEnvironment(
  'GOOGLE_DESKTOP_CLIENT_SECRET',
);

const String _callbackPath = '/';

/// The PKCE verifier and its S256 challenge.
class PkcePair {
  const PkcePair({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;
}

/// Generates a cryptographically secure PKCE verifier and S256 challenge.
PkcePair generatePkcePair({Random? random}) {
  final verifier = _randomToken(random ?? Random.secure(), 32);
  final challenge = base64UrlEncode(
    sha256.convert(ascii.encode(verifier)).bytes,
  ).replaceAll('=', '');
  return PkcePair(verifier: verifier, challenge: challenge);
}

/// Generates a cryptographically secure OAuth state value.
String generateOAuthState({Random? random}) =>
    _randomToken(random ?? Random.secure(), 32);

String _randomToken(Random random, int byteCount) {
  final bytes = List<int>.generate(byteCount, (_) => random.nextInt(256));
  return base64UrlEncode(bytes).replaceAll('=', '');
}

/// Builds the Google authorization URL for the installed-app flow.
Uri buildGoogleAuthorizationUrl({
  required String clientId,
  required Uri redirectUri,
  required String state,
  required String codeChallenge,
}) {
  return Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': clientId,
    'redirect_uri': redirectUri.toString(),
    'response_type': 'code',
    'scope': googleDesktopScopes,
    'code_challenge': codeChallenge,
    'code_challenge_method': 'S256',
    'state': state,
    'prompt': 'select_account',
  });
}

/// The result of a validated OAuth authorization callback.
sealed class OAuthCallbackResult {
  const OAuthCallbackResult();
}

final class OAuthAuthorizationCode extends OAuthCallbackResult {
  const OAuthAuthorizationCode(this.code);

  final String code;
}

/// The user declined the authorization request.
final class OAuthAuthorizationCancelled extends OAuthCallbackResult {
  const OAuthAuthorizationCancelled();
}

/// Google returned an OAuth error other than user cancellation.
final class OAuthAuthorizationError extends OAuthCallbackResult {
  const OAuthAuthorizationError(this.error);

  final String error;
}

/// A single-use loopback HTTP server for the OAuth authorization callback.
///
/// It binds to the IPv4 loopback interface on an available port, validates the
/// returned state, and accepts exactly one authorization response.
class OAuthCallbackServer {
  OAuthCallbackServer({required this.expectedState});

  final String expectedState;

  HttpServer? _server;
  bool _cancelled = false;

  bool get isRunning => _server != null;

  /// The redirect URI the authorization request must use.
  Uri get redirectUri {
    final server = _server;
    if (server == null) {
      throw StateError('OAuth callback server has not started.');
    }
    return Uri(
      scheme: 'http',
      host: '127.0.0.1',
      port: server.port,
      path: _callbackPath,
    );
  }

  Future<void> start() async {
    if (_cancelled || _server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  }

  /// Stops accepting callbacks and ends an in-flight wait.
  ///
  /// [close] remains idempotent, so the owner can still call it during cleanup.
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    unawaited(close());
  }

  /// Waits for one authorization response.
  ///
  /// Throws [GoogleAuthException] for an invalid state, a malformed callback,
  /// or a timeout. The caller remains responsible for [close].
  Future<OAuthCallbackResult> waitForCallback({
    required Duration timeout,
  }) async {
    if (_cancelled) return const OAuthAuthorizationCancelled();

    final server = _server;
    if (server == null) {
      throw StateError('OAuth callback server has not started.');
    }

    try {
      await for (final request in server.timeout(timeout)) {
        if (_cancelled) return const OAuthAuthorizationCancelled();

        // Browsers may request unrelated resources such as a favicon.
        if (request.uri.path != _callbackPath) {
          await _respond(request, HttpStatus.notFound, _notFoundPage);
          continue;
        }

        final parameters = request.uri.queryParameters;
        if (!_constantTimeEquals(parameters['state'] ?? '', expectedState)) {
          if (_cancelled) return const OAuthAuthorizationCancelled();
          logGoogleAuthStage(
            'callback',
            outcome: 'state-mismatch',
            failure: true,
          );
          await _respond(request, HttpStatus.badRequest, _invalidStatePage);
          throw const GoogleAuthException(GoogleAuthFailure.stateMismatch);
        }

        final error = parameters['error'];
        if (error != null && error.isNotEmpty) {
          if (_cancelled) return const OAuthAuthorizationCancelled();
          logGoogleAuthStage(
            'callback',
            outcome: 'oauth-error',
            detail: 'google_error=$error',
            failure: true,
          );
          await _respond(request, HttpStatus.ok, _completePage);
          return error == 'access_denied'
              ? const OAuthAuthorizationCancelled()
              : OAuthAuthorizationError(error);
        }

        final code = parameters['code'];
        if (code == null || code.isEmpty) {
          if (_cancelled) return const OAuthAuthorizationCancelled();
          logGoogleAuthStage(
            'callback',
            outcome: 'missing-code',
            failure: true,
          );
          await _respond(request, HttpStatus.badRequest, _missingCodePage);
          throw const GoogleAuthException(GoogleAuthFailure.callbackError);
        }

        if (_cancelled) return const OAuthAuthorizationCancelled();
        logGoogleAuthStage('callback', outcome: 'authorization-code-received');
        await _respond(request, HttpStatus.ok, _completePage);
        return OAuthAuthorizationCode(code);
      }

      if (_cancelled) return const OAuthAuthorizationCancelled();
      logGoogleAuthStage('callback', outcome: 'stream-ended', failure: true);
      throw const GoogleAuthException(GoogleAuthFailure.callbackError);
    } on TimeoutException {
      if (_cancelled) return const OAuthAuthorizationCancelled();
      logGoogleAuthStage('callback', outcome: 'timeout', failure: true);
      throw const GoogleAuthException(GoogleAuthFailure.callbackTimeout);
    }
  }

  /// Stops the listener. Safe to call more than once.
  Future<void> close() async {
    final server = _server;
    _server = null;
    if (server == null) return;
    await server.close(force: true);
  }

  Future<void> _respond(
    HttpRequest request,
    int statusCode,
    String body,
  ) async {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.html
      ..headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    request.response.write(body);
    await request.response.close();
  }
}

bool _constantTimeEquals(String left, String right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index++) {
    difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
  }
  return difference == 0;
}

const String _completePage =
    '<!doctype html><html><head><meta charset="utf-8">'
    '<title>Stash-it</title></head><body>'
    '<p>You can close this tab and return to Stash-it to finish signing '
    'in.</p></body></html>';

const String _invalidStatePage =
    '<!doctype html><html><head><meta charset="utf-8">'
    '<title>Stash-it</title></head><body>'
    '<p>This sign-in response could not be verified. Return to Stash-it and '
    'try again.</p></body></html>';

const String _missingCodePage =
    '<!doctype html><html><head><meta charset="utf-8">'
    '<title>Stash-it</title></head><body>'
    '<p>This sign-in response is incomplete. Return to Stash-it and try '
    'again.</p></body></html>';

const String _notFoundPage =
    '<!doctype html><html><head><meta charset="utf-8">'
    '<title>Stash-it</title></head><body>'
    '<p>Not found.</p></body></html>';

/// Opens a URL in the system default browser.
typedef BrowserLauncher = Future<bool> Function(Uri url);

/// Acquires a Google ID token on Windows through the system browser.
///
/// The flow uses OAuth 2.0 Authorization Code with PKCE (S256), a dynamic
/// loopback redirect on `127.0.0.1`, and no embedded WebView. The authorization
/// code is exchanged directly with the original verifier; the returned ID token
/// enters the existing [GoogleAuthClient] pipeline unchanged.
class WindowsGoogleAuthService implements GoogleAuthCancellation {
  WindowsGoogleAuthService({
    required this.clientId,
    this.clientSecret = googleDesktopClientSecret,
    Dio? dio,
    BrowserLauncher? launchBrowser,
    this.callbackTimeout = const Duration(minutes: 5),
    this.random,
    OAuthCallbackServer Function(String expectedState)? callbackServerFactory,
  }) : _dio = dio ?? Dio(),
       _launchBrowser = launchBrowser ?? _launchInSystemBrowser,
       _createCallbackServer =
           callbackServerFactory ??
           ((state) => OAuthCallbackServer(expectedState: state));

  final String clientId;
  final String clientSecret;
  final Duration callbackTimeout;
  final Random? random;
  final Dio _dio;
  final BrowserLauncher _launchBrowser;
  final OAuthCallbackServer Function(String expectedState)
  _createCallbackServer;

  bool _cancelled = false;
  OAuthCallbackServer? _activeCallbackServer;

  @override
  void cancel() {
    final callbackServer = _activeCallbackServer;
    if (callbackServer == null || _cancelled) return;

    _cancelled = true;
    logGoogleAuthStage('sign-in', outcome: 'cancellation-requested');
    callbackServer.cancel();
  }

  @override
  Future<GoogleAuthCredential?> signIn() async {
    if (clientId.isEmpty) {
      logGoogleAuthStage(
        'configuration',
        outcome: 'missing-desktop-client-id',
        failure: true,
      );
      throw const GoogleAuthException(GoogleAuthFailure.notConfigured);
    }

    if (clientSecret.isEmpty) {
      logGoogleAuthStage(
        'configuration',
        outcome: 'missing-desktop-client-secret',
        failure: true,
      );
      throw const GoogleAuthException(GoogleAuthFailure.notConfigured);
    }

    _cancelled = false;
    logGoogleAuthStage('sign-in', outcome: 'started');

    final pkce = generatePkcePair(random: random);
    final state = generateOAuthState(random: random);
    final callbackServer = _createCallbackServer(state);
    _activeCallbackServer = callbackServer;

    try {
      await callbackServer.start();
      if (_cancelled) return null;
      logGoogleAuthStage('callback-server', outcome: 'started');

      final redirectUri = callbackServer.redirectUri;

      final authorizationUrl = buildGoogleAuthorizationUrl(
        clientId: clientId,
        redirectUri: redirectUri,
        state: state,
        codeChallenge: pkce.challenge,
      );

      final bool launched;
      try {
        launched = await _launchBrowser(authorizationUrl);
      } catch (error, stackTrace) {
        logGoogleAuthStage(
          'browser',
          outcome: 'failed',
          detail: 'exception=${error.runtimeType}',
          failure: true,
          stackTrace: stackTrace,
        );
        throw const GoogleAuthException(GoogleAuthFailure.browserLaunchFailed);
      }
      if (_cancelled) return null;
      if (!launched) {
        logGoogleAuthStage('browser', outcome: 'not-opened', failure: true);
        throw const GoogleAuthException(GoogleAuthFailure.browserLaunchFailed);
      }
      logGoogleAuthStage('browser', outcome: 'opened');

      final result = await callbackServer.waitForCallback(
        timeout: callbackTimeout,
      );
      if (_cancelled) return null;

      switch (result) {
        case OAuthAuthorizationCancelled():
          logGoogleAuthStage('callback', outcome: 'cancelled');
          return null;
        case OAuthAuthorizationError():
          throw const GoogleAuthException(GoogleAuthFailure.callbackError);
        case OAuthAuthorizationCode(:final code):
          final idToken = await _exchangeCode(
            code: code,
            redirectUri: redirectUri,
            codeVerifier: pkce.verifier,
          );
          if (_cancelled) return null;
          return _credentialFromIdToken(idToken);
      }
    } on GoogleAuthException catch (error, stackTrace) {
      logGoogleAuthStage(
        'sign-in',
        outcome: 'failed',
        detail: 'failure=${error.failure.name}',
        failure: true,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      logGoogleAuthStage(
        'sign-in',
        outcome: 'failed',
        detail: 'exception=${error.runtimeType}',
        failure: true,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      await callbackServer.close();
      if (identical(_activeCallbackServer, callbackServer)) {
        _activeCallbackServer = null;
      }
      _cancelled = false;
    }
  }

  Future<String> _exchangeCode({
    required String code,
    required Uri redirectUri,
    required String codeVerifier,
  }) async {
    logGoogleAuthStage('token-exchange', outcome: 'started');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        googleTokenEndpoint,
        data: <String, String>{
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri.toString(),
          'code_verifier': codeVerifier,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      final idToken = response.data?['id_token'];
      if (idToken is! String || idToken.isEmpty) {
        logGoogleAuthStage(
          'token-exchange',
          outcome: 'missing-id-token',
          failure: true,
        );
        throw const GoogleAuthException(GoogleAuthFailure.missingIdToken);
      }

      logGoogleAuthStage('token-exchange', outcome: 'succeeded');
      return idToken;
    } on GoogleAuthException {
      rethrow;
    } on DioException catch (error, stackTrace) {
      logGoogleAuthStage(
        'token-exchange',
        outcome: 'failed',
        detail: googleTokenExchangeFailureDetail(
          error,
          secrets: [code, codeVerifier, clientSecret],
        ),
        failure: true,
        stackTrace: stackTrace,
      );
      throw GoogleAuthException(
        GoogleAuthFailure.tokenExchangeFailed,
        statusCode: error.response?.statusCode,
        oauthError: googleOAuthErrorCode(error),
      );
    } catch (error, stackTrace) {
      logGoogleAuthStage(
        'token-exchange',
        outcome: 'failed',
        detail: 'exception=${error.runtimeType}',
        failure: true,
        stackTrace: stackTrace,
      );
      throw const GoogleAuthException(GoogleAuthFailure.tokenExchangeFailed);
    }
  }

  GoogleAuthCredential _credentialFromIdToken(String idToken) {
    final claims = _decodeIdTokenClaims(idToken);
    final email = claims['email'];
    final name = claims['name'];

    return GoogleAuthCredential(
      idToken: idToken,
      email: email is String ? email : '',
      displayName: name is String && name.isNotEmpty ? name : null,
    );
  }

  /// Reads display hints from the ID token without treating them as proof.
  ///
  /// The backend verifies the token. If the payload cannot be read, the flow
  /// still continues with the token because the server remains authoritative.
  Map<String, dynamic> _decodeIdTokenClaims(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) return const {};
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }
}

Future<bool> _launchInSystemBrowser(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);
