import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/collection_summary.dart';

part 'collections_state.freezed.dart';

/// Loaded state for collections list.
@freezed
abstract class CollectionsState with _$CollectionsState {
  const factory CollectionsState({
    required List<CollectionSummary> items,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
    @Default('newest') String sort,
  }) = _CollectionsState;
}
