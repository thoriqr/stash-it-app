import 'package:flutter/foundation.dart';

import 'saved_item_summary.dart';

/// One page of the Inbox listing, after the wire shape has been mapped away.
///
/// Holds the three things a caller needs and nothing else: the rows, whether
/// more exist, and the cursor that fetches them.
@immutable
class SavedItemPage {
  const SavedItemPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

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
  /// Read together with [nextCursor]; the listing stops when either says no.
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
