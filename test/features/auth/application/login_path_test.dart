import 'package:dio/dio.dart' show Dio;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';

import '../../../support/fake_http.dart';

/// The regression test for the dependency cycle that made manual sign-in fail.
///
/// ## What failed
///
/// Sign-in surfaced as `ApiFailureTransport` with
/// `cause=CircularDependencyError`, chain `sessionControllerProvider`. The
/// client built this graph:
///
/// ```text
/// appDio -> sessionController -> authRepository -> authApi -> appDio
/// ```
///
/// The `AuthInterceptor` obtained its `TokenProvider` from a closure that called
/// `ref.read(sessionControllerProvider.notifier)` at request time, which looked
/// like it broke the edge. It did not. Riverpod's
/// `_debugAssertCanDependOn` walks the reading provider's transitive
/// *dependents* and throws if the target is among them — a static property of
/// the graph, re-evaluated on **every** read. The closure therefore only moved
/// the throw from construction to the first request, where it arrived as a
/// `DioException` with no response and was classified as a transport failure.
///
/// ## What these tests pin
///
/// Only the two providers `bootstrap` overrides are stubbed here. Anything more
/// — in particular an `authRepositoryProvider` override — removes the very edges
/// that closed the loop, which is exactly what made the previous version of
/// `session_controller_test.dart` pass while the app could not sign in.
void main() {
  const accessKey = 'stash_it.auth.access_token';
  const refreshKey = 'stash_it.auth.refresh_token';

  late InMemorySecureStorage backend;
  late FakeHttpAdapter adapter;
  late ProviderContainer container;

  ProviderContainer makeContainer({AuthTokens? restored}) {
    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(backend),
        ),
        restoredTokensProvider.overrideWithValue(restored),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Points both real clients at a scripted transport. No socket is opened.
  void useFakeTransport() {
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;
  }

  void scriptSuccessfulLogin() {
    adapter.on(
      '/auth/login',
      body: {
        'data': {
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
          'user': {'id': 'u1', 'email': 'a@b.c', 'display_name': 'Test'},
        },
        'message': 'login successful',
      },
    );
  }

  setUp(() {
    backend = InMemorySecureStorage();
    adapter = FakeHttpAdapter();
  });

  group('provider resolution', () {
    test('appDio resolves with the real session controller in the graph', () {
      container = makeContainer();

      expect(
        container.read(appDioProvider),
        isA<Dio>(),
        reason: 'the API client must build with the shipping provider graph',
      );
    });

    test('sessionController resolves without building appDio', () {
      // The load-bearing property: the session controller reaches the network
      // only through `refreshDio`, so resolving it cannot drag the API client
      // (and therefore itself) back into the graph.
      container = makeContainer();

      expect(container.read(sessionControllerProvider), isNull);
      expect(container.read(appDioProvider), isNotNull);
    });

    test('refreshDio carries no auth interceptor', () {
      // Keeps renewal structurally unable to recurse.
      container = makeContainer();

      final types = container
          .read(refreshDioProvider)
          .interceptors
          .map((i) => i.runtimeType.toString())
          .toList();

      expect(types.any((t) => t.contains('AuthInterceptor')), isFalse);
    });

    test('appDio does carry the auth interceptor', () {
      container = makeContainer();

      final types = container
          .read(appDioProvider)
          .interceptors
          .map((i) => i.runtimeType.toString())
          .toList();

      expect(types.any((t) => t.contains('AuthInterceptor')), isTrue);
    });
  });

  group('manual sign-in', () {
    test('completes without a CircularDependencyError', () async {
      container = makeContainer();
      useFakeTransport();
      scriptSuccessfulLogin();

      await container
          .read(authStateProvider.notifier)
          .signIn('user@example.com', 'password123');

      expect(container.read(authStateProvider), AuthStatus.signedIn);
    });

    test('resolves the session controller from inside the interceptor', () async {
      // The precise line that used to throw. `onRequest` calls
      // `tokenProvider.readAccessToken()`, and the token provider is the session
      // controller, so this assertion fails if that resolution is cyclic again.
      container = makeContainer();
      useFakeTransport();
      scriptSuccessfulLogin();

      await container
          .read(authStateProvider.notifier)
          .signIn('user@example.com', 'password123');

      final request = adapter.lastRequestTo('/auth/login');
      expect(request, isNotNull);
      expect(
        request!.extra.containsKey('auth_retried'),
        isFalse,
        reason: 'the request went out unauthenticated and was never replayed',
      );
    });

    test('persists both credentials and adopts the session', () async {
      container = makeContainer();
      useFakeTransport();
      scriptSuccessfulLogin();

      await container
          .read(authStateProvider.notifier)
          .signIn('user@example.com', 'password123');

      expect(backend.values[accessKey], 'access-1');
      expect(backend.values[refreshKey], 'refresh-1');
      expect(
        container.read(sessionControllerProvider),
        const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
      );
    });

    test('a refused sign-in stays signed out and stores nothing', () async {
      container = makeContainer();
      useFakeTransport();
      adapter.on(
        '/auth/login',
        status: 401,
        body: errorBody('INVALID_CREDENTIALS'),
      );

      await expectLater(
        container
            .read(authStateProvider.notifier)
            .signIn('user@example.com', 'wrongpassword'),
        throwsA(isA<Object>()),
      );

      expect(container.read(authStateProvider), AuthStatus.signedOut);
      expect(backend.values, isEmpty);
    });
  });

  group('sign-out', () {
    test('revokes server-side and clears locally', () async {
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';

      container = makeContainer(
        restored: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      useFakeTransport();
      adapter.on(
        '/auth/logout',
        body: {'data': null, 'message': 'logout successful'},
      );

      await container.read(authStateProvider.notifier).signOut();

      expect(adapter.countFor('/auth/logout'), 1);
      expect(backend.values, isEmpty);
      expect(container.read(authStateProvider), AuthStatus.signedOut);
    });

    test(
      'an expired access token is renewed, then the revocation is replayed',
      () async {
        // Handled by the auth interceptor, not by sign-out code: it sees
        // ACCESS_TOKEN_EXPIRED, renews on refreshDio, and replays logout once.
        // Without this the server session would survive until it lapses — up to
        // 90 days.
        backend.values[accessKey] = 'access-1';
        backend.values[refreshKey] = 'refresh-1';

        container = makeContainer(
          restored: const AuthTokens(
            accessToken: 'access-1',
            refreshToken: 'refresh-1',
          ),
        );
        useFakeTransport();

        adapter.onExpiring(
          '/auth/logout',
          FakeReply.error(401, 'ACCESS_TOKEN_EXPIRED'),
          const FakeReply(200, {'data': null, 'message': 'logout successful'}),
          retriedMarker: 'auth_retried',
        );
        adapter.on(
          '/auth/refresh',
          body: {
            'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
            'message': 'token refreshed successfully',
          },
        );

        await container.read(authStateProvider.notifier).signOut();

        expect(adapter.countFor('/auth/refresh'), 1, reason: 'renewed first');
        expect(
          adapter.countFor('/auth/logout'),
          2,
          reason: 'revocation replayed',
        );
        expect(backend.values, isEmpty);
        expect(container.read(authStateProvider), AuthStatus.signedOut);
      },
    );

    test('a failed revocation still clears local credentials', () async {
      // The user's intent is satisfied locally regardless, and leaving the app
      // apparently signed in would be the worse outcome.
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';

      container = makeContainer(
        restored: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      useFakeTransport();
      adapter.on(
        '/auth/logout',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      adapter.on(
        '/auth/refresh',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await container.read(authStateProvider.notifier).signOut();

      expect(backend.values, isEmpty);
      expect(container.read(authStateProvider), AuthStatus.signedOut);
    });

    test('an unrenewable session still clears local credentials', () async {
      backend.values[accessKey] = 'access-1';
      backend.values[refreshKey] = 'refresh-1';

      container = makeContainer(
        restored: const AuthTokens(
          accessToken: 'access-1',
          refreshToken: 'refresh-1',
        ),
      );
      useFakeTransport();

      adapter.onExpiring(
        '/auth/logout',
        FakeReply.error(401, 'ACCESS_TOKEN_EXPIRED'),
        const FakeReply(200, {'data': null, 'message': 'ok'}),
        retriedMarker: 'auth_retried',
      );
      adapter.on(
        '/auth/refresh',
        status: 401,
        body: errorBody('SESSION_REVOKED'),
      );

      await container.read(authStateProvider.notifier).signOut();

      expect(backend.values, isEmpty);
      expect(container.read(authStateProvider), AuthStatus.signedOut);
    });
  });
}
