import 'saved_item_summary.dart';

/// Describes what a successful `DELETE /saved-items/{id}` response establishes.
///
/// A successful response confirms that the item was deleted. The result
/// distinguishes whether the response also provided the collection flags
/// needed to determine whether a follow-up collection deletion can be offered.
sealed class SavedItemDeleteResult {
  const SavedItemDeleteResult();
}

/// The item was deleted, and the response includes its collection flags.
///
/// These flags are advisory, not authorization. The collection may change
/// after the response is generated, so the server must re-check its current
/// state when a collection deletion is requested.
final class SavedItemDeleted extends SavedItemDeleteResult {
  const SavedItemDeleted({
    required this.collectionId,
    required this.collectionEmpty,
    required this.collectionDeletable,
  });

  /// The ID of the collection that contained the deleted item.
  final String collectionId;

  /// Whether the collection contained no other saved items after deletion.
  final bool collectionEmpty;

  /// Whether the server considers the collection deletable at response time.
  ///
  /// This is a convenience flag derived from the collection's empty state
  /// and whether it is the Unsorted collection. It does not replace
  /// [collectionEmpty].
  final bool collectionDeletable;

  /// Whether the optional collection deletion dialog may be offered.
  ///
  /// All of the following conditions must be met:
  ///
  /// - Both server-provided flags are true.
  /// - The response contains a non-empty collection ID.
  /// - The collection ID matches the item's last-known collection ID.
  /// - The item's collection name is non-empty after trimming, because it is
  ///   used in the dialog text.
  ///
  /// Collection IDs are treated as opaque strings. The client checks that
  /// the ID is non-empty and matches the item's collection ID without
  /// imposing an additional format requirement.
  bool mayOfferCollectionDeletionFor(SavedItemSummary item) {
    return collectionDeletable &&
        collectionEmpty &&
        collectionId.trim().isNotEmpty &&
        collectionId == item.collectionId &&
        item.collectionName.trim().isNotEmpty;
  }
}

/// The item was deleted, but the response's collection flags were unavailable.
///
/// A successful response with an unreadable body still confirms the item
/// deletion. Without the collection ID and flags, the client cannot offer
/// a follow-up collection deletion.
final class SavedItemDeletionFlagsUnavailable extends SavedItemDeleteResult {
  const SavedItemDeletionFlagsUnavailable();
}
