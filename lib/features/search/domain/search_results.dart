import 'package:flutter/foundation.dart';

import '../../saved_items/domain/saved_item_summary.dart';
import 'search_collection.dart';

/// One successful `GET /search` answer, after the wire shape has been mapped
/// away.
///
/// **Two independent groups, each in the order the server sent it.** Collections
/// and saved items are never merged, interleaved or re-sorted: the backend ranks
/// each array by relevance, and a second ordering rule here could disagree with
/// it (**D4**). The presentation decides that Collections render first.
@immutable
class SearchResults {
  const SearchResults({required this.collections, required this.savedItems});

  final List<SearchCollection> collections;

  final List<SavedItemSummary> savedItems;

  /// Whether the successful answer matched nothing in either group.
  ///
  /// This is a **successful empty result**, not a failure and not evidence that
  /// anything was never saved.
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
