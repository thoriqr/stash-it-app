import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/network/token_provider.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';

import '../../../support/fake_http.dart';

/// Renewal behaviour of [SessionController].
///
/// Driven through the **real** provider graph — only the credential store and
/// the bootstrap-supplied tokens are overridden, exactly as `bootstrap` does.
/// An earlier version of this file overrode `authRepositoryProvider` with a fake
/// repository, which removed the very edge that closed the dependency cycle, so
/// the graph under test was not the one that ships.
///
/// `RefreshApi` cannot be subclassed — its constructor is a redirecting factory
/// to generated code — so renewal outcomes are scripted on the transport rather
/// than injected as a fake object. That exercises the real decode path too.
void main() {
  const accessKey = 'stash_it.auth.access_token';
  const refreshKey = 'stash_it.auth.refresh_token';

  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;

  /// Builds a container wired exactly as `bootstrap` wires the app.
  ProviderContainer makeContainer({AuthTokens? restored}) {
    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(restored),
      ],
      // Stops Riverpod retrying a provider driven into an error state, which
      // would otherwise make error-path tests slow and add call-count noise.
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  SessionController controller() =>
      container.read(sessionControllerProvider.notifier);

  /// The success envelope `POST /auth/refresh` returns.
  Map<String, dynamic> rotated([
    String access = 'access-2',
    String? refresh,
  ]) => {
    'data': {'access_token': access, 'refresh_token': refresh ?? 'refresh-2'},
    'message': 'token refreshed successfully',
  };

  setUp(() {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
  });

  group('startup restoration', () {
    test('a stored pair is held, with no network call', () {
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';

      container = makeContainer(
        restored: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      container.read(appDioProvider).httpClientAdapter = adapter;

      expect(container.read(authStateProvider), AuthStatus.signedIn);
      expect(
        adapter.requests,
        isEmpty,
        reason: 'startup must not validate or spend a rotation',
      );
    });

    test('no stored credentials starts signed out', () {
      container = makeContainer();

      expect(container.read(authStateProvider), AuthStatus.signedOut);
    });

    test('a partial pair is not a session', () async {
      // Nothing could renew it, so reporting a session would let the user in with
      // a token whose first request 401s and cannot recover.
      backend.values[accessKey] = 'access-1';

      expect(await SecureCredentialStore(backend).read(), isNull);
    });
  });

  group('single-flight renewal', () {
    test('concurrent callers share one submission', () async {
      // The backend revokes the whole session on reuse, so N concurrent expiries
      // must produce exactly one POST /auth/refresh.
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[refreshKey] = 'refresh-1';
      adapter.onBlocking('/auth/refresh', FakeReply(200, rotated()));

      final pending = [
        controller().refreshAccessToken(),
        controller().refreshAccessToken(),
        controller().refreshAccessToken(),
      ];

      await untilCalled(() => adapter.countFor('/auth/refresh') > 0);
      adapter.releaseBlocked();

      final tokens = await Future.wait(pending);

      expect(adapter.countFor('/auth/refresh'), 1);
      expect(tokens, everyElement('access-2'));
    });

    test('only the current refresh token is ever presented', () async {
      // A renewal that read a stale in-memory copy would present a token the
      // backend has already replaced — exactly what trips reuse detection.
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[refreshKey] = 'refresh-1';
      adapter.on('/auth/refresh', body: rotated());
      await controller().refreshAccessToken();

      // A later renewal must read the rotated token from storage.
      adapter.on('/auth/refresh', body: rotated('access-3', 'refresh-3'));
      await controller().refreshAccessToken();

      final submitted = adapter.requests
          .where((r) => r.path.contains('/auth/refresh'))
          .map((r) => r.jsonField('refresh_token'))
          .toList();

      expect(
        submitted,
        ['refresh-1', 'refresh-2'],
        reason:
            'the second renewal must present the token the first rotation '
            'issued; presenting refresh-1 again would trip reuse detection and '
            'revoke the session',
      );
    });

    test('the shared future is released after a success', () async {
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[refreshKey] = 'refresh-1';
      adapter.on('/auth/refresh', body: rotated());

      await controller().refreshAccessToken();
      adapter.on('/auth/refresh', body: rotated('access-3', 'refresh-3'));
      await controller().refreshAccessToken();

      expect(
        adapter.countFor('/auth/refresh'),
        2,
        reason: 'a completed future must not be reused for the next renewal',
      );
    });

    test('the shared future is released after a failure', () async {
      // A cached rejection would make every later renewal fail with the first
      // error, leaving the app permanently unable to recover.
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[refreshKey] = 'refresh-1';
      adapter.on(
        '/auth/refresh',
        status: 429,
        body: errorBody('IP_RATE_LIMIT_EXCEEDED'),
      );

      await expectLater(
        controller().refreshAccessToken(),
        throwsA(isA<DioException>()),
      );

      adapter.on('/auth/refresh', body: rotated('access-3', 'refresh-3'));

      expect(await controller().refreshAccessToken(), 'access-3');
    });
  });

  group('renewal outcomes', () {
    test(
      'a successful rotation persists both tokens before returning',
      () async {
        container = makeContainer();
        container.read(refreshDioProvider).httpClientAdapter = adapter;

        backend.values[accessKey] = 'access-1';
        backend.values[refreshKey] = 'refresh-1';
        adapter.on('/auth/refresh', body: rotated());

        await controller().refreshAccessToken();

        expect(backend.values[accessKey], 'access-2');
        expect(backend.values[refreshKey], 'refresh-2');
      },
    );

    test('each terminal code clears credentials and signs out', () async {
      for (final code in const [
        'REFRESH_TOKEN_INVALID',
        'SESSION_REVOKED',
        'SESSION_EXPIRED',
      ]) {
        backend = InMemorySecureStorage();
        adapter = FakeHttpAdapter();

        container = makeContainer();
        container.read(refreshDioProvider).httpClientAdapter = adapter;

        backend.values[accessKey] = 'access-1';
        backend.values[refreshKey] = 'refresh-1';
        adapter.on('/auth/refresh', status: 401, body: errorBody(code));

        await expectLater(
          controller().refreshAccessToken(),
          throwsA(
            isA<SessionExpiredException>().having((e) => e.code, 'code', code),
          ),
        );

        expect(
          backend.values,
          isEmpty,
          reason: '$code must clear the stored credentials',
        );
        expect(
          container.read(authStateProvider),
          AuthStatus.signedOut,
          reason: 'the status must follow the session without being pushed to',
        );
      }
    });

    test('a late request does not re-arm the one-time notice', () async {
      container = makeContainer(
        restored: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';
      adapter.on(
        '/auth/refresh',
        status: 401,
        body: errorBody('SESSION_REVOKED'),
      );

      await expectLater(
        controller().refreshAccessToken(),
        throwsA(isA<SessionExpiredException>()),
      );
      expect(controller().consumeSessionEnded(), isTrue);

      // A request already in flight when the terminal reply arrived now finds
      // its refresh token gone and tries to end the session again.
      await expectLater(
        controller().refreshAccessToken(),
        throwsA(
          isA<SessionExpiredException>().having(
            (e) => e.code,
            'code',
            'NO_REFRESH_TOKEN',
          ),
        ),
      );

      expect(
        controller().consumeSessionEnded(),
        isFalse,
        reason: 'the second ending must not re-arm the already-consumed notice',
      );
      expect(backend.values, isEmpty);
    });

    test('an ambiguous failure keeps credentials and does not retry', () async {
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';
      adapter.on(
        '/auth/refresh',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        controller().refreshAccessToken(),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiFailureRefreshUncertain>(),
          ),
        ),
      );

      expect(
        backend.values[refreshKey],
        'refresh-1',
        reason: 'a 500 may or may not have committed; do not destroy evidence',
      );
      expect(
        adapter.countFor('/auth/refresh'),
        1,
        reason: 'no automatic retry after an ambiguous outcome',
      );
    });

    test('a rate-limited renewal keeps credentials', () async {
      // The limiter mounts in front of the handler and fails closed without
      // consuming the token, so the session is untouched.
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';
      adapter.on(
        '/auth/refresh',
        status: 429,
        body: errorBody('IP_RATE_LIMIT_EXCEEDED'),
      );

      await expectLater(
        controller().refreshAccessToken(),
        throwsA(isA<DioException>()),
      );

      expect(backend.values[refreshKey], 'refresh-1');
    });

    test('an unreadable success body keeps credentials', () async {
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';
      adapter.on('/auth/refresh', body: {'data': null, 'message': 'ok'});

      await expectLater(
        controller().refreshAccessToken(),
        throwsA(isA<DioException>()),
      );

      expect(backend.values[refreshKey], 'refresh-1');
    });

    test('no stored refresh token ends the session', () async {
      container = makeContainer();
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      await expectLater(
        controller().refreshAccessToken(),
        throwsA(isA<SessionExpiredException>()),
      );

      expect(adapter.countFor('/auth/refresh'), 0, reason: 'nothing to submit');
      expect(container.read(authStateProvider), AuthStatus.signedOut);
    });
  });

  group('credential persistence failures', () {
    test(
      'a failed write does not report success and clears the partial pair',
      () async {
        // The backend rotates both tokens together, so a half-written pair is
        // indistinguishable from a real session once persisted — and unusable.
        container = makeContainer();
        container.read(refreshDioProvider).httpClientAdapter = adapter;

        backend.values[accessKey] = 'access-1';
        backend.values[refreshKey] = 'refresh-1';
        backend.failingWrites.add(accessKey);
        adapter.on('/auth/refresh', body: rotated());

        await expectLater(
          controller().refreshAccessToken(),
          throwsA(isA<ApiFailureCredentialStorage>()),
        );

        expect(backend.values, isEmpty);
        expect(container.read(authStateProvider), AuthStatus.signedOut);
      },
    );
  });

  group('credential failures the interceptor has to survive', () {
    // These run through `appDio`, so the real interceptor is in the loop rather
    // than a stubbed `TokenProvider`. What they pin is the other end of the
    // contract: a credential layer that fails in a way renewal does not model
    // must still reach the caller as a *completed* request. A failure the
    // interceptor does not catch leaves its handler uncompleted, and an
    // uncompleted handler is a request that never returns — so every assertion
    // here is also a liveness assertion.

    /// How long a request is given to complete before the test calls it hung.
    const budget = Duration(seconds: 5);

    /// Points both real clients at the scripted transport and scripts a
    /// protected route that answers `ACCESS_TOKEN_EXPIRED`.
    void expireProtectedRoute() {
      container.read(appDioProvider).httpClientAdapter = adapter;
      container.read(refreshDioProvider).httpClientAdapter = adapter;
      adapter.on(
        '/protected',
        status: 401,
        body: errorBody('ACCESS_TOKEN_EXPIRED'),
      );
    }

    test('a refresh token that cannot be read fails the request', () async {
      // Reading the refresh token is the first thing a renewal does, so the
      // store failing here means no request was ever attempted and no
      // `POST /auth/refresh` was made.
      container = makeContainer();
      expireProtectedRoute();
      backend.values[refreshKey] = 'refresh-1';
      backend.failingReads.add(refreshKey);

      await expectLater(
        container
            .read(appDioProvider)
            .get<dynamic>('/protected')
            .timeout(budget),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiFailureCredentialStorage>(),
          ),
        ),
      );

      expect(
        adapter.countFor('/auth/refresh'),
        0,
        reason: 'the failure happened before anything could be submitted',
      );
      expect(
        backend.values[refreshKey],
        'refresh-1',
        reason: 'a failure to read is not a reason to destroy anything',
      );
    });

    test(
      'a terminal refresh whose cleanup fails still completes the request',
      () async {
        // The backend has committed the revocation, so this really is the end of
        // the session — but the local clear reports that it did not happen.
        // `_endSession` clears before it discards, so a failed clear leaves the
        // client still describing a session. That is deliberate: it must not
        // claim the credentials are gone when storage says otherwise. What it
        // must never do is leave the request hanging.
        container = makeContainer(
          restored: const AuthTokens(
            accessToken: 'access-1',
            refreshToken: 'refresh-1',
          ),
        );
        expireProtectedRoute();
        backend.values[accessKey] = 'access-1';
        backend.values[refreshKey] = 'refresh-1';
        backend.failingDeletes.add(accessKey);
        adapter.on(
          '/auth/refresh',
          status: 401,
          body: errorBody('SESSION_REVOKED'),
        );

        await expectLater(
          container
              .read(appDioProvider)
              .get<dynamic>('/protected')
              .timeout(budget),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error',
              isA<ApiFailureCredentialStorage>(),
            ),
          ),
        );

        expect(
          container.read(authStateProvider),
          AuthStatus.signedIn,
          reason:
              'a clear that failed must not be reported as a completed sign-out',
        );
        expect(backend.values, {
          'stash_it.auth.access_token': 'access-1',
          refreshKey: 'refresh-1',
        }, reason: 'nothing was removed, because the clear never finished');
      },
    );

    test('a renewal that cannot persist its pair fails the request', () async {
      // The end-to-end shape of the write failure the interceptor has to
      // survive: the rotation succeeded on the server, the pair could not be
      // written, and there is therefore no token to replay with.
      container = makeContainer();
      expireProtectedRoute();
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';
      backend.failingWrites.add(accessKey);
      adapter.on('/auth/refresh', body: rotated());

      await expectLater(
        container
            .read(appDioProvider)
            .get<dynamic>('/protected')
            .timeout(budget),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<ApiFailureCredentialStorage>(),
          ),
        ),
      );

      expect(
        adapter.countFor('/protected'),
        1,
        reason: 'nothing is replayed without a token the client can use',
      );
    });
  });
}
