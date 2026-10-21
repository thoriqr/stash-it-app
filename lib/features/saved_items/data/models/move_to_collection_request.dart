import 'package:freezed_annotation/freezed_annotation.dart';

part 'move_to_collection_request.freezed.dart';
part 'move_to_collection_request.g.dart';

/// Body of `PUT /saved-items/{id}/collection`.
///
/// ```json
/// { "collection_name": "Wishlist" }
/// ```
///
/// **A name, never an id.** The endpoint creates the collection when it does not
/// exist and reuses the existing user collection when it does, so the client
/// cannot be responsible for resolving an id first: doing so would race another
/// caller and would make "create and move" two requests instead of one atomic
/// call.
///
/// The field is exactly `collection_name`. A `collection_id` is not part of the
/// documented contract and is never sent. Values are trimmed and validated by the
/// caller; the server remains authoritative for both rules and for
/// case-insensitive uniqueness.
@freezed
abstract class MoveToCollectionRequest with _$MoveToCollectionRequest {
  const factory MoveToCollectionRequest({
    @JsonKey(name: 'collection_name') required String collectionName,
  }) = _MoveToCollectionRequest;

  factory MoveToCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$MoveToCollectionRequestFromJson(json);
}
