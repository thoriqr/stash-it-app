import 'package:freezed_annotation/freezed_annotation.dart';

part 'listed_collection.freezed.dart';
part 'listed_collection.g.dart';

/// The collection as it appears in the user's collection list.
///
/// Matches backend `ListedCollectionResponse` exactly: includes `system_key`
/// so Unsorted can be identified (D2). Also includes count fields.
@freezed
abstract class ListedCollectionResponse with _$ListedCollectionResponse {
  const factory ListedCollectionResponse({
    required String id,
    required String name,
    required String type,
    @JsonKey(name: 'system_key') String? systemKey,
    @JsonKey(name: 'saved_items_count') required int savedItemsCount,
    @JsonKey(name: 'saved_items_count_overflow')
    required bool savedItemsCountOverflow,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _ListedCollectionResponse;

  factory ListedCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$ListedCollectionResponseFromJson(json);
}

/// `data.collections` wrapper.
@freezed
abstract class ListCollectionsDataResponse with _$ListCollectionsDataResponse {
  const factory ListCollectionsDataResponse({
    required List<ListedCollectionResponse> collections,
  }) = _ListCollectionsDataResponse;

  factory ListCollectionsDataResponse.fromJson(Map<String, dynamic> json) =>
      _$ListCollectionsDataResponseFromJson(json);
}

/// `meta.cursor` for GET /collections.
@freezed
abstract class CursorPageMetaResponse with _$CursorPageMetaResponse {
  const factory CursorPageMetaResponse({
    @JsonKey(name: 'has_more') required bool hasMore,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _CursorPageMetaResponse;

  factory CursorPageMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$CursorPageMetaResponseFromJson(json);
}

/// `meta` for GET /collections.
@freezed
abstract class ListCollectionsMetaResponse with _$ListCollectionsMetaResponse {
  const factory ListCollectionsMetaResponse({
    required CursorPageMetaResponse cursor,
  }) = _ListCollectionsMetaResponse;

  factory ListCollectionsMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$ListCollectionsMetaResponseFromJson(json);
}

/// Full envelope for GET /collections.
@freezed
abstract class ListCollectionsResponse with _$ListCollectionsResponse {
  const factory ListCollectionsResponse({
    required ListCollectionsDataResponse data,
    String? message,
    ListCollectionsMetaResponse? meta,
  }) = _ListCollectionsResponse;

  factory ListCollectionsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListCollectionsResponseFromJson(json);
}
