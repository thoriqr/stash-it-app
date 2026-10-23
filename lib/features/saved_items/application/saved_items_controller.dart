import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
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

/// What a failed manual pull-to-refresh says.
///
/// A refresh is a **read**: the rows already on screen remain valid, so the
/// notice must not suggest that an item was lost or was never saved.
/// [FeedbackTone.uncertain] is the tone for a request whose refreshed page did
/// not arrive — the client cannot claim the displayed list is current, but it
/// is not reporting a failed item.
///
/// Published only by [SavedItems.refresh]. An initial load, [SavedItems.retry],
/// [SavedItems.loadMore] and [SavedItems.refreshHead] all stay silent.
AppFeedback _refreshFailedFeedback() => AppFeedback(
  tone: FeedbackTone.uncertain,
  copy: "Couldn't refresh. Check your connection.",
);

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
/// keep Riverpod's default, and no global policy is changed. [SavedItems.retry]
/// remains the explicit recovery from a failed first load, and
/// [SavedItems.refresh] is the manual pull-to-refresh path; neither is automatic,
/// which is the manual retry **D23** asks for.
@Riverpod(keepAlive: true, retry: _neverRetry)
class SavedItems extends _$SavedItems {
  /// Identifies the list a page request belongs to.
  ///
  /// A manual refresh starts a new list. A load-more already in flight belongs
  /// to the old one and must be dropped rather than appended to the new rows or
  /// used to move the new cursor.
  int _listVersion = 0;

  /// The manual refresh currently in flight, shared by concurrent gestures.
  Future<void>? _refreshInFlight;

  /// Ids removed locally after a confirmed delete.
  ///
  /// A load-more or refresh already in flight when the delete completes can
  /// return the row after the local removal. These tombstones keep such a reply
  /// from resurrecting it. They are cleared only when a first page requested
  /// **after** every tombstone was added is adopted: at that point the server's
  /// page is authoritative and its cursor was issued after the delete too.
  final Set<String> _tombstones = {};

  /// Collection ids whose rows were removed locally after a confirmed
  /// collection delete.
  ///
  /// A page requested before that delete can return one of those rows after the
  /// in-place removal. Filtering by collection also covers rows the Inbox had
  /// not loaded yet, which a per-item tombstone cannot.
  final Set<String> _removedCollectionIds = {};

  /// Confirmed bulk moves, keyed by the collection the items left.
  ///
  /// A page requested before the move can still describe the old collection.
  /// Rewriting it on adoption keeps the chip truthful without replacing loaded
  /// pages or starting a fetch.
  final Map<String, _CollectionTarget> _relocatedCollections = {};

  /// Increments on every local reconciliation — a removed item, a removed
  /// collection, or a confirmed bulk move. A first-page request records this
  /// value and only clears the protections when it has not changed, which is how
  /// a reply that was already in flight cannot authorise clearing them.
  int _tombstoneVersion = 0;

  @override
  Future<SavedItemsState> build() async {
    // A rebuild is a new list too. Any page requested against the previous one
    // must not land in this one.
    _listVersion++;
    final tombstoneVersion = _tombstoneVersion;

    final page = await ref.watch(savedItemsRepositoryProvider).list();
    return _adoptFirstPage(page, requestedAtTombstoneVersion: tombstoneVersion);
  }

  /// Replaces the loaded history with a fresh first page.
  ///
  /// This is the pull-to-refresh path, distinct from [retry] and [refreshHead].
  /// The current rows stay on screen while the request is in flight — the
  /// `RefreshIndicator` is the only progress UI — and are replaced, together
  /// with the cursor, only when the new first page arrives. Replacing rather
  /// than merging is deliberate: the user asked for current server state, and
  /// keeping older pages would preserve rows and a continuation point that no
  /// longer match the refreshed head.
  ///
  /// Concurrent gestures share one request. A load-more already in flight is
  /// invalidated through [_listVersion], so its page cannot be appended to the
  /// refreshed list or advance its cursor.
  ///
  /// **Failure:** with rows on screen, they remain exactly as they were and the
  /// indicator retracts so the user can try again. With nothing on screen — an
  /// empty result or an earlier failure — the failure becomes the provider's
  /// error state, preserving the existing inline copy and Retry action. A failed
  /// gesture is also announced once through the app-wide feedback channel; see
  /// [_refreshFailedFeedback].
  Future<void> refresh() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final version = ++_listVersion;
    final tombstoneVersion = _tombstoneVersion;

    late final Future<void> future;
    future = _refresh(version, tombstoneVersion).whenComplete(() {
      if (identical(_refreshInFlight, future)) _refreshInFlight = null;
    });
    _refreshInFlight = future;

