import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/search/data/models/search_response.dart';

import '../../../../support/search_fixtures.dart';

/// The Search DTOs against the verified response shape.
void main() {
  group('decoding', () {
    test('both groups decode and keep the server order', () {
      final response = SearchResponse.fromJson(
        SearchFixtures.response(
          collections: [
            SearchFixtures.collection(id: 'c1', name: 'First'),
            SearchFixtures.collection(id: 'c2', name: 'Second'),
          ],
          savedItems: [
            SearchFixtures.savedItem(id: 'i1', title: 'First item'),
            SearchFixtures.savedItem(id: 'i2', title: 'Second item'),
          ],
        ),
      );

      expect(response.data.collections.map((c) => c.id).toList(), ['c1', 'c2']);
      expect(response.data.savedItems.map((i) => i.id).toList(), ['i1', 'i2']);
      expect(response.message, 'search completed successfully');
    });

    test('empty arrays are a successful response, not a null result', () {
      final response = SearchResponse.fromJson(SearchFixtures.emptyResponse());

      expect(response.data.savedItems, isEmpty);
      expect(response.data.collections, isEmpty);
    });

    test('nullable metadata stays null rather than being omitted', () {
      final response = SearchResponse.fromJson(
        SearchFixtures.response(
          savedItems: [
            SearchFixtures.savedItem(title: null, domain: null, imageUrl: null),
          ],
        ),
      );

      final item = response.data.savedItems.single;
      expect(item.title, isNull);
      expect(item.domain, isNull);
      expect(item.imageUrl, isNull);
      expect(item.url, isNotEmpty);
    });

    test('the nested collection keeps both id and name', () {
      final response = SearchResponse.fromJson(
        SearchFixtures.response(
          savedItems: [
            SearchFixtures.savedItem(
              collectionId: 'collection-9',
              collectionName: 'Wishlist',
            ),
          ],
        ),
      );

      final collection = response.data.savedItems.single.collection;
      expect(collection.id, 'collection-9');
      expect(collection.name, 'Wishlist');
    });

    test('a collection result exposes only id and name', () {
      final collection = SearchCollectionResponse.fromJson(
        SearchFixtures.collection(id: 'c1', name: 'Camera Gear'),
      );

      expect(collection.toJson().keys.toSet(), {'id', 'name'});
    });

    test('a saved item declares no field the endpoint does not send', () {
      final item = SearchSavedItemResponse.fromJson(SearchFixtures.savedItem());

      // This is the guard against a made-up `description`, `platform`, counts
      // or score sneaking into the Search model: the DTO's own wire surface is
      // pinned to the documented keys.
      expect(item.toJson().keys.toSet(), {
        'id',
        'title',
        'url',
        'domain',
        'image_url',
        'enrichment_status',
        'collection',
        'created_at',
      });
    });
  });
}
