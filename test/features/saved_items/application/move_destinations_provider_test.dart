import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/data/collections_repository.dart';
import 'package:stash_it_app/features/collections/data/datasources/collections_api.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/saved_items/application/move_destinations_provider.dart';

import '../../collections/data/collections_fixtures.dart';
import '../../../support/fake_http.dart';

/// The bounded main-sheet preview: `sort=name`, one page with the six-item
/// fetch limit, no eager pagination, and a hard stop when a page claims more
/// but supplies no cursor.
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
  ProviderSubscription<AsyncValue<CollectionPage>> listen() {
    return container.listen(moveDestinationsProvider, (_, _) {});
  }

  test(
    'reads one bespoke preview page with sort=name and never follows it',
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
              CollectionsFixtures.collection(id: 'c3', name: 'Gamma'),
              CollectionsFixtures.collection(id: 'c4', name: 'Delta'),
              CollectionsFixtures.collection(id: 'c5', name: 'Epsilon'),
            ],
            nextCursor: 'next-page',
            hasMore: true,
          ),
        ),
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [
              CollectionsFixtures.collection(id: 'c6', name: 'Zeta'),
            ],
          ),
        ),
      ]);

      final subscription = listen();
      addTearDown(subscription.close);

      final preview = await container.read(moveDestinationsProvider.future);

      expect(preview.items.map((collection) => collection.id), [
        'system-1',
        'c1',
        'c2',
        'c3',
        'c4',
        'c5',
      ]);
      expect(
        preview.items.map((collection) => collection.name),
        ['Unsorted', 'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon'],
        reason: 'the provider never sorts again; this is the server page order',
      );
      expect(
        preview.items.first.type,
        'system',
        reason: 'system collections are displayed, never filtered out',
      );
      expect(preview.hasMore, isTrue);
      expect(preview.nextCursor, 'next-page');
      expect(adapter.countFor('/collections'), 1);
      final query = Uri.parse(adapter.requests.single.path).queryParameters;
      expect(query['sort'], 'name');
      expect(query['limit'], '$moveDestinationsFetchLimit');
      expect(query['cursor'], isNull);
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
    final preview = await container.read(moveDestinationsProvider.future);

    expect(preview.items.single.name, 'Alpha');
    expect(adapter.countFor('/collections'), 2);
  });

  test(
    'opening the preview does not mutate the Collections screen state',
    () async {
      adapter.onSequence('/collections', [
        FakeReply(
          200,
          CollectionsFixtures.page(
            collections: [
              CollectionsFixtures.collection(id: 'screen', name: 'Screen'),
            ],
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
      final preview = await container.read(moveDestinationsProvider.future);

      expect(preview.items.single.name, 'Picker');
      expect(
        container.read(collectionsProvider).requireValue,
        screen,
        reason: 'the preview never advances or collapses the screen provider',
      );
      expect(
        adapter.requests.map(
          (request) => Uri.parse(request.path).queryParameters['sort'],
        ),
        ['newest', 'name'],
      );
      expect(adapter.countFor('/collections'), 2);
    },
  );
}
