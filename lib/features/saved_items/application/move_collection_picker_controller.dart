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
/// the failure from the user and can make an automatic page load look stalled.
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
/// **One page at a time, as the list reaches its end.** The main sheet loads only
/// its bounded preview; this controller starts with one page and follows
/// `next_cursor` as the picker scrolls near the bottom. Nothing here sweeps every
/// page eagerly, and the footer's Retry is the only manual pagination control.
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
  /// treated as a failed page instead of causing an unbounded pagination loop.
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

  /// Loads the next page as the list approaches its end.
  ///
  /// Called by the picker's scroll listener, so it must be cheap to call
  /// repeatedly: the guards below are the throttle. It **refuses after a failed
  /// page** — only [retryLoadMore] may resume that cursor — which is what stops a
  /// scroll notification from re-issuing a request that just failed.
  Future<void> loadMore() async {
    final current = _currentState;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.loadMoreFailed) {
      return;
    }

    await _requestNextPage(current);
  }

  /// Retries the page that failed, using the same cursor.
  ///
  /// The only path that may resume paging after a failure, and the only reason
  /// the footer exists. It intentionally does not require
  /// [MoveCollectionPickerState.loadMoreFailed]: the footer is the only caller and
  /// it is rendered from that flag, while the in-flight guard is what actually
  /// prevents a repeated tap from stacking requests.
  ///
  /// Loaded rows are never discarded. On success the page is appended, the cursor
  /// metadata advances, and automatic pagination resumes; on another failure the
  /// footer error returns.
  Future<void> retryLoadMore() async {
    final current = _currentState;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    await _requestNextPage(current);
  }

  /// Fetches [current]'s `next_cursor` page and appends it.
  ///
  /// A missing cursor, or one this walk already consumed, cannot be continued:
  /// that is reported once as a failed page rather than requested again, which is
  /// what stops an automatic walk from looping on a server that does not advance.
  Future<void> _requestNextPage(MoveCollectionPickerState current) async {
    final cursor = current.nextCursor;

    if (cursor == null || cursor.isEmpty) {
      state = AsyncData(current.copyWith(loadMoreFailed: true));
      return;
    }

    if (!_loadedCursors.add(cursor)) {
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
