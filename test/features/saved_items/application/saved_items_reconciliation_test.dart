import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_state.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/fake_saved_items_repository.dart';

/// The Inbox's in-place reconciliation after a collection delete or a confirmed
/// bulk move.
///
/// These are the rules that cannot live in a per-screen cache: the Inbox is
/// kept alive, may have pages in flight, and must answer for rows it has not
/// loaded yet. The provider is therefore driven directly, with a repository
/// whose page can be held open.
void main() {
  const sourceId = 'collection-1';
  const targetId = 'collection-2';

  SavedItemSummary item(
    String id, {
    required String collection,
    String? name,
  }) => SavedItemSummary(
    id: id,
    collectionId: collection,
    collectionName:
        name ?? (collection == sourceId ? 'Camera Gear' : 'Reading list'),
    url: 'https://example.com/articles/$id',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Item $id',
  );

  SavedItemPage pageOf(
    List<SavedItemSummary> items, {
    String? nextCursor,
    bool hasMore = false,
  }) => SavedItemPage(items: items, nextCursor: nextCursor, hasMore: hasMore);

  /// One provider container over a repository whose Inbox reads are scripted by
  /// [onList], so a page can be completed after a local change.
  ({ProviderContainer container, _ScriptedInboxRepository repository}) make() {
    final repository = _ScriptedInboxRepository();
    final container = ProviderContainer(
      overrides: [savedItemsRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return (container: container, repository: repository);
  }

  SavedItemsState stateOf(ProviderContainer container) =>
      switch (container.read(savedItemsProvider)) {
        AsyncData(:final value) => value,
        final other => throw StateError('expected data, got $other'),
      };

  test(
    'removing a collection drops its loaded rows and keeps the cursor',
    () async {
      final made = make();
      final first = Completer<SavedItemPage>();
      made.repository.next = () => first.future;

      final loaded = made.container.read(savedItemsProvider.future);
      first.complete(
        pageOf(
          [
            item('a', collection: sourceId),
            item('b', collection: 'collection-9', name: 'Wishlist'),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      );
      await loaded;

      made.container
          .read(savedItemsProvider.notifier)
          .removeItemsInCollection(sourceId);

      final state = stateOf(made.container);
      expect(state.items.map((i) => i.id), ['b']);
      expect(state.nextCursor, 'cursor-2');
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);
    },
  );

  test(
    'a first page requested before the removal cannot restore its rows',
    () async {
      final made = make();
      final first = Completer<SavedItemPage>();
      made.repository.next = () => first.future;

      // The request starts (capturing the tombstone version), the delete lands
      // while it is in flight, and only then does the page arrive.
      final loaded = made.container.read(savedItemsProvider.future);
      made.container
          .read(savedItemsProvider.notifier)
          .removeItemsInCollection(sourceId);
      first.complete(
        pageOf([
          item('a', collection: sourceId),
          item('b', collection: targetId),
        ]),
      );
      await loaded;

      expect(
        stateOf(made.container).items.map((i) => i.id),
        ['b'],
        reason:
            'a reply that predates the delete is filtered, not adopted whole',
      );
    },
  );

  test('a later page cannot add a row the removal already covered', () async {
    final made = make();
    final first = Completer<SavedItemPage>();
    final second = Completer<SavedItemPage>();
    made.repository.next = () => first.future;

    final loaded = made.container.read(savedItemsProvider.future);
    first.complete(
      pageOf(
        [item('a', collection: sourceId)],
        nextCursor: 'cursor-2',
        hasMore: true,
      ),
    );
    await loaded;

    // The next page was requested before the delete and names a row the Inbox
    // had not loaded. Per-item tombstones could not cover it; the collection id
    // does.
    made.repository.next = () => second.future;
    final more = made.container.read(savedItemsProvider.notifier).loadMore();
    made.container
        .read(savedItemsProvider.notifier)
        .removeItemsInCollection(sourceId);
    second.complete(pageOf([item('late', collection: sourceId)]));
    await more;

    expect(stateOf(made.container).items, isEmpty);
  });

  test(
    'a confirmed move rewrites only the rows that left the source',
    () async {
      final made = make();
      final first = Completer<SavedItemPage>();
      made.repository.next = () => first.future;

      final loaded = made.container.read(savedItemsProvider.future);
      first.complete(
        pageOf([
          item('a', collection: sourceId),
          item('b', collection: 'collection-9', name: 'Wishlist'),
        ]),
      );
      await loaded;

      made.container
          .read(savedItemsProvider.notifier)
          .applyCollectionToItems(
            sourceCollectionId: sourceId,
            targetCollectionId: targetId,
            targetCollectionName: 'Reading list',
          );

      final items = stateOf(made.container).items;
      expect(items.map((i) => i.id), ['a', 'b']);
      expect(items.first.collectionId, targetId);
      expect(items.first.collectionName, 'Reading list');
      expect(
        items.last.collectionName,
        'Wishlist',
        reason: 'a row in another collection is not part of this move',
      );
      expect(
        items.first.title,
        'Item a',
        reason: 'only the collection changed',
      );
    },
  );

  test(
    'a page requested before the move is rewritten when it arrives',
    () async {
      final made = make();
      final first = Completer<SavedItemPage>();
      made.repository.next = () => first.future;

      final loaded = made.container.read(savedItemsProvider.future);
      first.complete(pageOf([item('a', collection: sourceId)]));
      await loaded;

      made.repository.next = () =>
          Future.value(pageOf([item('a', collection: sourceId)]));
      final stale = made.container.read(savedItemsProvider.notifier).refresh();
      made.container
          .read(savedItemsProvider.notifier)
          .applyCollectionToItems(
            sourceCollectionId: sourceId,
            targetCollectionId: targetId,
            targetCollectionName: 'Reading list',
          );
      await stale;

      final items = stateOf(made.container).items;
      expect(items.single.collectionId, targetId);
      expect(items.single.collectionName, 'Reading list');
    },
  );

  test('deleting the destination later drops the rows it received', () async {
    final made = make();
    final first = Completer<SavedItemPage>();
    made.repository.next = () => first.future;

    final loaded = made.container.read(savedItemsProvider.future);
    first.complete(pageOf([item('a', collection: sourceId)]));
    await loaded;

    final notifier = made.container.read(savedItemsProvider.notifier);
    notifier.applyCollectionToItems(
      sourceCollectionId: sourceId,
      targetCollectionId: targetId,
      targetCollectionName: 'Reading list',
    );
    notifier.removeItemsInCollection(targetId);

    expect(stateOf(made.container).items, isEmpty);
  });
}

/// An Inbox repository whose next read is supplied per request.
///
/// Holding the page open is what makes "requested before the local change"
/// testable without sleeping: the change happens while the future is pending.
final class _ScriptedInboxRepository extends FakeSavedItemsRepository {
  _ScriptedInboxRepository()
    : super(
        detailResults: const [
          SavedItemSummary(
            id: 'unused',
            collectionId: 'unused',
            collectionName: 'unused',
            url: 'https://example.com',
            enrichmentStatus: EnrichmentStatus.pending,
          ),
        ],
      );

  Future<SavedItemPage> Function()? next;

  @override
  Future<SavedItemPage> list({String? cursor}) {
    final handler = next;
    if (handler == null) {
      throw StateError('no Inbox page scripted');
    }
    return handler();
  }
}
