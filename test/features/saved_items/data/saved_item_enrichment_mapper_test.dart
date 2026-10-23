import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/enrich_saved_item_response.dart';
import 'package:stash_it_app/features/saved_items/data/saved_item_enrichment_mapper.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/saved_items_fixtures.dart';

/// The enrich response mapped onto the four fields a re-read can change.
///
/// The mapper is the boundary that decides what the client may overwrite. It must
/// copy nullable metadata exactly — including null, which clears an older value —
/// and must not invent a collection: the response carries none.
void main() {
  SavedItemEnrichmentResult enriched({
    String id = 'item-1',
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    String enrichmentStatus = 'completed',
  }) => savedItemEnrichmentFrom(
    EnrichSavedItemResponse.fromJson(
      SavedItemsFixtures.enriched(
        id: id,
        title: title,
        description: description,
        imageUrl: imageUrl,
        enrichmentStatus: enrichmentStatus,
      ),
    ),
  );

  group('the fields a re-read can change', () {
    test('maps the item id and all four values', () {
      final result = enriched();

      expect(result.savedItemId, 'item-1');
      expect(result.title, 'Understanding CRDTs');
      expect(
        result.description,
        'Conflict-free replicated data types converge.',
      );
      expect(result.imageUrl, 'https://example.com/og.png');
      expect(result.enrichmentStatus, EnrichmentStatus.completed);
    });

    test('an explicit null is preserved, not defaulted', () {
      final result = enriched(title: null, description: null, imageUrl: null);

      expect(result.title, isNull);
      expect(result.description, isNull);
      expect(result.imageUrl, isNull);
    });

    test('an empty or whitespace value is carried through untouched', () {
      expect(enriched(title: '').title, '');
      expect(enriched(description: '   ').description, '   ');
      expect(enriched(imageUrl: '').imageUrl, '');
      expect(enriched(imageUrl: '   ').imageUrl, '   ');
    });
  });

  group('enrichment status', () {
    test('maps the three documented values', () {
      expect(
        enriched(enrichmentStatus: 'pending').enrichmentStatus,
        EnrichmentStatus.pending,
      );
      expect(
        enriched(enrichmentStatus: 'completed').enrichmentStatus,
        EnrichmentStatus.completed,
      );
      expect(
        enriched(enrichmentStatus: 'failed').enrichmentStatus,
        EnrichmentStatus.failed,
      );
    });

    test('an unrecognised value resolves defensively to pending', () {
      expect(
        enriched(enrichmentStatus: 'something_new').enrichmentStatus,
        EnrichmentStatus.pending,
      );
    });
  });

  group('hasNoMetadata', () {
    test('a completed attempt with nothing found is the empty state', () {
      final result = enriched(title: null, description: null, imageUrl: null);

      expect(result.enrichmentStatus, EnrichmentStatus.completed);
      expect(result.hasNoMetadata, isTrue);
    });

    test('a reported image counts as metadata', () {
      final result = enriched(
        title: null,
        description: null,
        imageUrl: 'https://example.com/og.png',
      );

      expect(result.hasNoMetadata, isFalse);
    });

    test('a blank image is not metadata', () {
      final result = enriched(title: null, description: null, imageUrl: '   ');

      expect(result.hasNoMetadata, isTrue);
    });

    test('a failed attempt is never the empty-metadata claim', () {
      final result = enriched(
        title: null,
        description: null,
        imageUrl: null,
        enrichmentStatus: 'failed',
      );

      expect(result.enrichmentStatus, EnrichmentStatus.failed);
      expect(result.hasNoMetadata, isFalse);
    });
  });
}
