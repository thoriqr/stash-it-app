import 'package:freezed_annotation/freezed_annotation.dart';

part 'move_to_collection_response.freezed.dart';
part 'move_to_collection_response.g.dart';

/// `data.collection` of a successful `PUT /saved-items/{id}/collection`.
///
/// ```json
/// {
///   "id": "...", "name": "Wishlist", "type": "user",
///   "created_at": "...", "updated_at": "..."
/// }
/// ```
///
/// **No `system_key`.** This endpoint only ever files an item into a user
/// collection, so exposing the field would imply a system collection could be
/// targeted here. The client must not infer anything from [name] either; it is
/// the stored display name, reported so confirmation copy can use it.
@freezed
abstract class MoveToCollectionCollectionResponse
    with _$MoveToCollectionCollectionResponse {
  const factory MoveToCollectionCollectionResponse({
    required String id,
    required String name,
    required String type,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _MoveToCollectionCollectionResponse;

  factory MoveToCollectionCollectionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$MoveToCollectionCollectionResponseFromJson(json);
}

/// `data.saved_item` of a successful move.
///
/// ```json
/// {
///   "id": "...", "url": "...", "domain": "...", "platform": "...",
///   "title": "...", "collection_id": "...", "created_at": "...",
///   "updated_at": "..."
/// }
/// ```
///
/// **Not the full detail object.** The move operation neither reads nor writes
/// enrichment, so `description`, `image_url`, `enrichment_status` and
/// `last_enriched_at` are deliberately absent. Decoding this as
/// `SavedItemDetailResponse` or `SavedItemSummary` would therefore fail or invent
/// fields. The response exists so a contract change is visible at the boundary;
/// the client uses [collectionId] only as a fallback when a fresh detail read is
/// unavailable.
@freezed
abstract class MoveToCollectionSavedItemResponse
    with _$MoveToCollectionSavedItemResponse {
  const factory MoveToCollectionSavedItemResponse({
    required String id,
    required String url,
    String? domain,
    String? platform,
    String? title,
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _MoveToCollectionSavedItemResponse;

  factory MoveToCollectionSavedItemResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$MoveToCollectionSavedItemResponseFromJson(json);
}

/// `data` of a successful `PUT /saved-items/{id}/collection`.
///
/// [collectionCreated] and [alreadyInCollection] are mutually exclusive. The
/// backend reports a no-op repeat call through [alreadyInCollection] rather than
/// as a conflict, and leaves the item's `updated_at` unchanged.
@freezed
abstract class MoveToCollectionDataResponse
    with _$MoveToCollectionDataResponse {
  const factory MoveToCollectionDataResponse({
    required MoveToCollectionCollectionResponse collection,
    @JsonKey(name: 'saved_item')
    required MoveToCollectionSavedItemResponse savedItem,
    @JsonKey(name: 'collection_created') required bool collectionCreated,
    @JsonKey(name: 'already_in_collection') required bool alreadyInCollection,
  }) = _MoveToCollectionDataResponse;

  factory MoveToCollectionDataResponse.fromJson(Map<String, dynamic> json) =>
      _$MoveToCollectionDataResponseFromJson(json);
}

/// The whole `200` body of `PUT /saved-items/{id}/collection`.
///
/// ```json
/// {
///   "data": {
///     "collection": { ... },
///     "saved_item": { ... },
///     "collection_created": true,
///     "already_in_collection": false
///   },
///   "message": "saved item moved into collection successfully"
/// }
/// ```
///
/// **No `meta`.** The endpoint performs one write and has no page, so there is
/// nothing to paginate. `message` is declared because it is sent, and is never
/// rendered (**D22**).
@freezed
abstract class MoveToCollectionResponse with _$MoveToCollectionResponse {
  const factory MoveToCollectionResponse({
    required MoveToCollectionDataResponse data,
    String? message,
  }) = _MoveToCollectionResponse;

  factory MoveToCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$MoveToCollectionResponseFromJson(json);
}
