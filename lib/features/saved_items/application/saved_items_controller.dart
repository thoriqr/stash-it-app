import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import 'saved_items_state.dart';

part 'saved_items_controller.g.dart';

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
@Riverpod(keepAlive: true)
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
      final merged = _append(current.items, page.items);

      state = AsyncData(
        current.copyWith(
          items: merged,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // ApiFailure or anything else. See the doc comment: the loaded rows stay,
      // and `isLoadingMore` is cleared so a later scroll can try again.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
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
