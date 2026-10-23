import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_saved_item_response.freezed.dart';
part 'delete_saved_item_response.g.dart';

/// `data` of a successful `DELETE /saved-items/{id}`.
///
/// ```json
/// {
///   "collection_id": "...",
///   "collection_empty": true,
///   "collection_deletable": true
/// }
/// ```
///
/// **The three fields are directly inside `data`**, not nested under a
/// `saved_item` object. They report what the delete left behind in the collection
/// the item was in; they do not delete that collection.
///
/// All three are non-nullable on the wire. A response missing one is not a
/// partial success this client can act on: the item delete may still have
/// committed, so the repository reports the deletion without collection flags
/// rather than inventing `false` values.
@freezed
abstract class DeleteSavedItemDataResponse with _$DeleteSavedItemDataResponse {
  const factory DeleteSavedItemDataResponse({
    @JsonKey(name: 'collection_id') required String collectionId,
    @JsonKey(name: 'collection_empty') required bool collectionEmpty,
    @JsonKey(name: 'collection_deletable') required bool collectionDeletable,
  }) = _DeleteSavedItemDataResponse;

  factory DeleteSavedItemDataResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSavedItemDataResponseFromJson(json);
}

/// The whole `200` body of `DELETE /saved-items/{id}`.
///
/// There is no `meta`: a delete has nothing to paginate. The response shape is
/// deliberately not `Future<void>` because the flags are the input to the
/// optional follow-up collection deletion.
@freezed
abstract class DeleteSavedItemResponse with _$DeleteSavedItemResponse {
  const factory DeleteSavedItemResponse({
    required DeleteSavedItemDataResponse data,
    String? message,
  }) = _DeleteSavedItemResponse;

  factory DeleteSavedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSavedItemResponseFromJson(json);
}
