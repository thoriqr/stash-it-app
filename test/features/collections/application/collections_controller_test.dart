import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/models/auth_tokens.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/application/collections_state.dart';

import '../../../support/fake_http.dart';
import '../data/collections_fixtures.dart';

void main() {
  late FakeHttpAdapter adapter;

  Future<ProviderContainer> makeContainer({AuthTokens? session}) async {
    final store = InMemorySecureStorage();
    if (session != null) {
      await SecureCredentialStore(store).write(session);
    }

    final made = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(SecureCredentialStore(store)),
        restoredTokensProvider.overrideWithValue(session),
      ],
      retry: (_, _) => null,
    );
    made.read(appDioProvider).httpClientAdapter = adapter;
    made.read(refreshDioProvider).httpClientAdapter = adapter;
    return made;
  }

  CollectionsState stateOf(ProviderContainer container) =>
      switch (container.read(collectionsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  setUp(() {
    adapter = FakeHttpAdapter();
  });

  void scriptPages(List<Map<String, dynamic>> pages) {
    adapter.onSequence('/collections', [
      for (final page in pages) FakeReply(200, page),
    ]);
  }

  group('first page', () {
    test('loads with default newest sort', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection(id: 'a', name: 'A')],
        ),
      ]);

      await container.read(collectionsProvider.future);

      final state = stateOf(container);
      expect(state.items.length, 1);
      expect(state.sort, 'newest');
      expect(adapter.requests.first.path, contains('/collections'));
      expect(
        Uri.parse(adapter.requests.first.path).queryParameters['sort'],
        'newest',
      );
    });

    test('empty page', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([CollectionsFixtures.emptyPage()]);

      await container.read(collectionsProvider.future);

      expect(stateOf(container).items, isEmpty);
      expect(stateOf(container).hasMore, isFalse);
    });
  });

  group('sorting', () {
    test('selecting oldest sends correct sort and no cursor', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection()],
        ),
        CollectionsFixtures.page(
          collections: [
            CollectionsFixtures.collection(id: 'old1', name: 'Old'),
          ],
        ),
      ]);

      await container.read(collectionsProvider.future);
      await container.read(collectionsProvider.notifier).setSort('oldest');
      await container.read(collectionsProvider.future);

      expect(stateOf(container).sort, 'oldest');
      expect(adapter.countFor('/collections'), 2);
      final secondPath = adapter.requests[1].path;
      final q = Uri.parse(secondPath).queryParameters;
      expect(q['sort'], 'oldest');
      expect(q.containsKey('cursor'), false);
    });

    test('selecting name sends correct sort', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection()],
        ),
        CollectionsFixtures.page(
          collections: [
            CollectionsFixtures.collection(id: 'n1', name: 'Alpha'),
          ],
        ),
      ]);

      await container.read(collectionsProvider.future);
      await container.read(collectionsProvider.notifier).setSort('name');
      await container.read(collectionsProvider.future);

      expect(stateOf(container).sort, 'name');
      final q = Uri.parse(adapter.requests[1].path).queryParameters;
      expect(q['sort'], 'name');
    });

    test('changing sort while in flight ignores stale response', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.onSequenceHolding('/collections', [
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [CollectionsFixtures.collection(id: 'a')],
          ),
        ),
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [CollectionsFixtures.collection(id: 'stale')],
          ),
        ),
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [CollectionsFixtures.collection(id: 'latest')],
          ),
        ),
      ], holdAt: 2);

      await container.read(collectionsProvider.future);
      final n = container.read(collectionsProvider.notifier);
      final setOld = n.setSort('oldest');
      await untilCalled(() => adapter.countFor('/collections') == 2);
      final setName = n.setSort('name');
      adapter.releaseBlocked();
      await Future.wait([setOld, setName]);
      await container.read(collectionsProvider.future);

      expect(stateOf(container).items.map((e) => e.id), contains('latest'));
      expect(stateOf(container).sort, 'name');
    });
  });

  group('in-place removal', () {
    test('removes one collection without resetting sort or cursor', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        CollectionsFixtures.page(
          collections: [
            CollectionsFixtures.collection(id: 'a', name: 'A'),
            CollectionsFixtures.collection(id: 'b', name: 'B'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
        CollectionsFixtures.page(
          collections: [
            CollectionsFixtures.collection(id: 'a', name: 'A'),
            CollectionsFixtures.collection(id: 'b', name: 'B'),
          ],
          nextCursor: 'oldest-cursor',
          hasMore: true,
        ),
      ]);

      await container.read(collectionsProvider.future);
      await container.read(collectionsProvider.notifier).setSort('oldest');
      await container.read(collectionsProvider.future);
      final before = adapter.countFor('/collections');

      container.read(collectionsProvider.notifier).removeCollection('a');

      final state = stateOf(container);
      expect(state.items.map((c) => c.id), ['b']);
      expect(state.sort, 'oldest');
      expect(state.nextCursor, 'oldest-cursor');
      expect(state.hasMore, isTrue);
      expect(
        adapter.countFor('/collections'),
        before,
        reason: 'removal must not refetch and lose the chosen sort',
      );
    });
  });

  group('pagination', () {
    test('load more uses active sort and correct cursor', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection(id: 'a')],
          nextCursor: 'c1',
          hasMore: true,
        ),
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection(id: 'b')],
        ),
      ]);

      await container.read(collectionsProvider.future);
      await container.read(collectionsProvider.notifier).loadMore();

      final q2 = Uri.parse(adapter.requests[1].path).queryParameters;
      expect(q2['cursor'], 'c1');
      expect(q2['sort'], 'newest');
      expect(stateOf(container).items.length, 2);
    });

    test('load more stops at end', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      scriptPages([
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection(id: 'a')],
          nextCursor: 'c1',
          hasMore: true,
        ),
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection(id: 'b')],
          hasMore: false,
        ),
      ]);

      await container.read(collectionsProvider.future);
      await container.read(collectionsProvider.notifier).loadMore();

      expect(stateOf(container).hasMore, isFalse);
    });
  });

  group('errors', () {
    test('maps server error on load', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.on(
        '/collections',
        status: 500,
        body: {
          'error': {'code': 'INTERNAL_SERVER_ERROR'},
        },
      );

      await expectLater(
        container.read(collectionsProvider.future),
        throwsA(isA<Object>()),
      );
      expect(container.read(collectionsProvider), isA<AsyncError>());
    });

    test('retry refetches', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);

      adapter.on(
        '/collections',
        status: 500,
        body: {
          'error': {'code': 'INTERNAL_SERVER_ERROR'},
        },
      );

      await expectLater(
        container.read(collectionsProvider.future),
        throwsA(isA<Object>()),
      );

      scriptPages([
        CollectionsFixtures.page(
          collections: [CollectionsFixtures.collection()],
        ),
      ]);
      await container.read(collectionsProvider.notifier).retry();
      await container.read(collectionsProvider.future);

      expect(stateOf(container).items.length, 1);
    });
  });
}
