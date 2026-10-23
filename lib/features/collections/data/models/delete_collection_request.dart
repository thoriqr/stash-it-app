import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_collection_request.freezed.dart';
part 'delete_collection_request.g.dart';

/// The body of `DELETE /collections/{id}`.
///
/// The request states what happens to the collection's saved items; the route
/// deliberately does not default either field. This client sends both actions:
/// `delete` when the collection is known to be empty (and when the user chooses
/// to discard its items), and `move` with the destination the user picked. Both
/// fields are always present, matching the one contract the backend declares.
///
/// `target_collection_id` is explicitly `null` for `delete`. The backend treats a
/// target alongside `delete` as a contradiction
/// (`INVALID_COLLECTION_DELETE_TARGET`), so the key is included rather than
/// omitted: the request says, positively, that there is no target.
@freezed
abstract class DeleteCollectionRequest with _$DeleteCollectionRequest {
  const factory DeleteCollectionRequest({
    @JsonKey(name: 'saved_items_action') required String savedItemsAction,
    @JsonKey(name: 'target_collection_id', includeIfNull: true)
    required String? targetCollectionId,
  }) = _DeleteCollectionRequest;

  factory DeleteCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteCollectionRequestFromJson(json);
}
