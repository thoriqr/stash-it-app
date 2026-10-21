import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/data/collections_repository.dart';
import 'package:stash_it_app/features/collections/data/datasources/collections_api.dart';
import 'package:stash_it_app/features/saved_items/application/move_destinations_provider.dart';

import '../../collections/data/collections_fixtures.dart';
import '../../../support/fake_http.dart';

/// The picker snapshot: `sort=name`, every page, de-duplication, system
/// collections included, and a hard stop when a page claims more but supplies no
/// cursor.
void main() {
  late FakeHttpAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    container = ProviderContainer(
      overrides: [
        collectionsRepositoryProvider.overrideWithValue(
          CollectionsRepository(api: CollectionsApi(dio)),
        ),
      ],
      retry: (_, _) => null,
    );
  });

  tearDown(() => container.dispose());

  /// A subscription keeps the auto-dispose provider alive across the awaits.
  ProviderSubscription<AsyncValue<List<dynamic>>> listen() {
    return container.listen(moveDestinationsProvider, (_, _) {});
  }

  test(
    'reads sort=name, follows every page, and preserves server order',
    () async {
      adapter.onSequence('/collections', [
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [
              CollectionsFixtures.collection(
                id: 'system-1',
                name: 'Unsorted',
                type: 'system',
                systemKey: 'unsorted',
              ),
              CollectionsFixtures.collection(id: 'c1', name: 'Alpha'),
              CollectionsFixtures.collection(id: 'c2', name: 'Beta'),
            ],
            nextCursor: 'next-page',
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [
              CollectionsFixtures.collection(id: 'c2', name: 'Beta'),
              CollectionsFixtures.collection(id: 'c3', name: 'Gamma'),
              CollectionsFixtures.collection(
                id: 'system-2',
                name: 'Saved',
                type: 'system',
                systemKey: 'saved',
              ),
            ],
          ),
        ),
      ]);

      final subscription = listen();
      addTearDown(subscription.close);

      final destinations = await container.read(
        moveDestinationsProvider.future,
      );

      expect(destinations.map((collection) => collection.id), [
        'system-1',
        'c1',
        'c2',
        'c3',
        'system-2',
      ]);
      expect(
        destinations.map((collection) => collection.name),
        ['Unsorted', 'Alpha', 'Beta', 'Gamma', 'Saved'],
        reason: 'the provider never sorts again; this is the server page order',
      );
      expect(
        destinations
            .where((collection) => collection.type == 'system')
            .map((collection) => collection.name),
        ['Unsorted', 'Saved'],
        reason: 'system collections are displayed, never filtered out',
      );
      expect(
        destinations.every((collection) => collection.type == 'user'),
        isFalse,
      );
      expect(adapter.countFor('/collections'), 2);
      expect(
        adapter.requests.map(
          (request) => Uri.parse(request.path).queryParameters['sort'],
        ),
        ['name', 'name'],
      );
      expect(
        adapter.requests.map(
          (request) => Uri.parse(request.path).queryParameters['cursor'],
        ),
        [null, 'next-page'],
      );
    },
  );

  test('has_more with no cursor is unreadable, not a complete list', () async {
    adapter.on(
      '/collections',
      body: CollectionsFixtures.page(
        collections: [CollectionsFixtures.collection()],
        hasMore: true,
      ),
    );

    final subscription = listen();
    addTearDown(subscription.close);

    await expectLater(
      container.read(moveDestinationsProvider.future),
      throwsA(isA<ApiFailureUnreadableResponse>()),
    );
    expect(adapter.countFor('/collections'), 1);
  });

  test('an error is visible and a manual invalidate can recover', () async {
    adapter.onSequence('/collections', [
      FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
      FakeReply(
        200,
        CollectionsFixtures.page(
          collections: [
            CollectionsFixtures.collection(id: 'c1', name: 'Alpha'),
          ],
        ),
      ),
    ]);

    final subscription = listen();
    addTearDown(subscription.close);

    await expectLater(
      container.read(moveDestinationsProvider.future),
      throwsA(isA<ApiFailureServerFault>()),
    );
    expect(container.read(moveDestinationsProvider), isA<AsyncError>());

    container.invalidate(moveDestinationsProvider);
    final destinations = await container.read(moveDestinationsProvider.future);

    expect(destinations.single.name, 'Alpha');
    expect(adapter.countFor('/collections'), 2);
  });

  test(
    'opening the picker does not mutate the Collections screen state',
    () async {
      adapter.onSequence('/collections', [
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [
              CollectionsFixtures.collection(id: 'screen', name: 'Screen'),
            ],
            nextCursor: 'screen-next',
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [
              CollectionsFixtures.collection(id: 'picker', name: 'Picker'),
            ],
          ),
        ),
      ]);

      final screen = await container.read(collectionsProvider.future);
      final subscription = listen();
      addTearDown(subscription.close);
      final destinations = await container.read(
        moveDestinationsProvider.future,
      );

      expect(destinations.single.name, 'Picker');
      expect(
        container.read(collectionsProvider).requireValue,
        screen,
        reason: 'the picker never advances or collapses the screen provider',
      );
      expect(
        adapter.requests.map(
          (request) => Uri.parse(request.path).queryParameters['sort'],
        ),
        ['newest', 'name'],
      );
    },
  );
}
