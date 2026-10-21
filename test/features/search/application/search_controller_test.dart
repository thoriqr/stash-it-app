import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/search/application/search_controller.dart';
import 'package:stash_it_app/features/search/application/search_state.dart';
import 'package:stash_it_app/features/search/data/datasources/search_api.dart';
import 'package:stash_it_app/features/search/data/search_providers.dart';
import 'package:stash_it_app/features/search/data/search_repository.dart';

import '../../../support/fake_http.dart';
import '../../../support/search_fixtures.dart';

/// The Search lifecycle: no request until submission, local rune validation,
/// stale-response protection, clearing, and manual-only recovery.
///
/// Drives the real repository and Retrofit client against a scripted transport.
/// The repository provider is overridden with one built on that transport, so no
/// socket and no auth pipeline are involved.
void main() {
  late FakeHttpAdapter adapter;

  final now = DateTime.utc(2026, 10, 2, 12, 0);

  setUp(() => adapter = FakeHttpAdapter());

  /// A container with a scripted transport and one live listener, which an
  /// auto-dispose provider needs in order to stay alive across awaits.
  ProviderContainer makeContainer() {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    final container = ProviderContainer(
      overrides: [
        searchRepositoryProvider.overrideWithValue(
          SearchRepository(api: SearchApi(dio), now: () => now),
        ),
      ],
      // Search's own annotation already refuses retries; this also keeps any
      // unrelated provider build in the test from arming a backoff timer.
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    final subscription = container.listen(
      searchProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    return container;
  }

  void scriptResponse({
    List<Map<String, dynamic>> savedItems = const [],
    List<Map<String, dynamic>> collections = const [],
  }) {
    adapter.on(
      '/search',
      body: SearchFixtures.response(
        savedItems: savedItems,
        collections: collections,
      ),
    );
  }

  group('initial state', () {
    test('performs no request', () {
      final container = makeContainer();

      expect(container.read(searchProvider), isA<SearchInitial>());
      expect(adapter.requests, isEmpty);
    });
  });

  group('submission', () {
    test('trims the query and fetches both groups', () async {
      scriptResponse(
        collections: [SearchFixtures.collection(id: 'c1', name: 'Camera Gear')],
        savedItems: [
          SearchFixtures.savedItem(id: 'i1', title: 'A sensor guide'),
          SearchFixtures.savedItem(id: 'i2', title: 'A field review'),
        ],
      );
      final container = makeContainer();

      await container.read(searchProvider.notifier).submit('  camera  ');

      expect(
        Uri.parse(adapter.lastRequestTo('/search')!.path).queryParameters['q'],
        'camera',
      );

      final state = container.read(searchProvider);
      expect(state, isA<SearchSuccess>());
      state as SearchSuccess;
      expect(state.query, 'camera');
      expect(state.collections.map((c) => c.id), ['c1']);
      expect(state.savedItems.map((i) => i.id), ['i1', 'i2']);
    });

    test('a local-invalid query never reaches the network', () async {
      final container = makeContainer();

      for (final invalid in ['', '   ', 'a', ' a ', 'a' * 129]) {
        await container.read(searchProvider.notifier).submit(invalid);
        expect(
          adapter.requests,
          isEmpty,
          reason: '"$invalid" must be rejected locally',
        );
        expect(container.read(searchProvider), isA<SearchInitial>());
      }
    });

    test('counts Unicode runes, not UTF-16 units or UTF-8 bytes', () async {
      scriptResponse();
      final container = makeContainer();

      // Two runes that occupy two UTF-16 units and four UTF-8 bytes.
      await container.read(searchProvider.notifier).submit('éé');
      expect(adapter.countFor('/search'), 1);

      // Two emoji are two runes but four UTF-16 units.
      await container.read(searchProvider.notifier).submit('😀😀');
      expect(adapter.countFor('/search'), 2);
    });

    test('accepts exactly 128 runes and rejects 129', () async {
      scriptResponse();
      final container = makeContainer();

      await container.read(searchProvider.notifier).submit('é' * 128);
      expect(adapter.countFor('/search'), 1);

      await container.read(searchProvider.notifier).submit('é' * 129);
      expect(
        adapter.countFor('/search'),
        1,
        reason: '129 runes is over the backend limit',
      );

      // 129 emoji are 129 runes although they occupy 258 UTF-16 units, so this
      // also proves the check is not a UTF-16 unit or byte count.
      await container
          .read(searchProvider.notifier)
          .submit(String.fromCharCode(0x1F600) * 128);
      expect(adapter.countFor('/search'), 2);

      await container
          .read(searchProvider.notifier)
          .submit(String.fromCharCode(0x1F600) * 129);
      expect(
        adapter.countFor('/search'),
        2,
        reason: '129 runes is over the backend limit',
      );
    });

    test('an empty success is distinct from a failure', () async {
      scriptResponse();
      final container = makeContainer();

      await container.read(searchProvider.notifier).submit('nothing');

      final state = container.read(searchProvider);
      expect(state, isA<SearchSuccess>());
      state as SearchSuccess;
      expect(state.collections, isEmpty);
      expect(state.savedItems, isEmpty);
    });

    test(
      'a failure retains the submitted query and the typed failure',
      () async {
        adapter.on(
          '/search',
          status: 500,
          body: errorBody('INTERNAL_SERVER_ERROR'),
        );
        final container = makeContainer();

        await container.read(searchProvider.notifier).submit('camera');

        final state = container.read(searchProvider);
        expect(state, isA<SearchFailure>());
        state as SearchFailure;
        expect(state.query, 'camera');
        expect(state.failure, isA<ApiFailureServerFault>());
      },
    );
  });

  group('clearing', () {
    test('resets the screen and invalidates an in-flight response', () async {
      adapter.onBlocking(
        '/search',
        FakeReply(
          200,
          SearchFixtures.response(
            savedItems: [SearchFixtures.savedItem(id: 'stale')],
          ),
        ),
      );
      final container = makeContainer();

      final inFlight = container.read(searchProvider.notifier).submit('camera');
      await untilCalled(() => adapter.countFor('/search') == 1);
      expect(container.read(searchProvider), isA<SearchLoading>());

      container.read(searchProvider.notifier).clear();
      expect(container.read(searchProvider), isA<SearchInitial>());

      adapter.releaseBlocked();
      await inFlight;

      expect(
        container.read(searchProvider),
        isA<SearchInitial>(),
        reason: 'a cleared screen must not receive the old answer',
      );
    });
  });

  group('stale responses', () {
    test('a superseded request cannot replace newer results', () async {
      final first = SearchFixtures.response(
        savedItems: [SearchFixtures.savedItem(id: 'first', title: 'First')],
      );
      final second = SearchFixtures.response(
        savedItems: [SearchFixtures.savedItem(id: 'second', title: 'Second')],
      );
      adapter.onSequenceHolding('/search', [
        FakeReply(200, first),
        FakeReply(200, second),
      ], holdAt: 1);
      final container = makeContainer();

      final firstRequest = container
          .read(searchProvider.notifier)
          .submit('first');
      await untilCalled(() => adapter.countFor('/search') == 1);

      final secondRequest = container
          .read(searchProvider.notifier)
          .submit('second');
      await secondRequest;
      expect(
        (container.read(searchProvider) as SearchSuccess).savedItems.single.id,
        'second',
      );

      adapter.releaseBlocked();
      await firstRequest;

      final state = container.read(searchProvider);
      expect(state, isA<SearchSuccess>());
      expect((state as SearchSuccess).query, 'second');
      expect(state.savedItems.single.id, 'second');
    });
  });

  group('recovery', () {
    test('a failed request is not retried automatically', () async {
      adapter.on(
        '/search',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      final container = makeContainer();

      await container.read(searchProvider.notifier).submit('camera');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        adapter.countFor('/search'),
        1,
        reason: 'no Riverpod retry and no client retry loop',
      );
      expect(container.read(searchProvider), isA<SearchFailure>());
    });

    test('Retry resubmits the failed query once', () async {
      adapter.onSequence('/search', [
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
        FakeReply(
          200,
          SearchFixtures.response(
            savedItems: [SearchFixtures.savedItem(id: 'i1')],
          ),
        ),
      ]);
      final container = makeContainer();

      await container.read(searchProvider.notifier).submit('camera');
      expect(container.read(searchProvider), isA<SearchFailure>());

      await container.read(searchProvider.notifier).retry();

      final state = container.read(searchProvider);
      expect(state, isA<SearchSuccess>());
      expect((state as SearchSuccess).query, 'camera');
      expect(adapter.countFor('/search'), 2);
    });
  });
}
