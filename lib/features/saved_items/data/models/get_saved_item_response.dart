import 'package:freezed_annotation/freezed_annotation.dart';

import 'listed_saved_item.dart';

part 'get_saved_item_response.freezed.dart';
part 'get_saved_item_response.g.dart';

/// The `data.saved_item` payload returned by
/// `GET /saved-items/{id}` and `POST /saved-items/{id}/enrich`.
///
/// ```json
/// {
///   "id": "...", "url": "...", "domain": "...", "platform": "...",
///   "title": "...", "description": "...", "image_url": "...",
///   "note": "...", "price_amount": "24500000", "price_currency": "IDR",
///   "collection_id": "...", "enrichment_status": "completed",
///   "last_enriched_at": "...", "created_at": "...", "updated_at": "..."
/// }
/// ```
///
/// Declares every documented saved item field. This DTO is separate from
/// `ListedSavedItemResponse` because the detail response reports the collection
/// as a sibling of the item, while listing rows use a different response shape.
///
/// Both endpoints return the same saved item structure, so the enrichment
/// response reuses this DTO rather than declaring a duplicate.
///
/// `domain`, `platform`, `title`, `description`, `image_url`, `note`,
/// `price_amount`, `price_currency` and `last_enriched_at` are nullable. A
/// completed item may still have a null `title`; this does not necessarily
/// indicate an enrichment failure.
///
/// `price_amount` stays a string so its decimal precision is never reduced by a
/// floating-point conversion.
///
/// Fields with snake_case wire keys use [JsonKey] to ensure the generated
/// decoder reads the correct JSON keys.
@freezed
abstract class SavedItemDetailResponse with _$SavedItemDetailResponse {
  const factory SavedItemDetailResponse({
    required String id,
    required String url,
    String? domain,
    String? platform,
    String? title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? note,
    @JsonKey(name: 'price_amount') String? priceAmount,
    @JsonKey(name: 'price_currency') String? priceCurrency,
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'enrichment_status') required String enrichmentStatus,
    @JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _SavedItemDetailResponse;

  factory SavedItemDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$SavedItemDetailResponseFromJson(json);
}

/// The `data` payload of a successful `GET /saved-items/{id}` response.
///
/// The saved item and its collection are returned as sibling objects, not as a
/// nested collection inside the item. `saved_item.collection_id` matches
/// `collection.id`.
///
/// Reuses [SavedItemCollectionResponse] for the collection's `{id, name}`
/// shape. Collection type and system identifiers are provided separately by
/// `GET /collections`.
///
/// Both objects are required. A missing or null value does not represent a
/// successful response this client can use.
@freezed
abstract class GetSavedItemDataResponse with _$GetSavedItemDataResponse {
  const factory GetSavedItemDataResponse({
    @JsonKey(name: 'saved_item') required SavedItemDetailResponse savedItem,
    required SavedItemCollectionResponse collection,
  }) = _GetSavedItemDataResponse;

  factory GetSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSavedItemDataResponseFromJson(json);
}

/// The complete `200` response body of `GET /saved-items/{id}`.
///
/// ```json
/// {
///   "data": { "saved_item": { ... }, "collection": { "id": "...", "name": "..." } },
///   "message": "saved item retrieved successfully"
/// }
/// ```
///
/// This response has no pagination metadata because it contains a single item.
/// `message` is included in the response contract but is not used for
/// presentation.
@freezed
abstract class GetSavedItemResponse with _$GetSavedItemResponse {
  const factory GetSavedItemResponse({
    required GetSavedItemDataResponse data,
    String? message,
  }) = _GetSavedItemResponse;

  factory GetSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSavedItemResponseFromJson(json);
}
