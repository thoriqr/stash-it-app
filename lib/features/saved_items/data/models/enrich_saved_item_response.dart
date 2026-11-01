import 'package:freezed_annotation/freezed_annotation.dart';

import 'get_saved_item_response.dart';

part 'enrich_saved_item_response.freezed.dart';
part 'enrich_saved_item_response.g.dart';

/// The `data` payload of a successful `POST /saved-items/{id}/enrich` response.
///
/// ```json
/// {
///   "saved_item": {
///     "id": "...", "url": "...", "domain": "...", "platform": "...",
///     "title": "...", "description": "...", "image_url": "...",
///     "collection_id": "...", "enrichment_status": "completed",
///     "last_enriched_at": "...", "created_at": "...", "updated_at": "..."
///   }
/// }
/// ```
///
/// Reuses [SavedItemDetailResponse] because the enriched item has the same
/// response fields as the saved item detail endpoint.
///
/// No collection object is included. Enrichment does not change collection
/// membership, so the client retains the collection information it already has.
@freezed
abstract class EnrichSavedItemDataResponse with _$EnrichSavedItemDataResponse {
  const factory EnrichSavedItemDataResponse({
    @JsonKey(name: 'saved_item') required SavedItemDetailResponse savedItem,
  }) = _EnrichSavedItemDataResponse;

  factory EnrichSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$EnrichSavedItemDataResponseFromJson(json);
}

/// The complete `200` response body of `POST /saved-items/{id}/enrich`.
///
/// ```json
/// {
///   "data": { "saved_item": { ... } },
///   "message": "saved item enriched successfully"
/// }
/// ```
///
/// A `200` response indicates that the enrichment request was processed, not
/// necessarily that extraction succeeded. If the page could not be read or
/// extracted, the item is still returned with `enrichment_status: failed`.
///
/// A missing item returns `404 SAVED_ITEM_NOT_FOUND`. Other rejected requests
/// also return non-2xx responses.
///
/// This response has no pagination metadata. `message` is included in the
/// response contract but is not used for presentation.
@freezed
abstract class EnrichSavedItemResponse with _$EnrichSavedItemResponse {
  const factory EnrichSavedItemResponse({
    required EnrichSavedItemDataResponse data,
    String? message,
  }) = _EnrichSavedItemResponse;

  factory EnrichSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$EnrichSavedItemResponseFromJson(json);
}
