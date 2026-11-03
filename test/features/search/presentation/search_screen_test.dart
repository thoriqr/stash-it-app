import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/search/data/datasources/search_api.dart';
import 'package:stash_it_app/features/search/data/search_providers.dart';
import 'package:stash_it_app/features/search/data/search_repository.dart';
import 'package:stash_it_app/features/search/presentation/search_screen.dart';
import 'package:stash_it_app/features/search/presentation/widgets/search_collection_row.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../../../support/fake_http.dart';
import '../../../support/search_fixtures.dart';

/// The Search screen: explicit submission, two ordered groups, and the four
/// answers it must keep distinguishable.
void main() {
  late FakeHttpAdapter adapter;

  final now = DateTime.utc(2026, 10, 2, 12, 0);

  setUp(() => adapter = FakeHttpAdapter());

  /// A tall surface so a ListView builds every result the assertions need.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpSearch(WidgetTester tester, {Locale? locale}) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchRepositoryProvider.overrideWithValue(
            SearchRepository(api: SearchApi(dio), now: () => now),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SearchScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
  }

  group('initial state', () {
    testWidgets('shows the discovery copy and sends no request', (
      tester,
    ) async {
      await pumpSearch(tester);

      expect(find.text('Find something you saved'), findsOneWidget);
      expect(
        find.text(
          'Search matches item titles, domains, URLs and collection names.',
        ),
        findsOneWidget,
      );
      expect(find.text('Search saved items and collections'), findsOneWidget);
      expect(find.text('SEARCH'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(adapter.requests, isEmpty);
    });
  });

  group('submission', () {
    testWidgets('typing alone sends no request but reveals the clear icon', (
      tester,
    ) async {
      await pumpSearch(tester);

      await tester.enterText(find.byType(TextField), 'camera');
      await tester.pump();

      expect(adapter.requests, isEmpty);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Find something you saved'), findsOneWidget);
    });

    testWidgets('the keyboard search action submits the trimmed query', (
      tester,
    ) async {
      adapter.on('/search', body: SearchFixtures.emptyResponse());
      await pumpSearch(tester);

      await submit(tester, '  camera  ');
      await tester.pumpAndSettle();

      expect(
        Uri.parse(adapter.lastRequestTo('/search')!.path).queryParameters['q'],
        'camera',
      );
      expect(find.text('No matches for \u2018camera\u2019'), findsOneWidget);
    });

    testWidgets('an invalid query is explained locally and never sent', (
      tester,
    ) async {
      await pumpSearch(tester);

      await submit(tester, 'a');
      await tester.pump();

      expect(find.text('Search needs at least 2 characters.'), findsOneWidget);
      expect(adapter.requests, isEmpty);

      // The input is retained for correction, and editing dismisses the note.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'a');

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();
      expect(find.text('Search needs at least 2 characters.'), findsNothing);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('a whitespace-only query is empty, not short', (tester) async {
      await pumpSearch(tester);

      await submit(tester, '   ');
      await tester.pump();

      expect(find.text('Enter something to search for.'), findsOneWidget);
      expect(adapter.requests, isEmpty);
    });

    testWidgets('a query over 128 runes is refused locally', (tester) async {
      await pumpSearch(tester);

      await submit(tester, 'é' * 129);
      await tester.pump();

      expect(
        find.text(
          'Search is limited to 128 characters. Shorten it and try again.',
        ),
        findsOneWidget,
      );
      expect(adapter.requests, isEmpty);
    });
  });

  group('results', () {
    testWidgets('renders Collections before Saved Items in server order', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          collections: [
            SearchFixtures.collection(id: 'c2', name: 'Second Collection'),
            SearchFixtures.collection(id: 'c1', name: 'First Collection'),
          ],
          savedItems: [
            SearchFixtures.savedItem(id: 'i2', title: 'Second Item'),
            SearchFixtures.savedItem(id: 'i1', title: 'First Item'),
          ],
        ),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('COLLECTIONS'), findsOneWidget);
      expect(find.text('SAVED ITEMS'), findsOneWidget);

      final collectionsY = tester.getTopLeft(find.text('COLLECTIONS')).dy;
      final savedItemsY = tester.getTopLeft(find.text('SAVED ITEMS')).dy;
      expect(collectionsY, lessThan(savedItemsY));

      // Each group keeps the order the server sent, even though the ids are
      // not alphabetical.
      final secondCollectionY = tester
          .getTopLeft(find.text('Second Collection'))
          .dy;
      final firstCollectionY = tester
          .getTopLeft(find.text('First Collection'))
          .dy;
      expect(secondCollectionY, lessThan(firstCollectionY));

      final secondItemY = tester.getTopLeft(find.text('Second Item')).dy;
      final firstItemY = tester.getTopLeft(find.text('First Item')).dy;
      expect(secondItemY, lessThan(firstItemY));
    });

    testWidgets('a group with no results is hidden, not drawn empty', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          collections: [SearchFixtures.collection(name: 'Camera Gear')],
        ),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('COLLECTIONS'), findsOneWidget);
      expect(find.text('SAVED ITEMS'), findsNothing);
      expect(find.textContaining('No matches for'), findsNothing);
    });

    testWidgets('a group with no matches is hidden when the other matched', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          savedItems: [SearchFixtures.savedItem(title: 'A sensor guide')],
        ),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('SAVED ITEMS'), findsOneWidget);
      expect(find.text('COLLECTIONS'), findsNothing);
      expect(find.textContaining('No matches for'), findsNothing);
    });

    testWidgets('collection rows carry no trailing kind or chevron', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          collections: [SearchFixtures.collection(name: 'Camera Gear')],
        ),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.byType(SearchCollectionRow), findsOneWidget);
      expect(find.text('Camera Gear'), findsOneWidget);
      expect(find.text('collection'), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('saved rows offer no Retry but are wired to the detail route', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          savedItems: [
            SearchFixtures.savedItem(
              id: 'i1',
              title: null,
              enrichmentStatus: 'pending',
            ),
            SearchFixtures.savedItem(
              id: 'i2',
              title: 'A failed read',
              enrichmentStatus: 'failed',
            ),
          ],
        ),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.byType(SavedItemRow), findsNWidgets(2));
      expect(find.text('Retry'), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);

      // The route-level test in `test/app/search_navigation_test.dart` verifies
      // where a tap goes. Here the row must simply carry a tap handler while
      // still offering no enrichment action.
      final rows = tester.widgetList<SavedItemRow>(find.byType(SavedItemRow));
      expect(rows, isNotEmpty);
      expect(rows.every((row) => row.onTap != null), isTrue);

      // The shared row still reports the two states accurately; Search has not
      // suppressed the enrichment wording, only the action.
      expect(find.text('Reading page…'), findsOneWidget);
      expect(find.text("Couldn't read this page"), findsOneWidget);
    });
  });

  group('empty result', () {
    testWidgets('is a successful message, not an error', (tester) async {
      adapter.on('/search', body: SearchFixtures.emptyResponse());
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('No matches for \u2018camera\u2019'), findsOneWidget);
      expect(
        find.textContaining('may still match by title, domain, URL'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsNothing);
      expect(find.text('COLLECTIONS'), findsNothing);
      expect(find.text('SAVED ITEMS'), findsNothing);
      // No claim about whether anything was ever saved.
      expect(find.textContaining('never saved'), findsNothing);
    });
  });

  group('loading', () {
    testWidgets('is a compact spinner, never a result skeleton', (
      tester,
    ) async {
      adapter.onBlocking(
        '/search',
        FakeReply(200, SearchFixtures.emptyResponse()),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Skeletonizer), findsNothing);
      // The field stays usable while the request is in flight.
      expect(find.byType(TextField), findsOneWidget);

      adapter.releaseBlocked();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'the clear icon resets and prevents a late answer from reappearing',
      (tester) async {
        adapter.onBlocking(
          '/search',
          FakeReply(
            200,
            SearchFixtures.response(
              savedItems: [SearchFixtures.savedItem(title: 'Stale Item')],
            ),
          ),
        );
        await pumpSearch(tester);

        await submit(tester, 'camera');
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        expect(find.text('Find something you saved'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );

        adapter.releaseBlocked();
        await tester.pumpAndSettle();

        expect(find.text('Find something you saved'), findsOneWidget);
        expect(find.text('Stale Item'), findsNothing);
        expect(
          adapter.countFor('/search'),
          1,
          reason: 'clearing is not an empty search',
        );
      },
    );
  });

  group('failure', () {
    testWidgets('shows client copy and a Retry action, never the message', (
      tester,
    ) async {
      adapter.on(
        '/search',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );
      await pumpSearch(tester);

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('Search did not run'), findsOneWidget);
      expect(
        find.text('We could not reach the server. Try again shortly.'),
        findsOneWidget,
      );
      expect(find.textContaining('redacted for tests'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
      'INVALID_SEARCH_QUERY gets the validation copy, not unreadable',
      (tester) async {
        adapter.on(
          '/search',
          status: 400,
          body: errorBody('INVALID_SEARCH_QUERY'),
        );
        await pumpSearch(tester);

        await submit(tester, 'camera');
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Search needs between 2 and 128 characters. Check your search and '
            'try again.',
          ),
          findsOneWidget,
        );
        expect(
          find.text("We couldn't read the server's reply. Try again."),
          findsNothing,
        );
      },
    );
  });

  group('Indonesian localization', () {
    testWidgets('renders the title, placeholder and initial state', (
      tester,
    ) async {
      await pumpSearch(tester, locale: const Locale('id'));

      expect(find.text('CARI'), findsOneWidget);
      expect(find.text('Cari item tersimpan dan koleksi'), findsOneWidget);
      expect(find.text('Temukan sesuatu yang Anda simpan'), findsOneWidget);
      expect(
        find.text(
          'Pencarian mencocokkan judul item, domain, URL, dan nama koleksi.',
        ),
        findsOneWidget,
      );
      expect(adapter.requests, isEmpty);
    });

    testWidgets('renders all local validation messages', (tester) async {
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, '   ');
      await tester.pump();
      expect(find.text('Masukkan sesuatu untuk dicari.'), findsOneWidget);

      await submit(tester, 'a');
      await tester.pump();
      expect(
        find.text('Pencarian membutuhkan setidaknya 2 karakter.'),
        findsOneWidget,
      );

      await submit(tester, 'é' * 129);
      await tester.pump();
      expect(
        find.text('Pencarian dibatasi 128 karakter. Persingkat dan coba lagi.'),
        findsOneWidget,
      );
      expect(adapter.requests, isEmpty);
    });

    testWidgets('zero results keep the query unchanged', (tester) async {
      adapter.on('/search', body: SearchFixtures.emptyResponse());
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(
        find.text('Tidak ada hasil untuk \u2018camera\u2019'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Item mungkin masih cocok berdasarkan judul, domain, URL, atau nama koleksi. Coba kata lain, atau jelajahi Koleksi.',
        ),
        findsOneWidget,
      );
      expect(
        Uri.parse(adapter.lastRequestTo('/search')!.path).queryParameters['q'],
        'camera',
      );
      expect(find.text('KOLEKSI'), findsNothing);
      expect(find.text('ITEM TERSIMPAN'), findsNothing);
    });

    testWidgets('renders group headings and preserves server content', (
      tester,
    ) async {
      useTallSurface(tester);
      adapter.on(
        '/search',
        body: SearchFixtures.response(
          collections: [SearchFixtures.collection(name: 'Nama Koleksi')],
          savedItems: [
            SearchFixtures.savedItem(
              title: 'Judul Server',
              url: 'https://example.com/server-item',
              domain: 'example.com',
              collectionName: 'Koleksi Server',
            ),
          ],
        ),
      );
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('KOLEKSI'), findsOneWidget);
      expect(find.text('ITEM TERSIMPAN'), findsOneWidget);
      expect(find.text('Nama Koleksi'), findsOneWidget);
      expect(find.text('Judul Server'), findsOneWidget);
      expect(find.text('Koleksi Server'), findsOneWidget);
      expect(
        Uri.parse(adapter.lastRequestTo('/search')!.path).queryParameters['q'],
        'camera',
      );
    });

    testWidgets('localizes the clear tooltip and loading semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      adapter.onBlocking(
        '/search',
        FakeReply(
          200,
          SearchFixtures.response(
            savedItems: [SearchFixtures.savedItem(title: 'Stale Item')],
          ),
        ),
      );
      await pumpSearch(tester, locale: const Locale('id'));

      await tester.enterText(find.byType(TextField), 'camera');
      await tester.pump();
      expect(find.byTooltip('Kosongkan'), findsOneWidget);

      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(find.bySemanticsLabel('Mencari'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.text('Temukan sesuatu yang Anda simpan'), findsOneWidget);
      expect(find.bySemanticsLabel('Mencari'), findsNothing);
      expect(find.byTooltip('Kosongkan'), findsNothing);

      adapter.releaseBlocked();
      await tester.pumpAndSettle();
      expect(find.text('Temukan sesuatu yang Anda simpan'), findsOneWidget);
      expect(find.text('Stale Item'), findsNothing);

      semantics.dispose();
    });

    testWidgets('renders typed server errors and retries', (tester) async {
      adapter.onSequence('/search', [
        FakeReply.error(500, 'INTERNAL_SERVER_ERROR'),
        FakeReply(
          200,
          SearchFixtures.response(
            savedItems: [SearchFixtures.savedItem(title: 'Recovered Item')],
          ),
        ),
      ]);
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(find.text('Pencarian tidak berjalan'), findsOneWidget);
      expect(
        find.text(
          'Kami tidak dapat menghubungi server. Coba lagi sebentar lagi.',
        ),
        findsOneWidget,
      );
      expect(find.text('Coba lagi'), findsOneWidget);

      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Recovered Item'), findsOneWidget);
      expect(find.text('Pencarian tidak berjalan'), findsNothing);
    });

    testWidgets('renders the transport failure copy', (tester) async {
      adapter.onOffline('/search');
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tidak ada koneksi ke server. Kami tidak dapat menjalankan pencarian Anda.',
        ),
        findsOneWidget,
      );
      expect(find.text('Coba lagi'), findsOneWidget);
    });

    testWidgets('renders the rate-limit wait in seconds', (tester) async {
      adapter.on(
        '/search',
        status: 429,
        body: errorBody('USER_RATE_LIMIT_EXCEEDED'),
        headers: {
          'retry-after': ['45'],
        },
      );
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(
        find.text('Terlalu banyak pencarian. Coba lagi dalam 45 detik.'),
        findsOneWidget,
      );
    });

    testWidgets('renders the server validation failure copy', (tester) async {
      adapter.on(
        '/search',
        status: 400,
        body: errorBody('INVALID_SEARCH_QUERY'),
      );
      await pumpSearch(tester, locale: const Locale('id'));

      await submit(tester, 'camera');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Pencarian membutuhkan antara 2 dan 128 karakter. Periksa pencarian Anda dan coba lagi.',
        ),
        findsOneWidget,
      );
    });
  });
}
