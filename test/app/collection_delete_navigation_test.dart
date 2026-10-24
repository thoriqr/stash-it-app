import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_page.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/collections/presentation/widgets/collection_tile.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/collection_destination_row.dart';

import '../support/fake_collections_repository.dart';
import '../support/fake_http.dart';
import '../support/fake_saved_items_repository.dart';

/// Deleting a collection, in the real route tree.
///
/// The screen tests cover the decisions themselves; these two cover what happens
/// **after** the transaction commits: the route the user came from is the one
/// they return to, and the Collections list they land on is the reconciled one.
void main() {
  const collectionId = 'collection-1';
  const targetId = 'collection-2';
  const collectionName = 'Camera Gear';
  const targetName = 'Reading list';

  CollectionSummary collection({
    String id = collectionId,
    String name = collectionName,
  }) => CollectionSummary(
    id: id,
    name: name,
    type: 'user',
    isUnsorted: false,
    savedItemsCount: 1,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  SavedItemSummary item(String id) => SavedItemSummary(
    id: id,
    collectionId: collectionId,
    collectionName: collectionName,
    url: 'https://example.com/articles/$id',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Item $id',
  );

  CollectionPage pageOf(List<CollectionSummary> items) =>
      CollectionPage(items: items, nextCursor: null, hasMore: false);

  CollectionSavedItemsPage contentsOf(List<SavedItemSummary> items) =>
      CollectionSavedItemsPage(
        collectionId: collectionId,
        collectionName: collectionName,
        items: items,
        nextCursor: null,
        hasMore: false,
      );

  /// Pumps the app with its real route tree and repository-supplied listings.
  ///
  /// `createAppRouter` omits the auth redirect, which is what lets these start
  /// signed in without a session — the same harness
  /// `collection_detail_navigation_test.dart` uses.
  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    required FakeSavedItemsRepository savedItems,
    required FakeCollectionsRepository collections,
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
          collectionsRepositoryProvider.overrideWithValue(collections),
        ],
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('an empty collection deleted from its route returns to '
      'Collections without it', (tester) async {
    final savedItems = FakeSavedItemsRepository(
      detailResults: [item('unused')],
      collectionResults: [contentsOf(const [])],
    );
    final collections = FakeCollectionsRepository(
      results: [
        pageOf([collection()]),
      ],
      deleteResults: [null],
    );
    final router = await pumpApp(
      tester,
      savedItems: savedItems,
      collections: collections,
    );

    router.go(AppRoutes.collections);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CollectionTile));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, AppRoutes.collectionDetail(collectionId));

    await tester.tap(find.byTooltip('Collection actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete collection'));
    await tester.pumpAndSettle();

    // The empty collection's single confirmation, not the three-action sheet.
    expect(find.text('Delete Camera Gear?'), findsOneWidget);
    expect(find.text('Move items to another collection'), findsNothing);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // One request, and the route it was opened from is where the user ends up.
    expect(collections.deleteIds, [collectionId]);
    expect(collections.moveCalls, 0);
    expect(router.state.uri.path, AppRoutes.collections);
    expect(find.widgetWithText(AppBar, 'COLLECTIONS'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.byType(CollectionTile),
      findsNothing,
      reason: 'the deleted collection is gone from the reconciled list',
    );
    expect(
      savedItems.collectionCalls,
      1,
      reason: 'the popped route is not re-read after a successful delete',
    );
  });

  testWidgets('moving the items and deleting from the sheet returns to '
      'Collections with authoritative counts', (tester) async {
    final savedItems = FakeSavedItemsRepository(
      detailResults: [item('unused')],
      collectionResults: [
        contentsOf([item('a'), item('b')]),
      ],
    );
    final collections = FakeCollectionsRepository(
      // The initial list, the destination picker's own page, then the refresh
      // that follows the confirmed move — the last page stays repeating.
      results: [
        pageOf([collection(), collection(id: targetId, name: targetName)]),
        pageOf([collection(), collection(id: targetId, name: targetName)]),
        pageOf([collection(id: targetId, name: targetName)]),
      ],
      moveResults: [null],
    );
    final router = await pumpApp(
      tester,
      savedItems: savedItems,
      collections: collections,
    );

    router.go(AppRoutes.collections);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(CollectionTile, collectionName));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Collection actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move items to another collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CollectionDestinationRow, targetName));
    await tester.pumpAndSettle();

    // The destination traveled with the delete in one request.
    expect(collections.moves, [(sourceId: collectionId, targetId: targetId)]);
    expect(collections.deleteCalls, 0);
    expect(router.state.uri.path, AppRoutes.collections);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Both names were on screen; after the refresh only the destination is.
    expect(find.widgetWithText(CollectionTile, targetName), findsOneWidget);
    expect(find.widgetWithText(CollectionTile, collectionName), findsNothing);
    expect(
      savedItems.collectionCalls,
      1,
      reason: 'a successful delete does not refresh a route that is popping',
    );
  });
}
