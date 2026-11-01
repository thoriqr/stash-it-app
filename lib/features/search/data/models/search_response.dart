import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_response.freezed.dart';
part 'search_response.g.dart';

/// The collection associated with a saved item in a `GET /search` response.
///
/// Contains only `id` and `name`. This nested object identifies where the
/// saved item belongs without requiring another request. It is narrower than
/// the collection listing model: type, system key, counts and timestamps are
/// not included and must not be inferred.
@freezed
abstract class SearchSavedItemCollectionResponse
    with _$SearchSavedItemCollectionResponse {
  const factory SearchSavedItemCollectionResponse({
    required String id,
    required String name,
  }) = _SearchSavedItemCollectionResponse;

  factory SearchSavedItemCollectionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$SearchSavedItemCollectionResponseFromJson(json);
}

/// One saved item returned by `GET /search`.
///
/// Declares only the fields supplied by this endpoint. It does not include
/// description, platform, last enrichment time, update time, a top-level
/// collection ID or a relevance score.
///
/// `title`, `domain` and `image_url` are nullable. A null value is a valid
/// response state; for example, a completed item may have no title. The client
/// does not derive replacement values from the URL.
///
/// Each field whose JSON key uses snake_case declares its wire name explicitly
/// so the generated decoder reads the correct key.
@freezed
abstract class SearchSavedItemResponse with _$SearchSavedItemResponse {
  const factory SearchSavedItemResponse({
    required String id,
    String? title,
    required String url,
    String? domain,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'enrichment_status') required String enrichmentStatus,
    required SearchSavedItemCollectionResponse collection,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _SearchSavedItemResponse;

  factory SearchSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchSavedItemResponseFromJson(json);
}

/// One collection returned by `GET /search`.
///
/// Contains only `id` and `name`. Search returns a collection as a possible
/// destination, not as a full collection record. Counts, type, system
/// identity and timestamps are not available, so this DTO is intentionally
/// separate from `CollectionSummary`.
@freezed
abstract class SearchCollectionResponse with _$SearchCollectionResponse {
  const factory SearchCollectionResponse({
    required String id,
    required String name,
  }) = _SearchCollectionResponse;

  factory SearchCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchCollectionResponseFromJson(json);
}

/// The `data` object in a successful `GET /search` response.
///
/// Both arrays are required and non-null. A search with no matches is still a
/// successful response containing two empty arrays. If either array is
/// missing or null, the response does not match the expected contract.
///
/// Each array is returned in server-defined relevance order, with the best
/// matches first. The client does not re-sort, merge or interleave the arrays.
@freezed
abstract class SearchDataResponse with _$SearchDataResponse {
  const factory SearchDataResponse({
    @JsonKey(name: 'saved_items')
    required List<SearchSavedItemResponse> savedItems,
    required List<SearchCollectionResponse> collections,
  }) = _SearchDataResponse;

  factory SearchDataResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchDataResponseFromJson(json);
}

/// The complete `200` response body of `GET /search`.
///
/// The response contains `data` and an optional `message`. There is no `meta`
/// object because search is capped rather than paginated. The response
/// provides no cursor, total count or truncation indicator, so the client
/// cannot determine whether additional matches exist beyond the returned
/// results.
@freezed
abstract class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required SearchDataResponse data,
    String? message,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}
