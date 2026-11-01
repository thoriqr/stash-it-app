import 'package:freezed_annotation/freezed_annotation.dart';

import 'list_saved_items_response.dart';

part 'collection_saved_items_response.freezed.dart';
part 'collection_saved_items_response.g.dart';

/// The collection associated with a page of saved items.
///
/// Contains only `id` and `name`. The collection ID is already known from the
/// request path, while the name is needed by the client for display. Collection
/// type and counts are provided separately by `GET /collections`.
@freezed
abstract class ListedSavedItemsCollectionResponse
    with _$ListedSavedItemsCollectionResponse {
  const factory ListedSavedItemsCollectionResponse({
    required String id,
    required String name,
  }) = _ListedSavedItemsCollectionResponse;

  factory ListedSavedItemsCollectionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ListedSavedItemsCollectionResponseFromJson(json);
}

/// One item returned by `GET /collections/{id}/saved-items`.
///
/// This DTO is separate from [ListedSavedItemResponse] because the collection
/// listing reports its collection once in `data.collection`. Each item contains
/// only `collection_id`, unlike Inbox items, which include a nested collection.
///
/// All documented response fields are declared, including fields not currently
/// used by the presentation layer, so changes to the API response remain
/// detectable.
///
/// `domain`, `platform`, `title`, `description`, `image_url` and
/// `last_enriched_at` are nullable fields. In particular, a completed item may
/// legitimately have a null `title`; this does not indicate an enrichment
/// failure.
///
/// Each field whose wire key uses snake_case declares its corresponding
/// [JsonKey] so the generated decoder reads the correct JSON key.
@freezed
abstract class CollectionSavedItemResponse with _$CollectionSavedItemResponse {
  const factory CollectionSavedItemResponse({
    required String id,
    required String url,
    String? domain,
    String? platform,
    String? title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'enrichment_status') required String enrichmentStatus,
    @JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _CollectionSavedItemResponse;

  factory CollectionSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$CollectionSavedItemResponseFromJson(json);
}

/// The `data` payload of a successful
/// `GET /collections/{id}/saved-items` response.
///
/// The collection is included even when it contains no saved items, so the
/// client can still display its name in the empty state.
///
/// Both `collection` and `saved_items` are required. An empty collection is
/// represented by an empty `saved_items` list, not a missing or null value.
@freezed
abstract class ListCollectionSavedItemsDataResponse
    with _$ListCollectionSavedItemsDataResponse {
  const factory ListCollectionSavedItemsDataResponse({
    required ListedSavedItemsCollectionResponse collection,
    @JsonKey(name: 'saved_items')
    required List<CollectionSavedItemResponse> savedItems,
  }) = _ListCollectionSavedItemsDataResponse;

  factory ListCollectionSavedItemsDataResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ListCollectionSavedItemsDataResponseFromJson(json);
}

/// The complete `200` response from
/// `GET /collections/{id}/saved-items`.
///
/// Reuses [ListSavedItemsMetaResponse] for cursor pagination, keeping the
/// continuation metadata consistent with the Inbox listing.
///
/// `next_cursor` is null when `has_more` is false and on an empty page.
@freezed
abstract class ListCollectionSavedItemsResponse
    with _$ListCollectionSavedItemsResponse {
  const factory ListCollectionSavedItemsResponse({
    required ListCollectionSavedItemsDataResponse data,
    String? message,
    ListSavedItemsMetaResponse? meta,
  }) = _ListCollectionSavedItemsResponse;

  factory ListCollectionSavedItemsResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ListCollectionSavedItemsResponseFromJson(json);
}
