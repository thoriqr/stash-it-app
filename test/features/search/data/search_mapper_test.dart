import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/search/data/models/search_response.dart';
import 'package:stash_it_app/features/search/data/search_mapper.dart';

import '../../../support/search_fixtures.dart';

/// Search DTO to domain mapping.
///
/// The two things that matter: nothing the endpoint does not send is invented,
/// and the enrichment/time rules match the Inbox because they are the shared
/// helpers, not a second implementation.
void main() {
  final now = DateTime.utc(2026, 10, 2, 12, 0);

  SearchSavedItemResponse item({
    String? title = 'Understanding CRDTs',
    String url = 'https://example.com/articles/crdts-explained',
    String? domain = 'example.com',
    String? imageUrl = 'https://example.com/og.png',
    String enrichmentStatus = 'completed',
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
    String createdAt = '2026-10-02T10:30:00Z',
  }) => SearchSavedItemResponse.fromJson(
    SearchFixtures.savedItem(
      title: title,
      url: url,
      domain: domain,
      imageUrl: imageUrl,
      enrichmentStatus: enrichmentStatus,
      collectionId: collectionId,
      collectionName: collectionName,
      createdAt: createdAt,
    ),
  );

  group('saved items', () {
    test('maps the available fields and keeps both ids', () {
      final mapped = searchSavedItemFrom(item(), now: now);

      expect(mapped.id, 'item-1');
      expect(mapped.collectionId, 'collection-1');
      expect(mapped.url, 'https://example.com/articles/crdts-explained');
      expect(mapped.title, 'Understanding CRDTs');
      expect(mapped.collectionName, 'Camera Gear');
      expect(mapped.enrichmentStatus, EnrichmentStatus.completed);
      expect(mapped.hasPreviewImage, isTrue);
      expect(mapped.savedTimeLabel, 'Saved 1 hour ago');
    });

    test('a missing description stays absent instead of being invented', () {
      final mapped = searchSavedItemFrom(item(), now: now);

      // `/search` does not return a description at all. The shared row simply
      // renders no description line.
      expect(mapped.description, isNull);
    });

    test('a missing title falls back to the URL, then the host', () {
      final withUrl = searchSavedItemFrom(item(title: null), now: now);

      expect(withUrl.title, isNull);
      expect(withUrl.usesFallbackTitle, isTrue);
      expect(withUrl.displayTitle, withUrl.url);
      expect(withUrl.displaySource, 'example.com');

      final withEmptyUrl = searchSavedItemFrom(
        item(title: null, url: ''),
        now: now,
      );
      expect(withEmptyUrl.displayTitle, isEmpty);
    });

    test('null and blank image URLs mean no preview', () {
      expect(
        searchSavedItemFrom(item(imageUrl: null), now: now).hasPreviewImage,
        isFalse,
      );
      expect(
        searchSavedItemFrom(item(imageUrl: '   '), now: now).hasPreviewImage,
        isFalse,
      );
    });

    test('a completed item with no metadata is a normal success', () {
      final mapped = searchSavedItemFrom(
        item(title: null, imageUrl: null),
        now: now,
      );

      expect(mapped.enrichmentStatus, EnrichmentStatus.completed);
      expect(mapped.hasNoMetadata, isTrue);
    });

    test('maps the three documented enrichment values', () {
      for (final (wire, expected) in [
        ('pending', EnrichmentStatus.pending),
        ('completed', EnrichmentStatus.completed),
        ('failed', EnrichmentStatus.failed),
      ]) {
        expect(
          searchSavedItemFrom(
            item(enrichmentStatus: wire),
            now: now,
          ).enrichmentStatus,
          expected,
        );
      }
    });

    test('an unknown enrichment value asserts nothing', () {
      expect(
        searchSavedItemFrom(
          item(enrichmentStatus: 'something_new'),
          now: now,
        ).enrichmentStatus,
        EnrichmentStatus.pending,
      );
    });

    test('the saved-time label follows the shared Inbox wording', () {
      String? labelFor(String createdAt) => searchSavedItemFrom(
        item(createdAt: createdAt),
        now: now,
      ).savedTimeLabel;

      expect(labelFor('2026-10-02T11:59:30Z'), 'Saved just now');
      expect(labelFor('2026-10-02T11:00:00Z'), 'Saved 1 hour ago');
      expect(labelFor('2026-10-01T06:00:00Z'), 'Saved yesterday');
      expect(labelFor('2026-09-30T12:00:00Z'), 'Saved 2 days ago');
      expect(labelFor('not a date'), isNull);
      expect(labelFor('2026-10-03T12:00:00Z'), isNull);
    });
  });

  group('collections', () {
    test('maps only the fields the endpoint returns', () {
      final mapped = searchCollectionFrom(
        SearchCollectionResponse.fromJson(
          SearchFixtures.collection(id: 'c1', name: 'Camera Gear'),
        ),
      );

      expect(mapped.id, 'c1');
      expect(mapped.name, 'Camera Gear');
    });
  });

  group('whole response', () {
    test('preserves each group in the server order', () {
      final data = SearchDataResponse.fromJson(
        SearchFixtures.response(
              collections: [
                SearchFixtures.collection(id: 'c2', name: 'Second'),
                SearchFixtures.collection(id: 'c1', name: 'First'),
              ],
              savedItems: [
                SearchFixtures.savedItem(id: 'i2', title: 'Second'),
                SearchFixtures.savedItem(id: 'i1', title: 'First'),
              ],
            )['data']
            as Map<String, dynamic>,
      );

      final results = searchResultsFrom(data, now: now);

      expect(results.collections.map((c) => c.id), ['c2', 'c1']);
      expect(results.savedItems.map((i) => i.id), ['i2', 'i1']);
      expect(results.isEmpty, isFalse);
    });

    test('both empty arrays are a successful empty result', () {
      final data = SearchDataResponse.fromJson(
        SearchFixtures.emptyResponse()['data'] as Map<String, dynamic>,
      );

      final results = searchResultsFrom(data, now: now);

      expect(results.collections, isEmpty);
      expect(results.savedItems, isEmpty);
      expect(results.isEmpty, isTrue);
    });
  });
}
