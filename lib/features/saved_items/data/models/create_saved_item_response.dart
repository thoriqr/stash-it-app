import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_saved_item_response.freezed.dart';
part 'create_saved_item_response.g.dart';

/// `data.saved_item` of a successful `POST /saved-items`.
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
/// **Four fields, and no more.** The backend documents this as deliberately the
/// smallest useful representation rather than a shortened copy of the detail
/// response (`saved_item/response.go`): a save commits before enrichment runs, so
/// reporting `title`, `platform`, `description`, `image_url` or
/// `last_enriched_at` would present a set of nulls as though they had been looked
/// up. `domain` — the one column with a value at this point — is not reported
/// either.
///
/// **Consequences this client must honour.**
/// - It is **not** enough to build a `SavedItemSummary`, and nothing here tries.
///   The new row appears by re-reading the listing, not by synthesising one from
///   this response.
/// - `enrichment_status` is the stored value, which on a fresh save is always
///   `pending`; enrichment is queued by the time this arrives but has not run.
/// - All four are `required` so a missing one is a decode failure rather than a
///   silently invented value: the repository accepts a `201` only in this shape.
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

/// `data` of a successful `POST /saved-items`.
///
/// **Not nullable.** Every `201` carries the created item, and a null `data` is a
/// body this client cannot use rather than a successful save it can report — the
/// repository turns it into `ApiFailureUnreadableResponse` by decoding, not by
/// branching.
@freezed
abstract class CreateSavedItemDataResponse with _$CreateSavedItemDataResponse {
  const factory CreateSavedItemDataResponse({
    @JsonKey(name: 'saved_item') required CreatedSavedItemResponse savedItem,
  }) = _CreateSavedItemDataResponse;

  factory CreateSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemDataResponseFromJson(json);
}

/// The whole `201` body of `POST /saved-items`.
///
/// ```json
/// {
///   "data": { "saved_item": { ... } },
///   "message": "saved item created successfully"
/// }
/// ```
///
/// **No `meta`.** The route creates one item and has no page, so unlike the
/// listing there is nothing to paginate and no second structured field. `message`
/// is declared because it is sent, and is never rendered (**D22**).
@freezed
abstract class CreateSavedItemResponse with _$CreateSavedItemResponse {
  const factory CreateSavedItemResponse({
    required CreateSavedItemDataResponse data,
    String? message,
  }) = _CreateSavedItemResponse;

  factory CreateSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSavedItemResponseFromJson(json);
}
