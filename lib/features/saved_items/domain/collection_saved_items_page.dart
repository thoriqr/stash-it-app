import 'package:flutter/foundation.dart';

import 'saved_item_summary.dart';

/// One page of saved items from a collection, mapped to domain models.
///
/// The collection ID and name are carried alongside the page. The name comes
/// from `data.collection` in the response, rather than the route or the tile
/// that opened the screen. This ensures the header reflects the latest name,
/// including changes made after the collection list was loaded.
///
/// Each row uses [SavedItemSummary], which is also used by Inbox and Search.
/// This keeps the row presentation, title fallback and enrichment status
/// consistent across features.
@immutable
class CollectionSavedItemsPage {
  const CollectionSavedItemsPage({
    required this.collectionId,
    required this.collectionName,
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  /// The ID of the collection containing these items.
  final String collectionId;

  /// The collection name as reported by the latest response.
  ///
  /// Names are free text. This value is preserved without trimming,
  /// changing its casing or interpreting it based on its display name.
  final String collectionName;

  /// The items in the order returned by the API.
  ///
  /// The server defines the ordering as `created_at DESC, id DESC` and does
  /// not expose a sort parameter, so the client preserves the returned order.
  final List<SavedItemSummary> items;

  /// The opaque token for the next page, or null when there is no next page.
  ///
  /// The token is passed back to the server unchanged and is never parsed
  /// by the client.
  final String? nextCursor;

  /// Whether another page is available.
  ///
  /// Used together with [nextCursor]. The API returns a null `next_cursor`
  /// when `has_more` is false. Inconsistent pagination metadata is treated
  /// as an unreadable response rather than as a completed listing.
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      other is CollectionSavedItemsPage &&
      other.collectionId == collectionId &&
      other.collectionName == collectionName &&
      other.hasMore == hasMore &&
      other.nextCursor == nextCursor &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(
    collectionId,
    collectionName,
    Object.hashAll(items),
    nextCursor,
    hasMore,
  );

  @override
  String toString() =>
      'CollectionSavedItemsPage($collectionName, ${items.length} items, '
      'hasMore: $hasMore)';
}
