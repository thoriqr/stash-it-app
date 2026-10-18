import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/saved_items/data/datasources/saved_items_api.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_repository.dart';

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
}
