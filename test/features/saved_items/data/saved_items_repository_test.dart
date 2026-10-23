import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_delete_result.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

/// The repository: envelope decoding, cursor passthrough, and failure mapping.
///
/// Also the one place this feature is checked against the **real** auth pipeline,
/// so a regression there is caught here rather than on a device.
void main() {
  late FakeHttpAdapter adapter;
  late Dio dio;
  late SavedItemsRepository repository;

  final now = DateTime.utc(2026, 10, 2, 12, 0);

  SavedItemsRepository build(Dio client) =>
      SavedItemsRepository(api: SavedItemsApi(client), now: () => now);

  setUp(() {
    adapter = FakeHttpAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    repository = build(dio);
  });

  group('listing', () {
    test('decodes a page and keeps the server order', () async {
      adapter.on(
        '/saved-items',
        body: SavedItemsFixtures.page(
          items: [
            SavedItemsFixtures.item(id: 'a', title: 'First'),
            SavedItemsFixtures.item(id: 'b', title: 'Second'),
          ],
        ),
      );

      final page = await repository.list();

      expect(page.items.map((i) => i.id).toList(), ['a', 'b']);
      expect(page.items.first.title, 'First');
      expect(page.items.first.collectionName, 'Camera Gear');
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('an empty page is an empty result, not an error', () async {
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      final page = await repository.list();

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('sends no cursor on the first request', () async {
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await repository.list();

      expect(
        Uri.parse(adapter.lastRequestTo('/saved-items')!.path).query,
        isEmpty,
      );
    });

    test('passes an opaque cursor back to the server unchanged', () async {
      adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

      await repository.list(
        cursor: 'eyJ2IjoxLCJ2YWwiOiIyMDI2LTEwLTAyVDEwOjMwOjAwWiJ9',
      );

      expect(
        Uri.parse(
          adapter.lastRequestTo('/saved-items')!.path,
        ).queryParameters['cursor'],
        'eyJ2IjoxLCJ2YWwiOiIyMDI2LTEwLTAyVDEwOjMwOjAwWiJ9',
      );
    });

    test(
      'exposes has_more and next_cursor as the contract reports them',
      () async {
        adapter.on(
          '/saved-items',
          body: SavedItemsFixtures.page(
            items: [SavedItemsFixtures.item()],
            nextCursor: 'next-page-token',
            hasMore: true,
          ),
        );

        final page = await repository.list();

        expect(page.hasMore, isTrue);
        expect(page.nextCursor, 'next-page-token');
      },
    );

    test('reports a response with no meta as unreadable', () async {
      // Without `meta.cursor` there is no cursor and no `has_more`, so the
      // listing cannot be paginated safely. Treating it as a complete single
      // page would silently hide pages the user can reach.
      adapter.on(
        '/saved-items',
        body: {
          'data': {
            'saved_items': [SavedItemsFixtures.item()],
          },
          'message': 'saved items retrieved successfully',
        },
      );

      await expectLater(
        repository.list(),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('maps a null data payload to an unreadable response', () async {
      adapter.on(
        '/saved-items',
        body: {
          'data': null,
          'message': 'saved items retrieved successfully',
          'meta': {
            'cursor': {'has_more': false, 'next_cursor': null},
          },
        },
      );

      await expectLater(
        repository.list(),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });

  group('failures', () {
    test('maps a 500 to a server fault', () async {
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.list(),
        throwsA(isA<ApiFailureServerFault>()),
      );
    });

    test('maps a 401 to an auth requirement', () async {
      adapter.on(
        '/saved-items',
        status: 401,
        body: errorBody('INVALID_ACCESS_TOKEN'),
      );

      await expectLater(
        repository.list(),
        throwsA(isA<ApiFailureAuthRequired>()),
      );
    });

    test('maps a validation error to its own variant', () async {
      adapter.on(
        '/saved-items',
        status: 400,
        body: errorBody('VALIDATION_ERROR'),
      );

      await expectLater(
        repository.list(),
        throwsA(isA<ApiFailureValidation>()),
      );
    });

    test('maps INVALID_CURSOR through the defensive bucket', () async {
      // Documented for this route, but with no dedicated ApiFailure variant.
      // It lands in `ApiFailureUnreadableResponse`, whose copy is client-owned
      // and never shows the backend's code or message.
      adapter.on(
        '/saved-items',
        status: 400,
        body: errorBody('INVALID_CURSOR'),
      );

      final failure = await repository
          .list(cursor: 'garbage')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(failure, isA<ApiFailureUnreadableResponse>());
      expect(
        (failure as ApiFailureUnreadableResponse).code,
        'INVALID_CURSOR',
        reason: 'kept for diagnosis only; it is never rendered',
      );
    });

    test('never surfaces the backend message as the failure text', () async {
      adapter.on(
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.list(),
        throwsA(
          predicate((Object f) {
            // [D22] no variant carries a backend message.
            return f is ApiFailure &&
                !f.toString().contains('redacted for tests');
          }),
        ),
      );
    });
  });

  group('create', () {
    test('sends POST /saved-items with the url and nothing else', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(),
      );

      await repository.create(url: 'https://example.com/articles/1');

      final request = adapter.lastRequestTo('/saved-items')!;
      expect(request.method, 'POST');
      expect(
        adapter.countFor('/saved-items'),
        1,
        reason: 'one POST — no retry, no second attempt',
      );
      expect(request.body, {
        'url': 'https://example.com/articles/1',
      }, reason: 'exactly one field: the request model has no other');
    });

    test('accepts the documented 201', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: SavedItemsFixtures.created(url: 'https://example.com/articles/1'),
      );

      await expectLater(
        repository.create(url: 'https://example.com/articles/1'),
        completes,
      );
    });

    test('a 201 without the documented fields is not a success', () async {
      // The body is the *only* thing that can confirm the create here, so a
      // shape the client cannot read is reported as unreadable rather than
      // accepted. `enrichment_status` is the field most likely to be forgotten.
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: {
          'data': {
            'saved_item': {
              'id': 'a',
              'url': 'https://example.com/articles/1',
              'collection_id': 'b',
            },
          },
          'message': 'saved item created successfully',
        },
      );

      await expectLater(
        repository.create(url: 'https://example.com/articles/1'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a 201 with no data is not a success', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 201,
        body: {'data': null, 'message': 'saved item created successfully'},
      );

      await expectLater(
        repository.create(url: 'https://example.com/articles/1'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('maps INVALID_URL to the actionable validation variant', () async {
      // 400, emitted after the body parsed: the URL is not usable. The variant is
      // what tells the UI the user's input has to change, so it must not fall
      // into the "unrecognised code" bucket.
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 400,
        body: errorBody('INVALID_URL'),
      );

      await expectLater(
        repository.create(url: 'https://example.com'),
        throwsA(isA<ApiFailureValidation>()),
      );
    });

    test('keeps the Retry-After the server sent on a spent budget', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 429,
        body: errorBody('USER_RATE_LIMIT_EXCEEDED'),
        headers: {
          'retry-after': ['120'],
        },
      );

      final failure = await repository
          .create(url: 'https://example.com')
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(failure, isA<ApiFailureRateLimited>());
      expect(
        (failure! as ApiFailureRateLimited).retryAfter,
        const Duration(seconds: 120),
        reason: 'the countdown is the server\'s, never a client guess',
      );
    });

    test(
      'a limiter that failed closed is a server error, not a budget',
      () async {
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 503,
          body: errorBody('USER_RATE_LIMIT_UNAVAILABLE'),
        );

        await expectLater(
          repository.create(url: 'https://example.com'),
          throwsA(isA<ApiFailureServerUnavailable>()),
        );
      },
    );

    test('a 500 from the insert is a known failure', () async {
      adapter.onMethod(
        'POST',
        '/saved-items',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.create(url: 'https://example.com'),
        throwsA(isA<ApiFailureServerFault>()),
      );
    });

    test(
      'a reply whose body cannot be read is unreadable, not a refusal',
      () async {
        // A gateway answering in HTML. The taxonomy cannot tell this apart from a
        // `201` whose body failed to decode, and the second one means the save
        // committed — so neither may be reported as a known failure.
        adapter.onMethod(
          'POST',
          '/saved-items',
          status: 502,
          body: '<html><body>Bad gateway</body></html>',
        );

        await expectLater(
          repository.create(url: 'https://example.com'),
          throwsA(isA<ApiFailureUnreadableResponse>()),
        );
      },
    );

    test('a request that never arrives is uncertain', () async {
      adapter.onOffline('/saved-items', method: 'POST');

      await expectLater(
        repository.create(url: 'https://example.com'),
        throwsA(isA<ApiFailureTransport>()),
      );
    });
  });

  group('move to collection', () {
    const id = '01a0f359-093b-737a-963a-80f7ca6768ed';
    const path = '/saved-items/$id/collection';

    test('PUTs the name and intent and decodes the stored result', () async {
      adapter.onMethod(
        'PUT',
        path,
        body: SavedItemsFixtures.moved(
          savedItemId: id,
          collectionName: 'Reading List',
          collectionCreated: true,
        ),
      );

      final result = await repository.moveToCollection(
        savedItemId: id,
        collectionName: 'Reading List',
        intent: MoveToCollectionIntent.create,
      );

      final request = adapter.lastRequestTo(path)!;
      expect(request.method, 'PUT');
      expect(adapter.countFor(path), 1, reason: 'one explicit write');
      expect(request.body, {
        'collection_name': 'Reading List',
        'collection_intent': 'create',
      });
      expect(
        (request.body as Map<String, dynamic>).containsKey('collection_id'),
        isFalse,
        reason: 'the contract resolves a name; it has no id field',
      );

      expect(result.collectionName, 'Reading List');
      expect(result.collectionCreated, isTrue);
      expect(result.alreadyInCollection, isFalse);
    });

    test('serializes the existing intent exactly', () async {
      adapter.onMethod(
        'PUT',
        path,
        body: SavedItemsFixtures.moved(
          savedItemId: id,
          collectionName: 'YouTube',
        ),
      );

      await repository.moveToCollection(
        savedItemId: id,
        collectionName: 'YouTube',
        intent: MoveToCollectionIntent.existing,
      );

      expect(adapter.lastRequestTo(path)!.body, {
        'collection_name': 'YouTube',
        'collection_intent': 'existing',
      });
    });

    test(
      'accepts already_in_collection without treating it as a conflict',
      () async {
        adapter.onMethod(
          'PUT',
          path,
          body: SavedItemsFixtures.moved(
            savedItemId: id,
            collectionName: 'Wishlist',
            alreadyInCollection: true,
          ),
        );

        final result = await repository.moveToCollection(
          savedItemId: id,
          collectionName: 'wishlist',
          intent: MoveToCollectionIntent.existing,
        );

        expect(adapter.countFor(path), 1);
        expect(result.alreadyInCollection, isTrue);
        expect(result.collectionName, 'Wishlist');
      },
    );

    test('maps INVALID_COLLECTION_NAME to validation', () async {
      adapter.onMethod(
        'PUT',
        path,
        status: 400,
        body: errorBody('INVALID_COLLECTION_NAME'),
      );

      await expectLater(
        repository.moveToCollection(
          savedItemId: id,
          collectionName: 'bad',
          intent: MoveToCollectionIntent.create,
        ),
        throwsA(isA<ApiFailureValidation>()),
      );
    });

    test('maps COLLECTION_NAME_ALREADY_EXISTS to its own conflict', () async {
      adapter.onMethod(
        'PUT',
        path,
        status: 409,
        body: errorBody('COLLECTION_NAME_ALREADY_EXISTS'),
      );

      final failure = await repository
          .moveToCollection(
            savedItemId: id,
            collectionName: 'Unsorted',
            intent: MoveToCollectionIntent.create,
          )
          .then<Object?>((_) => null, onError: (Object error) => error);

      expect(failure, isA<ApiFailureCollectionNameAlreadyExists>());
      expect(
        (failure! as ApiFailureCollectionNameAlreadyExists).code,
        'COLLECTION_NAME_ALREADY_EXISTS',
        reason: 'diagnosis only; no owning collection is named',
      );
    });

    test('maps SAVED_ITEM_NOT_FOUND to not-found, not unreadable', () async {
      adapter.onMethod(
        'PUT',
        path,
        status: 404,
        body: errorBody('SAVED_ITEM_NOT_FOUND'),
      );

      final failure = await repository
          .moveToCollection(
            savedItemId: id,
            collectionName: 'Wishlist',
            intent: MoveToCollectionIntent.existing,
          )
          .then<Object?>((_) => null, onError: (Object error) => error);

      expect(failure, isA<ApiFailureNotFound>());
      expect((failure! as ApiFailureNotFound).code, 'SAVED_ITEM_NOT_FOUND');
    });

    test('a 200 whose body does not decode is unreadable', () async {
      // The status passed validation, so the write may have committed. The
      // repository reports an unestablished representation, never a known
      // failure, and the caller reconciles.
      final body = SavedItemsFixtures.moved();
      (body['data'] as Map<String, dynamic>).remove('collection');
      adapter.onMethod('PUT', path, body: body);

      await expectLater(
        repository.moveToCollection(
          savedItemId: id,
          collectionName: 'Wishlist',
          intent: MoveToCollectionIntent.existing,
        ),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a request that never arrives is transport', () async {
      adapter.onOffline(path, method: 'PUT');

      await expectLater(
        repository.moveToCollection(
          savedItemId: id,
          collectionName: 'Wishlist',
          intent: MoveToCollectionIntent.existing,
        ),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('a 500 maps to a server fault at the boundary', () async {
      adapter.onMethod(
        'PUT',
        path,
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.moveToCollection(
          savedItemId: id,
          collectionName: 'Wishlist',
          intent: MoveToCollectionIntent.existing,
        ),
        throwsA(isA<ApiFailureServerFault>()),
      );
    });
  });

  group('detail', () {
    const id = '01a0f359-093b-737a-963a-80f7ca6768ed';
    const path = '/saved-items/$id';

    test('GETs one item by id and maps the sibling collection', () async {
      adapter.onMethod(
        'GET',
        path,
        body: SavedItemsFixtures.detail(
          id: id,
          title: 'One item',
          collectionName: 'Wishlist',
        ),
      );

      final item = await repository.getById(id);

      expect(adapter.countFor(path), 1, reason: 'one read, no retry');
      final request = adapter.lastRequestTo(path)!;
      expect(request.method, 'GET');
      expect(Uri.parse(request.path).path, path);
      expect(
        Uri.parse(request.path).hasQuery,
        isFalse,
        reason: 'the id is a path parameter, not query state',
      );

      expect(item.id, id);
      expect(item.title, 'One item');
      expect(
        item.collectionName,
        'Wishlist',
        reason: 'the name comes from the sibling collection object',
      );
    });

    test('maps the verified RESOURCE_NOT_FOUND to typed not-found', () async {
      adapter.onMethod(
        'GET',
        path,
        status: 404,
        body: errorBody('RESOURCE_NOT_FOUND'),
      );

      final failure = await repository
          .getById(id)
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(failure, isA<ApiFailureNotFound>());
      expect(
        (failure! as ApiFailureNotFound).code,
        'RESOURCE_NOT_FOUND',
        reason: 'retained for diagnosis, never displayed',
      );
    });

    test('an unreadable 404 is unreadable, not not-found', () async {
      // A gateway answering in HTML. The status alone is not evidence that the
      // resource is gone; only the verified code is.
      adapter.onMethod(
        'GET',
        path,
        status: 404,
        body: '<html><body>Not found</body></html>',
      );

      await expectLater(
        repository.getById(id),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a 404 with an unrecognised code is not not-found', () async {
      adapter.onMethod(
        'GET',
        path,
        status: 404,
        body: errorBody('SOMETHING_ELSE'),
      );

      await expectLater(
        repository.getById(id),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a 200 whose body does not decode is unreadable', () async {
      final body = SavedItemsFixtures.detail(id: id);
      ((body['data'] as Map<String, dynamic>)['saved_item']
              as Map<String, dynamic>)
          .remove('created_at');
      adapter.onMethod('GET', path, body: body);

      await expectLater(
        repository.getById(id),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test('a request that never arrives is transport', () async {
      adapter.onOffline(path, method: 'GET');

      await expectLater(
        repository.getById(id),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('a 401 is an auth requirement', () async {
      adapter.onMethod(
        'GET',
        path,
        status: 401,
        body: errorBody('INVALID_ACCESS_TOKEN'),
      );

      await expectLater(
        repository.getById(id),
        throwsA(isA<ApiFailureAuthRequired>()),
      );
    });
  });

  group('delete', () {
    const path = '/saved-items/item-1';

    test('sends DELETE and decodes the collection flags', () async {
      adapter.onMethod(
        'DELETE',
        path,
        body: SavedItemsFixtures.deleted(
          collectionId: 'collection-1',
          collectionEmpty: true,
          collectionDeletable: true,
        ),
      );

      final result = await repository.delete('item-1');

      expect(adapter.requests.single.method, 'DELETE');
      expect(adapter.requests.single.path, contains(path));
      expect(result, isA<SavedItemDeleted>());
      final deleted = result as SavedItemDeleted;
      expect(deleted.collectionId, 'collection-1');
      expect(deleted.collectionEmpty, isTrue);
      expect(deleted.collectionDeletable, isTrue);
    });

    test(
      'a 200 with an unreadable body still means the item was deleted',
      () async {
        // The row delete committed before the flags were read. Returning a
        // failure here would invite a retry of a write that already happened.
        adapter.onMethod(
          'DELETE',
          path,
          body: {'data': {}, 'message': 'saved item deleted successfully'},
        );

        final result = await repository.delete('item-1');

        expect(result, isA<SavedItemDeletionFlagsUnavailable>());
      },
    );

    test(
      'a 500 is a server fault, which the caller must treat as ambiguous',
      () async {
        adapter.onMethod(
          'DELETE',
          path,
          status: 500,
          body: errorBody('INTERNAL_SERVER_ERROR'),
        );

        await expectLater(
          repository.delete('item-1'),
          throwsA(isA<ApiFailureServerFault>()),
        );
      },
    );

    test('maps RESOURCE_NOT_FOUND to typed not-found', () async {
      adapter.onMethod(
        'DELETE',
        path,
        status: 404,
        body: errorBody('RESOURCE_NOT_FOUND'),
      );

      await expectLater(
        repository.delete('item-1'),
        throwsA(isA<ApiFailureNotFound>()),
      );
    });

    test('an unreadable 500 stays ambiguous rather than not-found', () async {
      adapter.onMethod(
        'DELETE',
        path,
        status: 500,
        body: '<html><body>Bad gateway</body></html>',
      );

      await expectLater(
        repository.delete('item-1'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });
}
