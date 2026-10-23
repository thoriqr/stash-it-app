import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/application/collections_state.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/application/delete_saved_item_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_delete_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_http.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The destructive flow's controller: one request per action, the item delete's
/// ambiguous outcomes, and in-place cache reconciliation.
void main() {
  const itemId = 'item-1';
  const collectionId = 'collection-1';
  const collectionName = 'Camera Gear';

  SavedItemSummary summary({
    String id = itemId,
    String collection = collectionId,
    String name = collectionName,
  }) => SavedItemSummary(
    id: id,
    collectionId: collection,
    url: 'https://example.com/articles/crdts-explained',
    collectionName: name,
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Understanding CRDTs',
  );

  CollectionSummary collection({
    String id = collectionId,
    String name = collectionName,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: 'user',
    isUnsorted: false,
    savedItemsCount: 1,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  SavedItemDeleted eligible({
    String responseCollectionId = collectionId,
    bool empty = true,
    bool deletable = true,
  }) => SavedItemDeleted(
    collectionId: responseCollectionId,
    collectionEmpty: empty,
    collectionDeletable: deletable,
  );

  _Harness makeHarness({
    List<SavedItemSummary> inboxItems = const [],
    List<CollectionSummary> collections = const [],
    List<Object> deleteResults = const [],
    List<Object?> collectionDeleteResults = const [],
    List<Object> collectionContentsResults = const [],
    Future<SavedItemDeleteResult> Function(String id)? onDelete,
    Future<void> Function(String id)? onCollectionDelete,
  }) {
    final saved = FakeSavedItemsRepository(
      listPage: SavedItemPage(
        items: inboxItems,
        nextCursor: null,
        hasMore: false,
      ),
      detailResults: [inboxItems.isEmpty ? summary() : inboxItems.first],
      deleteResults: deleteResults,
      onDelete: onDelete,
      collectionResults: collectionContentsResults,
    );
    final collectionsRepository = FakeCollectionsRepository(
      results: [
        CollectionPage(items: collections, nextCursor: null, hasMore: false),
      ],
      deleteResults: collectionDeleteResults,
      onDelete: onCollectionDelete,
    );

    final container = ProviderContainer(
      overrides: [
        savedItemsRepositoryProvider.overrideWithValue(saved),
        collectionsRepositoryProvider.overrideWithValue(collectionsRepository),
      ],
      retry: (_, _) => null,
    );

    return _Harness(
      container: container,
      saved: saved,
      collections: collectionsRepository,
    );
  }

  SavedItemsState inboxOf(ProviderContainer container) =>
      switch (container.read(savedItemsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  CollectionsState collectionsOf(ProviderContainer container) =>
      switch (container.read(collectionsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  CollectionSavedItemsState contentsOf(
    ProviderContainer container,
    String collectionId,
  ) => switch (container.read(collectionSavedItemsProvider(collectionId))) {
    AsyncData(:final value) => value,
    final other => throw StateError('expected data, got $other'),
  };

  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  group('a confirmed item delete', () {
    test(
      'removes the row from both loaded listings and defers success feedback',
      () async {
        final item = summary();
        final other = summary(id: 'item-2');
        final contents = collectionSavedItemsProvider(collectionId);
        final harness = makeHarness(
          inboxItems: [item, other],
          deleteResults: [eligible()],
          collectionContentsResults: [
            CollectionSavedItemsPage(
              collectionId: collectionId,
              collectionName: collectionName,
              items: [item],
              nextCursor: null,
              hasMore: false,
            ),
          ],
        );
        addTearDown(harness.container.dispose);

        harness.container.listen(savedItemsProvider, (_, _) {});
        harness.container.listen(contents, (_, _) {});
        await harness.container.read(savedItemsProvider.future);
        await harness.container.read(contents.future);

        final notifier = harness.container.read(
          deleteSavedItemProvider.notifier,
        );
        final outcome = await notifier.deleteItem(item);

        expect(outcome, isA<DeleteSavedItemCollectionOffered>());
        expect(harness.saved.deleteIds, [itemId]);
        expect(inboxOf(harness.container).items.map((i) => i.id), ['item-2']);
        expect(contentsOf(harness.container, collectionId).items, isEmpty);
        expect(
          noticeOf(harness.container),
          isNull,
          reason: 'the success banner must not cover the second dialog',
        );

        notifier.keepCollection();

        expect(noticeOf(harness.container)?.tone, FeedbackTone.success);
        expect(noticeOf(harness.container)?.copy, 'Item deleted.');
        expect(
          harness.collections.deleteCalls,
          0,
          reason: 'keeping the collection sends no request',
        );
      },
    );

    test(
      'a response that fails eligibility reports only the item delete',
      () async {
        final item = summary();
        final harness = makeHarness(
          inboxItems: [item],
          deleteResults: [eligible(responseCollectionId: 'collection-other')],
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);

        final outcome = await harness.container
            .read(deleteSavedItemProvider.notifier)
            .deleteItem(item);

        expect(outcome, isA<DeleteSavedItemSucceeded>());
        expect(inboxOf(harness.container).items, isEmpty);
        expect(noticeOf(harness.container)?.copy, 'Item deleted.');
      },
    );

    test(
      'a 200 with unreadable flags still reports the item deleted',
      () async {
        final item = summary();
        final harness = makeHarness(
          inboxItems: [item],
          deleteResults: [const SavedItemDeletionFlagsUnavailable()],
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);

        final outcome = await harness.container
            .read(deleteSavedItemProvider.notifier)
            .deleteItem(item);

        expect(outcome, isA<DeleteSavedItemSucceeded>());
        expect(noticeOf(harness.container)?.copy, 'Item deleted.');
        expect(harness.collections.deleteCalls, 0);
      },
    );

    test(
      'a 500 is uncertain: the row stays and no collection is offered',
      () async {
        final item = summary();
        final harness = makeHarness(
          inboxItems: [item],
          deleteResults: [const ApiFailureServerFault()],
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);

        final outcome = await harness.container
            .read(deleteSavedItemProvider.notifier)
            .deleteItem(item);

        expect(outcome, isA<DeleteSavedItemUnconfirmed>());
        expect(inboxOf(harness.container).items.map((i) => i.id), [
          itemId,
        ], reason: 'an ambiguous write must not remove the row');
        expect(noticeOf(harness.container)?.tone, FeedbackTone.uncertain);
        expect(noticeOf(harness.container)?.copy, contains("couldn't confirm"));
        expect(harness.collections.deleteCalls, 0);
      },
    );

    test(
      'a 404 removes the row but never claims this request deleted it',
      () async {
        final item = summary();
        final harness = makeHarness(
          inboxItems: [item],
          deleteResults: [const ApiFailureNotFound(code: 'RESOURCE_NOT_FOUND')],
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);

        final outcome = await harness.container
            .read(deleteSavedItemProvider.notifier)
            .deleteItem(item);

        expect(outcome, isA<DeleteSavedItemNotFound>());
        expect(inboxOf(harness.container).items, isEmpty);
        expect(
          noticeOf(harness.container)?.copy,
          'This item is no longer available.',
        );
        expect(noticeOf(harness.container)?.copy, isNot('Item deleted.'));
      },
    );

    test('a second action while the first is in flight is ignored', () async {
      final item = summary();
      final completer = Completer<SavedItemDeleteResult>();
      final harness = makeHarness(
        inboxItems: [item],
        onDelete: (_) => completer.future,
      );
      addTearDown(harness.container.dispose);
      harness.container.listen(savedItemsProvider, (_, _) {});
      await harness.container.read(savedItemsProvider.future);

      final notifier = harness.container.read(deleteSavedItemProvider.notifier);
      final first = notifier.deleteItem(item);

      expect(harness.container.read(deleteSavedItemProvider), isTrue);
      final second = await notifier.deleteItem(item);
      expect(second, isA<DeleteSavedItemIgnored>());
      expect(harness.saved.deleteCalls, 1);

      completer.complete(eligible());
      expect(await first, isA<DeleteSavedItemCollectionOffered>());
      expect(harness.container.read(deleteSavedItemProvider), isFalse);
      expect(harness.saved.deleteCalls, 1);
    });
  });

  group('the optional collection delete', () {
    test('success removes the collection and reports both deletions', () async {
      final item = summary();
      final kept = collection(id: 'collection-2', name: 'Wishlist');
      final contents = collectionSavedItemsProvider(collectionId);
      final harness = makeHarness(
        inboxItems: [item],
        collections: [collection(), kept],
        deleteResults: [eligible()],
        collectionDeleteResults: [null],
        collectionContentsResults: [
          CollectionSavedItemsPage(
            collectionId: collectionId,
            collectionName: collectionName,
            items: [item],
            nextCursor: null,
            hasMore: false,
          ),
          const ApiFailureNotFound(code: 'COLLECTION_NOT_FOUND'),
        ],
      );
      addTearDown(harness.container.dispose);

      harness.container.listen(savedItemsProvider, (_, _) {});
      harness.container.listen(collectionsProvider, (_, _) {});
      harness.container.listen(contents, (_, _) {});
      await harness.container.read(savedItemsProvider.future);
      await harness.container.read(collectionsProvider.future);
      await harness.container.read(contents.future);

      final notifier = harness.container.read(deleteSavedItemProvider.notifier);
      await notifier.deleteItem(item);
      final outcome = await notifier.deleteCollection(
        collectionId: collectionId,
        collectionName: collectionName,
      );

      expect(outcome, isA<DeleteCollectionSucceeded>());
      expect(harness.collections.deleteIds, [collectionId]);
      expect(collectionsOf(harness.container).items.map((c) => c.id), [
        'collection-2',
      ]);
      expect(
        noticeOf(harness.container)?.copy,
        'Item deleted, and Camera Gear was deleted.',
      );

      // The mounted collection listing is invalidated so its existing not-found
      // state can take over; the item delete is not repeated.
      await untilCalled(() => harness.saved.collectionCalls == 2);
      expect(
        harness.container.read(contents),
        isA<AsyncError<CollectionSavedItemsState>>(),
      );
      expect(harness.saved.deleteCalls, 1);
    });

    test('a caller that is leaving can skip the collection refresh', () async {
      final item = summary();
      final contents = collectionSavedItemsProvider(collectionId);
      final harness = makeHarness(
        inboxItems: [item],
        collections: [collection()],
        deleteResults: [eligible()],
        collectionDeleteResults: [null],
        collectionContentsResults: [
          CollectionSavedItemsPage(
            collectionId: collectionId,
            collectionName: collectionName,
            items: [item],
            nextCursor: null,
            hasMore: false,
          ),
        ],
      );
      addTearDown(harness.container.dispose);

      harness.container.listen(savedItemsProvider, (_, _) {});
      harness.container.listen(collectionsProvider, (_, _) {});
      harness.container.listen(contents, (_, _) {});
      await harness.container.read(savedItemsProvider.future);
      await harness.container.read(collectionsProvider.future);
      await harness.container.read(contents.future);

      final notifier = harness.container.read(deleteSavedItemProvider.notifier);
      await notifier.deleteItem(item);
      final outcome = await notifier.deleteCollection(
        collectionId: collectionId,
        collectionName: collectionName,
        invalidateContents: false,
      );

      expect(outcome, isA<DeleteCollectionSucceeded>());
      expect(
        harness.saved.collectionCalls,
        1,
        reason: 'the screen being popped must not fetch a deleted collection',
      );
      expect(contentsOf(harness.container, collectionId).items, isEmpty);
      expect(collectionsOf(harness.container).items.map((c) => c.id), isEmpty);
      expect(
        noticeOf(harness.container)?.copy,
        'Item deleted, and Camera Gear was deleted.',
      );
    });

    test(
      'COLLECTION_NOT_EMPTY keeps the collection and never retries the item',
      () async {
        final item = summary();
        final harness = makeHarness(
          inboxItems: [item],
          collections: [collection()],
          deleteResults: [eligible()],
          collectionDeleteResults: [
            const ApiFailureCollectionNotEmpty(code: 'COLLECTION_NOT_EMPTY'),
          ],
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        harness.container.listen(collectionsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);
        await harness.container.read(collectionsProvider.future);

        final notifier = harness.container.read(
          deleteSavedItemProvider.notifier,
        );
        await notifier.deleteItem(item);
        final outcome = await notifier.deleteCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );

        expect(outcome, isA<DeleteCollectionNotEmpty>());
        expect(collectionsOf(harness.container).items.map((c) => c.id), [
          collectionId,
        ]);
        expect(noticeOf(harness.container)?.tone, FeedbackTone.warning);
        expect(noticeOf(harness.container)?.copy, contains('now has items'));
        expect(harness.saved.deleteCalls, 1);
      },
    );

    test(
      'an ambiguous collection delete leaves the collection row in place',
      () async {
        final item = summary();
        final harness = makeHarness(
          inboxItems: [item],
          collections: [collection()],
          deleteResults: [eligible()],
          collectionDeleteResults: [const ApiFailureTransport()],
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        harness.container.listen(collectionsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);
        await harness.container.read(collectionsProvider.future);

        final notifier = harness.container.read(
          deleteSavedItemProvider.notifier,
        );
        await notifier.deleteItem(item);
        final outcome = await notifier.deleteCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );

        expect(outcome, isA<DeleteCollectionUnconfirmed>());
        expect(collectionsOf(harness.container).items.map((c) => c.id), [
          collectionId,
        ]);
        expect(noticeOf(harness.container)?.tone, FeedbackTone.uncertain);
        expect(noticeOf(harness.container)?.copy, contains("couldn't confirm"));
        expect(harness.saved.deleteCalls, 1);
      },
    );

    test(
      'a second collection action while the first is in flight is ignored',
      () async {
        final item = summary();
        final completer = Completer<void>();
        final harness = makeHarness(
          inboxItems: [item],
          deleteResults: [eligible()],
          onCollectionDelete: (_) => completer.future,
        );
        addTearDown(harness.container.dispose);
        harness.container.listen(savedItemsProvider, (_, _) {});
        await harness.container.read(savedItemsProvider.future);

        final notifier = harness.container.read(
          deleteSavedItemProvider.notifier,
        );
        await notifier.deleteItem(item);

        final first = notifier.deleteCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );
        expect(harness.container.read(deleteSavedItemProvider), isTrue);
        final second = await notifier.deleteCollection(
          collectionId: collectionId,
          collectionName: collectionName,
        );
        expect(second, isA<DeleteCollectionIgnored>());
        expect(harness.collections.deleteCalls, 1);

        completer.complete();
        expect(await first, isA<DeleteCollectionSucceeded>());
        expect(harness.container.read(deleteSavedItemProvider), isFalse);
        expect(harness.collections.deleteCalls, 1);
      },
    );
  });
}

class _Harness {
  const _Harness({
    required this.container,
    required this.saved,
    required this.collections,
  });

  final ProviderContainer container;
  final FakeSavedItemsRepository saved;
  final FakeCollectionsRepository collections;
}
