import 'package:freezed_annotation/freezed_annotation.dart';

import 'list_saved_items_response.dart';

part 'collection_saved_items_response.freezed.dart';
part 'collection_saved_items_response.g.dart';

/// The collection a page of saved items was read from.
///
/// ```json
/// { "id": "...", "name": "Wishlist" }
/// ```
///
/// **Only `id` and `name`.** The backend's
/// `ListedSavedItemsCollectionResponse` is deliberately the narrowest collection
/// shape it has: the caller already arrived knowing the id, so the one thing it
/// cannot know from the path is the name. `type`, `system_key` and the counts
/// belong to `GET /collections`, and **D2** forbids deciding which collection is
/// the system one from a display name — so nothing here may be used for that.
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

/// One row of `GET /collections/{id}/saved-items` — the backend's
/// `ListedSavedItemResponse`.
///
/// ```json
/// {
///   "id": "...", "url": "...", "domain": "...", "platform": "youtube",
///   "title": "...", "description": "...", "image_url": "...",
///   "collection_id": "...", "enrichment_status": "completed",
///   "last_enriched_at": "...", "created_at": "...", "updated_at": "..."
/// }
/// ```
///
/// **A second type, and not a reuse of [ListedSavedItemResponse].** The Inbox
/// listing nests a `collection` object in every row because it spans collections;
/// this listing names the collection once, in `data.collection`, and the row has
/// only `collection_id`. Declaring that field optional on the Inbox DTO would make
/// a required part of *that* contract look optional and turn a real contract
/// change into a silent difference, so the two shapes stay separate.
///
/// **Every documented field is declared**, including the ones presentation does
/// not read. A DTO that dropped documented keys would make a contract change
/// invisible until something needed the field.
///
/// **[D21] The nullable six stay nullable.** `domain`, `platform`, `title`,
/// `description`, `image_url` and `last_enriched_at` are reported as an explicit
/// `null` on a key that is always present. `title: null` on a `completed` item is
/// **[D17]** confirmed and ordinary — it is not a fault, and nothing here fills it
/// in.
///
/// **Every field names its wire key.** The backend's JSON is snake_case; without
/// `@JsonKey` the generated decoder looks for camelCase and fails at runtime as a
/// `TypeError`, which surfaces as an unreadable response rather than a decode bug.
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

/// `data` of a successful `GET /collections/{id}/saved-items`.
///
/// **The collection is reported on every response, including an empty one.** The
/// backend states this explicitly: an empty collection is an ordinary state and
/// still has a name worth showing, so a client never has to distinguish "no
/// items" from "no collection" to decide what to render.
///
/// **Not nullable, and the list is never `null`.** An empty collection answers
/// `"saved_items": []`, so a missing `data` or a null list is a shape this client
/// does not understand rather than an empty result.
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

/// The whole `200` body of `GET /collections/{id}/saved-items`.
///
/// ```json
/// {
///   "data": {
///     "collection": { "id": "...", "name": "Wishlist" },
///     "saved_items": [ ... ]
///   },
///   "message": "saved items retrieved successfully",
///   "meta": { "cursor": { "has_more": true, "next_cursor": "eyJ2Ijox..." } }
/// }
/// ```
///
/// `meta` reuses [ListSavedItemsMetaResponse] rather than restating the cursor
/// shape: both listings are cursor-paginated the same way, and two hand-written
/// copies of `{has_more, next_cursor}` would be one more thing to keep in step.
///
/// **`next_cursor` is the only continuation signal.** It is explicitly `null`
/// whenever `has_more` is false, and always on an empty page.
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
