import 'package:flutter/foundation.dart';

import 'saved_item_summary.dart';

/// One page of the Inbox listing, mapped to domain models.
///
/// Contains the items, whether another page is available, and the cursor
/// used to request the next page.
@immutable
class SavedItemPage {
  const SavedItemPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

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
  /// Used together with [nextCursor] to determine whether pagination can
  /// continue.
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      other is SavedItemPage &&
      other.hasMore == hasMore &&
      other.nextCursor == nextCursor &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(Object.hashAll(items), nextCursor, hasMore);

  @override
  String toString() =>
      'SavedItemPage(${items.length} items, hasMore: $hasMore)';
}
