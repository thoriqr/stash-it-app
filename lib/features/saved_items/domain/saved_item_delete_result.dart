import 'saved_item_summary.dart';

/// What a successful `DELETE /saved-items/{id}` established.
///
/// The route answers `200` only after the item row was deleted, so every value
/// here means **the item is gone**. The two cases differ in whether the reply
/// carried the collection flags that make the optional collection follow-up
/// possible.
sealed class SavedItemDeleteResult {
  const SavedItemDeleteResult();
}

/// The item was deleted and the reply reported the collection it left behind.
///
/// The flags are **advisory**, not authorization: another request may add an
/// item immediately after the count, and `collection_deletable` can be true for
/// a collection that has since been removed. The follow-up delete re-checks the
/// collection on the server.
final class SavedItemDeleted extends SavedItemDeleteResult {
  const SavedItemDeleted({
    required this.collectionId,
    required this.collectionEmpty,
    required this.collectionDeletable,
  });

  /// The collection the deleted item was in, as the server reported it.
  final String collectionId;

  /// Whether that collection held no other saved item once this one was gone.
  final bool collectionEmpty;

  /// Whether the server considers that collection deletable right now.
  ///
  /// The backend computes this as `collection_empty` **and** the collection not
  /// being Unsorted. It is a convenience, not a substitute for [collectionEmpty].
  final bool collectionDeletable;

  /// Whether the optional "collection is now empty" dialog may be offered.
  ///
  /// Every condition is required:
  ///
  /// - both server flags are true;
  /// - the response names a non-empty collection id;
  /// - that id is exactly the id the detail screen last read for this item; and
  /// - the item's collection name is non-empty after trimming, because it is part
  ///   of both dialog strings.
  ///
  /// **IDs are opaque strings in this client.** There is no UUID validator in the
  /// project, and adding one here would invent a rule the rest of the client does
  /// not apply. A non-empty id that equals the item's last-known id is the
  /// project's usable id.
  bool mayOfferCollectionDeletionFor(SavedItemSummary item) {
    return collectionDeletable &&
        collectionEmpty &&
        collectionId.trim().isNotEmpty &&
        collectionId == item.collectionId &&
        item.collectionName.trim().isNotEmpty;
  }
}

/// The item was deleted, but the reply's collection flags could not be read.
///
/// A `200` whose body does not match the documented shape still means the delete
/// committed. There is no collection id to name, so no follow-up is offered and
/// the screen reports only the item deletion.
final class SavedItemDeletionFlagsUnavailable extends SavedItemDeleteResult {
  const SavedItemDeletionFlagsUnavailable();
}
