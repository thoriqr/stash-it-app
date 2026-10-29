import 'dart:async';

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
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/collection_saved_items_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_delete_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../support/fake_collections_repository.dart';
import '../support/fake_http.dart';
import '../support/fake_saved_items_repository.dart';
import '../support/pending_urls.dart';

/// The detail route in the real route tree.
///
/// `createAppRouter` deliberately omits the auth redirect, which is what lets
/// these tests start signed in without a session; the redirect is covered against
/// the production router in `auth_redirect_widget_test.dart`.
void main() {
  SavedItemSummary rowItem(int index) => SavedItemSummary(
    id: 'item-$index',
    collectionId: 'collection-1',
    url: 'https://example.com/articles/$index',
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    title: 'Row $index',
    description: 'A row description.',
  );

  SavedItemSummary detailItem({
    String id = 'fresh',
    String title = 'Fresh detail title',
  }) => SavedItemSummary(
    id: id,
    collectionId: 'collection-1',
    url: 'https://example.com/articles/fresh',
    collectionName: 'Camera Gear',
    enrichmentStatus: EnrichmentStatus.completed,
    title: title,
    description: 'Freshly read from the detail endpoint.',
  );

  CollectionSummary collectionSummary() => CollectionSummary(
    id: 'collection-1',
    name: 'Camera Gear',
    type: 'user',
    isUnsorted: false,
    savedItemsCount: 1,
    savedItemsCountOverflow: false,
    createdAt: DateTime.utc(2026, 10, 1),
    updatedAt: DateTime.utc(2026, 10, 1),
  );

  SavedItemPage inboxPage({int count = 12}) => SavedItemPage(
    items: [for (var i = 0; i < count; i++) rowItem(i)],
    nextCursor: null,
    hasMore: false,
  );

  /// Pumps the app with its real route tree and a repository-supplied Inbox.
  Future<GoRouter> pumpApp(
    WidgetTester tester,
    FakeSavedItemsRepository repository, {
    FakeCollectionsRepository? collections,
  }) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    final pendingStore = await testPendingUrlStore();

    final collectionsRepository =
        collections ??
        FakeCollectionsRepository(
          results: const [
            CollectionPage(items: [], nextCursor: null, hasMore: false),
          ],
        );

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
          savedItemsRepositoryProvider.overrideWithValue(repository),
          collectionsRepositoryProvider.overrideWithValue(
            collectionsRepository,
          ),
        ],
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String currentPath(GoRouter router) => router.state.uri.path;

  /// Opens the detail for the first Inbox row (`item-0`).
  Future<({GoRouter router, FakeSavedItemsRepository repository})> pumpDetail(
    WidgetTester tester, {
    List<Object> deleteResults = const [],
    Future<SavedItemDeleteResult> Function(String id)? onDelete,
    FakeCollectionsRepository? collections,
  }) async {
    final repository = FakeSavedItemsRepository(
      listPage: inboxPage(count: 3),
      detailResults: [detailItem(id: 'item-0')],
      deleteResults: deleteResults,
      onDelete: onDelete,
    );
    final router = await pumpApp(tester, repository, collections: collections);

    await tester.tap(find.byType(SavedItemRow).hitTestable().first);
    await tester.pumpAndSettle();

    return (router: router, repository: repository);
  }

  Future<void> openFirstDeleteDialog(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Delete this item'));
    await tester.tap(find.text('Delete this item'));
    await tester.pumpAndSettle();
  }

  Future<void> confirmFirstDeleteDialog(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(AppButton, 'Delete'));
    await tester.pumpAndSettle();
  }

  FakeCollectionsRepository collectionDeleter({
    List<Object?> deleteResults = const [null],
  }) => FakeCollectionsRepository(
    results: const [
      CollectionPage(items: [], nextCursor: null, hasMore: false),
    ],
    deleteResults: deleteResults,
  );

  testWidgets('tapping a row pushes the detail and back restores the Inbox', (
    tester,
  ) async {
    final repository = FakeSavedItemsRepository(
      listPage: inboxPage(),
      detailResults: [detailItem()],
    );
    final router = await pumpApp(tester, repository);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    final offsetBefore = tester
        .widget<ListView>(find.byType(ListView))
        .controller!
        .offset;

    final rowFinder = find.byType(SavedItemRow).hitTestable().first;
    final tappedId = tester.widget<SavedItemRow>(rowFinder).item.id;
    await tester.tap(rowFinder);
    await tester.pumpAndSettle();

    // The detail is a full-screen route above the shell, not a destination.
    expect(find.widgetWithText(AppBar, 'ITEM'), findsOneWidget);
    expect(find.text('Fresh detail title'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
    expect(router.canPop(), isTrue);

    // The detail read the item again, by the id the row carried.
    expect(repository.detailIds, [tappedId]);
    expect(repository.detailCalls, 1);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.inbox);
    expect(find.widgetWithText(AppBar, 'INBOX'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<ListView>(find.byType(ListView)).controller!.offset,
      offsetBefore,
      reason: 'the shell retained the Inbox scroll position across the push',
    );
    expect(find.byType(SavedItemRow), findsWidgets);

    // Reopening the item fetches it again: the detail provider is auto-dispose
    // and the route carries only the id, never the row's copy.
    await tester.tap(find.byType(SavedItemRow).hitTestable().first);
    await tester.pumpAndSettle();
    expect(repository.detailCalls, 2);
    expect(find.text('Fresh detail title'), findsOneWidget);
  });

  testWidgets('the detail is not a fifth navigation destination', (
    tester,
  ) async {
    final repository = FakeSavedItemsRepository(
      listPage: inboxPage(count: 3),
      detailResults: [detailItem()],
    );
    final router = await pumpApp(tester, repository);

    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
      hasLength(4),
      reason: 'D1 fixes four destinations',
    );

    await tester.tap(find.byType(SavedItemRow).hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationDestination), findsNothing);
    expect(currentPath(router), AppRoutes.savedItemDetail('item-0'));
  });

  testWidgets('direct entry has a Back to Inbox fallback', (tester) async {
    final repository = FakeSavedItemsRepository(
      listPage: inboxPage(count: 2),
      detailResults: [detailItem()],
    );
    final router = await pumpApp(tester, repository);

    router.go(AppRoutes.savedItemDetail('item-1'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'ITEM'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byTooltip('Back to Inbox'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Inbox'));
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.inbox);
    expect(find.widgetWithText(AppBar, 'INBOX'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('a directly-entered not-found item can return to the Inbox', (
    tester,
  ) async {
    final repository = FakeSavedItemsRepository(
      listPage: inboxPage(count: 2),
      detailResults: [const ApiFailureNotFound(code: 'RESOURCE_NOT_FOUND')],
    );
    final router = await pumpApp(tester, repository);

    router.go(AppRoutes.savedItemDetail('missing'));
    await tester.pumpAndSettle();

    expect(find.text('This item is no longer available'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    await tester.tap(find.widgetWithText(AppButton, 'Back to Inbox'));
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.inbox);
    expect(find.widgetWithText(AppBar, 'INBOX'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets(
    'the first dialog states the consequence and Keep sends nothing',
    (tester) async {
      final result = await pumpDetail(tester);
      final repository = result.repository;

      await openFirstDeleteDialog(tester);

      expect(find.text('Delete this item?'), findsOneWidget);
      expect(
        find.text('This removes the saved item. It cannot be undone.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Keep'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Delete'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppButton, 'Keep'));
      await tester.pumpAndSettle();

      expect(repository.deleteCalls, 0);
      expect(currentPath(result.router), AppRoutes.savedItemDetail('item-0'));
      expect(find.text('Delete this item?'), findsNothing);
    },
  );

  testWidgets('dismissing the first dialog by the barrier is also Keep', (
    tester,
  ) async {
    final result = await pumpDetail(tester);

    await openFirstDeleteDialog(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(result.repository.deleteCalls, 0);
    expect(currentPath(result.router), AppRoutes.savedItemDetail('item-0'));
    expect(find.text('Delete this item?'), findsNothing);
  });

  testWidgets('an ineligible response leaves without a second dialog', (
    tester,
  ) async {
    final result = await pumpDetail(
      tester,
      deleteResults: [
        const SavedItemDeleted(
          collectionId: 'collection-1',
          collectionEmpty: false,
          collectionDeletable: false,
        ),
      ],
    );

    await openFirstDeleteDialog(tester);
    await confirmFirstDeleteDialog(tester);

    expect(result.repository.deleteIds, ['item-0']);
    expect(currentPath(result.router), AppRoutes.inbox);
    expect(find.text('Camera Gear is now empty'), findsNothing);
    expect(find.text('Item deleted.'), findsOneWidget);
    expect(find.text('Row 0'), findsNothing);
  });

  testWidgets(
    'the empty-collection dialog names the collection and Keep it sends '
    'no collection request',
    (tester) async {
      final collections = collectionDeleter();
      final result = await pumpDetail(
        tester,
        deleteResults: [
          const SavedItemDeleted(
            collectionId: 'collection-1',
            collectionEmpty: true,
            collectionDeletable: true,
          ),
        ],
        collections: collections,
      );

      await openFirstDeleteDialog(tester);
      await confirmFirstDeleteDialog(tester);

      expect(find.text('Camera Gear is now empty'), findsOneWidget);
      expect(
        find.text(
          'This was the last item in Camera Gear. You can keep this empty '
          'collection or delete it.',
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(AppButton, 'Keep it'), findsOneWidget);
      expect(
        find.widgetWithText(AppButton, 'Delete collection'),
        findsOneWidget,
      );
      expect(collections.deleteCalls, 0);

      await tester.tap(find.widgetWithText(AppButton, 'Keep it'));
      await tester.pumpAndSettle();

      expect(collections.deleteCalls, 0);
      expect(currentPath(result.router), AppRoutes.inbox);
      expect(find.text('Item deleted.'), findsOneWidget);
    },
  );

  testWidgets('dismissing the empty-collection dialog is Keep it', (
    tester,
  ) async {
    final collections = collectionDeleter();
    final result = await pumpDetail(
      tester,
      deleteResults: [
        const SavedItemDeleted(
          collectionId: 'collection-1',
          collectionEmpty: true,
          collectionDeletable: true,
        ),
      ],
      collections: collections,
    );

    await openFirstDeleteDialog(tester);
    await confirmFirstDeleteDialog(tester);
    expect(find.text('Camera Gear is now empty'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(collections.deleteCalls, 0);
    expect(currentPath(result.router), AppRoutes.inbox);
    expect(find.text('Item deleted.'), findsOneWidget);
  });

  testWidgets('Delete collection sends exactly one request and leaves', (
    tester,
  ) async {
    final collections = collectionDeleter();
    final result = await pumpDetail(
      tester,
      deleteResults: [
        const SavedItemDeleted(
          collectionId: 'collection-1',
          collectionEmpty: true,
          collectionDeletable: true,
        ),
      ],
      collections: collections,
    );

    await openFirstDeleteDialog(tester);
    await confirmFirstDeleteDialog(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Delete collection'));
    await tester.pumpAndSettle();

    expect(collections.deleteCalls, 1);
    expect(collections.deleteIds, ['collection-1']);
    expect(currentPath(result.router), AppRoutes.inbox);
    expect(
      find.text('Item deleted, and Camera Gear was deleted.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'an ambiguous item delete stays on the detail with uncertain copy',
    (tester) async {
      final result = await pumpDetail(
        tester,
        deleteResults: [const ApiFailureServerFault()],
      );

      await openFirstDeleteDialog(tester);
      await confirmFirstDeleteDialog(tester);

      expect(currentPath(result.router), AppRoutes.savedItemDetail('item-0'));
      expect(find.text('Camera Gear is now empty'), findsNothing);
      expect(find.textContaining("couldn't confirm"), findsOneWidget);
      expect(find.text('Fresh detail title'), findsOneWidget);
    },
  );

  testWidgets('both actions are disabled while the item delete is in flight', (
    tester,
  ) async {
    final completer = Completer<SavedItemDeleteResult>();
    final result = await pumpDetail(tester, onDelete: (_) => completer.future);

    await openFirstDeleteDialog(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final deleteButton = tester.widget<AppButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppButton && widget.variant == AppButtonVariant.danger,
      ),
    );
    final moveButton = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Move to a collection'),
    );

    expect(deleteButton.busy, isTrue);
    expect(deleteButton.onPressed, isNull);
    expect(moveButton.onPressed, isNull);

    completer.complete(const SavedItemDeletionFlagsUnavailable());
    await tester.pumpAndSettle();

    expect(currentPath(result.router), AppRoutes.inbox);
  });

  testWidgets(
    'deleting the collection the detail was opened from pops both routes',
    (tester) async {
      final collections = FakeCollectionsRepository(
        results: [
          CollectionPage(
            items: [collectionSummary()],
            nextCursor: null,
            hasMore: false,
          ),
        ],
        deleteResults: const [null],
      );
      final repository = FakeSavedItemsRepository(
        listPage: inboxPage(count: 3),
        detailResults: [detailItem(id: 'item-0')],
        deleteResults: [
          const SavedItemDeleted(
            collectionId: 'collection-1',
            collectionEmpty: true,
            collectionDeletable: true,
          ),
        ],
        collectionResults: [
          CollectionSavedItemsPage(
            collectionId: 'collection-1',
            collectionName: 'Camera Gear',
            items: [detailItem(id: 'item-0')],
            nextCursor: null,
            hasMore: false,
          ),
        ],
      );

      final router = await pumpApp(
        tester,
        repository,
        collections: collections,
      );
      router.go(AppRoutes.collections);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Camera Gear'));
      await tester.pumpAndSettle();
      expect(currentPath(router), AppRoutes.collectionDetail('collection-1'));

      await tester.tap(find.byType(SavedItemRow).hitTestable().first);
      await tester.pumpAndSettle();
      expect(currentPath(router), AppRoutes.savedItemDetail('item-0'));

      await openFirstDeleteDialog(tester);
      await confirmFirstDeleteDialog(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Delete collection'));
      await tester.pumpAndSettle();

      expect(currentPath(router), AppRoutes.collections);
      expect(collections.deleteCalls, 1);
      expect(
        repository.collectionCalls,
        1,
        reason: 'the collection screen being popped is not refreshed',
      );
      expect(find.text('COLLECTION'), findsNothing);
      expect(
        find.text('Item deleted, and Camera Gear was deleted.'),
        findsOneWidget,
      );
    },
  );
}
