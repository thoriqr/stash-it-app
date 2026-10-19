import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import 'saved_items_state.dart';

part 'saved_items_controller.g.dart';

/// Riverpod's automatic retry, refused, for the one provider that must not have
/// any.
///
/// Passed to `@Riverpod` as a named function because the annotation is a `const`
/// constructor and an inline `(_, __) => null` is not a constant expression.
/// Returning `null` is how Riverpod is told not to retry: `triggerRetry` treats
/// it as "no delay", arms no timer, and publishes `AsyncError` to the listener
/// instead of `AsyncLoading` (`riverpod/lib/src/core/element.dart`).
///
/// It is a top-level tear-off rather than a static member so it is a compile-time
/// constant, which is what the annotation argument requires.
Duration? _neverRetry(int retryCount, Object error) => null;

/// The Inbox listing: the first page, and any page after it.
///
/// An [AsyncNotifier] rather than a `FutureProvider`, for two reasons. `retry()`
/// has to genuinely **refetch** rather than re-read a cached future, and paging
/// has to **append** to what is already on screen without the list ever passing
/// through a loading state that would blank it.
///
/// **`@Riverpod(keepAlive: true)`.** `@riverpod` generates an auto-dispose
/// provider, which would discard the loaded page every time the user leaves the
/// Inbox for another destination and back. The listing is a recent-history
/// screen, so keeping it is the point.
///
/// **`retry: _neverRetry` — no automatic retry, ever.** Riverpod retries a failed
/// provider build by default: `ProviderContainer.defaultRetry` allows **ten**
/// rebuilds on a 200 ms doubling backoff capped at 6.4 s, and its only
/// exclusions are `ProviderException` and `Error`. An `ApiFailure` is neither —
/// it is a plain sealed class — so every failure below, including
/// `ApiFailureRefreshUncertain`, would be retried.
///
/// That would undo the session policy this client already implements. A renewal
/// that fails ambiguously is deliberately **not** retried: the outcome is
/// genuinely unknown, the stored credentials are kept, and the user decides
/// (`session_controller.dart`, `ApiFailureRefreshUncertain`). A rebuild here
/// issues a brand-new request with a brand-new `RequestOptions`, so the
/// interceptor's one-replay bound resets each time and a second
/// `POST /auth/refresh` presents the **same** refresh token. The backend treats
/// that as reuse, revokes the whole session, and answers `SESSION_REVOKED` — so
/// an automatic retry converts a deliberately preserved session into a terminal
/// one roughly 200 ms later, without the user having touched anything.
///
/// Scoped to this provider deliberately: the session controller and the router
/// keep Riverpod's default, and no global policy is changed. [SavedItems.retry] —
/// which the Inbox's Retry button calls — remains the only way this listing is
/// fetched again, which is the manual retry **D23** asks for.
@Riverpod(keepAlive: true, retry: _neverRetry)
class SavedItems extends _$SavedItems {
  @override
  Future<SavedItemsState> build() async {
    final page = await ref.watch(savedItemsRepositoryProvider).list();
    return _toState(page);
  }

  /// Refetches the newest page, discarding whatever is on screen.
  ///
  /// Invalidating re-runs [build], so this is a real request rather than a
  /// re-read of a cached one, and it returns the screen to its loading state
  /// exactly as a first load does.
  Future<void> retry() async {
    ref.invalidateSelf();
  }

