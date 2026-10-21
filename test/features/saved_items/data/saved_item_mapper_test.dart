import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/models/listed_saved_item.dart';
import 'package:stash_it_app/features/saved_items/data/saved_item_mapper.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import '../../../support/saved_items_fixtures.dart';

/// DTO to presentation model.
///
/// The three things that matter: nullable metadata survives as null rather than
/// becoming a fault, an unrecognised enrichment value cannot make the row claim
/// success or failure, and an unparseable timestamp produces no label at all
/// rather than a fabricated one.
void main() {
  final now = DateTime.utc(2026, 10, 2, 12, 0);

  ListedSavedItemResponse dto({
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl = 'https://example.com/og.png',
    String enrichmentStatus = 'completed',
    String createdAt = '2026-10-02T10:30:00Z',
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
  }) => ListedSavedItemResponse.fromJson(
    SavedItemsFixtures.item(
      title: title,
      description: description,
      imageUrl: imageUrl,
      enrichmentStatus: enrichmentStatus,
      createdAt: createdAt,
      collectionId: collectionId,
      collectionName: collectionName,
    ),
  );

  group('nullable metadata', () {
    test(
      'a row with no title keeps title null, so the row falls back to the URL',
      () {
        final item = savedItemFrom(dto(title: null), now: now);

        expect(item.title, isNull);
        expect(item.usesFallbackTitle, isTrue);
        expect(item.displayTitle, item.url);
        // A missing title is neutral copy, never a fault.
        expect(item.hasNoMetadata, isFalse);
      },
    );

    test('a row with no description keeps it null', () {
      expect(
        savedItemFrom(dto(description: null), now: now).description,
        isNull,
      );
    });

    test('a completed row with no metadata at all is still a success', () {
      final item = savedItemFrom(
        dto(title: null, description: null, imageUrl: null),
        now: now,
      );

      expect(item.enrichmentStatus, EnrichmentStatus.completed);
      expect(item.hasNoMetadata, isTrue);
    });

    test('image_url drives the thumbnail, and null means no image', () {
      expect(savedItemFrom(dto(), now: now).hasPreviewImage, isTrue);
      expect(
        savedItemFrom(dto(imageUrl: null), now: now).hasPreviewImage,
        isFalse,
      );
    });

    test('an empty image_url is treated as no image', () {
      // The contract sends a URL or null. An empty string is not a usable image
      // and must not render a slot that claims to have one.
      expect(
        savedItemFrom(dto(imageUrl: '   '), now: now).hasPreviewImage,
        isFalse,
      );
    });
  });

  group('enrichment status', () {
    test('maps the three documented values', () {
      expect(
        savedItemFrom(
          dto(enrichmentStatus: 'pending'),
          now: now,
        ).enrichmentStatus,
        EnrichmentStatus.pending,
      );
      expect(
        savedItemFrom(
          dto(enrichmentStatus: 'completed'),
          now: now,
        ).enrichmentStatus,
        EnrichmentStatus.completed,
      );
      expect(
        savedItemFrom(
          dto(enrichmentStatus: 'failed'),
          now: now,
        ).enrichmentStatus,
        EnrichmentStatus.failed,
      );
    });

    test('an unrecognised value resolves to pending, not to a claim', () {
      // The contract states exactly three values, so this is unreachable against
      // a conforming server. `pending` is the value a row is *stored* with, and
      // the one state that asserts nothing about what enrichment found.
      final item = savedItemFrom(
        dto(enrichmentStatus: 'something_new'),
        now: now,
      );

      expect(item.enrichmentStatus, EnrichmentStatus.pending);
    });
  });

  group('collection', () {
    test('keeps the id and name from the nested collection object', () {
      final item = savedItemFrom(
        dto(collectionId: 'collection-9', collectionName: 'Wishlist'),
        now: now,
      );

      expect(item.collectionId, 'collection-9');
      expect(item.collectionName, 'Wishlist');
    });
  });

  group('saved-time label', () {
    String? labelFor(String createdAt) =>
        savedItemFrom(dto(createdAt: createdAt), now: now).savedTimeLabel;

    test('words each range the way the approved prototype does', () {
      expect(labelFor('2026-10-02T11:59:30Z'), 'Saved just now');
      expect(labelFor('2026-10-02T11:59:00Z'), 'Saved 1 min ago');
      expect(labelFor('2026-10-02T11:12:00Z'), 'Saved 48 min ago');
      expect(labelFor('2026-10-02T11:00:00Z'), 'Saved 1 hour ago');
      expect(labelFor('2026-10-02T09:00:00Z'), 'Saved 3 hours ago');
      // 30 hours back: past a day but inside the "yesterday" window.
      expect(labelFor('2026-10-01T06:00:00Z'), 'Saved yesterday');
      expect(labelFor('2026-09-30T12:00:00Z'), 'Saved 2 days ago');
    });

    test('is null for an unparseable timestamp, rather than invented', () {
      expect(labelFor('not a date'), isNull);
      expect(labelFor(''), isNull);
    });

    test('is null when the timestamp is in the future', () {
      // Clock skew is not evidence about the item.
      expect(labelFor('2026-10-03T12:00:00Z'), isNull);
    });
  });
}
