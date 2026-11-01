import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'collection_saved_items_state.freezed.dart';

/// Represents the collection detail data currently loaded by the screen:
/// collection identity, loaded items, and pagination state.
///
/// [collectionName] is stored alongside the items because both come from the
/// same page response. This keeps the header and list consistent with the
/// collection data most recently received.
///
/// Freezed provides value equality, allowing providers to detect whether the
/// state has actually changed before notifying listeners.
///
/// No `fromJson` is needed because this state is built from an already-decoded
/// API response and is not serialized independently.
@freezed
abstract class CollectionSavedItemsState with _$CollectionSavedItemsState {
  const factory CollectionSavedItemsState({
    required String collectionId,
    required String collectionName,
    required List<SavedItemSummary> items,
    String? nextCursor,
    @Default(false) bool hasMore,

    /// A page request is in progress. The footer shows its loading state.
    @Default(false) bool isLoadingMore,

    /// The last page request failed and the user has not manually retried it.
    ///
    /// Kept separate from [isLoadingMore] so the scroll listener can stop
    /// requesting the same cursor after a failure. Further pagination resumes
    /// only when the user explicitly selects Retry.
    @Default(false) bool loadMoreFailed,
  }) = _CollectionSavedItemsState;
}
