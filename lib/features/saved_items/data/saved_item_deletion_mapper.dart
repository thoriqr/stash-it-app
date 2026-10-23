import '../domain/saved_item_delete_result.dart';
import 'models/delete_saved_item_response.dart';

/// Maps the decoded delete envelope to the presentation-independent result.
///
/// The mapper exists for the same reason as the other saved-item mappers: the
/// wire DTO stays at the data boundary, and the controller never imports a
/// generated response type.
SavedItemDeleteResult savedItemDeleteResultFrom(
  DeleteSavedItemResponse response,
) {
  final data = response.data;
  return SavedItemDeleted(
    collectionId: data.collectionId,
    collectionEmpty: data.collectionEmpty,
    collectionDeletable: data.collectionDeletable,
  );
}
