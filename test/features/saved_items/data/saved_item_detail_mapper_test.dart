import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/get_saved_item_response.dart';
import 'package:stash_it_app/features/saved_items/data/saved_item_detail_mapper.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/saved_items_fixtures.dart';

/// Detail DTO to the presentation model the screen renders.
///
/// The mapper reuses [SavedItemSummary] rather than introducing a detail-only
/// model: the approved layout needs the title fallback, source line, collection,
/// enrichment state, description and preview flag, all of which the existing
/// model represents. `platform`, `last_enriched_at` and `updated_at` are decoded
/// by the DTO but deliberately not promoted, because there is no approved UI for
/// them.
void main() {
  final now = DateTime.utc(2026, 10, 2, 12, 0);

  SavedItemSummary detail({
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    String enrichmentStatus = 'completed',
    String createdAt = '2026-10-02T10:30:00Z',
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
  }) => savedItemDetailFrom(
    GetSavedItemResponse.fromJson(
      SavedItemsFixtures.detail(
        title: title,
        description: description,
        imageUrl: imageUrl,
        enrichmentStatus: enrichmentStatus,
        createdAt: createdAt,
        collectionId: collectionId,
        collectionName: collectionName,
      ),
    ),
    now: now,
  );

  group('the fields the detail screen renders', () {
    test('maps the item and the collection from the sibling object', () {
      final item = detail(
        collectionId: 'collection-9',
        collectionName: 'Wishlist',
      );

      expect(item.id, '01a0f359-093b-737a-963a-80f7ca6768ed');
      expect(item.url, 'https://example.com/articles/crdts-explained');
      expect(item.collectionId, 'collection-9');
      expect(item.collectionName, 'Wishlist');
      expect(item.title, 'Understanding CRDTs');
      expect(item.description, 'Conflict-free replicated data types converge.');
      expect(item.hasPreviewImage, isTrue);
      expect(item.enrichmentStatus, EnrichmentStatus.completed);
      expect(item.savedTimeLabel, 'Saved 1 hour ago');
    });

    test('a detail and a listing row can never disagree on the collection', () {
      // The two DTOs put the collection in different places; both mappers read
      // its id and name from the `{id, name}` object, never from a display name.
      final item = detail(
        collectionId: 'collection-7',
        collectionName: 'Reading list',
      );

      expect(item.collectionId, 'collection-7');
      expect(item.collectionName, 'Reading list');
    });
  });

  group('title fallback', () {
    test('a null title stays null and the summary falls back to the URL', () {
      final item = detail(title: null);

      expect(item.title, isNull);
      expect(item.usesFallbackTitle, isTrue);
      expect(item.displayTitle, item.url);
      expect(
        item.displaySource,
        'example.com',
        reason: 'the source line is the host alone when the title is the URL',
      );
    });

    test('an empty title is treated as missing', () {
      final item = detail(title: '   ');

      expect(item.title, '   ');
      expect(item.usesFallbackTitle, isTrue);
      expect(item.displayTitle, item.url);
    });

    test('a completed item with no metadata is normal, not a failure', () {
      final item = detail(title: null, description: null, imageUrl: null);

      expect(item.enrichmentStatus, EnrichmentStatus.completed);
      expect(item.hasNoMetadata, isTrue);
      expect(item.usesFallbackTitle, isTrue);
      expect(item.displayTitle, item.url);
    });
  });

  group('description', () {
    test('null stays null', () {
      expect(detail(description: null).description, isNull);
    });

    test('an empty description is preserved, not invented or dropped', () {
      // The mapper must not fill a missing description with copy of its own; the
      // screen decides that an empty string is not worth rendering.
      expect(detail(description: '').description, '');
      expect(detail(description: '   ').description, '   ');
    });

    test('full text is preserved, including newlines', () {
      const long =
          'A description that runs long enough to need several lines.\n'
          'It keeps its second paragraph, because the detail screen exists to '
          'show the page rather than an excerpt.';

      expect(detail(description: long).description, long);
    });
  });

  group('preview flag', () {
    test('a URL means a preview, null and whitespace mean none', () {
      expect(detail().hasPreviewImage, isTrue);
      expect(detail(imageUrl: null).hasPreviewImage, isFalse);
      expect(detail(imageUrl: '').hasPreviewImage, isFalse);
      expect(detail(imageUrl: '   ').hasPreviewImage, isFalse);
    });
  });

  group('enrichment state', () {
    test('maps the three documented values', () {
      expect(
        detail(enrichmentStatus: 'pending').enrichmentStatus,
        EnrichmentStatus.pending,
      );
      expect(
        detail(enrichmentStatus: 'completed').enrichmentStatus,
        EnrichmentStatus.completed,
      );
      expect(
        detail(enrichmentStatus: 'failed').enrichmentStatus,
        EnrichmentStatus.failed,
      );
    });

    test('pending with no metadata is not "no metadata found"', () {
      // `hasNoMetadata` is a completed-only claim. A pending item has not been
      // read yet, so saying enrichment found nothing would be false.
      final item = detail(
        title: null,
        description: null,
        imageUrl: null,
        enrichmentStatus: 'pending',
      );

      expect(item.enrichmentStatus, EnrichmentStatus.pending);
      expect(item.hasNoMetadata, isFalse);
    });

    test('failed with metadata still carries that metadata', () {
      final item = detail(enrichmentStatus: 'failed');

      expect(item.enrichmentStatus, EnrichmentStatus.failed);
      expect(item.title, 'Understanding CRDTs');
      expect(item.description, 'Conflict-free replicated data types converge.');
      expect(item.hasPreviewImage, isTrue);
      expect(item.hasNoMetadata, isFalse);
    });

    test('an unrecognised value resolves to pending, not to a claim', () {
      // Defensive and unreachable against a conforming server. `pending` is the
      // stored value before enrichment runs and asserts nothing about the result.
      expect(
        detail(enrichmentStatus: 'something_new').enrichmentStatus,
        EnrichmentStatus.pending,
      );
    });
  });

  group('saved-time label', () {
    test('is derived from created_at against the injected clock', () {
      expect(
        detail(createdAt: '2026-10-02T11:59:30Z').savedTimeLabel,
        'Saved just now',
      );
      expect(
        detail(createdAt: '2026-10-02T11:00:00Z').savedTimeLabel,
        'Saved 1 hour ago',
      );
    });

    test('is null when the timestamp cannot be parsed', () {
      expect(detail(createdAt: 'not a date').savedTimeLabel, isNull);
    });
  });
}
