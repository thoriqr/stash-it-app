import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import 'collection_saved_items_state.dart';

part 'collection_saved_items_controller.g.dart';

/// Riverpod's automatic retry, refused for this listing.
///
/// Every failure here is an [ApiFailure] — a plain sealed class, which Riverpod's
/// default policy does not exclude — so the generated default would rebuild the
/// provider up to ten times on a doubling backoff, issuing ten requests nobody
/// asked for. That is the opposite of the manual retry **[D23]** asks for, and for
/// a listing that failed on a `401` it would repeat the authentication dance the
/// interceptor has already given up on.
///
/// A top-level tear-off rather than a static member so it is a compile-time
/// constant, which is what the annotation argument requires.
Duration? _neverRetry(int retryCount, Object error) => null;

/// What a failed manual pull-to-refresh says.
///
/// A refresh is a **read**: the rows already on screen remain valid, so the notice
/// must not suggest that anything was lost or never saved.
/// [FeedbackTone.uncertain] is the tone for a request whose refreshed page did not
/// arrive.
AppFeedback _refreshFailedFeedback() => AppFeedback(
  tone: FeedbackTone.uncertain,
  copy: "Couldn't refresh. Check your connection.",
);

/// One collection's saved items, with cursor pagination.
///
/// **Keyed by collection id and auto-dispose.** The detail is transient screen
/// state: it belongs to one visit to one collection and must not outlive the
/// route. This is the opposite of `collectionsProvider`, which is keep-alive
/// because Collections is a retained destination. Pushing the saved-item detail on
/// top does **not** dispose this: the collection screen stays mounted, so the
/// provider is still watched and the loaded pages and scroll position survive.
///
/// **The read is the screen's whole purpose.** Opening a collection issues exactly
/// one `GET /collections/{id}/saved-items`; nothing here enriches, organizes or
/// writes, because the endpoint is read-only and looking at a collection is not a
/// reason to fetch anything.
@Riverpod(retry: _neverRetry)
class CollectionSavedItems extends _$CollectionSavedItems {
  /// The collection this provider is for, established by [build].
  ///
  /// Held rather than read from the generated argument because every mutation
  /// below needs it after an `await`, when the state object may not be available.
  late String _collectionId;

  /// Identifies the list a page request belongs to.
  ///
  /// A retry or a pull-to-refresh starts a new list. A page already in flight
  /// belongs to the old one and must be dropped rather than appended to the new
  /// rows or used to move the new cursor.
  int _listVersion = 0;

  /// Cursors already consumed successfully by the current list.
  ///
  /// A server that repeats a cursor is treated as a failed page instead of causing
  /// an unbounded load-more loop. Cleared whenever a new first page is adopted,
  /// because a cursor is only "already consumed" within one walk of the listing.
  final Set<String> _consumedCursors = {};

  /// The manual refresh currently in flight, shared by concurrent gestures.
  Future<void>? _refreshInFlight;

  /// The explicit first-page retry currently in flight.
  Future<void>? _retryInFlight;

  @override
  Future<CollectionSavedItemsState> build(String collectionId) async {
    // A rebuild is a new list too, so any page requested against a previous one
    // must not land in this one.
    _listVersion++;
    _collectionId = collectionId;

    final page = await ref
        .watch(savedItemsRepositoryProvider)
        .listInCollection(collectionId);

    // `has_more` without a usable cursor cannot be paged. Reporting it as an
    // unreadable response is what stops the screen offering a Retry that would
    // only fail the same way.
    _requireUsableCursor(page);

    return _toState(page);
  }

  /// Replaces whatever is on screen with a fresh first page.
  ///
  /// This is the pull-to-refresh path. The current rows stay on screen while the
  /// request is in flight — the `RefreshIndicator` is the only progress UI — and
  /// are replaced, together with the cursor, only when the new first page arrives.
  /// Replacing rather than merging is deliberate: the user asked for current
  /// server state, and keeping older pages would preserve rows and a continuation
  /// point that no longer match the refreshed head.
  ///
  /// Concurrent gestures share one request. A page already in flight is
  /// invalidated through [_listVersion], so it cannot be appended to the refreshed
  /// list or advance its cursor.
  ///
  /// **Failure:** with rows on screen, they remain exactly as they were and the
  /// indicator retracts so the user can try again; the failure is also announced
  /// once through the app-wide feedback channel, because a gesture the user made
  /// otherwise looks like it did nothing. With nothing on screen — an empty result
  /// or an earlier failure — the failure becomes the provider's error state, so the
  /// inline copy and its Retry appear.
  Future<void> refresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final version = ++_listVersion;

    late final Future<void> future;
    future = _refresh(version).whenComplete(() {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    });
    _refreshInFlight = future;

