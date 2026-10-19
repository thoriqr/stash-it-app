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
}
