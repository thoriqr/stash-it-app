import 'package:freezed_annotation/freezed_annotation.dart';

part 'listed_saved_item.freezed.dart';
part 'listed_saved_item.g.dart';

/// The collection associated with a saved item in the listing.
///
/// ```json
/// { "id": "...", "name": "Wishlist" }
/// ```
///
/// Contains only `id` and `name`. Collection type and system identifiers are
/// provided separately by `GET /collections`.
///
/// The collection is nested inside each item because `GET /saved-items` spans
/// multiple collections. Each row therefore identifies its own collection,
/// allowing the client to display collection information without making a
/// separate request for every item.
@freezed
abstract class SavedItemCollectionResponse with _$SavedItemCollectionResponse {
  const factory SavedItemCollectionResponse({
    required String id,
    required String name,
  }) = _SavedItemCollectionResponse;

  factory SavedItemCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$SavedItemCollectionResponseFromJson(json);
}

/// One row returned by `GET /saved-items`.
///
/// ```json
/// {
///   "id": "...", "url": "...", "domain": "...", "platform": "youtube",
///   "title": "...", "description": "...", "image_url": "...",
///   "note": "...", "price_amount": "24500000", "price_currency": "IDR",
///   "collection_id": "...", "enrichment_status": "completed",
///   "last_enriched_at": "...", "created_at": "...", "updated_at": "...",
///   "collection": { "id": "...", "name": "..." }
/// }
/// ```
///
/// Declares every documented response field, including fields not currently
/// used by the presentation layer, so changes to the API response remain
/// detectable.
///
/// `title`, `description`, `image_url`, `note`, `price_amount`,
/// `price_currency` and `last_enriched_at` are nullable. These fields may
/// legitimately be null even when `enrichment_status` is `completed`. For
/// example, a page may not expose a title without making enrichment
/// unsuccessful.
///
/// `price_amount` remains a string because the backend sends the numeric
/// amount as JSON text. Keeping the wire representation avoids losing decimal
/// precision before presentation formats it.
///
/// Fields with snake_case wire keys use [JsonKey] to ensure the generated
/// decoder reads the correct JSON keys.
@freezed
abstract class ListedSavedItemResponse with _$ListedSavedItemResponse {
  const factory ListedSavedItemResponse({
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
    required SavedItemCollectionResponse collection,
  }) = _ListedSavedItemResponse;

  factory ListedSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ListedSavedItemResponseFromJson(json);
}
