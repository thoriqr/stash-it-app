import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/session/session_boundary.dart';
import 'package:stash_it_app/core/network/token_provider.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';

import '../../../support/fake_http.dart';
import '../../../support/pending_urls.dart';

void main() {
  const url = 'https://example.com/articles/crdts-explained';

  group('the local list', () {
    test('exposes the entries, the count, and newest-first order', () async {
      var now = DateTime.utc(2026, 10, 28, 12);
      final store = await testPendingUrlStore(now: () => now);
      await store.upsert(url: 'https://example.com/older', uncertain: false);
      now = now.add(const Duration(minutes: 1));
      await store.upsert(url: url, uncertain: true);

      final container = ProviderContainer(
        overrides: [pendingUrlStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      final snapshot = await container.read(pendingUrlsProvider.future);

      expect(snapshot.entries.map((entry) => entry.url), [
        url,
        'https://example.com/older',
      ]);
      expect(container.read(pendingUrlCountProvider), 2);
      expect(snapshot.entries.first.uncertain, isTrue);
    });

    test('works without any authentication provider', () async {
      final store = await testPendingUrlStore();
      await store.upsert(url: url, uncertain: false);

      final container = ProviderContainer(
        overrides: [pendingUrlStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      final snapshot = await container.read(pendingUrlsProvider.future);

      expect(snapshot.entries.single.url, url);
      expect(container.read(pendingUrlCountProvider), 1);
    });

    test('announces a prune that happened during a write', () async {
      final created = DateTime.utc(2026, 10, 1, 12);
      var now = created;
      final store = await testPendingUrlStore(now: () => now);
      await store.upsert(url: 'https://example.com/old', uncertain: false);

      now = created.add(const Duration(days: 8));
      await store.upsert(url: 'https://example.com/new', uncertain: false);

      final container = ProviderContainer(
        overrides: [pendingUrlStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      final snapshot = await container.read(pendingUrlsProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(snapshot.entries.single.url, 'https://example.com/new');
      expect(
        container.read(feedbackProvider)?.copy,
        'Some links saved on this device expired after seven days.',
      );
    });

    test('prunes expired entries and announces them once', () async {
      final created = DateTime.utc(2026, 10, 1, 12);
      var now = created;
      final store = await testPendingUrlStore(now: () => now);
      await store.upsert(url: url, uncertain: false);

      now = created.add(const Duration(days: 8));
      final container = ProviderContainer(
        overrides: [pendingUrlStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      final snapshot = await container.read(pendingUrlsProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(snapshot.entries, isEmpty);
      expect(snapshot.expiredCount, 1);
      expect(
        container.read(feedbackProvider)?.copy,
        'Some links saved on this device expired after seven days.',
      );

      container.read(feedbackProvider.notifier).dismiss();
      container.invalidate(pendingUrlsProvider);
      await container.read(pendingUrlsProvider.future);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(feedbackProvider),
        isNull,
        reason: 'the pruned entries are gone, so the notice is not repeated',
      );
    });
  });

  group('authentication independence', () {
    const session = AuthTokens(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
    );

    Future<
      ({
        ProviderContainer container,
        PendingUrlStore store,
        FakeHttpAdapter adapter,
        InMemorySecureStorage backend,
      })
    >
    harness() async {
      final adapter = FakeHttpAdapter();
      final backend = InMemorySecureStorage();
      final credentials = SecureCredentialStore(backend);
      await credentials.write(session);
      final store = await testPendingUrlStore();
      await store.upsert(url: url, uncertain: false);

      final container = ProviderContainer(
        overrides: [
          credentialStoreProvider.overrideWithValue(credentials),
          restoredTokensProvider.overrideWithValue(session),
          pendingUrlStoreProvider.overrideWithValue(store),
        ],
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      container.read(appDioProvider).httpClientAdapter = adapter;
      container.read(refreshDioProvider).httpClientAdapter = adapter;

      // Keep the app-level boundary alive, so this test exercises the same
      // listener that runs at the app root.
      container.read(sessionBoundaryProvider);
      await container.read(pendingUrlsProvider.future);

      return (
        container: container,
        store: store,
        adapter: adapter,
        backend: backend,
      );
    }

    test('entries survive sign-out', () async {
      final h = await harness();
      h.adapter.onMethod(
        'POST',
        '/auth/logout',
        body: {'data': null, 'message': 'bye'},
      );

      await h.container.read(authStateProvider.notifier).signOut();
      await Future<void>.delayed(Duration.zero);

      expect(h.container.read(authStateProvider), AuthStatus.signedOut);
      expect(h.backend.values, isEmpty);
      expect(h.container.read(pendingUrlCountProvider), 1);
      expect((await h.store.readAll()).entries.single.url, url);
    });

    test('entries survive a terminal session expiry', () async {
      final h = await harness();
      h.adapter.onMethod(
        'POST',
        '/auth/refresh',
        status: 401,
        body: errorBody('SESSION_REVOKED'),
      );

      await expectLater(
        h.container
            .read(sessionControllerProvider.notifier)
            .refreshAccessToken(),
        throwsA(isA<SessionExpiredException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(h.container.read(authStateProvider), AuthStatus.signedOut);
      expect(h.backend.values, isEmpty);
      expect(h.container.read(pendingUrlCountProvider), 1);
      expect((await h.store.readAll()).entries.single.url, url);
    });

    test('entries survive signing in with another account', () async {
      final h = await harness();
      h.adapter.onMethod(
        'POST',
        '/auth/logout',
        body: {'data': null, 'message': 'bye'},
      );
      h.adapter.onMethod(
        'POST',
        '/auth/login',
        body: {
          'data': {
            'access_token': 'access-b',
            'refresh_token': 'refresh-b',
            'user': {
              'id': 'user-b',
              'email': 'b@example.com',
              'display_name': 'User B',
            },
          },
          'message': 'login successful',
        },
      );

      await h.container.read(authStateProvider.notifier).signOut();
      await h.container
          .read(authStateProvider.notifier)
          .signIn('b@example.com', 'password123');
      await Future<void>.delayed(Duration.zero);

      expect(h.container.read(authStateProvider), AuthStatus.signedIn);
      expect(h.container.read(pendingUrlCountProvider), 1);
      expect((await h.store.readAll()).entries.single.url, url);
    });
  });
}
