import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'saved_items_state.freezed.dart';

/// What the Inbox has loaded: the rows so far, and where the next page is.
///
/// **Its own file, deliberately.** Freezed's and Riverpod's builders cannot both
/// own one library's `part` file, and separating a value type from the notifier
/// that produces it is clearer than fighting over the generated name.
///
/// Freezed for **value equality**: a provider compares with `==` to decide
/// whether to notify, so a state rebuilt from the same page would otherwise look
/// new on every rebuild and re-render the list for no reason (`AGENTS.md` §4).
///
/// **No `fromJson`.** This type never crosses a serialization boundary — it is
/// built from an already-decoded page — so a generated decoder would be an
/// unused factory over a type with no wire form. That is the same reasoning that
/// keeps `ApiFailure` hand-written. Dropping it also removes the `*.g.dart`
/// part, which is what lets this file be Freezed at all.
@freezed
abstract class SavedItemsState with _$SavedItemsState {
  const factory SavedItemsState({
    required List<SavedItemSummary> items,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _SavedItemsState;
}
