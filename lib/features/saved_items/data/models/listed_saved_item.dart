import 'package:freezed_annotation/freezed_annotation.dart';

part 'listed_saved_item.freezed.dart';
part 'listed_saved_item.g.dart';

/// The collection an item is filed in, as the listing reports it.
///
/// ```json
/// { "id": "...", "name": "Wishlist" }
/// ```
///
/// **Only `id` and `name`.** `type` and `system_key` belong to
/// `GET /collections`, and **D2** forbids this client resolving "Unsorted" by
/// display name — so nothing here may be used to decide which collection is the
/// system one.
///
/// The object is inside the item rather than beside the page because the listing
/// spans every collection the caller owns: there is no single collection for the
/// response to name, so each row has to name its own, and a client never has to
/// make a request per row to learn where an item lives.
@freezed
abstract class SavedItemCollectionResponse with _$SavedItemCollectionResponse {
  const factory SavedItemCollectionResponse({
    required String id,
    required String name,
  }) = _SavedItemCollectionResponse;

  factory SavedItemCollectionResponse.fromJson(Map<String, dynamic> json) =>
      _$SavedItemCollectionResponseFromJson(json);
}

/// One row of `GET /saved-items` — the backend's `ListedSavedItemResponse`.
///
/// ```json
/// {
///   "id": "...", "url": "...", "domain": "...", "platform": "youtube",
///   "title": "...", "description": "...", "image_url": "...",
///   "collection_id": "...", "enrichment_status": "completed",
///   "last_enriched_at": "...", "created_at": "...", "updated_at": "...",
///   "collection": { "id": "...", "name": "..." }
/// }
/// ```
///
/// **Every documented field is declared**, including the ones presentation does
/// not read yet (`domain`, `platform`, `last_enriched_at`, `created_at`,
/// `updated_at`). A DTO that silently dropped documented keys would make a
/// contract change invisible until something needed the field.
///
/// **[D21] The nullable four stay nullable.** `title`, `description`,
/// `image_url` and `last_enriched_at` are reported as an explicit `null` on a key
/// that is always present, and a `null` is an ordinary state — an item whose page
/// exposed no title is `completed` with a `null` title, which is **[D17]**
/// confirmed and must not be rendered as a fault.
///
/// **Every field names its wire key.** The backend's JSON is snake_case; without
/// `@JsonKey` the generated decoder looks for camelCase and fails at runtime as a
/// `TypeError`, which surfaces as an unreadable response rather than a decode bug.
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
