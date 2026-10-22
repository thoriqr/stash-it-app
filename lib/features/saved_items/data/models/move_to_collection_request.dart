import 'package:freezed_annotation/freezed_annotation.dart';

part 'move_to_collection_request.freezed.dart';
part 'move_to_collection_request.g.dart';

/// Body of `PUT /saved-items/{id}/collection`.
///
/// ```json
/// { "collection_name": "Wishlist", "collection_intent": "existing" }
/// ```
///
/// **A name, never an id.** The endpoint resolves the name to a collection, so
/// the client cannot be responsible for resolving an id first: doing so would
/// race another caller and would make "create and move" two requests instead of
/// one atomic call.
///
/// **`collection_intent` is required and is exactly `existing` or `create`.**
/// The value is mapped from `MoveToCollectionIntent` by the repository; this DTO
/// holds the already-mapped string because it is a wire model. The backend does
/// not default it: the same taken name is a destination under `existing` and a
/// conflict under `create`.
///
/// The fields are exactly `collection_name` and `collection_intent`. A
/// `collection_id` is not part of the documented contract and is never sent.
/// Values are trimmed and validated by the caller; the server remains
/// authoritative for both rules and for case-insensitive uniqueness.
@freezed
abstract class MoveToCollectionRequest with _$MoveToCollectionRequest {
  const factory MoveToCollectionRequest({
    @JsonKey(name: 'collection_name') required String collectionName,
    @JsonKey(name: 'collection_intent') required String collectionIntent,
  }) = _MoveToCollectionRequest;

  factory MoveToCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$MoveToCollectionRequestFromJson(json);
}
