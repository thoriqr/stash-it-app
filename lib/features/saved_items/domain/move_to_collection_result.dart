import 'package:flutter/foundation.dart';

/// What the server confirmed about one move.
///
/// A domain result, not the wire envelope: the response's saved-item fields are
/// not carried because they omit detail-only fields and cannot rebuild the
/// existing presentation model. The three facts here are the ones a caller acts
/// on — where the item ended up, whether that collection was created, and whether
/// the request was a no-op because it was already there.
@immutable
class MoveToCollectionResult {
  const MoveToCollectionResult({
    required this.collectionId,
    required this.collectionName,
    required this.collectionCreated,
    required this.alreadyInCollection,
  });

  /// The id of the collection the server reports the item is in now.
  final String collectionId;

  /// The **stored** display name, with the server's casing and trimming.
  ///
  /// Confirmation copy uses this value, never the name the user typed: a
  /// case-insensitive match must still report the collection's real name.
  final String collectionName;

  /// Whether this call created the collection.
  final bool collectionCreated;

  /// Whether the item was already in the target collection.
  ///
  /// Mutually exclusive with [collectionCreated]. True means the server wrote
  /// nothing, which is why the client does not need to refresh state after it.
  final bool alreadyInCollection;

  @override
  bool operator ==(Object other) =>
      other is MoveToCollectionResult &&
      other.collectionId == collectionId &&
      other.collectionName == collectionName &&
      other.collectionCreated == collectionCreated &&
      other.alreadyInCollection == alreadyInCollection;

  @override
  int get hashCode => Object.hash(
    collectionId,
    collectionName,
    collectionCreated,
    alreadyInCollection,
  );
}
