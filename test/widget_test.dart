import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';

import 'support/fake_http.dart';
import 'support/pending_urls.dart';
import 'support/saved_items_fixtures.dart';

void main() {
  /// Pumps the application inside the required [ProviderScope].
  ///
  /// Each test gets its own router so navigation history never leaks between
  /// test cases, and its own scripted transport so the Inbox's
  /// `GET /saved-items` never reaches a socket (`AGENTS.md` §5).
  Future<GoRouter> pumpApp(WidgetTester tester) async {
    final adapter = FakeHttpAdapter();
    adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
    final pendingStore = await testPendingUrlStore();

    final container = ProviderContainer(
      // The app root keeps the session boundary alive, and `createAppRouter`
      // bypasses auth; the controller still needs a store it never reads here.
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        pendingUrlStoreProvider.overrideWithValue(pendingStore),
      ],
      // Riverpod 3 retries a failed provider with backoff; an unscripted
      // listing would leave one of those timers pending past the test body.
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    container.read(appDioProvider).httpClientAdapter = adapter;
    container.read(refreshDioProvider).httpClientAdapter = adapter;

    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: StashItApp(router: router),
      ),
    );
    await tester.pumpAndSettle();

    return router;
  }

  Future<void> tapDestination(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  int selectedDestinationIndex(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  String currentPath(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.path;

  testWidgets('app shell starts on the Inbox destination', (
    WidgetTester tester,
  ) async {
    final router = await pumpApp(tester);

    // Screen titles are the approved pixel face, written uppercase at the call
    // site because Flutter has no text-transform.
    expect(find.widgetWithText(AppBar, 'INBOX'), findsOneWidget);
    expect(currentPath(router), '/inbox');
    expect(selectedDestinationIndex(tester), 0);
  });

  testWidgets('all four destinations are reachable from the navigation bar', (
    WidgetTester tester,
  ) async {
    final router = await pumpApp(tester);

    for (final destination in const <(String, String)>[
      ('Collections', '/collections'),
      ('Search', '/search'),
      ('Profile', '/profile'),
      ('Inbox', '/inbox'),
    ]) {
      await tapDestination(tester, destination.$1);

      expect(
        find.widgetWithText(AppBar, destination.$1.toUpperCase()),
        findsOneWidget,
        reason: '${destination.$1} should be shown after selecting it',
      );
      expect(
        currentPath(router),
        destination.$2,
        reason:
            'selecting ${destination.$1} should navigate to '
            '${destination.$2}',
      );
    }
  });

  testWidgets('navigation bar selection follows the active destination', (
    WidgetTester tester,
  ) async {
    final router = await pumpApp(tester);

    await tapDestination(tester, 'Search');

    expect(selectedDestinationIndex(tester), 2);
    expect(currentPath(router), '/search');

    await tapDestination(tester, 'Profile');

    expect(selectedDestinationIndex(tester), 3);
    expect(currentPath(router), '/profile');
  });

  testWidgets('every destination exposes the Settings action', (tester) async {
    final router = await pumpApp(tester);

    for (final destination in const <(String, String)>[
      ('Inbox', '/inbox'),
      ('Collections', '/collections'),
      ('Search', '/search'),
      ('Profile', '/profile'),
    ]) {
      await tapDestination(tester, destination.$1);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Settings'),
        ),
        findsOneWidget,
        reason: '${destination.$1} should expose Settings',
      );
      expect(currentPath(router), destination.$2);
    }
  });

  testWidgets('Settings opens above the shell and returns to the same state', (
    tester,
  ) async {
    final router = await pumpApp(tester);

    await tapDestination(tester, 'Search');
    final field = find.byType(TextField);
    await tester.enterText(field, 'flutter');
    await tester.pump();

    expect(tester.widget<TextField>(field).controller?.text, 'flutter');

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    // `push` adds Settings above the shell. The browser location can still
    // report the shell's base path, so assert the displayed route and that it
    // can pop rather than relying on `currentConfiguration.uri`.
    expect(router.canPop(), isTrue);
    expect(find.widgetWithText(AppBar, 'SETTINGS'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byTooltip('Settings'), findsNothing);
    expect(find.byTooltip('Back to Inbox'), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(currentPath(router), '/search');
    expect(selectedDestinationIndex(tester), 2);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'flutter',
    );
  });

  testWidgets('direct Settings entry falls back to the Inbox', (tester) async {
    final router = await pumpApp(tester);

    router.go(AppRoutes.settings);
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.settings);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byTooltip('Back to Inbox'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Inbox'));
    await tester.pumpAndSettle();

    expect(currentPath(router), AppRoutes.inbox);
    expect(find.widgetWithText(AppBar, 'INBOX'), findsOneWidget);
    expect(selectedDestinationIndex(tester), 0);
  });
}
