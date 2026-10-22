import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/collection_saved_items_response.dart';

import '../../../../support/collection_saved_items_fixtures.dart';

/// Decoding of the documented `GET /collections/{id}/saved-items` contract.
///
/// The wire keys are snake_case, so a missing `@JsonKey` would look for camelCase
/// and fail at runtime rather than at compile time. These pin the mapping against
/// the exact shape the backend documents — including the row shape, which
/// deliberately has **no** nested `collection`.
void main() {
  group('CollectionSavedItemResponse', () {
    test('decodes a fully-populated row', () {
      final item = CollectionSavedItemResponse.fromJson(
        CollectionSavedItemsFixtures.item(),
      );

      expect(item.id, 'item-1');
      expect(item.url, 'https://example.com/articles/crdts-explained');
      expect(item.domain, 'example.com');
      expect(item.platform, 'web');
      expect(item.title, 'Understanding CRDTs');
      expect(item.description, 'Conflict-free replicated data types converge.');
      expect(item.imageUrl, 'https://example.com/og.png');
      expect(item.collectionId, 'collection-1');
      expect(item.enrichmentStatus, 'completed');
      expect(item.lastEnrichedAt, '2026-10-02T10:31:00Z');
      expect(item.createdAt, '2026-10-02T10:30:00Z');
      expect(item.updatedAt, '2026-10-02T10:31:00Z');
    });

    test('keeps every nullable field null when the server sends null', () {
      // The contract: these are reported as an explicit `null` on a key that is
      // always present. A `completed` item whose page exposed nothing is ordinary
      // — [D17] — so nullability is a state, not a fault.
      final item = CollectionSavedItemResponse.fromJson(
        CollectionSavedItemsFixtures.item(
          domain: null,
          platform: null,
          title: null,
          description: null,
          imageUrl: null,
          lastEnrichedAt: null,
        ),
      );

      expect(item.domain, isNull);
      expect(item.platform, isNull);
      expect(item.title, isNull);
      expect(item.description, isNull);
      expect(item.imageUrl, isNull);
      expect(item.lastEnrichedAt, isNull);

      // Only the values are absent; the rest of the row is intact.
      expect(item.enrichmentStatus, 'completed');
      expect(item.collectionId, 'collection-1');
    });
  });

  group('ListCollectionSavedItemsResponse', () {
    test('decodes the collection once, beside the rows', () {
      final response = ListCollectionSavedItemsResponse.fromJson(
        CollectionSavedItemsFixtures.page(
          collectionId: 'wishlist-id',
          collectionName: 'Wishlist',
          items: [
            CollectionSavedItemsFixtures.item(
              id: 'a',
              collectionId: 'wishlist-id',
            ),
            CollectionSavedItemsFixtures.item(
              id: 'b',
              collectionId: 'wishlist-id',
            ),
          ],
          nextCursor: 'cursor-2',
          hasMore: true,
        ),
      );

      expect(response.data.collection.id, 'wishlist-id');
      expect(response.data.collection.name, 'Wishlist');
      expect(response.data.savedItems.map((item) => item.id), ['a', 'b']);
      expect(response.message, 'saved items retrieved successfully');
      expect(response.meta!.cursor.hasMore, isTrue);
      expect(response.meta!.cursor.nextCursor, 'cursor-2');
    });

    test('decodes an empty collection, still named', () {
      // The empty case is a success with a collection object: the screen shows a
      // header either way, and never has to treat "no rows" as "no collection".
      final response = ListCollectionSavedItemsResponse.fromJson(
        CollectionSavedItemsFixtures.emptyPage(collectionName: 'Empty Box'),
      );

      expect(response.data.savedItems, isEmpty);
      expect(response.data.collection.name, 'Empty Box');
      expect(response.meta!.cursor.hasMore, isFalse);
      expect(response.meta!.cursor.nextCursor, isNull);
    });

    test('a final page reports an explicit null cursor', () {
      final response = ListCollectionSavedItemsResponse.fromJson(
        CollectionSavedItemsFixtures.page(
          items: [CollectionSavedItemsFixtures.item()],
        ),
      );

      expect(response.meta!.cursor.hasMore, isFalse);
      expect(response.meta!.cursor.nextCursor, isNull);
    });

    test('an absent meta decodes as null rather than an empty cursor', () {
      // The repository turns this into an unreadable response rather than a
      // single complete page, so the decoder must not invent `has_more: false`.
      final response = ListCollectionSavedItemsResponse.fromJson({
        'data': {
          'collection': {'id': 'collection-1', 'name': 'Camera Gear'},
          'saved_items': <Map<String, dynamic>>[],
        },
        'message': 'saved items retrieved successfully',
      });

      expect(response.meta, isNull);
    });
  });
}
