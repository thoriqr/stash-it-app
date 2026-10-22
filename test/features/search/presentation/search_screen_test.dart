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

  Future<void> pumpSearch(WidgetTester tester) async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchRepositoryProvider.overrideWithValue(
            SearchRepository(api: SearchApi(dio), now: () => now),
          ),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const SearchScreen()),
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
}
