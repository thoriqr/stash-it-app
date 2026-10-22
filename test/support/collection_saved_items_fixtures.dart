import 'saved_items_fixtures.dart';

/// Fixtures for the documented `GET /collections/{id}/saved-items` contract.
///
/// One place that knows the wire shape, so a test asserting on behaviour does not
/// restate the envelope. The item is built from [SavedItemsFixtures.item] and then
/// has the nested `collection` removed, exactly as the backend reports it here —
/// the collection is a sibling of the rows, not a field inside each one.
class CollectionSavedItemsFixtures {
  const CollectionSavedItemsFixtures._();

  /// One row: the twelve documented fields and **no nested `collection`**.
  static Map<String, dynamic> item({
    String id = 'item-1',
    String collectionId = 'collection-1',
    String url = 'https://example.com/articles/crdts-explained',
    String? domain = 'example.com',
    String? platform = 'web',
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    String enrichmentStatus = 'completed',
    String? lastEnrichedAt = '2026-10-02T10:31:00Z',
    String createdAt = '2026-10-02T10:30:00Z',
    String updatedAt = '2026-10-02T10:31:00Z',
  }) =>
      SavedItemsFixtures.item(
          id: id,
          url: url,
          domain: domain,
          platform: platform,
          title: title,
          description: description,
          imageUrl: imageUrl,
          collectionId: collectionId,
          enrichmentStatus: enrichmentStatus,
          lastEnrichedAt: lastEnrichedAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        )
        // The Inbox listing nests this in every row because it spans
        // collections. Here the collection is reported once, beside the rows.
        ..remove('collection');

  /// The whole `200` body.
  ///
  /// **The collection is present even when there are no rows**: an empty
  /// collection is an ordinary state that still has a name to show, so the header
  /// never has to fall back on a name from an earlier read.
  static Map<String, dynamic> page({
    List<Map<String, dynamic>> items = const [],
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
    String? nextCursor,
    bool hasMore = false,
  }) => {
    'data': {
      'collection': {'id': collectionId, 'name': collectionName},
      'saved_items': items,
    },
    'message': 'saved items retrieved successfully',
    'meta': {
      'cursor': {'has_more': hasMore, 'next_cursor': nextCursor},
    },
  };

  /// An empty final page — what a collection with nothing in it receives.
  static Map<String, dynamic> emptyPage({
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
  }) => page(collectionId: collectionId, collectionName: collectionName);
}
