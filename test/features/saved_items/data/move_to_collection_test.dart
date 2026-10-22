import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/move_to_collection_mapper.dart';
import 'package:stash_it_app/features/saved_items/data/models/move_to_collection_request.dart';
import 'package:stash_it_app/features/saved_items/data/models/move_to_collection_response.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';

import '../../../support/saved_items_fixtures.dart';

/// The move DTOs and mapper: the exact envelope, the intent-and-name request,
/// and the three facts callers act on.
void main() {
  group('request', () {
    test('serializes exactly the name and the intent, never an id', () {
      final json = const MoveToCollectionRequest(
        collectionName: 'Reading List',
        collectionIntent: 'create',
      ).toJson();

      expect(json, {
        'collection_name': 'Reading List',
        'collection_intent': 'create',
      });
      expect(json.containsKey('collection_id'), isFalse);
    });

    test('the domain intents serialize to the exact backend values', () {
      expect(MoveToCollectionIntent.existing.wireValue, 'existing');
      expect(MoveToCollectionIntent.create.wireValue, 'create');
    });
  });

  group('response', () {
    test('decodes the no-meta envelope and both flags', () {
      final response = MoveToCollectionResponse.fromJson(
        SavedItemsFixtures.moved(
          collectionId: 'collection-1',
          collectionName: 'Reading List',
          collectionCreated: true,
          alreadyInCollection: false,
        ),
      );

      expect(response.message, isNotNull);
      expect(response.data.collection.id, 'collection-1');
      expect(response.data.collection.name, 'Reading List');
      expect(response.data.collection.type, 'user');
      expect(response.data.savedItem.collectionId, 'collection-1');
      expect(response.data.collectionCreated, isTrue);
      expect(response.data.alreadyInCollection, isFalse);
    });

    test('reports an already-in no-op', () {
      final response = MoveToCollectionResponse.fromJson(
        SavedItemsFixtures.moved(
          collectionName: 'Wishlist',
          collectionCreated: false,
          alreadyInCollection: true,
        ),
      );

      expect(response.data.collectionCreated, isFalse);
      expect(response.data.alreadyInCollection, isTrue);
    });

    test('the saved item is not the detail shape', () {
      // These four fields are exactly what the detail response adds; the move
      // response deliberately omits them. A client that decoded the move body as
      // a detail item would either fail or fabricate nulls.
      final response = MoveToCollectionResponse.fromJson(
        SavedItemsFixtures.moved(),
      );
      final json = SavedItemsFixtures.moved();
      final savedItem =
          (json['data'] as Map<String, dynamic>)['saved_item']
              as Map<String, dynamic>;

      expect(savedItem.containsKey('description'), isFalse);
      expect(savedItem.containsKey('image_url'), isFalse);
      expect(savedItem.containsKey('enrichment_status'), isFalse);
      expect(savedItem.containsKey('last_enriched_at'), isFalse);
      expect(response.data.savedItem.title, isNotNull);
    });

    test('a missing required flag is a decode failure', () {
      final json = SavedItemsFixtures.moved();
      (json['data'] as Map<String, dynamic>).remove('collection_created');

      expect(
        () => MoveToCollectionResponse.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('mapper', () {
    test(
      'uses the stored collection name and reports a created collection',
      () {
        final result = moveToCollectionResultFrom(
          MoveToCollectionResponse.fromJson(
            SavedItemsFixtures.moved(
              collectionId: 'collection-1',
              collectionName: 'Reading List',
              collectionCreated: true,
            ),
          ),
        );

        expect(result.collectionId, 'collection-1');
        expect(
          result.collectionName,
          'Reading List',
          reason: 'the backend casing, not a lowercased comparison form',
        );
        expect(result.collectionCreated, isTrue);
        expect(result.alreadyInCollection, isFalse);
      },
    );

    test('reports an already-in no-op', () {
      final result = moveToCollectionResultFrom(
        MoveToCollectionResponse.fromJson(
          SavedItemsFixtures.moved(
            collectionName: 'Wishlist',
            alreadyInCollection: true,
          ),
        ),
      );

      expect(result.alreadyInCollection, isTrue);
      expect(result.collectionCreated, isFalse);
    });
  });
}
