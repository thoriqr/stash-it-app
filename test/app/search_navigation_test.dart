import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/features/search/data/datasources/search_api.dart';
import 'package:stash_it_app/features/search/data/search_providers.dart';
import 'package:stash_it_app/features/search/data/search_repository.dart';
import 'package:stash_it_app/features/search/presentation/widgets/search_collection_row.dart';

import '../support/fake_http.dart';
import '../support/fake_saved_items_repository.dart';
import '../support/pending_urls.dart';
import '../support/search_fixtures.dart';

/// Search results in the real route tree.
///
/// Both groups reuse the existing detail screens: a collection row pushes
/// `/collections/:id` and a saved-item row pushes `/saved-items/:id`. The
/// destination reads by id, and popping returns to the retained Search
/// destination with its query and results intact.
void main() {
  const collectionId = 'collection-1';
  const savedItemId = 'item-1';

  late FakeHttpAdapter adapter;

  setUp(() => adapter = FakeHttpAdapter());

  SavedItemSummary detailItem() => SavedItemSummary(
    id: savedItemId,
    collectionId: collectionId,
    url: 'https://example.com/articles/sensor-guide',
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Fresh detail title',
    description: 'Freshly read from the detail endpoint.',
  );

  /// Pumps the app with its real route tree, opens Search and runs one query.
  ///
  /// `createAppRouter` deliberately omits the auth redirect, which is what lets
  /// these tests start signed in without a session. The collection listing is
  /// built from the id the detail screen asks for, so the header proves which id
  /// arrived as well as [FakeSavedItemsRepository.collectionIds] recording it.
  Future<({GoRouter router, FakeSavedItemsRepository savedItems})> pumpSearch(
    WidgetTester tester,
  ) async {
    final savedItems = FakeSavedItemsRepository(
      detailResults: [detailItem()],
      onListInCollection: (id, cursor) async => CollectionSavedItemsPage(
        collectionId: id,
        collectionName: 'Server-side $id',
        items: const [],
        nextCursor: null,
        hasMore: false,
      ),
    );
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    final router = createAppRouter();
    addTearDown(router.dispose);
    final pendingStore = await testPendingUrlStore();

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          // The app root keeps the session boundary alive, and `createAppRouter`
          // bypasses auth; the controller still needs a store it never reads.
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          pendingUrlStoreProvider.overrideWithValue(pendingStore),
          searchRepositoryProvider.overrideWithValue(
            SearchRepository(
              api: SearchApi(dio),
              now: () => DateTime.utc(2026, 10, 2, 12),
            ),
          ),
          savedItemsRepositoryProvider.overrideWithValue(savedItems),
        ],
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    router.go(AppRoutes.search);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'camera');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    return (router: router, savedItems: savedItems);
  }

  testWidgets('the tapped collection result opens that collection and back '
      'restores Search', (tester) async {
    adapter.on(
      '/search',
      body: SearchFixtures.response(
        collections: [
          SearchFixtures.collection(id: 'collection-1', name: 'Archive Shelf'),
          SearchFixtures.collection(id: 'collection-2', name: 'Softbox Drawer'),
        ],
        savedItems: [
          SearchFixtures.savedItem(id: 'item-1', title: 'A sensor guide'),
        ],
      ),
    );

    final (:router, :savedItems) = await pumpSearch(tester);

    // The second result, so the route cannot be carrying a fixed first id.
    await tester.tap(find.byType(SearchCollectionRow).at(1));
    await tester.pumpAndSettle();

    // The existing collection detail, reached with the tapped result's id.
    expect(router.state.uri.path, AppRoutes.collectionDetail('collection-2'));
    expect(savedItems.collectionIds, ['collection-2']);
    expect(find.widgetWithText(AppBar, 'COLLECTION'), findsOneWidget);
    expect(find.text('Server-side collection-2'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.search);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'camera',
      reason: 'the submitted query survives the push',
    );
    expect(find.text('Archive Shelf'), findsOneWidget);
    expect(find.text('Softbox Drawer'), findsOneWidget);
    expect(find.text('A sensor guide'), findsOneWidget);
    expect(
      adapter.countFor('/search'),
      1,
      reason: 'returning must not run the search again',
    );
  });

  testWidgets('the tapped saved item result opens that item and back restores '
      'Search', (tester) async {
    adapter.on(
      '/search',
      body: SearchFixtures.response(
        collections: [
          SearchFixtures.collection(id: 'collection-1', name: 'Archive Shelf'),
        ],
        savedItems: [
          SearchFixtures.savedItem(id: 'item-1', title: 'A sensor guide'),
          SearchFixtures.savedItem(id: 'item-2', title: 'A lighting guide'),
        ],
      ),
    );

    final (:router, :savedItems) = await pumpSearch(tester);

    // The second result, for the same reason as the collection case.
    await tester.tap(find.byType(SavedItemRow).at(1));
    await tester.pumpAndSettle();

    // The existing saved-item detail, reached with the tapped result's id.
    expect(router.state.uri.path, AppRoutes.savedItemDetail('item-2'));
    expect(savedItems.detailIds, ['item-2']);
    expect(find.widgetWithText(AppBar, 'ITEM'), findsOneWidget);
    expect(find.text('Fresh detail title'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.search);
    expect(find.text('Archive Shelf'), findsOneWidget);
    expect(find.text('A sensor guide'), findsOneWidget);
    expect(find.text('A lighting guide'), findsOneWidget);
    expect(
      adapter.countFor('/search'),
      1,
      reason: 'returning must not run the search again',
    );
  });
}
