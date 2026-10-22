import 'package:flutter/foundation.dart';

import 'saved_item_summary.dart';

/// One page of one collection's saved items, after the wire shape has been
/// mapped away.
///
/// **The collection travels with the page.** The name is only ever known from
/// `data.collection`, so it cannot be carried in the route and cannot be assumed
/// from the tile that opened the screen — a collection renamed since
/// `GET /collections` was read would then be displayed under its old name. Keeping
/// it here means the header is exactly what the server just said, on every page.
///
/// The rows are the same [SavedItemSummary] the Inbox and Search render, so the
/// row widget, the title fallback chain and the enrichment wording are shared
/// rather than re-implemented.
@immutable
class CollectionSavedItemsPage {
  const CollectionSavedItemsPage({
    required this.collectionId,
    required this.collectionName,
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  /// The collection these rows belong to, as the response reported it.
  final String collectionId;

  /// The collection's name, exactly as the server reported it.
  ///
  /// Names are free text (**D2**): nothing here trims, re-cases or compares it
  /// against `Unsorted` or any other display name.
  final String collectionName;

  /// The rows, in the order the API returned them.
  ///
  /// **Not re-sorted.** The contract fixes the order at `created_at DESC, id
  /// DESC` and offers no sort parameter, so sorting here would be a second
  /// ordering rule that could disagree with the server's (**D4**).
  final List<SavedItemSummary> items;

  /// The token for the following page, or null on the final page.
  ///
  /// **Opaque.** It is stored and handed back to the server unchanged, and is
  /// never parsed: its encoding is not part of the contract.
  final String? nextCursor;

  /// Whether another page exists.
  ///
  /// Read together with [nextCursor]; the listing stops when either says no. The
  /// contract ties `has_more: false` to a null `next_cursor`, so a page that has
  /// one without the other cannot be paginated and is reported as unreadable
  /// rather than silently treated as complete.
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
