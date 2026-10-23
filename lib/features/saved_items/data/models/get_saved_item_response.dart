import 'package:freezed_annotation/freezed_annotation.dart';

import 'listed_saved_item.dart';

part 'get_saved_item_response.freezed.dart';
part 'get_saved_item_response.g.dart';

/// `data.saved_item` of a successful `GET /saved-items/{id}`, and of a successful
/// `POST /saved-items/{id}/enrich`.
///
/// ```json
/// {
///   "id": "...", "url": "...", "domain": "...", "platform": "...",
///   "title": "...", "description": "...", "image_url": "...",
///   "collection_id": "...", "enrichment_status": "completed",
///   "last_enriched_at": "...", "created_at": "...", "updated_at": "..."
/// }
/// ```
///
/// **The complete saved item, and the same twelve fields the listing declares.**
/// It is a separate DTO rather than a reuse of `ListedSavedItemResponse` because
/// the collection is not inside it here: the detail endpoint reports the item and
/// its collection as siblings, while the listing puts the collection inside each
/// row because that listing spans every collection. Sharing one type would force
/// one of the two shapes to carry a field it cannot always fill.
///
/// **Both routes carry this identical object.** The Go `SavedItemResponse` of the
/// enrich endpoint is field-for-field the same struct the detail endpoint returns,
/// so the enrich envelope reuses this type (see `enrich_saved_item_response.dart`)
/// rather than declaring a second copy that could drift. Neither route nests a
/// collection: only the detail response adds one, as a sibling of this object.
///
/// **Every documented field is declared**, including the ones presentation does
/// not read (`domain`, `platform`, `last_enriched_at`, `updated_at`). A DTO that
/// silently dropped documented keys would make a contract change invisible.
///
/// **[D21] The nullable six stay nullable.** `domain`, `platform`, `title`,
/// `description`, `image_url` and `last_enriched_at` are reported as an explicit
/// `null` on a key that is always present. `completed` does not imply metadata
/// was found (D17), so a null title is an ordinary state.
///
/// **Every field names its wire key.** The backend's JSON is snake_case; without
/// `@JsonKey` the generated decoder looks for camelCase and fails at runtime as a
/// `TypeError`, which surfaces as an unreadable response rather than a decode bug.
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
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'enrichment_status') required String enrichmentStatus,
    @JsonKey(name: 'last_enriched_at') String? lastEnrichedAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _SavedItemDetailResponse;

  factory SavedItemDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$SavedItemDetailResponseFromJson(json);
}

/// `data` of a successful `GET /saved-items/{id}`.
///
/// The item and the collection it is filed in arrive as **siblings**, not as a
/// nested object. `saved_item.collection_id` always equals `collection.id`.
///
/// The collection reuses [SavedItemCollectionResponse] because its schema is
/// exactly the same `{id, name}` object the listing reports. `type` and
/// `system_key` belong to `GET /collections`; **D2** forbids resolving Unsorted
/// by display name, and nothing here tries to.
///
/// **Not nullable.** A successful response always carries both objects, and a
/// missing `data` is a shape this client cannot use — the repository turns it
/// into `ApiFailureUnreadableResponse` by failing to decode, not by branching.
@freezed
abstract class GetSavedItemDataResponse with _$GetSavedItemDataResponse {
  const factory GetSavedItemDataResponse({
    @JsonKey(name: 'saved_item') required SavedItemDetailResponse savedItem,
    required SavedItemCollectionResponse collection,
  }) = _GetSavedItemDataResponse;

  factory GetSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSavedItemDataResponseFromJson(json);
}

/// The whole `200` body of `GET /saved-items/{id}`.
///
/// ```json
/// {
///   "data": { "saved_item": { ... }, "collection": { "id": "...", "name": "..." } },
///   "message": "saved item retrieved successfully"
/// }
/// ```
///
/// **No `meta`.** The route reads one item and has no page, so unlike the
/// listing there is nothing to paginate and no second structured field. `message`
/// is declared because it is sent, and is never rendered (**D22**).
@freezed
abstract class GetSavedItemResponse with _$GetSavedItemResponse {
  const factory GetSavedItemResponse({
    required GetSavedItemDataResponse data,
    String? message,
  }) = _GetSavedItemResponse;

  factory GetSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSavedItemResponseFromJson(json);
}
