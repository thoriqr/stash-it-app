import 'package:freezed_annotation/freezed_annotation.dart';

part 'listed_collection.freezed.dart';
part 'listed_collection.g.dart';

/// A collection returned in the user's collection list.
///
/// Includes `system_key` to identify system collections such as Unsorted,
/// along with saved-item counts and collection timestamps.
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

/// The `data` object containing the collection list.
@freezed
abstract class ListCollectionsDataResponse with _$ListCollectionsDataResponse {
  const factory ListCollectionsDataResponse({
    required List<ListedCollectionResponse> collections,
  }) = _ListCollectionsDataResponse;

  factory ListCollectionsDataResponse.fromJson(Map<String, dynamic> json) =>
      _$ListCollectionsDataResponseFromJson(json);
}

/// Cursor pagination metadata.
///
/// `has_more` indicates whether another page is available, and `next_cursor`
/// provides the cursor for requesting it.
@freezed
abstract class CursorPageMetaResponse with _$CursorPageMetaResponse {
  const factory CursorPageMetaResponse({
    @JsonKey(name: 'has_more') required bool hasMore,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _CursorPageMetaResponse;

  factory CursorPageMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$CursorPageMetaResponseFromJson(json);
}

/// Pagination metadata for the collection list response.
@freezed
abstract class ListCollectionsMetaResponse with _$ListCollectionsMetaResponse {
  const factory ListCollectionsMetaResponse({
    required CursorPageMetaResponse cursor,
  }) = _ListCollectionsMetaResponse;

  factory ListCollectionsMetaResponse.fromJson(Map<String, dynamic> json) =>
      _$ListCollectionsMetaResponseFromJson(json);
}

/// Response envelope for `GET /collections`.
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
