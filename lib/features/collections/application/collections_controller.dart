import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/collections_providers.dart';
import '../domain/collection_page.dart';
import '../domain/collection_summary.dart';
import 'collections_state.dart';

part 'collections_controller.g.dart';

Duration? _neverRetry(int retryCount, Object error) => null;

/// Collections list controller with cursor pagination.
///
/// Mirrors SavedItemsController pattern.
@Riverpod(keepAlive: true, retry: _neverRetry)
class Collections extends _$Collections {
  int _listVersion = 0;
  String _currentSort = 'newest';

  /// Ids removed after a confirmed collection delete.
  ///
  /// A load-more or refresh already in flight can return the collection after the
  /// in-place removal. Keeping these ids out of every adopted page prevents a
  /// resurrection without resetting the sort or discarding loaded pages.
  final Set<String> _removedCollectionIds = {};

  @override
  Future<CollectionsState> build() async {
    _listVersion++;
    _currentSort = 'newest';
    final page = await ref
        .watch(collectionsRepositoryProvider)
        .list(sort: _currentSort);
    return _toState(page, sort: _currentSort);
  }

  /// Drops the loaded list at an authentication boundary.
  ///
  /// **An [AsyncLoading] reset, and no request.** The session boundary
  /// invalidates separately after a sign-in; sign-out must not fetch without a
  /// session. Every consumer matches `AsyncData`, so changing the state's kind
  /// stops the previous account's names being rendered even though Riverpod keeps
  /// that value inside the loading state. The sort returns to the listing's
  /// default and the ids removed for the previous account are forgotten, so
  /// neither can filter the next account's collections. In-flight pages are
  /// invalidated through [_listVersion].
  void clearForSessionChange() {
    if (!ref.mounted) return;

    _listVersion++;
    _currentSort = 'newest';
    _removedCollectionIds.clear();
    state = const AsyncLoading();
  }

  Future<void> retry() async {
    ref.invalidateSelf();
  }

  Future<void> setSort(String sort) async {
    if (sort == _currentSort) return;
    _currentSort = sort;
    final version = ++_listVersion;
    state = const AsyncLoading();
    try {
      final page = await ref
          .read(collectionsRepositoryProvider)
          .list(sort: sort);
      // A newer sort, refresh or session boundary owns the list now. A reply
      // from the previous request must not replace its state.
      if (!ref.mounted || version != _listVersion) return;
      state = AsyncData(_toState(page, sort: sort));
    } catch (error, stackTrace) {
      if (!ref.mounted || version != _listVersion) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    final version = ++_listVersion;
    final sort = _currentSort;
    try {
      final page = await ref
          .read(collectionsRepositoryProvider)
          .list(sort: sort);
      if (!ref.mounted || version != _listVersion) return;
      state = AsyncData(_toState(page, sort: sort));
    } catch (error, stackTrace) {
      if (!ref.mounted || version != _listVersion) return;
      final current = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (current == null || current.items.isEmpty) {
        state = AsyncError(error, stackTrace);
      }
      // If items exist, keep them on screen (like SavedItems)
    }
  }

  /// Removes one confirmed-deleted collection in place.
  ///
  /// The current sort, cursor and `hasMore` are preserved. The id is also kept out
  /// of pages adopted later, so a load-more or refresh requested before the
  /// delete cannot bring the row back. The caller has already confirmed the delete
  /// and publishes its own feedback.
  void removeCollection(String collectionId) {
    _removedCollectionIds.add(collectionId);

    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null) return;

    final items = current.items
        .where((item) => item.id != collectionId)
        .toList(growable: false);
    if (items.length == current.items.length) return;

    state = AsyncData(current.copyWith(items: items));
  }

  Future<void> loadMore() async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    final cursor = current?.nextCursor;
    if (current == null || cursor == null || !current.hasMore) return;
    if (current.isLoadingMore) return;

    final version = _listVersion;
    final sort = _currentSort;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await ref
          .read(collectionsRepositoryProvider)
          .list(sort: sort, cursor: cursor);

      if (!ref.mounted || version != _listVersion) return;

      final latest = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (latest == null) return;

      state = AsyncData(
        latest.copyWith(
          items: _append(latest.items, page.items),
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
          sort: sort,
        ),
      );
    } catch (_) {
      if (!ref.mounted || version != _listVersion) return;

      final latest = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (latest == null) return;

      state = AsyncData(latest.copyWith(isLoadingMore: false));
    }
  }

  List<CollectionSummary> _append(
    List<CollectionSummary> existing,
    List<CollectionSummary> incoming,
  ) {
    final seen = {for (final item in existing) item.id};
    final merged = List<CollectionSummary>.of(existing);
    for (final item in incoming) {
      if (_removedCollectionIds.contains(item.id)) continue;
      if (seen.add(item.id)) merged.add(item);
    }
    return merged;
  }

  CollectionsState _toState(CollectionPage page, {String sort = 'newest'}) =>
      CollectionsState(
        items: page.items
            .where((item) => !_removedCollectionIds.contains(item.id))
            .toList(growable: false),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        sort: sort,
      );
}
