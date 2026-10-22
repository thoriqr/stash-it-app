import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'collection_saved_items_state.freezed.dart';

/// What one collection's detail screen has loaded: the collection the response
/// named, the rows so far, and where the next page is.
///
/// **The collection name is part of the state, not a constructor argument.** It
/// only ever arrives with a page, so putting it here makes it impossible for the
/// screen to render a header it did not just read — and impossible for the page
/// and its header to come from two different requests.
///
/// Freezed for **value equality**: a provider compares with `==` to decide
/// whether to notify, so a state rebuilt from the same page would otherwise look
/// new on every rebuild and re-render the list for no reason (`AGENTS.md` §4).
///
/// **No `fromJson`.** This type never crosses a serialization boundary — it is
/// built from an already-decoded page — so a generated decoder would be an unused
/// factory over a type with no wire form.
@freezed
abstract class CollectionSavedItemsState with _$CollectionSavedItemsState {
  const factory CollectionSavedItemsState({
    required String collectionId,
    required String collectionName,
    required List<SavedItemSummary> items,
    String? nextCursor,
    @Default(false) bool hasMore,

    /// A page is in flight, so the footer says so and no second page is started.
    @Default(false) bool isLoadingMore,

    /// The last page request failed and **has not been retried by the user**.
    ///
    /// It is a separate flag from `isLoadingMore` because it has to *block* the
    /// scroll listener. Clearing the loading flag alone — which is what the other
    /// listings in this app do — lets the next scroll notification ask for the
    /// same cursor again, and a screen that keeps failing becomes a scroll-driven
    /// retry loop. **[D23]** asks for manual retry, so the footer's Retry is the
    /// only thing that may resume paging.
    @Default(false) bool loadMoreFailed,
  }) = _CollectionSavedItemsState;
}
