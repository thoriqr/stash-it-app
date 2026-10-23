import 'package:freezed_annotation/freezed_annotation.dart';

import 'get_saved_item_response.dart';

part 'enrich_saved_item_response.freezed.dart';
part 'enrich_saved_item_response.g.dart';

/// `data` of a successful `POST /saved-items/{id}/enrich`.
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
/// **`saved_item` is the same twelve-field object the detail route reports**, and
/// this DTO reuses [SavedItemDetailResponse] for it rather than declaring a second
/// copy of the same keys. The Go struct is field-for-field identical, so a second
/// DTO could only drift from the first.
///
/// **The item has no nested `collection` and the data has no sibling one.** The
/// enrich route never changes collection membership, so it does not resolve the
/// collection name; the detail screen keeps the name it already read. A DTO that
/// expected a collection here would reject the verified body.
@freezed
abstract class EnrichSavedItemDataResponse with _$EnrichSavedItemDataResponse {
  const factory EnrichSavedItemDataResponse({
    @JsonKey(name: 'saved_item') required SavedItemDetailResponse savedItem,
  }) = _EnrichSavedItemDataResponse;

  factory EnrichSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$EnrichSavedItemDataResponseFromJson(json);
}

/// The whole `200` body of `POST /saved-items/{id}/enrich`.
///
/// ```json
/// {
///   "data": { "saved_item": { ... } },
///   "message": "saved item enriched successfully"
/// }
/// ```
///
/// **A `200` is the response whether extraction succeeded or failed.** The
/// endpoint is synchronous: it fetches and extracts the page inline, records the
/// outcome, and reports the item as it now stands. A page that could not be read
/// arrives as `enrichment_status: failed` in this body, not as an HTTP error —
/// only the item being missing (`404 SAVED_ITEM_NOT_FOUND`) and a refused
/// request are non-2xx.
///
/// **No `meta`.** There is one item and nothing to paginate. `message` is
/// declared because it is sent, and is never rendered (**D22**).
@freezed
abstract class EnrichSavedItemResponse with _$EnrichSavedItemResponse {
  const factory EnrichSavedItemResponse({
    required EnrichSavedItemDataResponse data,
    String? message,
  }) = _EnrichSavedItemResponse;

  factory EnrichSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$EnrichSavedItemResponseFromJson(json);
}
