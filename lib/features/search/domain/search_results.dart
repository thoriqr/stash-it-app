import 'package:flutter/foundation.dart';

import '../../saved_items/domain/saved_item_summary.dart';
import 'search_collection.dart';

/// Holds a successful `GET /search` response after mapping it to domain models.
///
/// Collections and saved items remain separate groups, each preserving the
/// order returned by the server. The client does not merge, interleave or
/// re-sort them. The presentation layer determines how the groups are
/// displayed, with collections rendered first.
@immutable
class SearchResults {
  const SearchResults({required this.collections, required this.savedItems});

  final List<SearchCollection> collections;

  final List<SavedItemSummary> savedItems;

  /// Whether both result groups are empty.
  ///
  /// An empty result is a successful search outcome, not a failure or evidence
  /// that an item was never saved.
  bool get isEmpty => collections.isEmpty && savedItems.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is SearchResults &&
      listEquals(other.collections, collections) &&
      listEquals(other.savedItems, savedItems);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(collections), Object.hashAll(savedItems));

  @override
  String toString() =>
      'SearchResults(${collections.length} collections, '
      '${savedItems.length} saved items)';
}
