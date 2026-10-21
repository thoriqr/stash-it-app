import '../domain/move_to_collection_result.dart';
import 'models/move_to_collection_response.dart';

/// Maps the move response envelope into the three facts callers act on.
///
/// **Decoded from `data.collection` and the two booleans, not from the saved
/// item.** The response's saved-item object deliberately omits detail-only fields
/// and cannot rebuild a `SavedItemSummary`; treating it as one would either fail
/// or fabricate nulls. The collection name reported here is the server's stored
/// value, including its casing, and is what confirmation copy must use.
///
/// The response has no `meta`. Nothing here reads the envelope's `message`:
/// backend prose is never displayed (**D22**).
MoveToCollectionResult moveToCollectionResultFrom(
  MoveToCollectionResponse response,
) {
  final data = response.data;

  return MoveToCollectionResult(
    collectionId: data.collection.id,
    collectionName: data.collection.name,
    collectionCreated: data.collectionCreated,
    alreadyInCollection: data.alreadyInCollection,
  );
}
