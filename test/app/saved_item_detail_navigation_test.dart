import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_page.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/presentation/widgets/saved_item_row.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

import '../support/fake_saved_items_repository.dart';

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

  SavedItemSummary detailItem({String title = 'Fresh detail title'}) =>
      SavedItemSummary(
        id: 'fresh',
        collectionId: 'collection-1',
        url: 'https://example.com/articles/fresh',
        collectionName: 'Camera Gear',
        enrichmentStatus: EnrichmentStatus.completed,
        title: title,
        description: 'Freshly read from the detail endpoint.',
      );

  SavedItemPage inboxPage({int count = 12}) => SavedItemPage(
    items: [for (var i = 0; i < count; i++) rowItem(i)],
    nextCursor: null,
    hasMore: false,
  );

  /// Pumps the app with its real route tree and a repository-supplied Inbox.
  Future<GoRouter> pumpApp(
    WidgetTester tester,
    FakeSavedItemsRepository repository,
  ) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [savedItemsRepositoryProvider.overrideWithValue(repository)],
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  String currentPath(GoRouter router) => router.state.uri.path;

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
}
