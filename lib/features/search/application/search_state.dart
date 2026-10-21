import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../domain/search_collection.dart';

part 'search_state.freezed.dart';

/// The Search screen's complete state.
///
/// A closed set rather than an `AsyncValue`, because Search has a genuine
/// **initial** state before any query exists. `AsyncValue` has no way to say
/// "nothing has been asked yet" that is distinct from a successful empty result,
/// and those two must never be confused: an initial screen cannot claim there
/// were no matches, and a zero-result answer must not look like a screen that
/// has not searched.
///
/// **No `fromJson`.** This type never crosses a serialization boundary, so a
/// generated decoder would be unused. That also leaves the file to Freezed
/// alone, which is what lets it use one generated `part`.
@freezed
sealed class SearchState with _$SearchState {
  /// Before the first valid submission. **No request has been made.**
  const factory SearchState.initial() = SearchInitial;

  /// A valid query is in flight. [query] is the trimmed query that was sent.
  const factory SearchState.loading({required String query}) = SearchLoading;

  /// A completed request. [query] is the trimmed query that produced these
  /// results, not whatever the field currently holds.
  ///
  /// Both lists are in the order the server sent them and may both be empty, in
  /// which case this is a **successful zero-result answer**.
  const factory SearchState.success({
    required String query,
    required List<SearchCollection> collections,
    required List<SavedItemSummary> savedItems,
  }) = SearchSuccess;

  /// A completed request that failed. [failure] is a typed `ApiFailure` (or an
  /// unexpected error), never a backend message.
  ///
  /// [query] is retained so Retry resubmits the query that actually failed and
  /// the screen can keep copy associated with it.
  const factory SearchState.failure({
    required String query,
    required Object failure,
  }) = SearchFailure;
}
