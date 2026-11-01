import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_collection_request.freezed.dart';
part 'delete_collection_request.g.dart';

/// Request body for deleting a collection.
///
/// Both fields are required. `saved_items_action` specifies how saved items
/// are handled, while `target_collection_id` identifies the destination when
/// the action is `move`.
///
/// For `delete`, `target_collection_id` must be explicitly `null`, not omitted.
/// This keeps the request unambiguous and prevents a contradictory target.
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
