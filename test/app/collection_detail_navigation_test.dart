import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/collections/presentation/widgets/collection_tile.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../support/fake_collections_repository.dart';
import '../support/fake_http.dart';
import '../support/fake_saved_items_repository.dart';

/// The collection detail route in the real route tree.
///
/// `createAppRouter` deliberately omits the auth redirect, which is what lets
/// these tests start signed in without a session; the redirect is covered against
/// the production router in `auth_redirect_widget_test.dart`.
void main() {
  const collectionId = 'collection-1';

  SavedItemSummary rowItem(int index) => SavedItemSummary(
    id: 'item-$index',
    collectionId: collectionId,
    url: 'https://example.com/articles/$index',
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Row $index',
    description: 'A row description.',
  );

  CollectionSavedItemsPage collectionPage({
    int count = 12,
    String collectionName = 'Server-side name',
  }) => CollectionSavedItemsPage(
    collectionId: collectionId,
    collectionName: collectionName,
    items: [for (var i = 0; i < count; i++) rowItem(i)],
    nextCursor: null,
    hasMore: false,
  );

  CollectionPage collectionsPage() => CollectionPage(
    items: [
      CollectionSummary(
        id: collectionId,
        name: 'Tile name',
        type: 'user',
        isUnsorted: false,
        savedItemsCount: 12,
        savedItemsCountOverflow: false,
        createdAt: DateTime.utc(2026, 10, 1),
        updatedAt: DateTime.utc(2026, 10, 1),
      ),
    ],
    nextCursor: null,
    hasMore: false,
  );

  SavedItemSummary detailItem() => SavedItemSummary(
    id: 'fresh',
    collectionId: collectionId,
    url: 'https://example.com/articles/fresh',
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Fresh detail title',
    description: 'Freshly read from the detail endpoint.',
  );

  /// Pumps the app with its real route tree and repository-supplied listings.
  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    required FakeSavedItemsRepository savedItems,
  }) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          // The app root keeps the session boundary alive, and `createAppRouter`
          // bypasses auth; the controller still needs a store it never reads.
          credentialStoreProvider.overrideWithValue(
            SecureCredentialStore(InMemorySecureStorage()),
          ),
          savedItemsRepositoryProvider.overrideWithValue(savedItems),
          collectionsRepositoryProvider.overrideWithValue(
            FakeCollectionsRepository(results: [collectionsPage()]),
          ),
        ],
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String currentPath(GoRouter router) => router.state.uri.path;

  testWidgets('a tile opens the collection, a row opens the item and back '
      'restores both', (tester) async {
    final savedItems = FakeSavedItemsRepository(
      listPage: const SavedItemPage(
        items: [],
        nextCursor: null,
        hasMore: false,
      ),
      detailResults: [detailItem()],
      collectionResults: [collectionPage()],
    );
    final router = await pumpApp(tester, savedItems: savedItems);

    router.go(AppRoutes.collections);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CollectionTile));
    await tester.pumpAndSettle();

    // The detail is a full-screen route above the shell, not a destination.
    expect(currentPath(router), AppRoutes.collectionDetail(collectionId));
    expect(find.widgetWithText(AppBar, 'COLLECTION'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
    expect(router.canPop(), isTrue);

    // The header is the name the detail endpoint returned, not the tile's.
    expect(find.text('Server-side name'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    final offsetBefore = tester
        .widget<ListView>(find.byType(ListView))
        .controller!
        .offset;

    final rowFinder = find.byType(SavedItemRow).hitTestable().first;
    final tappedId = tester.widget<SavedItemRow>(rowFinder).item.id;
    await tester.tap(rowFinder);
    await tester.pumpAndSettle();

    // The existing saved-item detail, reached with the row's id — not a second
    // detail route and not a copy of its logic.
    expect(currentPath(router), AppRoutes.savedItemDetail(tappedId));
    expect(find.widgetWithText(AppBar, 'ITEM'), findsOneWidget);
    expect(find.text('Fresh detail title'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(savedItems.detailIds, [tappedId]);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // Back on the collection, with its loaded pages and scroll position intact:
    // the provider is still watched, so nothing was re-read.
    expect(currentPath(router), AppRoutes.collectionDetail(collectionId));
    expect(find.text('Server-side name'), findsOneWidget);
    expect(find.byType(SavedItemRow), findsWidgets);
    expect(
      tester.widget<ListView>(find.byType(ListView)).controller!.offset,
      offsetBefore,
      reason: 'the collection list kept its scroll position under the detail',
    );
    expect(
      savedItems.collectionCalls,
      1,
      reason: 'returning from the detail must not refetch the collection',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.collections);
    expect(find.widgetWithText(AppBar, 'COLLECTIONS'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(CollectionTile), findsOneWidget);
  });

  testWidgets('direct entry has a Back to Collections fallback for a missing '
      'collection', (tester) async {
    final savedItems = FakeSavedItemsRepository(
      listPage: const SavedItemPage(
        items: [],
        nextCursor: null,
        hasMore: false,
      ),
      detailResults: [detailItem()],
      collectionResults: [
        const ApiFailureNotFound(code: 'COLLECTION_NOT_FOUND'),
      ],
    );
    final router = await pumpApp(tester, savedItems: savedItems);

    router.go(AppRoutes.collectionDetail('missing'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'COLLECTION'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('This collection is no longer available'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byTooltip('Back to Collections'), findsOneWidget);

    await tester.tap(find.widgetWithText(AppButton, 'Back to Collections'));
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.collections);
    expect(find.widgetWithText(AppBar, 'COLLECTIONS'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
