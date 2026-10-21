import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_response.freezed.dart';
part 'search_response.g.dart';

/// The collection an item is filed in, as `GET /search` reports it.
///
/// ```json
/// { "id": "...", "name": "Wishlist" }
/// ```
///
/// **Only `id` and `name`.** Search's saved-item shape carries this nested
/// object so a result can say where it lives without a second request. It is
/// deliberately narrower than the collection listing: `type`, `system_key`,
/// counts and timestamps are absent, so none of them may be inferred here.
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

/// One saved item in a `GET /search` response.
///
/// ```json
/// {
///   "id": "...", "title": "...", "url": "...", "domain": "...",
///   "image_url": "...", "enrichment_status": "completed",
///   "collection": { "id": "...", "name": "..." },
///   "created_at": "..."
/// }
/// ```
///
/// **Every documented field is declared, and nothing else.** Search does not
/// return `description`, `platform`, `last_enriched_at`, `updated_at`, a
/// top-level `collection_id` or a relevance score, so this DTO has no property
/// for any of them. A presentation layer cannot accidentally display a value
/// the endpoint never sent.
///
/// **[D21] The nullable three stay nullable.** `title`, `domain` and `image_url`
/// are reported as an explicit `null` on a key that is always present, and a
/// `null` is an ordinary state — a `completed` item with no title is normal, not
/// a fault. No value is derived from the URL in their place.
///
/// **Every field names its wire key.** The backend's JSON is snake_case;
/// without `@JsonKey` the generated decoder looks for camelCase and fails at
/// runtime as a `TypeError`, which surfaces as an unreadable response.
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

/// One collection in a `GET /search` response.
///
/// **Only `id` and `name`.** A collection result is a destination, not a record
/// of one, so counts, type, system identity and timestamps are all absent. This
/// is intentionally not `CollectionSummary`: that model requires fields Search
/// does not return, and reusing it would force this feature to invent them.
@freezed
abstract class SearchCollectionResponse with _$SearchCollectionResponse {
  const factory SearchCollectionResponse({
    required String id,
    required String name,
  }) = _SearchCollectionResponse;

  factory SearchCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchCollectionResponseFromJson(json);
}

/// `data` of a successful `GET /search`.
///
/// **Both arrays are always present.** A search that matched nothing is a
/// successful response with two empty arrays, never a `404` and never `null`.
/// Neither `data` nor either array is nullable, so a response that omits one is
/// a shape this client does not understand rather than an empty result.
///
/// **Order is the server's.** Each array arrives best match first. Nothing here
/// re-sorts, merges or interleaves them.
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

/// The whole `200` body of `GET /search`.
///
/// ```json
/// {
///   "data": { "saved_items": [ ... ], "collections": [ ... ] },
///   "message": "search completed successfully"
/// }
/// ```
///
/// **No `meta`.** Search is capped rather than paged: there is no cursor, no
/// total count and no truncation flag. The client therefore cannot know whether
/// a capped group has more matches, and must not claim that it does.
@freezed
abstract class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required SearchDataResponse data,
    String? message,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}
