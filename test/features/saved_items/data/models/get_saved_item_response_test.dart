import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/get_saved_item_response.dart';

import '../../../../support/saved_items_fixtures.dart';

/// Decoding of the documented `GET /saved-items/{id}` contract.
///
/// The detail response is **not** the listing with a nested collection: the item
/// and its collection are siblings, and there is no `meta`. These tests pin that
/// shape against the exact wire keys, since a missing `@JsonKey` would decode as
/// `null` at runtime rather than failing at compile time.
void main() {
  group('the detail envelope', () {
    test('decodes the item and its sibling collection', () {
      final response = GetSavedItemResponse.fromJson(
        SavedItemsFixtures.detail(),
      );

      final item = response.data.savedItem;
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

      // The collection is a sibling, not `item.collection`.
      expect(response.data.collection.id, item.collectionId);
      expect(response.data.collection.name, 'Camera Gear');
      expect(response.message, 'saved item retrieved successfully');
    });

    test('the response has no meta and the item has no nested collection', () {
      // Documenting the two shape differences that matter: the listing carries a
      // cursor and nests the collection per row, while the detail route carries
      // neither. A DTO that expected either would fail against the real server.
      final body = SavedItemsFixtures.detail();
      expect(body.containsKey('meta'), isFalse);

      final data = body['data'] as Map<String, dynamic>;
      final item = data['saved_item'] as Map<String, dynamic>;
      expect(item.containsKey('collection'), isFalse);
      expect(data['collection'], isA<Map<String, dynamic>>());
    });

    test('keeps every documented nullable field null', () {
      final body = SavedItemsFixtures.detail(
        domain: null,
        platform: null,
        title: null,
        description: null,
        imageUrl: null,
        lastEnrichedAt: null,
      );

      final rawItem =
          (body['data'] as Map<String, dynamic>)['saved_item']
              as Map<String, dynamic>;

      // The contract sends the key with an explicit null, never omits it. An
      // item whose page exposed nothing is `completed`, not failed (D17).
      for (final key in const [
        'domain',
        'platform',
        'title',
        'description',
        'image_url',
        'last_enriched_at',
      ]) {
        expect(
          rawItem.containsKey(key),
          isTrue,
          reason: '$key is a present key carrying null, not a missing key',
        );
      }

      final item = GetSavedItemResponse.fromJson(body).data.savedItem;
      expect(item.domain, isNull);
      expect(item.platform, isNull);
      expect(item.title, isNull);
      expect(item.description, isNull);
      expect(item.imageUrl, isNull);
      expect(item.lastEnrichedAt, isNull);
      expect(item.enrichmentStatus, 'completed');
    });

    test('rejects a missing required item field', () {
      // `url` is required by the contract. A body without it is not a detail
      // this client can use, and must not decode into an item with a fabricated
      // empty URL.
      final body = SavedItemsFixtures.detail();
      final item =
          (body['data'] as Map<String, dynamic>)['saved_item']
              as Map<String, dynamic>;
      item.remove('url');

      expect(
        () => GetSavedItemResponse.fromJson(body),
        throwsA(isA<TypeError>()),
      );
    });

    test('rejects a missing sibling collection', () {
      final body = SavedItemsFixtures.detail();
      (body['data'] as Map<String, dynamic>).remove('collection');

      expect(
        () => GetSavedItemResponse.fromJson(body),
        throwsA(isA<TypeError>()),
      );
    });

    test('rejects a null data payload', () {
      expect(
        () => GetSavedItemResponse.fromJson({
          'data': null,
          'message': 'saved item retrieved successfully',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
