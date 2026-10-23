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
import 'package:stash_it_app/features/saved_items/application/delete_collection_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_collections_repository.dart';
import '../../../support/fake_saved_items_repository.dart';

/// The collection-delete controller: one request per confirmed disposition,
/// in-place reconciliation of both loaded listings, and the outcomes that must
/// stay distinguishable.
void main() {
  const collectionId = 'collection-1';
  const collectionName = 'Camera Gear';
  const targetId = 'collection-2';
  const targetName = 'Reading list';

  SavedItemSummary item({
    required String id,
    String collection = collectionId,
    String name = collectionName,
  }) => SavedItemSummary(
    id: id,
    collectionId: collection,
    collectionName: name,
    url: 'https://example.com/articles/$id',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Item $id',
  );

  CollectionSummary collection({
    String id = collectionId,
    String name = collectionName,
    bool isUnsorted = false,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: isUnsorted ? 'system' : 'user',
    isUnsorted: isUnsorted,
    savedItemsCount: 1,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  _Harness harness({
    List<SavedItemSummary> inbox = const [],
    List<CollectionSummary> collections = const [],
    List<Object?> deleteResults = const [],
    List<Object?> moveResults = const [],
    Future<void> Function(String id)? onDelete,
    List<Object> contents = const [],
    bool loadInbox = false,
    bool loadCollections = false,
    bool loadContents = false,
  }) {
    final saved = FakeSavedItemsRepository(
      listPage: SavedItemPage(items: inbox, nextCursor: null, hasMore: false),
      detailResults: [item(id: 'detail')],
      collectionResults: contents,
    );
    final collectionsRepository = FakeCollectionsRepository(
      results: [
        CollectionPage(items: collections, nextCursor: null, hasMore: false),
      ],
      deleteResults: deleteResults,
      moveResults: moveResults,
      onDelete: onDelete,
    );

    final container = ProviderContainer(
      overrides: [
        savedItemsRepositoryProvider.overrideWithValue(saved),
        collectionsRepositoryProvider.overrideWithValue(collectionsRepository),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    return _Harness(
      container: container,
      saved: saved,
      collections: collectionsRepository,
      loadInbox: loadInbox,
      loadCollections: loadCollections,
      loadContents: loadContents,
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

  AppFeedback? noticeOf(ProviderContainer container) =>
      container.read(feedbackProvider);

  Future<_Harness> loaded({
    List<SavedItemSummary> inbox = const [],
    List<CollectionSummary> collections = const [],
    List<Object?> deleteResults = const [],
    List<Object?> moveResults = const [],
    Future<void> Function(String id)? onDelete,
    List<Object> contents = const [],
  }) async {
    final result = harness(
      inbox: inbox,
      collections: collections,
      deleteResults: deleteResults,
      moveResults: moveResults,
      onDelete: onDelete,
      contents: contents,
      loadInbox: inbox.isNotEmpty,
      loadCollections: collections.isNotEmpty,
      loadContents: contents.isNotEmpty,
    );
    await result.load();
    return result;
  }

  group('deleting the collection with its items', () {
    test(
      'sends delete, then drops the collection and its Inbox rows',
      () async {
        final source = collection();
        final h = await loaded(
          inbox: [
            item(id: 'in-source'),
            item(id: 'elsewhere', collection: 'collection-9', name: 'Wishlist'),
          ],
          collections: [
            source,
            collection(id: 'collection-9', name: 'Wishlist'),
          ],
          deleteResults: [null],
        );

        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .deleteDiscardingItems(
              collectionId: collectionId,
              collectionName: collectionName,
            );

        expect(outcome, isA<CollectionDeletionSucceeded>());
        expect(h.collections.deleteIds, [collectionId]);
        expect(h.collections.moveCalls, 0);
        expect(collectionsOf(h.container).items.map((c) => c.id), [
          'collection-9',
        ]);
        expect(inboxOf(h.container).items.map((i) => i.id), ['elsewhere']);
        expect(noticeOf(h.container)?.tone, FeedbackTone.success);
        expect(noticeOf(h.container)?.copy, 'Camera Gear was deleted.');
      },
    );

    test(
      'never starts an Inbox or Collections read that was not loaded',
      () async {
        final h = harness(deleteResults: [null]);

        await h.container
            .read(collectionDeletionProvider.notifier)
            .deleteDiscardingItems(
              collectionId: collectionId,
              collectionName: collectionName,
            );

        expect(
          h.saved.listCalls,
          0,
          reason:
              'a collection action must not fetch the Inbox as a side effect',
        );
        expect(
          h.collections.listCalls,
          0,
          reason: 'nor re-read the Collections list',
        );
        expect(h.container.read(collectionDeletionProvider), isFalse);
      },
    );

    test(
      'an unavailable collection reconciles it out of both caches',
      () async {
        final source = collection();
        final h = await loaded(
          inbox: [item(id: 'in-source')],
          collections: [source],
          deleteResults: [
            const ApiFailureNotFound(code: 'COLLECTION_NOT_FOUND'),
          ],
        );

        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .deleteDiscardingItems(
              collectionId: collectionId,
              collectionName: collectionName,
            );

        expect(outcome, isA<CollectionDeletionSourceNotFound>());
        expect(collectionsOf(h.container).items, isEmpty);
        expect(inboxOf(h.container).items, isEmpty);
        expect(
          noticeOf(h.container)?.copy,
          'Camera Gear is no longer available.',
        );
      },
    );

    test(
      'a target-not-found answer is not invented on the delete path',
      () async {
        final h = await loaded(
          collections: [collection()],
          deleteResults: [
            const ApiFailureCollectionDeleteTargetNotFound(
              code: 'COLLECTION_DELETE_TARGET_NOT_FOUND',
            ),
          ],
        );

        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .deleteDiscardingItems(
              collectionId: collectionId,
              collectionName: collectionName,
            );

        // The `delete` action has no destination, so no destination can be
        // offered for correction. A known not-deleted refusal.
        expect(outcome, isA<CollectionDeletionFailed>());
        expect(noticeOf(h.container)?.tone, FeedbackTone.danger);
        expect(collectionsOf(h.container).items, hasLength(1));
      },
    );

    test(
      'a concurrent insert re-reads the contents and retries nothing',
      () async {
        final h = await loaded(
          collections: [collection()],
          deleteResults: [
            const ApiFailureCollectionNotEmpty(code: 'COLLECTION_NOT_EMPTY'),
          ],
          contents: [
            CollectionSavedItemsPage(
              collectionId: collectionId,
              collectionName: collectionName,
              items: [item(id: 'arrived')],
              nextCursor: null,
              hasMore: false,
            ),
          ],
        );
        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .deleteDiscardingItems(
              collectionId: collectionId,
              collectionName: collectionName,
            );
        await pumpEventQueue();

        expect(outcome, isA<CollectionDeletionNotEmpty>());
        expect(h.collections.deleteCalls, 1, reason: 'no automatic retry');
        expect(
          h.saved.collectionCalls,
          2,
          reason: 'the contents were refreshed so the new row appears',
        );
        expect(collectionsOf(h.container).items, hasLength(1));
      },
    );

    test('an ambiguous transport answer changes no cache entry', () async {
      final h = await loaded(
        inbox: [item(id: 'in-source')],
        collections: [collection()],
        deleteResults: [const ApiFailureTransport()],
      );

      final outcome = await h.container
          .read(collectionDeletionProvider.notifier)
          .deleteDiscardingItems(
            collectionId: collectionId,
            collectionName: collectionName,
          );

      expect(outcome, isA<CollectionDeletionUnconfirmed>());
      expect(inboxOf(h.container).items, hasLength(1));
      expect(collectionsOf(h.container).items, hasLength(1));
      expect(noticeOf(h.container)?.tone, FeedbackTone.uncertain);
      expect(noticeOf(h.container)?.copy, contains("couldn't confirm"));
    });

    test('Unsorted is refused by the server, not by name', () async {
      final h = await loaded(
        collections: [collection(isUnsorted: true)],
        deleteResults: [
          const ApiFailureUnsortedCollectionProtected(
            code: 'UNSORTED_COLLECTION_PROTECTED',
          ),
        ],
      );

      final outcome = await h.container
          .read(collectionDeletionProvider.notifier)
          .deleteDiscardingItems(
            collectionId: collectionId,
            collectionName: collectionName,
          );

      expect(outcome, isA<CollectionDeletionProtected>());
      expect(collectionsOf(h.container).items, hasLength(1));
    });

    test('a second action while one is in flight sends no request', () async {
      final gate = Completer<void>();
      final h = harness(onDelete: (_) => gate.future);

      final notifier = h.container.read(collectionDeletionProvider.notifier);
      final first = notifier.deleteDiscardingItems(
        collectionId: collectionId,
        collectionName: collectionName,
      );
      final second = notifier.deleteDiscardingItems(
        collectionId: collectionId,
        collectionName: collectionName,
      );

      expect(await second, isA<CollectionDeletionIgnored>());
      expect(h.collections.deleteCalls, 1);

      gate.complete();
      expect(await first, isA<CollectionDeletionSucceeded>());
      expect(h.container.read(collectionDeletionProvider), isFalse);
    });
  });

  group('moving the items and deleting the collection', () {
    test(
      'sends one move request with the destination and rewrites the Inbox',
      () async {
        final source = collection();
        final target = collection(id: targetId, name: targetName);
        final h = await loaded(
          inbox: [
            item(id: 'in-source'),
            item(id: 'elsewhere', collection: 'collection-9', name: 'Wishlist'),
          ],
          collections: [source, target],
          moveResults: [null],
        );

        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .moveItemsAndDelete(
              collectionId: collectionId,
              collectionName: collectionName,
              target: target,
            );
        await pumpEventQueue();

        expect(outcome, isA<CollectionDeletionSucceeded>());
        expect(h.collections.moves, [
          (sourceId: collectionId, targetId: targetId),
        ]);
        expect(h.collections.moveCalls, 1, reason: 'no per-item moves');

        final items = inboxOf(h.container).items;
        expect(items, hasLength(2));
        final moved = items.firstWhere((i) => i.id == 'in-source');
        expect(moved.collectionId, targetId);
        expect(moved.collectionName, targetName);
        expect(
          items.firstWhere((i) => i.id == 'elsewhere').collectionName,
          'Wishlist',
          reason: 'only rows that left the source are rewritten',
        );

        // The list was refreshed for authoritative counts, not invalidated: a
        // rebuild would reset the chosen sort.
        expect(h.collections.listCalls, 2);
        expect(h.collections.sorts, ['newest', 'newest']);
        expect(collectionsOf(h.container).items.map((c) => c.id), [targetId]);
        expect(noticeOf(h.container)?.copy, contains('moved to Reading list'));
      },
    );

    test(
      'a missing destination leaves the source and every row intact',
      () async {
        final source = collection();
        final target = collection(id: targetId, name: targetName);
        final h = await loaded(
          inbox: [item(id: 'in-source')],
          collections: [source, target],
          moveResults: [
            const ApiFailureCollectionDeleteTargetNotFound(
              code: 'COLLECTION_DELETE_TARGET_NOT_FOUND',
            ),
          ],
        );

        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .moveItemsAndDelete(
              collectionId: collectionId,
              collectionName: collectionName,
              target: target,
            );

        expect(outcome, isA<CollectionDeletionTargetNotFound>());
        expect(inboxOf(h.container).items.single.collectionId, collectionId);
        expect(collectionsOf(h.container).items, hasLength(2));
        expect(
          h.collections.listCalls,
          1,
          reason: 'nothing was moved, so no count needs refreshing',
        );
        expect(noticeOf(h.container)?.tone, FeedbackTone.warning);
        expect(
          noticeOf(h.container)?.copy,
          contains('Choose another destination'),
        );
      },
    );

    test(
      'a concurrent insert on the move rolls back and refreshes contents',
      () async {
        final target = collection(id: targetId, name: targetName);
        final h = await loaded(
          collections: [collection(), target],
          moveResults: [
            const ApiFailureCollectionNotEmpty(code: 'COLLECTION_NOT_EMPTY'),
          ],
          contents: [
            CollectionSavedItemsPage(
              collectionId: collectionId,
              collectionName: collectionName,
              items: [item(id: 'arrived')],
              nextCursor: null,
              hasMore: false,
            ),
          ],
        );
        final outcome = await h.container
            .read(collectionDeletionProvider.notifier)
            .moveItemsAndDelete(
              collectionId: collectionId,
              collectionName: collectionName,
              target: target,
            );
        await pumpEventQueue();

        expect(outcome, isA<CollectionDeletionNotEmpty>());
        expect(h.collections.moveCalls, 1, reason: 'no automatic retry');
        expect(h.saved.collectionCalls, 2);
        expect(collectionsOf(h.container).items, hasLength(2));
      },
    );
  });
}

/// A container plus the fakes behind it, with the listed providers preloaded.
class _Harness {
  _Harness({
    required this.container,
    required this.saved,
    required this.collections,
    this.loadInbox = false,
    this.loadCollections = false,
    this.loadContents = false,
  });

  final ProviderContainer container;
  final FakeSavedItemsRepository saved;
  final FakeCollectionsRepository collections;

  final bool loadInbox;
  final bool loadCollections;
  final bool loadContents;

  Future<void> load() async {
    if (loadInbox) {
      container.listen(savedItemsProvider, (_, _) {});
      await container.read(savedItemsProvider.future);
    }
    if (loadCollections) {
      container.listen(collectionsProvider, (_, _) {});
      await container.read(collectionsProvider.future);
    }
    if (loadContents) {
      final contents = collectionSavedItemsProvider('collection-1');
      container.listen(contents, (_, _) {});
      await container.read(contents.future);
    }
  }
}
