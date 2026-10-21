import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/search/data/datasources/search_api.dart';
import 'package:stash_it_app/features/search/data/search_repository.dart';

import '../../../support/fake_http.dart';
import '../../../support/search_fixtures.dart';

/// The repository: envelope decoding, the exact request, and failure mapping.
void main() {
  late FakeHttpAdapter adapter;
  late Dio dio;
  late SearchRepository repository;

  final now = DateTime.utc(2026, 10, 2, 12, 0);

  setUp(() {
    adapter = FakeHttpAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    repository = SearchRepository(api: SearchApi(dio), now: () => now);
  });

  group('request', () {
    test('sends GET /search with q and no other parameter', () async {
      adapter.on('/search', body: SearchFixtures.emptyResponse());

      await repository.search('camera');

      final request = adapter.lastRequestTo('/search')!;
      expect(request.method, 'GET');

      final uri = Uri.parse(request.path);
      expect(uri.path, '/search');
      expect(uri.queryParameters, {'q': 'camera'});
      expect(
        uri.queryParameters.keys,
        ['q'],
        reason: 'no limit, page, cursor or sort parameter exists on this route',
      );
    });

    test(
      'sends the query exactly as supplied, without rewriting case',
      () async {
        adapter.on('/search', body: SearchFixtures.emptyResponse());

        await repository.search('Camera Gear');

        expect(
          Uri.parse(
            adapter.lastRequestTo('/search')!.path,
          ).queryParameters['q'],
          'Camera Gear',
        );
      },
    );
  });

  group('success', () {
    test('decodes both groups in the server order', () async {
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          collections: [
            SearchFixtures.collection(id: 'c2', name: 'Second'),
            SearchFixtures.collection(id: 'c1', name: 'First'),
          ],
          savedItems: [
            SearchFixtures.savedItem(id: 'i2', title: 'Second'),
            SearchFixtures.savedItem(id: 'i1', title: 'First'),
          ],
        ),
      );

      final results = await repository.search('camera');

      expect(results.collections.map((c) => c.id), ['c2', 'c1']);
      expect(results.savedItems.map((i) => i.id), ['i2', 'i1']);
      expect(results.isEmpty, isFalse);
    });

    test('an empty 200 is a successful empty result', () async {
      adapter.on('/search', body: SearchFixtures.emptyResponse());

      final results = await repository.search('camera');

      expect(results.collections, isEmpty);
      expect(results.savedItems, isEmpty);
      expect(results.isEmpty, isTrue);
    });

    test(
      'an empty group is not an error while the other has results',
      () async {
        adapter.on(
          '/search',
          body: SearchFixtures.response(
            collections: [SearchFixtures.collection(id: 'c1')],
          ),
        );

        final results = await repository.search('camera');

        expect(results.collections, hasLength(1));
        expect(results.savedItems, isEmpty);
        expect(results.isEmpty, isFalse);
      },
    );
  });

  group('failures', () {
    test('INVALID_SEARCH_QUERY is an actionable validation failure', () async {
      adapter.on(
        '/search',
        status: 400,
        body: errorBody('INVALID_SEARCH_QUERY'),
      );

      final failure = await repository
          .search('ca')
          .then<Object?>((_) => null, onError: (Object error) => error);

      expect(failure, isA<ApiFailureValidation>());
      expect(failure, isNot(isA<ApiFailureUnreadableResponse>()));
    });

    test('a spent search budget keeps the server Retry-After', () async {
      adapter.on(
        '/search',
        status: 429,
        body: errorBody('USER_RATE_LIMIT_EXCEEDED'),
        headers: {
          'retry-after': ['45'],
        },
      );

      final failure = await repository
          .search('camera')
          .then<Object?>((_) => null, onError: (Object error) => error);

      expect(failure, isA<ApiFailureRateLimited>());
      expect(
        (failure! as ApiFailureRateLimited).retryAfter,
        const Duration(seconds: 45),
      );
    });

    test('a limiter that failed closed is server-unavailable', () async {
      adapter.on(
        '/search',
        status: 503,
        body: errorBody('USER_RATE_LIMIT_UNAVAILABLE'),
      );

      await expectLater(
        repository.search('camera'),
        throwsA(isA<ApiFailureServerUnavailable>()),
      );
    });

    test('a 500 is a server fault', () async {
      adapter.on(
        '/search',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.search('camera'),
        throwsA(isA<ApiFailureServerFault>()),
      );
    });

    test('a request that never arrives is a transport failure', () async {
      adapter.onOffline('/search');

      await expectLater(
        repository.search('camera'),
        throwsA(isA<ApiFailureTransport>()),
      );
    });

    test('a null data payload is unreadable rather than empty', () async {
      adapter.on(
        '/search',
        body: {'data': null, 'message': 'search completed successfully'},
      );

      await expectLater(
        repository.search('camera'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });

    test(
      'a missing result array is unreadable, not treated as empty',
      () async {
        adapter.on(
          '/search',
          body: {
            'data': {
              'saved_items': [SearchFixtures.savedItem()],
            },
            'message': 'search completed successfully',
          },
        );

        await expectLater(
          repository.search('camera'),
          throwsA(isA<ApiFailureUnreadableResponse>()),
        );
      },
    );

    test('never surfaces the backend message as the failure text', () async {
      adapter.on(
        '/search',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      await expectLater(
        repository.search('camera'),
        throwsA(
          predicate((Object failure) {
            // [D22] no variant carries a backend message.
            return failure is ApiFailure &&
                !failure.toString().contains('redacted for tests');
          }),
        ),
      );
    });
  });
}
