import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/enrich_saved_item_response.dart';

import '../../../../support/saved_items_fixtures.dart';

/// Decoding of the documented `POST /saved-items/{id}/enrich` contract.
///
/// The enrich item is the same twelve-field object as the detail item — it reuses
/// [SavedItemDetailResponse] — but the envelope is smaller: `data` contains only
/// `saved_item`, with no sibling collection and no `meta`. A DTO that expected
/// either would reject the verified body.
void main() {
  group('the enrich envelope', () {
    test('decodes every one of the twelve documented item fields', () {
      final response = EnrichSavedItemResponse.fromJson(
        SavedItemsFixtures.enriched(),
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

      expect(response.message, 'saved item enriched successfully');
    });

    test('the data has no sibling collection and the body has no meta', () {
      final body = SavedItemsFixtures.enriched();
      expect(body.containsKey('meta'), isFalse);

      final data = body['data'] as Map<String, dynamic>;
      expect(data.keys, ['saved_item']);
      expect(
        (data['saved_item'] as Map<String, dynamic>).containsKey('collection'),
        isFalse,
        reason: 'enrichment never resolves or changes the collection',
      );
    });

    test('keeps every documented nullable field as an explicit null', () {
      final body = SavedItemsFixtures.enriched(
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

      final item = EnrichSavedItemResponse.fromJson(body).data.savedItem;
      expect(item.domain, isNull);
      expect(item.platform, isNull);
      expect(item.title, isNull);
      expect(item.description, isNull);
      expect(item.imageUrl, isNull);
      expect(item.lastEnrichedAt, isNull);
      // A completed extraction that found nothing is still completed (D17).
      expect(item.enrichmentStatus, 'completed');
    });

    test('carries a failed attempt as an ordinary 200 body', () {
      final item = EnrichSavedItemResponse.fromJson(
        SavedItemsFixtures.enriched(
          enrichmentStatus: 'failed',
          title: 'Kept from the previous read',
          description: null,
          imageUrl: null,
        ),
      ).data.savedItem;

      expect(item.enrichmentStatus, 'failed');
      expect(
        item.title,
        'Kept from the previous read',
        reason: 'a failed attempt preserves the metadata already stored',
      );
    });

    test('rejects a missing required item field', () {
      final body = SavedItemsFixtures.enriched();
      final item =
          (body['data'] as Map<String, dynamic>)['saved_item']
              as Map<String, dynamic>;
      item.remove('url');

      expect(
        () => EnrichSavedItemResponse.fromJson(body),
        throwsA(isA<TypeError>()),
      );
    });

    test('rejects a missing saved_item', () {
      final body = SavedItemsFixtures.enriched();
      (body['data'] as Map<String, dynamic>).remove('saved_item');

      expect(
        () => EnrichSavedItemResponse.fromJson(body),
        throwsA(isA<TypeError>()),
      );
    });

    test('rejects a null data payload', () {
      expect(
        () => EnrichSavedItemResponse.fromJson({
          'data': null,
          'message': 'saved item enriched successfully',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