    // A load-more from the previous list can no longer be used. Stop showing
    // its row while the refresh owns the list.
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current != null && current.isLoadingMore) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }

    return future;
  }

  Future<void> _refresh(int version, int tombstoneVersion) async {
    try {
      final page = await ref.read(savedItemsRepositoryProvider).list();

      // A newer refresh or a rebuild owns the list now.
      if (!ref.mounted || version != _listVersion) return;

      state = AsyncData(
        _adoptFirstPage(page, requestedAtTombstoneVersion: tombstoneVersion),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || version != _listVersion) return;

      final current = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };

      // The list is a history, and a failed refresh does not make the rows
      // already on screen wrong. With nothing to keep, use the same AsyncError
      // the initial load uses so the existing error copy and Retry appear.
      if (current == null || current.items.isEmpty) {
        state = AsyncError(error, stackTrace);
      }

      // This is the one failure path that announces itself: the user explicitly
      // asked for fresh state and the request did not deliver it. `retry`,
      // `loadMore` and `refreshHead` deliberately stay silent. Publishing here,
      // after the version guard, means a stale response cannot raise a notice;
      // coalesced gestures share this one `_refresh` and therefore one notice.
      ref.read(feedbackProvider.notifier).show(_refreshFailedFeedback());
    }
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
  /// neither operation discards the other's rows. A manual [refresh] is
  /// different: it starts a new list, so if it begins while this is in flight,
  /// its refreshed head wins and this reply is dropped.
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

    final version = _listVersion;
    final SavedItemPage head;
    try {
      head = await ref.read(savedItemsRepositoryProvider).list();
    } catch (_) {
      // ApiFailure or anything else. See the doc comment: the list is left as it
      // is, and the confirmed save is not re-reported as a failure.
      return;
    }

    if (!ref.mounted || version != _listVersion) return;

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

  /// Rewrites one loaded row's collection in place, without changing its
  /// position or the list's continuation point.
  ///
  /// This is the Inbox half of a confirmed move. [refreshHead] cannot do it: it
  /// skips ids already present, so the moved row would keep its stale collection
  /// chip while a duplicate row was avoided. Replacing the whole list would throw
  /// away pages the user has loaded and the cursor that continues them.
  ///
  /// **Only fields the move changed are replaced.** The rest of the row comes
  /// from the read that produced it; a move neither enriches nor re-titles.
  /// Cursor, `hasMore` and `isLoadingMore` are preserved exactly.
  ///
  /// **No row is invented.** If the id is not among the loaded rows, this does
  /// nothing. Adding a row would move an item the Inbox has not fetched into a
  /// position the server did not give it.
  ///
  /// **Not a network operation and not announced.** The caller has already
  /// confirmed the move and publishes its own feedback; a stale or empty list is
  /// not an error here.
  void applyCollection({
    required String savedItemId,
    required String collectionId,
    required String collectionName,
  }) {
    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (current == null) return;

    var found = false;
    final items = <SavedItemSummary>[];
    for (final item in current.items) {
      if (item.id != savedItemId) {
        items.add(item);
        continue;
      }

      found = true;
      if (item.collectionId == collectionId &&
          item.collectionName == collectionName) {
        items.add(item);
      } else {
        items.add(
          item.copyWithCollection(
            collectionId: collectionId,
            collectionName: collectionName,
          ),
        );
      }
    }

    if (!found) return;

    // Freezed's equality makes this a no-op when the row already matched, so a
    // repeated "already in collection" success does not notify listeners.
    state = AsyncData(current.copyWith(items: items));
  }

  /// Replaces one loaded row's enrichment fields in place.
  ///
  /// This is the Inbox half of a confirmed re-read. [refreshHead] cannot do it:
  /// the row is already present, so a merge would skip it and leave stale
  /// metadata on screen. Replacing the whole list would throw away pages the user
  /// has loaded and the cursor that continues them.
  ///
  /// **Only the four fields a re-read can change are replaced**, through
  /// [SavedItemSummary.copyWithEnrichment]: title, description, preview URL and
  /// enrichment status. The collection, URL, saved-time label and position come
  /// from the read that produced the row. An explicit null in [result] clears an
  /// older value, exactly as the server's write does.
  ///
  /// **No row is invented.** If the id is not among the loaded rows, this does
  /// nothing: inserting one would place an item the Inbox has not fetched into a
  /// position the server did not give it. Cursor, `hasMore`, `isLoadingMore` and
  /// every tombstone are preserved untouched — enrichment changes no membership
  /// and ends no page.
  ///
  /// **Not a network operation and not announced.** The caller publishes the
  /// re-read's own feedback.
  void applyEnrichment(SavedItemEnrichmentResult result) {
    final current = _currentState;
    if (current == null) return;

    var found = false;
    final items = <SavedItemSummary>[];
    for (final item in current.items) {
      if (item.id != result.savedItemId) {
        items.add(item);
        continue;
      }

      found = true;
      items.add(
        item.copyWithEnrichment(
          title: result.title,
          description: result.description,
          imageUrl: result.imageUrl,
          enrichmentStatus: result.enrichmentStatus,
        ),
      );
    }

    if (!found) return;

    state = AsyncData(current.copyWith(items: items));
  }

  /// Removes one confirmed-deleted row in place.
  ///
  /// Cursor, `hasMore` and `isLoadingMore` are preserved: deleting one row does
  /// not change where the next page continues. The id is also tombstoned so a
  /// page already in flight cannot reinsert it. The caller has already confirmed
  /// the delete and publishes its own feedback; this is not a network operation
  /// and does not announce anything.
  void removeItem(String savedItemId) {
    _tombstones.add(savedItemId);
    _tombstoneVersion++;

    final current = _currentState;
    if (current == null) return;

    final items = current.items
        .where((item) => item.id != savedItemId)
        .toList(growable: false);
    if (items.length == current.items.length) return;

    state = AsyncData(current.copyWith(items: items));
  }

  /// Removes every loaded row that belongs to [collectionId].
  ///
  /// This is the Inbox half of a confirmed collection delete. Position, cursor,
  /// `hasMore` and `isLoadingMore` are preserved: removing a collection removes
  /// rows, not the listing's continuation point. The collection id is remembered
  /// so a page already in flight cannot put any of those rows back — including a
  /// row the Inbox had not loaded when the delete landed.
  ///
  /// **No network operation and not announced.** The caller has confirmed the
  /// delete and publishes its own feedback.
  void removeItemsInCollection(String collectionId) {
    final id = collectionId.trim();
    if (id.isEmpty) return;

    _removedCollectionIds.add(id);
    _tombstoneVersion++;

    final current = _currentState;
    if (current == null) return;

    final items = _reconcileAll(current.items);
    if (items.length == current.items.length) return;

    state = AsyncData(current.copyWith(items: items));
  }

  /// Rewrites every loaded row in [sourceCollectionId] to the destination of a
  /// confirmed bulk move.
  ///
  /// The items still exist and keep their position in the recent-history order:
  /// the backend preserves their original save time. Only the collection id and
  /// displayed name change, so title, description, enrichment state, preview
  /// flag and saved-time label stay exactly as the read produced them.
  ///
  /// The mapping is applied to pages already in flight as well, so a reply
  /// fetched before the move cannot restore the old chip.
  ///
  /// **No network operation and not announced.** The caller has confirmed the
  /// move and publishes its own feedback.
  void applyCollectionToItems({
    required String sourceCollectionId,
    required String targetCollectionId,
    required String targetCollectionName,
  }) {
    final source = sourceCollectionId.trim();
    final target = targetCollectionId.trim();
    if (source.isEmpty || target.isEmpty || source == target) return;

    _relocatedCollections[source] = _CollectionTarget(
      id: target,
      name: targetCollectionName,
    );
    _tombstoneVersion++;

    final current = _currentState;
    if (current == null) return;

    var changed = false;
    final items = <SavedItemSummary>[];
    for (final item in current.items) {
      final reconciled = _reconcile(item);
      if (reconciled == null) {
        changed = true;
        continue;
      }
      if (!identical(reconciled, item)) changed = true;
      items.add(reconciled);
    }
    if (!changed) return;

    state = AsyncData(current.copyWith(items: items));
  }

  /// Appends the next page.
  ///
  /// Does nothing when the listing has already ended, when a page is already in
  /// flight, when a manual refresh owns the list, or when nothing is loaded to
  /// append to — so a scroll notification arriving repeatedly cannot queue
  /// duplicate requests.
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
    if (_refreshInFlight != null) return;

    final current = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };

    final cursor = current?.nextCursor;
    if (current == null || cursor == null || !current.hasMore) return;
    if (current.isLoadingMore) return;

    final version = _listVersion;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await ref
          .read(savedItemsRepositoryProvider)
          .list(cursor: cursor);

      // A manual refresh started after this request: its first page replaced
      // the list and cursor this page was fetched against. Appending now would
      // mix two list generations and move a cursor that no longer applies.
      if (!ref.mounted || version != _listVersion) return;

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
      if (!ref.mounted || version != _listVersion) return;

      final latest = switch (state) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (latest == null) return;

      state = AsyncData(latest.copyWith(isLoadingMore: false));
    }
  }

  SavedItemsState? get _currentState => switch (state) {
    AsyncData(:final value) => value,
    _ => null,
  };

  /// Prepends [incoming] — a newer first page — above [existing], in the order
  /// the server sent it, skipping any id already present.
  ///
  /// The counterpart of [_append] and needed for the same reason: a save that
  /// landed between two fetches can appear both in the refreshed first page and
  /// in an older page already on screen, and a duplicated row is a visible
  /// defect. A row already present keeps its existing position instead of moving
  /// to the head. Locally reconciled rows — deleted ids, removed collections and
  /// confirmed bulk moves — are applied first: this merge is not a fresh first
  /// page and cannot authorise clearing those protections.
  List<SavedItemSummary> _prepend(
    List<SavedItemSummary> incoming,
    List<SavedItemSummary> existing,
  ) {
    final seen = {for (final item in existing) item.id};
    final leading = <SavedItemSummary>[];

    for (final item in incoming) {
      final reconciled = _reconcile(item);
      if (reconciled == null) continue;
      if (seen.add(reconciled.id)) leading.add(reconciled);
    }

    return [...leading, ...existing];
  }

  /// Appends [incoming], skipping any id already present or locally reconciled.
  ///
  /// The contract's ordering is stable, so a conforming page cannot repeat an
  /// id. This is not about that: it is about the case the cursor explicitly
  /// survives — an item saved again between two page fetches can appear in both,
  /// and a duplicated row is a visible defect. A page requested before a delete
  /// or a bulk move can also return a row this listing has already reconciled;
  /// the tombstones and relocation map keep the old version out.
  List<SavedItemSummary> _append(
    List<SavedItemSummary> existing,
    List<SavedItemSummary> incoming,
  ) {
    final seen = {for (final item in existing) item.id};
    final merged = List<SavedItemSummary>.of(existing);

    for (final item in incoming) {
      final reconciled = _reconcile(item);
      if (reconciled == null) continue;
      if (seen.add(reconciled.id)) merged.add(reconciled);
    }

    return merged;
  }

  /// Applies every local reconciliation to one row, or drops it.
  ///
  /// A move can be followed by a move of its destination, so the chain is
  /// followed rather than applied once. A collection removed anywhere along that
  /// chain wins: the row no longer belongs to a collection this client can show.
  SavedItemSummary? _reconcile(SavedItemSummary item) {
    if (_tombstones.contains(item.id)) return null;

    var current = item;
    final visited = <String>{};

    while (true) {
      if (_removedCollectionIds.contains(current.collectionId)) return null;
      if (!visited.add(current.collectionId)) return current;

      final target = _relocatedCollections[current.collectionId];
      if (target == null) return current;

      current = current.copyWithCollection(
        collectionId: target.id,
        collectionName: target.name,
      );
    }
  }

  List<SavedItemSummary> _reconcileAll(Iterable<SavedItemSummary> source) {
    final items = <SavedItemSummary>[];
    for (final item in source) {
      final reconciled = _reconcile(item);
      if (reconciled != null) items.add(reconciled);
    }
    return items;
  }

  /// Adopts a first page and, when it was requested after every local change,
  /// clears the protections.
  ///
  /// The page is reconciled against the state that exists **now**, before it is
  /// cleared. A first-page request that began before a delete or move recorded an
  /// older [_tombstoneVersion], so it cannot clear a protection that change
  /// added; its reply is filtered or rewritten and the protection remains for
  /// any page still in flight. Once a page requested after the change is
  /// adopted, its cursor was issued after it too, so later pages cannot contain
  /// the old version either.
  SavedItemsState _adoptFirstPage(
    SavedItemPage page, {
    required int requestedAtTombstoneVersion,
  }) {
    final next = _toState(page);
    if (requestedAtTombstoneVersion == _tombstoneVersion) {
      _tombstones.clear();
      _removedCollectionIds.clear();
      _relocatedCollections.clear();
    }
    return next;
  }

  SavedItemsState _toState(SavedItemPage page) => SavedItemsState(
    items: _reconcileAll(page.items),
    nextCursor: page.nextCursor,
    hasMore: page.hasMore,
  );
}

/// The stored id and name of a collection a confirmed bulk move selected.
class _CollectionTarget {
  const _CollectionTarget({required this.id, required this.name});

  final String id;
  final String name;
}
