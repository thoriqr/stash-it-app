import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';

import 'support/fake_http.dart';
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

    final container = ProviderContainer(
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
}
