import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_repository.dart';
import 'package:stash_it_app/features/collections/data/datasources/collections_api.dart';

import '../../../support/fake_http.dart';

/// `DELETE /collections/{id}`: the request shape, the empty success body, and the
/// two collection-delete-specific refusals.
void main() {
  late FakeHttpAdapter adapter;
  late CollectionsRepository repository;

  const collectionId = 'collection-1';
  const path = '/collections/collection-1';

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    repository = CollectionsRepository(api: CollectionsApi(dio));
  });

  Map<String, dynamic> errorBody(String code) => {
    'error': {'code': code, 'message': 'backend prose is never displayed'},
  };

  test(
    'sends delete with an explicit null target and treats data:{} as success',
    () async {
      adapter.onMethod(
        'DELETE',
        path,
        body: {'data': {}, 'message': 'collection deleted successfully'},
      );

      await repository.delete(collectionId: collectionId);

      final request = adapter.requests.single;
      expect(request.method, 'DELETE');
      expect(request.path, contains(path));
      expect(request.body, {
        'saved_items_action': 'delete',
        'target_collection_id': null,
      });
    },
  );

  test('maps COLLECTION_NOT_EMPTY to the known not-deleted variant', () async {
    adapter.onMethod(
      'DELETE',
      path,
      status: 409,
      body: errorBody('COLLECTION_NOT_EMPTY'),
    );

    await expectLater(
      repository.delete(collectionId: collectionId),
      throwsA(isA<ApiFailureCollectionNotEmpty>()),
    );
  });

  test('maps UNSORTED_COLLECTION_PROTECTED to its own variant', () async {
    adapter.onMethod(
      'DELETE',
      path,
      status: 409,
      body: errorBody('UNSORTED_COLLECTION_PROTECTED'),
    );

    await expectLater(
      repository.delete(collectionId: collectionId),
      throwsA(isA<ApiFailureUnsortedCollectionProtected>()),
    );
  });

  test('move sends the action and the chosen destination together', () async {
    adapter.onMethod(
      'DELETE',
      path,
      body: {'data': {}, 'message': 'collection deleted successfully'},
    );

    await repository.moveItemsAndDelete(
      collectionId: collectionId,
      targetCollectionId: 'collection-2',
    );

    // One request carries both fields: there is no per-item move and no second
    // call that could leave the collection deleted with its items stranded.
    expect(adapter.requests.single.body, {
      'saved_items_action': 'move',
      'target_collection_id': 'collection-2',
    });
  });

  test('maps COLLECTION_DELETE_TARGET_NOT_FOUND to the destination', () async {
    adapter.onMethod(
      'DELETE',
      path,
      status: 404,
      body: errorBody('COLLECTION_DELETE_TARGET_NOT_FOUND'),
    );

    await expectLater(
      repository.moveItemsAndDelete(
        collectionId: collectionId,
        targetCollectionId: 'collection-2',
      ),
      throwsA(isA<ApiFailureCollectionDeleteTargetNotFound>()),
    );
  });

  test('maps an unavailable collection to typed not-found', () async {
    adapter.onMethod(
      'DELETE',
      path,
      status: 404,
      body: errorBody('COLLECTION_NOT_FOUND'),
    );

    await expectLater(
      repository.delete(collectionId: collectionId),
      throwsA(isA<ApiFailureNotFound>()),
    );
  });

  test('maps the two incoherent-body codes to malformed request', () async {
    adapter.onSequence(path, [
      FakeReply(400, errorBody('INVALID_COLLECTION_DELETE_ACTION')),
      FakeReply(400, errorBody('INVALID_COLLECTION_DELETE_TARGET')),
    ]);

    await expectLater(
      repository.delete(collectionId: collectionId),
      throwsA(isA<ApiFailureMalformedRequest>()),
      reason: 'INVALID_COLLECTION_DELETE_ACTION',
    );
    await expectLater(
      repository.delete(collectionId: collectionId),
      throwsA(isA<ApiFailureMalformedRequest>()),
      reason: 'INVALID_COLLECTION_DELETE_TARGET',
    );
  });

  test('a 500 is a server fault, not a success with an empty body', () async {
    adapter.onMethod(
      'DELETE',
      path,
      status: 500,
      body: errorBody('INTERNAL_SERVER_ERROR'),
    );

    await expectLater(
      repository.delete(collectionId: collectionId),
      throwsA(isA<ApiFailureServerFault>()),
    );
  });
}
