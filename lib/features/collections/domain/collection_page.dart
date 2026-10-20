import 'package:flutter/foundation.dart';

import 'collection_summary.dart';

/// One page of collections listing.
@immutable
class CollectionPage {
  const CollectionPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<CollectionSummary> items;
  final String? nextCursor;
  final bool hasMore;

  @override
  bool operator ==(Object other) =>
      other is CollectionPage &&
      other.hasMore == hasMore &&
      other.nextCursor == nextCursor &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(Object.hashAll(items), nextCursor, hasMore);

  @override
  String toString() =>
      'CollectionPage(${items.length} items, hasMore: $hasMore)';
}
