import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';

part 'move_collection_picker_controller.freezed.dart';
part 'move_collection_picker_controller.g.dart';

/// Riverpod's automatic retry, refused for the picker read.
///
/// A failed page is shown with an explicit Retry. Retrying silently would hide
/// the failure from the user and can make a load-more tap look ignored.
Duration? _neverRetry(int retryCount, Object error) => null;

/// Loaded state for the full Move to a collection picker.
@freezed
abstract class MoveCollectionPickerState with _$MoveCollectionPickerState {
  const factory MoveCollectionPickerState({
    required List<CollectionSummary> items,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
    @Default(false) bool loadMoreFailed,
  }) = _MoveCollectionPickerState;
}

/// Cursor-paginated collection browser for the Move to a collection flow.
///
/// **One page at a time, on demand.** The main sheet loads only its bounded
/// preview; this controller starts with one page and follows `next_cursor` only
/// when the user asks for more. Nothing here sweeps every page eagerly.
///
/// **The collections listing has no name filter.** A typed name can therefore
/// only be compared with collections the client has already fetched. Discovering
/// an existing collection outside the preview requires browsing these pages;
/// there is no efficient global lookup to claim, and the client does not pretend
/// there is one.
///
/// Pages are appended in server order and de-duplicated by id. The server already
/// sorts by name; this controller never sorts again (**D4**). System and user
/// collections are both kept (**D2**); the sheet filters out its current
/// collection by id because that collection is context, not a destination.
@Riverpod(retry: _neverRetry)
class MoveCollectionPicker extends _$MoveCollectionPicker {
  static const int _pageSize = 20;

  /// Cursors already consumed successfully. A server that repeats a cursor is
  /// treated as a failed page instead of causing an unbounded load-more loop.
  final Set<String> _loadedCursors = {};

  @override
  Future<MoveCollectionPickerState> build() async {
    _loadedCursors.clear();
    final page = await ref
        .watch(collectionsRepositoryProvider)
        .list(sort: 'name', limit: _pageSize);

    _requireUsableCursor(page);
    return _stateFrom(page);
  }

  /// Loads the next page, if one exists and no load is already running.
  Future<void> loadMore() async {
    final current = _currentState;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    final cursor = current.nextCursor;
    if (cursor == null || cursor.isEmpty || !_loadedCursors.add(cursor)) {
      state = AsyncData(current.copyWith(loadMoreFailed: true));
      return;
    }

    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );

    try {
      final page = await ref
          .read(collectionsRepositoryProvider)
          .list(sort: 'name', limit: _pageSize, cursor: cursor);

      if (!ref.mounted) return;

      _requireUsableCursor(page);

      final latest = _currentState;
      if (latest == null) return;

      state = AsyncData(
        latest.copyWith(
          items: _append(latest.items, page.items),
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;

      // A failed request did not consume the cursor; Retry may use it again.
      _loadedCursors.remove(cursor);

      final latest = _currentState;
      if (latest == null) return;

      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  MoveCollectionPickerState? get _currentState => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  static void _requireUsableCursor(CollectionPage page) {
    if (page.hasMore && (page.nextCursor == null || page.nextCursor!.isEmpty)) {
      throw const ApiFailureUnreadableResponse();
    }
  }

  static MoveCollectionPickerState _stateFrom(CollectionPage page) =>
      MoveCollectionPickerState(
        items: List<CollectionSummary>.unmodifiable(page.items),
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );

  static List<CollectionSummary> _append(
    List<CollectionSummary> existing,
    List<CollectionSummary> incoming,
  ) {
    final seen = {for (final item in existing) item.id};
    final merged = List<CollectionSummary>.of(existing);
    for (final item in incoming) {
      if (seen.add(item.id)) merged.add(item);
    }
    return List<CollectionSummary>.unmodifiable(merged);
  }
}