    // A page from the previous list can no longer be used. Stop showing its
    // footer while the refresh owns the list.
    final current = _currentState;
    if (current != null && current.isLoadingMore) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }

    return future;
  }

  Future<void> _refresh(int version) async {
    try {
      final page = await ref
          .read(savedItemsRepositoryProvider)
          .listInCollection(_collectionId);

      if (!ref.mounted || version != _listVersion) return;

      _requireUsableCursor(page);
      _applyFirstPage(page);
    } catch (error, stackTrace) {
      if (!ref.mounted || version != _listVersion) return;

      final current = _currentState;

      // The rows already on screen are not made wrong by a refresh that did not
      // deliver. With nothing to keep, use the same AsyncError the first load
      // uses so the existing copy and Retry appear.
      if (current == null || current.items.isEmpty) {
        state = AsyncError(error, stackTrace);
      }

      // Published after the version guard, so a stale response cannot raise a
      // notice, and coalesced gestures share this one `_refresh` and therefore
      // one notice.
      ref.read(feedbackProvider.notifier).show(_refreshFailedFeedback());
    }
  }

  /// Refetches page one, discarding whatever is on screen.
  ///
  /// **Not `ref.invalidateSelf()`.** Invalidating schedules a rebuild without
  /// telling this object whether one is already running, so two taps in quick
  /// succession can issue two requests. The in-flight future below makes the
  /// second call join the first instead, which is the behaviour the screen's Retry
  /// needs and what the test asserts.
  ///
  /// The whole state is replaced, which is what resets the cursor, `hasMore`,
  /// `isLoadingMore` and any pagination failure before the reload.
  Future<void> retry() {
    final inFlight = _retryInFlight;
    if (inFlight != null) return inFlight;

    final version = ++_listVersion;

    late final Future<void> future;
    future = _retry(version).whenComplete(() {
      if (identical(_retryInFlight, future)) _retryInFlight = null;
    });
    _retryInFlight = future;

    return future;
  }

  Future<void> _retry(int version) async {
    // A first load has no rows worth keeping: an explicit retry returns the screen
    // to its loading state, exactly as the Inbox does.
    state = const AsyncLoading();

    try {
      final page = await ref
          .read(savedItemsRepositoryProvider)
          .listInCollection(_collectionId);

      if (!ref.mounted || version != _listVersion) return;

      _requireUsableCursor(page);
      _applyFirstPage(page);
    } catch (error, stackTrace) {
      if (!ref.mounted || version != _listVersion) return;

      state = AsyncError(error, stackTrace);
    }
  }

  /// Requests the next page as the user approaches the end.
  ///
  /// Does nothing when the listing has already ended, when a page is already in
  /// flight, when a refresh owns the list, or when the previous page failed and has
  /// not been retried — so a scroll notification arriving repeatedly cannot queue
  /// duplicate requests, and **cannot retry a failed cursor either**.
  Future<void> loadMore() async {
    if (_refreshInFlight != null) return;

    final current = _currentState;
    if (current == null) return;

    if (!current.hasMore || current.isLoadingMore || current.loadMoreFailed) {
      return;
    }

    await _requestNextPage(current);
  }

  /// Retries the page that failed, using the same cursor.
  ///
  /// The only path that may resume paging after a failure, and the only reason the
  /// footer exists. It requires [CollectionSavedItemsState.loadMoreFailed], which
  /// is what keeps a plain scroll from doing the same thing.
  Future<void> retryLoadMore() async {
    if (_refreshInFlight != null) return;

    final current = _currentState;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    await _requestNextPage(current);
  }

  Future<void> _requestNextPage(CollectionSavedItemsState current) async {
    final cursor = current.nextCursor;

    // `has_more` is true, so the contract says a cursor exists. Without one the
    // page cannot be continued: report it once rather than asking again.
    if (cursor == null || cursor.isEmpty) {
      state = AsyncData(current.copyWith(loadMoreFailed: true));
      return;
    }

    // A cursor this walk already consumed means the server did not advance. Asking
    // again would return the same page forever, so it is a failed page instead.
    if (!_consumedCursors.add(cursor)) {
      state = AsyncData(current.copyWith(loadMoreFailed: true));
      return;
    }

    final version = _listVersion;
    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );

    try {
      final page = await ref
          .read(savedItemsRepositoryProvider)
          .listInCollection(_collectionId, cursor: cursor);

      // A refresh or retry started after this request: it replaced the list and
      // cursor this page was fetched against, so appending now would mix two list
      // generations.
      if (!ref.mounted || version != _listVersion) return;

      _requireUsableCursor(page);

      // Re-read rather than merge into `current`: the page may be answered after
      // other state changes, and writing the old snapshot back would drop them.
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
      // ApiFailure or anything else. The rows already on screen stay — this is a
      // collection the user is browsing, and page three failing must not throw
      // away pages one and two. The cursor did not advance, so it is released for
      // the explicit Retry to present again.
      if (!ref.mounted || version != _listVersion) return;

      _consumedCursors.remove(cursor);

      final latest = _currentState;
      if (latest == null) return;

      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  CollectionSavedItemsState? get _currentState => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  /// Adopts a new first page as the whole list.
  ///
  /// The consumed-cursor guard is scoped to one walk of the listing, so a new head
  /// starts a new walk. Without clearing it, a cursor that legitimately reappears
  /// after a refresh would be mistaken for a server repeating itself.
  void _applyFirstPage(CollectionSavedItemsPage page) {
    _consumedCursors.clear();
    state = AsyncData(_toState(page));
  }

  /// `has_more` and a usable cursor are one contract: paging with one and not the
  /// other cannot succeed, and an empty cursor would be sent as an absent query
  /// parameter, silently restarting the listing from page one.
  static void _requireUsableCursor(CollectionSavedItemsPage page) {
    if (page.hasMore && (page.nextCursor == null || page.nextCursor!.isEmpty)) {
      throw const ApiFailureUnreadableResponse();
    }
  }

  /// Appends [incoming], skipping any id already present.
  ///
  /// The contract's ordering is stable, so a conforming page cannot repeat an id.
  /// This is not about that: it is about the case the cursor explicitly survives —
  /// an item moved into this collection between two page fetches can appear in
  /// both, and a duplicated row is a visible defect.
  static List<SavedItemSummary> _append(
    List<SavedItemSummary> existing,
    List<SavedItemSummary> incoming,
  ) {
    final seen = {for (final item in existing) item.id};
    final merged = List<SavedItemSummary>.of(existing);

    for (final item in incoming) {
      if (seen.add(item.id)) merged.add(item);
    }

    return merged;
  }

  static CollectionSavedItemsState _toState(CollectionSavedItemsPage page) =>
      CollectionSavedItemsState(
        collectionId: page.collectionId,
        collectionName: page.collectionName,
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      );
}
