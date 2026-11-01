import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_saved_item_response.freezed.dart';
part 'create_saved_item_response.g.dart';

/// The `data.saved_item` payload of a successful `POST /saved-items`.
///
/// ```json
/// {
///   "id": "01a0f359-...",
///   "url": "https://example.com/articles/1",
///   "collection_id": "01a0f359-...",
///   "enrichment_status": "pending"
/// }
/// ```
///
/// Contains exactly four fields. This is a minimal representation of the
/// created item, not a shortened detail response. The item is saved before
/// enrichment runs, so metadata such as `title`, `platform`, `description`,
/// `image_url` and `last_enriched_at` is not included. `domain` is also omitted.
///
/// The client must not use this response to construct a `SavedItemSummary`.
/// It should re-read the listing to obtain the item in its normal listing shape.
///
/// A newly created item has an `enrichment_status` of `pending`. Enrichment
/// has been queued but has not completed when this response is returned.
///
/// All four fields are required. A missing field makes the response unreadable
/// to this client rather than allowing it to infer a value.
@freezed
abstract class CreatedSavedItemResponse with _$CreatedSavedItemResponse {
  const factory CreatedSavedItemResponse({
    required String id,
    required String url,
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'enrichment_status') required String enrichmentStatus,
  }) = _CreatedSavedItemResponse;

  factory CreatedSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatedSavedItemResponseFromJson(json);
}

/// The `data` payload of a successful `POST /saved-items` response.
///
/// `saved_item` is required. A missing or null value does not represent a
/// successful response the client can use.
@freezed
abstract class CreateSavedItemDataResponse with _$CreateSavedItemDataResponse {
  const factory CreateSavedItemDataResponse({
    @JsonKey(name: 'saved_item') required CreatedSavedItemResponse savedItem,
  }) = _CreateSavedItemDataResponse;

  factory CreateSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemDataResponseFromJson(json);
}

/// The complete `201` response body of `POST /saved-items`.
///
/// ```json
/// {
///   "data": { "saved_item": { ... } },
///   "message": "saved item created successfully"
/// }
/// ```
///
/// This response has no pagination metadata. `message` is included in the
/// response contract but is not used for presentation.
@freezed
abstract class CreateSavedItemResponse with _$CreateSavedItemResponse {
  const factory CreateSavedItemResponse({
    required CreateSavedItemDataResponse data,
    String? message,
  }) = _CreateSavedItemResponse;

  factory CreateSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemResponseFromJson(json);
}
