import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// The presentation model's image-related rules.
///
/// `hasPreviewImage` answers one question only — did the response report an
/// image? — and `copyWithCollection` must not lose the answer when an item is
/// moved. Those two facts are what let the preview widget own every rendering
/// decision without the model drifting underneath it.
void main() {
  SavedItemSummary summary({
    String? title = 'Understanding CRDTs',
    String? description = 'Conflict-free replicated data types converge.',
    String? imageUrl,
    EnrichmentStatus status = EnrichmentStatus.completed,
  }) => SavedItemSummary(
    id: 'item-1',
    collectionId: 'collection-1',
    url: 'https://example.com/articles/crdts-explained',
    collectionName: 'Camera Gear',
    enrichmentStatus: status,
    title: title,
    description: description,
    imageUrl: imageUrl,
    savedTimeLabel: 'Saved 1 hour ago',
  );

  group('hasPreviewImage', () {
    test('a URL means the response reported an image', () {
      expect(
        summary(imageUrl: 'https://example.com/og.png').hasPreviewImage,
        isTrue,
      );
    });

    test('null, empty and whitespace mean none', () {
      expect(summary(imageUrl: null).hasPreviewImage, isFalse);
      expect(summary(imageUrl: '').hasPreviewImage, isFalse);
      expect(summary(imageUrl: '   ').hasPreviewImage, isFalse);
    });

    test('it reports what arrived, not whether the URL is loadable', () {
      // The model does not validate URLs: a relative or unsupported value is
      // still what the response said, and the preview is what declines to load
      // it. Moving that judgement into the model would give two places an
      // opinion about the same URL.
      expect(summary(imageUrl: '/og.png').hasPreviewImage, isTrue);
      expect(
        summary(imageUrl: 'ftp://example.com/og.png').hasPreviewImage,
        isTrue,
      );
    });
  });

  group('hasNoMetadata', () {
    test('a reported image counts as metadata', () {
      expect(
        summary(
          title: null,
          description: null,
          imageUrl: 'https://example.com/og.png',
        ).hasNoMetadata,
        isFalse,
      );
    });

    test('no title, no description and no image is the empty state', () {
      expect(
        summary(title: null, description: null, imageUrl: null).hasNoMetadata,
        isTrue,
      );
    });

    test('a blank image URL is not metadata', () {
      expect(
        summary(title: null, description: null, imageUrl: '   ').hasNoMetadata,
        isTrue,
      );
    });

    test('it is never reached by a pending or failed item', () {
      // The empty-metadata claim belongs to a completed enrichment only.
      expect(
        summary(
          title: null,
          description: null,
          status: EnrichmentStatus.pending,
        ).hasNoMetadata,
        isFalse,
      );
      expect(
        summary(
          title: null,
          description: null,
          status: EnrichmentStatus.failed,
        ).hasNoMetadata,
        isFalse,
      );
    });
  });

  group('copyWithCollection', () {
    test('replaces only the collection and keeps the preview URL', () {
      final original = summary(imageUrl: 'https://example.com/og.png');

      final moved = original.copyWithCollection(
        collectionId: 'collection-2',
        collectionName: 'Wishlist',
      );

      expect(moved.imageUrl, 'https://example.com/og.png');
      expect(moved.hasPreviewImage, isTrue);
      expect(moved.collectionId, 'collection-2');
      expect(moved.collectionName, 'Wishlist');
      // Everything else is the read's, not the write response's.
      expect(moved.id, original.id);
      expect(moved.url, original.url);
      expect(moved.title, original.title);
      expect(moved.description, original.description);
      expect(moved.enrichmentStatus, original.enrichmentStatus);
      expect(moved.savedTimeLabel, original.savedTimeLabel);
    });

    test('a null URL stays null across the move', () {
      final moved = summary().copyWithCollection(
        collectionId: 'collection-2',
        collectionName: 'Wishlist',
      );

      expect(moved.imageUrl, isNull);
      expect(moved.hasPreviewImage, isFalse);
    });

    test('a whitespace URL is preserved verbatim, still meaning no image', () {
      final moved = summary(imageUrl: '   ').copyWithCollection(
        collectionId: 'collection-2',
        collectionName: 'Wishlist',
      );

      expect(moved.imageUrl, '   ');
      expect(moved.hasPreviewImage, isFalse);
    });

    test('the collection name is stored exactly as supplied', () {
      final moved = summary().copyWithCollection(
        collectionId: 'collection-2',
        collectionName: '  Reading List  ',
      );

      expect(moved.collectionName, '  Reading List  ');
    });
  });
}
