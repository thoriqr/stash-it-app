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

  @override
  Future<CollectionsState> build() async {
    _listVersion++;
    _currentSort = 'newest';
    final page = await ref
        .watch(collectionsRepositoryProvider)
        .list(sort: _currentSort);
    return _toState(page, sort: _currentSort);
  }

  Future<void> retry() async {
    ref.invalidateSelf();
  }

  Future<void> setSort(String sort) async {
    if (sort == _currentSort) return;
    _currentSort = sort;
    _listVersion++;
    state = const AsyncLoading();
    try {
      final page = await ref
          .read(collectionsRepositoryProvider)
          .list(sort: sort);
      if (!ref.mounted) return;
      state = AsyncData(_toState(page, sort: sort));
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
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

  static List<CollectionSummary> _append(
    List<CollectionSummary> existing,
    List<CollectionSummary> incoming,
  ) {
    final seen = {for (final item in existing) item.id};
    final merged = List<CollectionSummary>.of(existing);
    for (final item in incoming) {
      if (seen.add(item.id)) merged.add(item);
    }
    return merged;
  }

  static CollectionsState _toState(
    CollectionPage page, {
    String sort = 'newest',
  }) => CollectionsState(
    items: page.items,
    nextCursor: page.nextCursor,
    hasMore: page.hasMore,
    sort: sort,
  );
}
