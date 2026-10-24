import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';
import 'package:stash_it_app/features/settings/data/theme_preference_store.dart';

import '../../../support/fake_http.dart';
import '../../../support/saved_items_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<
    ({GoRouter router, ProviderContainer container, ThemePreferenceStore store})
  >
  pumpApp(
    WidgetTester tester, {
    Map<String, Object> storedValues = const {},
  }) async {
    SharedPreferences.setMockInitialValues(storedValues);
    final store = ThemePreferenceStore(await SharedPreferences.getInstance());

    final adapter = FakeHttpAdapter();
    adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());

    final container = ProviderContainer(
      overrides: [
        // The app root keeps the session boundary alive, and `createAppRouter`
        // bypasses auth; the controller still needs a store it never reads here.
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        themePreferenceStoreProvider.overrideWithValue(store),
        initialThemeModeProvider.overrideWithValue(store.read()),
      ],
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

    return (router: router, container: container, store: store);
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

  String currentPath(GoRouter router) =>
      router.routerDelegate.currentConfiguration.uri.path;

  ThemeMode appThemeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  Brightness appBrightness(WidgetTester tester) =>
      Theme.of(tester.element(find.text('INBOX'))).brightness;

  testWidgets('a fresh installation uses the system theme', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final app = await pumpApp(tester);

    expect(app.container.read(themeModeControllerProvider), ThemeMode.system);
    expect(appThemeMode(tester), ThemeMode.system);
    expect(appBrightness(tester), Brightness.light);
  });

  testWidgets('a restored preference is applied on the first frame', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      storedValues: const {ThemePreferenceStore.storageKey: 'dark'},
    );

    expect(app.container.read(themeModeControllerProvider), ThemeMode.dark);
    expect(appThemeMode(tester), ThemeMode.dark);
    expect(appBrightness(tester), Brightness.dark);
  });

  testWidgets('selecting a theme changes the whole app and persists it', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    final app = await pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(appThemeMode(tester), ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('SETTINGS'))).brightness,
      Brightness.dark,
    );
    expect(app.store.read(), ThemeMode.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(appThemeMode(tester), ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('SETTINGS'))).brightness,
      Brightness.light,
    );

    // System is still System even while an explicit Light choice is in force,
    // then follows the platform once selected.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('SETTINGS'))).brightness,
      Brightness.light,
    );

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();

    expect(appThemeMode(tester), ThemeMode.system);
    expect(app.store.read(), ThemeMode.system);
    expect(
      Theme.of(tester.element(find.text('SETTINGS'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('a theme change does not reset the selected shell branch', (
    tester,
  ) async {
    final app = await pumpApp(tester);

    await tapDestination(tester, 'Search');
    final field = find.byType(TextField);
    await tester.enterText(field, 'flutter');
    await tester.pump();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(app.router.canPop(), isTrue);
    expect(find.widgetWithText(AppBar, 'SETTINGS'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(currentPath(app.router), AppRoutes.search);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'flutter',
    );
  });
}
