import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/collections/presentation/collections_screen.dart';
import 'package:stash_it_app/features/collections/presentation/widgets/collection_skeleton.dart';
import 'package:stash_it_app/features/collections/presentation/widgets/collection_tile.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

import '../../../support/fake_collections_repository.dart';

void main() {
  CollectionSummary collection({
    String id = 'collection-1',
    String name = 'Reading List',
    int savedItemsCount = 5,
    bool savedItemsCountOverflow = false,
    bool isUnsorted = false,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: isUnsorted ? 'system' : 'user',
    isUnsorted: isUnsorted,
    savedItemsCount: savedItemsCount,
    savedItemsCountOverflow: savedItemsCountOverflow,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  CollectionPage page(
    List<CollectionSummary> items, {
    String? nextCursor,
    bool hasMore = false,
  }) => CollectionPage(items: items, nextCursor: nextCursor, hasMore: hasMore);

  Widget host(Widget child, {Locale? locale}) => MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );

  Future<FakeCollectionsRepository> pumpScreen(
    WidgetTester tester, {
    required List<Object> results,
    Locale? locale,
    FakeCollectionsRepository? repository,
  }) async {
    final fake = repository ?? FakeCollectionsRepository(results: results);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [collectionsRepositoryProvider.overrideWithValue(fake)],
        child: host(const CollectionsScreen(), locale: locale),
      ),
    );
    await tester.pumpAndSettle();
    return fake;
  }

  testWidgets('renders the English empty state and localized sort labels', (
    tester,
  ) async {
    await pumpScreen(tester, results: [page(const [])]);

    expect(find.widgetWithText(AppBar, 'COLLECTIONS'), findsOneWidget);
    expect(find.text('COLLECTIONS'), findsNWidgets(2));
    expect(find.text('Newest'), findsOneWidget);
    expect(find.text('No collections yet'), findsOneWidget);
    expect(
      find.text('Collections appear when you save links or organize them.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('keeps server collection names unchanged in Indonesian', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      results: [
        page([
          collection(id: 'server-1', name: 'Nama dari Server'),
          collection(id: 'server-2', name: 'Reading List'),
        ]),
      ],
      locale: const Locale('id'),
    );

    expect(find.widgetWithText(AppBar, 'KOLEKSI'), findsOneWidget);
    expect(find.text('KOLEKSI'), findsNWidgets(2));
    expect(find.text('Terbaru'), findsOneWidget);
    expect(find.text('Nama dari Server'), findsOneWidget);
    expect(find.text('Reading List'), findsOneWidget);
    expect(find.text('No collections yet'), findsNothing);
  });

  testWidgets('selects a localized sort label with the technical old sort', (
    tester,
  ) async {
    final repository = FakeCollectionsRepository(
      results: [
        page([collection(name: 'First')]),
        page([collection(name: 'Second')]),
      ],
    );
    await pumpScreen(
      tester,
      results: const [],
      repository: repository,
      locale: const Locale('id'),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Terlama'), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);

    await tester.tap(find.text('Terlama'));
    await tester.pumpAndSettle();

    expect(repository.sorts, ['newest', 'oldest']);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('shows the loading skeleton and then the empty state', (
    tester,
  ) async {
    final completer = Completer<CollectionPage>();
    final repository = FakeCollectionsRepository(results: [page(const [])]);
    repository.onList = (_, _, _) => completer.future;

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          collectionsRepositoryProvider.overrideWithValue(repository),
        ],
        child: host(const CollectionsScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(CollectionSkeletonList), findsOneWidget);
    expect(find.text('No collections yet'), findsNothing);

    completer.complete(page(const []));
    await tester.pumpAndSettle();

    expect(find.byType(CollectionSkeletonList), findsNothing);
    expect(find.text('No collections yet'), findsOneWidget);
  });

  testWidgets('renders typed load failures and retries once', (tester) async {
    final repository = await pumpScreen(
      tester,
      results: [
        const ApiFailureTransport(),
        page([collection(name: 'Recovered')]),
      ],
    );

    expect(
      find.text(
        'No connection to the server. We could not load your collections.',
      ),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repository.listCalls, 2);
    expect(find.text('Recovered'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('renders typed Indonesian failure copy', (tester) async {
    await pumpScreen(
      tester,
      results: [const ApiFailureAuthRequired()],
      locale: const Locale('id'),
    );

    expect(find.text('Masuk lagi untuk melihat koleksi Anda.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('uses the Collections fallback for unclassified read failures', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      results: const [ApiFailureNotFound(code: 'RESOURCE_NOT_FOUND')],
    );

    expect(
      find.text('We could not load your collections. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('keeps the system badge local and count labels plural', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      host(
        Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 150,
                width: 220,
                child: CollectionTile(
                  item: collection(
                    name: 'Unsorted',
                    isUnsorted: true,
                    savedItemsCount: 1,
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                width: 220,
                child: CollectionTile(
                  item: collection(
                    id: 'collection-2',
                    name: 'Reading List',
                    savedItemsCount: 2,
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                width: 220,
                child: CollectionTile(
                  item: collection(
                    id: 'collection-3',
                    name: 'Watch Later',
                    savedItemsCount: 100,
                    savedItemsCountOverflow: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('system'), findsOneWidget);
    expect(find.text('Unsorted'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('1 saved item')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('2 saved items')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('More than 99 saved items')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      host(
        Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 150,
                width: 220,
                child: CollectionTile(
                  item: collection(
                    name: 'Unsorted',
                    isUnsorted: true,
                    savedItemsCount: 1,
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                width: 220,
                child: CollectionTile(
                  item: collection(
                    id: 'collection-2',
                    name: 'Reading List',
                    savedItemsCount: 2,
                  ),
                ),
              ),
              SizedBox(
                height: 150,
                width: 220,
                child: CollectionTile(
                  item: collection(
                    id: 'collection-3',
                    name: 'Watch Later',
                    savedItemsCount: 100,
                    savedItemsCountOverflow: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        locale: const Locale('id'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('sistem'), findsOneWidget);
    expect(find.text('Unsorted'), findsOneWidget);
    expect(find.text('99+'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('1 item tersimpan')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('2 item tersimpan')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Lebih dari 99 item tersimpan')),
      findsOneWidget,
    );

    semantics.dispose();
  });
}