  /// Re-reads the newest page and **merges** it above what is already loaded.
  ///
  /// This is what follows a confirmed save, and it is not [retry]: invalidating
  /// would discard every page the user has scrolled through and the cursor that
  /// continues them, to display one new row at the top. The Inbox is a recent
  /// history, so dropping the history to show its newest entry is the wrong
  /// trade.
  ///
  /// **A reply is adopted as a whole.** The fetched page's rows go in front in
  /// server order (no client sorting, **D4**), an id already present keeps its
  /// existing position, and the never-negated facts the page carries —
  /// `nextCursor`/`hasMore` — are preserved rather than replaced when the list
  /// already had a continuation point. Its cursor still names the position after
  /// the last row those pages fetched; adopting the new first page's cursor would
  /// make the next [loadMore] re-fetch rows this list already holds.
  ///
  /// **Never throws, and never reports.** A save the server confirmed is not
  /// turned into a failure by a listing read that did not arrive: the rows on
  /// screen stay exactly as they were, which is a visibly stale list until the
  /// user retries. That is a documented limitation, not an error state.
  ///
  /// **Concurrent callers are handled by [loadMore], not here.** A page may be in
  /// flight while this runs; [loadMore] re-reads the state when it completes, so
  /// neither operation discards the other's rows.
  Future<void> refreshHead() async {
    final loaded = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    if (loaded == null) {
      // Nothing is on screen, so there is nothing to preserve and no wrong
      // cursor to keep. Invalidating re-runs `build`, which fetches page one —
      // exactly the page this would have asked for — and that fetch happens
      // *after* the save, so it includes the new item.
      ref.invalidateSelf();
      return;
    }

    final SavedItemPage head;
    try {
      head = await ref.read(savedItemsRepositoryProvider).list();
    } catch (_) {
      // ApiFailure or anything else. See the doc comment: the list is left as it
      // is, and the confirmed save is not re-reported as a failure.
      return;
    }

    if (!ref.mounted) return;

    // Re-read rather than reuse `loaded`: a `loadMore` may have completed while
    // this request was in flight, and merging into that snapshot would drop its
    // rows. If the listing is no longer in a data state at all, a retry replaced
    // it — this page belongs to the list the user is no longer looking at.
    final latest = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (latest == null) return;

    state = AsyncData(
      latest.copyWith(
        items: _prepend(head.items, latest.items),
        // A list that had more to load keeps its own continuation point; one
        // that had none adopts the new page's, which is how a fully-loaded
        // history learns that a save has pushed it past a page boundary.
        nextCursor: latest.hasMore ? latest.nextCursor : head.nextCursor,
        hasMore: latest.hasMore || head.hasMore,
      ),
    );
  }

  /// Appends the next page.
  ///
  /// Does nothing when the listing has already ended, when a page is already in
  /// flight, or when nothing is loaded to append to — so a scroll notification
  /// arriving repeatedly cannot queue duplicate requests.
  ///
  /// **Stops on either signal.** The contract says `has_more` is false and
  /// `next_cursor` is explicitly null together on the final page; both are
  /// checked so a partial meta cannot start a request that cannot succeed.
  ///
  /// **A failed page keeps the rows already on screen.** The list is the user's
  /// history, and replacing it with an error because page three failed would
  /// throw away pages one and two. There is no second error channel for it: the
  /// user can retry the listing, which is the manual retry **D23** asks for.
  Future<void> loadMore() async {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    final cursor = current?.nextCursor;
    if (current == null || cursor == null || !current.hasMore) return;
    if (current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await ref
          .read(savedItemsRepositoryProvider)
          .list(cursor: cursor);

      // Re-read rather than merge into `current`: `refreshHead` may have
      // prepended newer rows while this page was in flight, and writing the
      // snapshot back would silently drop them. If the listing has left its data
      // state altogether, a retry replaced it, so this page belongs to a list the
      // user is no longer looking at.
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
        ),
      );
    } catch (_) {
      // ApiFailure or anything else. See the doc comment: the loaded rows stay,
      // and `isLoadingMore` is cleared so a later scroll can try again.
      final latest = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (latest == null) return;

      state = AsyncData(latest.copyWith(isLoadingMore: false));
    }
  }

  /// Prepends [incoming] — a newer first page — above [existing], in the order
  /// the server sent it, skipping any id already present.
  ///
  /// The counterpart of [_append] and needed for the same reason: a save that
  /// landed between two fetches can appear both in the refreshed first page and
  /// in an older page already on screen, and a duplicated row is a visible
  /// defect. A row already present keeps its existing position instead of moving
  /// to the head.
  static List<SavedItemSummary> _prepend(
    List<SavedItemSummary> incoming,
    List<SavedItemSummary> existing,
  ) {
    final seen = {for (final item in existing) item.id};
    final leading = <SavedItemSummary>[];

    for (final item in incoming) {
      if (seen.add(item.id)) leading.add(item);
    }

    return [...leading, ...existing];
  }

  /// Appends [incoming], skipping any id already present.
  ///
  /// The contract's ordering is stable, so a conforming page cannot repeat an
  /// id. This is not about that: it is about the case the cursor explicitly
  /// survives — an item saved again between two page fetches can appear in both,
  /// and a duplicated row is a visible defect.
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

  static SavedItemsState _toState(SavedItemPage page) => SavedItemsState(
    items: page.items,
    nextCursor: page.nextCursor,
    hasMore: page.hasMore,
  );
}
