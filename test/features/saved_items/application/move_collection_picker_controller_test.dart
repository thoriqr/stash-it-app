import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/move_collection_picker_controller.dart';

import '../../../support/fake_collections_repository.dart';

/// The paginated browser behind `Browse all collections`: one page at a time,
/// cursor resumed, de-duplicated by id, and recoverable after a failed page.
void main() {
  CollectionSummary collection({
    required String id,
    required String name,
    String type = 'user',
    String? systemKey,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: type,
    isUnsorted: systemKey == 'unsorted',
    savedItemsCount: 0,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  CollectionPage page(
    List<CollectionSummary> items, {
    String? nextCursor,
    bool hasMore = false,
  }) => CollectionPage(items: items, nextCursor: nextCursor, hasMore: hasMore);

  ProviderContainer makeContainer(FakeCollectionsRepository repository) =>
      ProviderContainer(
        overrides: [
          collectionsRepositoryProvider.overrideWithValue(repository),
        ],
        retry: (_, _) => null,
      );

  test('starts at the first cursor page and appends the next one without '
      'duplicate rows', () async {
    final repository = FakeCollectionsRepository(
      results: [
        page(
          [
            collection(
              id: 'system-unsorted',
              name: 'Unsorted',
              type: 'system',
              systemKey: 'unsorted',
            ),
            collection(id: 'alpha', name: 'Alpha'),
          ],
          nextCursor: 'page-2',
          hasMore: true,
        ),
        page([
          collection(id: 'alpha', name: 'Alpha'),
          collection(id: 'beta', name: 'Beta'),
        ]),
      ],
    );
    final container = makeContainer(repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      moveCollectionPickerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final first = await container.read(moveCollectionPickerProvider.future);

    expect(first.items.map((item) => item.id), ['system-unsorted', 'alpha']);
    expect(first.hasMore, isTrue);
    expect(first.nextCursor, 'page-2');
    expect(repository.sorts, ['name']);
    expect(repository.limits, [20]);
    expect(repository.cursors, [null]);

    await container.read(moveCollectionPickerProvider.notifier).loadMore();

    final loaded = container.read(moveCollectionPickerProvider).requireValue;
    expect(loaded.items.map((item) => item.id), [
      'system-unsorted',
      'alpha',
      'beta',
    ], reason: 'the overlapping Alpha row appears once and server order stays');
    expect(loaded.hasMore, isFalse);
    expect(loaded.nextCursor, isNull);
    expect(loaded.isLoadingMore, isFalse);
    expect(loaded.loadMoreFailed, isFalse);
    expect(repository.sorts, ['name', 'name']);
    expect(repository.limits, [20, 20]);
    expect(repository.cursors, [null, 'page-2']);
  });

  test('a failed next page keeps the loaded rows and can be retried', () async {
    final repository = FakeCollectionsRepository(
      results: [
        page(
          [collection(id: 'alpha', name: 'Alpha')],
          nextCursor: 'page-2',
          hasMore: true,
        ),
        const ApiFailureServerFault(),
        page([collection(id: 'beta', name: 'Beta')]),
      ],
    );
    final container = makeContainer(repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      moveCollectionPickerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(moveCollectionPickerProvider.future);
    await container.read(moveCollectionPickerProvider.notifier).loadMore();

    final failed = container.read(moveCollectionPickerProvider).requireValue;
    expect(failed.items.map((item) => item.id), ['alpha']);
    expect(failed.hasMore, isTrue);
    expect(failed.isLoadingMore, isFalse);
    expect(failed.loadMoreFailed, isTrue);

    await container.read(moveCollectionPickerProvider.notifier).loadMore();

    final recovered = container.read(moveCollectionPickerProvider).requireValue;
    expect(recovered.items.map((item) => item.id), ['alpha', 'beta']);
    expect(recovered.hasMore, isFalse);
    expect(recovered.loadMoreFailed, isFalse);
    expect(repository.cursors, [null, 'page-2', 'page-2']);
  });

  test(
    'an initial error stays visible until the provider is retried',
    () async {
      final repository = FakeCollectionsRepository(
        results: [
          const ApiFailureServerFault(),
          page([collection(id: 'alpha', name: 'Alpha')]),
        ],
      );
      final container = makeContainer(repository);
      addTearDown(container.dispose);
      final subscription = container.listen(
        moveCollectionPickerProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(moveCollectionPickerProvider.future),
        throwsA(isA<ApiFailureServerFault>()),
      );
      expect(container.read(moveCollectionPickerProvider), isA<AsyncError>());

      container.invalidate(moveCollectionPickerProvider);
      final recovered = await container.read(
        moveCollectionPickerProvider.future,
      );

      expect(recovered.items.single.name, 'Alpha');
      expect(repository.listCalls, 2);
    },
  );

  test('an empty first page is a successful empty browser', () async {
    final repository = FakeCollectionsRepository(results: [page([])]);
    final container = makeContainer(repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      moveCollectionPickerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final state = await container.read(moveCollectionPickerProvider.future);

    expect(state.items, isEmpty);
    expect(state.hasMore, isFalse);
    expect(state.nextCursor, isNull);
    expect(repository.listCalls, 1);
  });

  test(
    'has_more with no cursor is unreadable, not a silently final page',
    () async {
      final repository = FakeCollectionsRepository(
        results: [
          page([collection(id: 'alpha', name: 'Alpha')], hasMore: true),
        ],
      );
      final container = makeContainer(repository);
      addTearDown(container.dispose);
      final subscription = container.listen(
        moveCollectionPickerProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(moveCollectionPickerProvider.future),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    },
  );
}
