import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/list_saved_items_response.dart';
import 'package:stash_it_app/features/saved_items/data/models/listed_saved_item.dart';

import '../../../../support/saved_items_fixtures.dart';

/// Decoding of the documented `GET /saved-items` contract.
///
/// The wire keys are snake_case, so a missing `@JsonKey` would look for camelCase
/// and fail at runtime rather than at compile time. These pin the mapping
/// against the exact shape the backend documents.
void main() {
  group('ListedSavedItemResponse', () {
    test('decodes a fully-populated row, including the nested collection', () {
      final item = ListedSavedItemResponse.fromJson(SavedItemsFixtures.item());

      expect(item.id, '01a0f359-093b-737a-963a-80f7ca6768ed');
      expect(item.url, 'https://example.com/articles/crdts-explained');
      expect(item.domain, 'example.com');
      expect(item.platform, 'web');
      expect(item.title, 'Understanding CRDTs');
      expect(item.description, 'Conflict-free replicated data types converge.');
      expect(item.imageUrl, 'https://example.com/og.png');
      expect(item.collectionId, '01a0f359-093b-737a-963a-80f7ca6768ed');
      expect(item.enrichmentStatus, 'completed');
      expect(item.lastEnrichedAt, '2026-10-02T10:31:00Z');
      expect(item.createdAt, '2026-10-02T10:30:00Z');
      expect(item.updatedAt, '2026-10-02T10:31:00Z');

      // The collection travels inside the item because the listing spans every
      // collection the caller owns.
      expect(item.collection.id, item.collectionId);
      expect(item.collection.name, 'Camera Gear');
    });

    test('keeps every nullable field null when the server sends null', () {
      // The contract: these are reported as an explicit `null` on a key that is
      // always present. An item whose page exposed nothing is `completed`, not
      // failed — [D17] — so nullability is an ordinary state.
      final item = ListedSavedItemResponse.fromJson(
        SavedItemsFixtures.item(
          domain: null,
          platform: null,
          title: null,
          description: null,
          imageUrl: null,
          lastEnrichedAt: null,
        ),
      );

      expect(item.title, isNull);
      expect(item.description, isNull);
      expect(item.imageUrl, isNull);
      expect(item.lastEnrichedAt, isNull);
      expect(item.domain, isNull);
      expect(item.platform, isNull);

      // The keys are always present, so only their values are absent.
      expect(item.enrichmentStatus, 'completed');
      expect(item.collection.name, 'Camera Gear');
    });

    test('decodes a pending row that has no metadata yet', () {
      final item = ListedSavedItemResponse.fromJson(
        SavedItemsFixtures.item(
          title: null,
          description: null,
          imageUrl: null,
          lastEnrichedAt: null,
          enrichmentStatus: 'pending',
        ),
      );

      expect(item.enrichmentStatus, 'pending');
      expect(item.title, isNull);
    });

    test('decodes a failed row', () {
      final item = ListedSavedItemResponse.fromJson(
        SavedItemsFixtures.item(enrichmentStatus: 'failed'),
      );

      expect(item.enrichmentStatus, 'failed');
    });
  });

  group('ListSavedItemsResponse', () {
    test('decodes the envelope with its cursor meta', () {
      final response = ListSavedItemsResponse.fromJson(
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item()],
          nextCursor: 'eyJ2IjoxLCJ2YWwiOiIyMDI2LTEwLTAyVDEwOjMwOjAwWiJ9',
          hasMore: true,
        ),
      );

      expect(response.message, 'saved items retrieved successfully');
      expect(response.data.savedItems, hasLength(1));
      expect(response.meta!.cursor.hasMore, isTrue);
      expect(
        response.meta!.cursor.nextCursor,
        'eyJ2IjoxLCJ2YWwiOiIyMDI2LTEwLTAyVDEwOjMwOjAwWiJ9',
      );
    });

    test('decodes an empty page as an empty list, never as null', () {
      final response = ListSavedItemsResponse.fromJson(
        SavedItemsFixtures.emptyPage(),
      );

      expect(response.data.savedItems, isEmpty);
      expect(response.meta!.cursor.hasMore, isFalse);
      expect(
        response.meta!.cursor.nextCursor,
        isNull,
        reason:
            'the contract makes next_cursor explicitly null on the last page',
      );
    });

    test('preserves an opaque cursor byte for byte', () {
      // The cursor's encoding is not part of the API surface. It is stored and
      // returned exactly as received, never parsed or rebuilt.
      const cursor = 'eyJ2IjoxLCJ2YWwiOiIyMDI2LTEwLTAyVDEwOjMwOjAwWiJ9.sig==';

      final response = ListSavedItemsResponse.fromJson(
        SavedItemsFixtures.page(
          items: [SavedItemsFixtures.item()],
          nextCursor: cursor,
          hasMore: true,
        ),
      );

      expect(response.meta!.cursor.nextCursor, cursor);
    });

    test('decodes rows in the order the server sent them', () {
      final response = ListSavedItemsResponse.fromJson(
        SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', title: 'First'),
            SavedItemsFixtures.item(id: 'b', title: 'Second'),
            SavedItemsFixtures.item(id: 'c', title: 'Third'),
          ],
        ),
      );

      expect(response.data.savedItems.map((i) => i.id).toList(), [
        'a',
        'b',
        'c',
      ], reason: 'ordering is the server\'s; the client never re-sorts');
    });
  });
}
