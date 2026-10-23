import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_delete_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// The optional follow-up is offered only when **every** signal agrees.
void main() {
  SavedItemSummary item({
    String collectionId = 'collection-1',
    String collectionName = 'Camera Gear',
  }) => SavedItemSummary(
    id: 'item-1',
    collectionId: collectionId,
    url: 'https://example.com/article',
    collectionName: collectionName,
    enrichmentStatus: EnrichmentStatus.completed,
  );

  SavedItemDeleted deleted({
    String collectionId = 'collection-1',
    bool empty = true,
    bool deletable = true,
  }) => SavedItemDeleted(
    collectionId: collectionId,
    collectionEmpty: empty,
    collectionDeletable: deletable,
  );

  test('offers only when both flags and both ids agree', () {
    expect(deleted().mayOfferCollectionDeletionFor(item()), isTrue);
  });

  test('the collection name is trimmed for the check', () {
    expect(
      deleted().mayOfferCollectionDeletionFor(
        item(collectionName: '  Camera Gear  '),
      ),
      isTrue,
    );
  });

  test('a non-empty collection is never offered', () {
    expect(
      deleted(empty: false).mayOfferCollectionDeletionFor(item()),
      isFalse,
    );
  });

  test('a non-deletable collection is never offered', () {
    expect(
      deleted(deletable: false).mayOfferCollectionDeletionFor(item()),
      isFalse,
    );
  });

  test('a blank response collection id is never offered', () {
    for (final id in ['', '   ']) {
      expect(
        deleted(collectionId: id).mayOfferCollectionDeletionFor(item()),
        isFalse,
        reason: id,
      );
    }
  });

  test('a response id that differs from the item is never offered', () {
    expect(
      deleted(
        collectionId: 'collection-other',
      ).mayOfferCollectionDeletionFor(item()),
      isFalse,
    );
  });

  test('a blank item collection name is never offered', () {
    for (final name in ['', '   ']) {
      expect(
        deleted().mayOfferCollectionDeletionFor(item(collectionName: name)),
        isFalse,
        reason: name,
      );
    }
  });
}
