import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'saved_items_state.freezed.dart';

/// Represents the saved items currently loaded by the Inbox, including
/// pagination state.
///
/// Freezed provides value equality, allowing providers to detect whether the
/// state has actually changed before notifying listeners.
///
/// No `fromJson` is needed because this state is built from an already-decoded
/// API response and is not serialized independently.
@freezed
abstract class SavedItemsState with _$SavedItemsState {
  const factory SavedItemsState({
    required List<SavedItemSummary> items,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _SavedItemsState;
}
