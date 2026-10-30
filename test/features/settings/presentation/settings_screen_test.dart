import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';
import 'package:stash_it_app/features/settings/data/language_preference_store.dart';
import 'package:stash_it_app/features/settings/data/theme_preference_store.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';
import 'package:stash_it_app/features/settings/presentation/settings_screen.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<
    ({
      ProviderContainer container,
      ThemePreferenceStore store,
      LanguagePreferenceStore languageStore,
      GoRouter router,
    })
  >
  pumpSettings(
    WidgetTester tester, {
    ThemeMode initial = ThemeMode.light,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ThemePreferenceStore(preferences);
    final languageStore = LanguagePreferenceStore(preferences);

    final container = ProviderContainer(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(store),
        initialThemeModeProvider.overrideWithValue(initial),
        languagePreferenceStoreProvider.overrideWithValue(languageStore),
        initialLanguagePreferenceProvider.overrideWithValue(
          languageStore.read(),
        ),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: AppRoutes.settings,
      routes: [
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.inbox,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('INBOX'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: initial,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    return (
      container: container,
      store: store,
      languageStore: languageStore,
      router: router,
    );
  }

  RadioGroup<ThemeMode> themeGroup(WidgetTester tester) {
    return tester.widget<RadioGroup<ThemeMode>>(
      find.byWidgetPredicate((widget) => widget is RadioGroup<ThemeMode>),
    );
  }

  RadioGroup<LanguagePreference> languageGroup(WidgetTester tester) {
    return tester.widget<RadioGroup<LanguagePreference>>(
      find.byWidgetPredicate(
        (widget) => widget is RadioGroup<LanguagePreference>,
      ),
    );
  }

  testWidgets('shows the Settings title, sections and three theme choices', (
    tester,
  ) async {
    await pumpSettings(tester);

    expect(find.widgetWithText(AppBar, 'SETTINGS'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    // Settings must not offer a second Settings action.
    expect(find.byTooltip('Settings'), findsNothing);
  });

  testWidgets('all three choices select and persist immediately', (
    tester,
  ) async {
    final app = await pumpSettings(tester);

    expect(themeGroup(tester).groupValue, ThemeMode.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(themeGroup(tester).groupValue, ThemeMode.dark);
    expect(app.container.read(themeModeControllerProvider), ThemeMode.dark);
    expect(app.store.read(), ThemeMode.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(themeGroup(tester).groupValue, ThemeMode.light);
    expect(app.container.read(themeModeControllerProvider), ThemeMode.light);
    expect(app.store.read(), ThemeMode.light);

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();

    expect(themeGroup(tester).groupValue, ThemeMode.system);
    expect(app.container.read(themeModeControllerProvider), ThemeMode.system);
    expect(app.store.read(), ThemeMode.system);
  });

  testWidgets('all three language choices select and persist immediately', (
    tester,
  ) async {
    final app = await pumpSettings(tester);

    expect(languageGroup(tester).groupValue, LanguagePreference.system);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(languageGroup(tester).groupValue, LanguagePreference.english);
    expect(
      app.container.read(languagePreferenceControllerProvider),
      LanguagePreference.english,
    );
    expect(app.languageStore.read(), LanguagePreference.english);

    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();

    expect(languageGroup(tester).groupValue, LanguagePreference.indonesian);
    expect(
      app.container.read(languagePreferenceControllerProvider),
      LanguagePreference.indonesian,
    );
    expect(app.languageStore.read(), LanguagePreference.indonesian);

    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();

    expect(languageGroup(tester).groupValue, LanguagePreference.system);
    expect(
      app.container.read(languagePreferenceControllerProvider),
      LanguagePreference.system,
    );
    expect(app.languageStore.read(), LanguagePreference.system);
  });

  testWidgets('direct entry provides a back action to the Inbox', (
    tester,
  ) async {
    final app = await pumpSettings(tester);

    expect(find.byTooltip('Back to Inbox'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Inbox'));
    await tester.pumpAndSettle();

    expect(
      app.router.routerDelegate.currentConfiguration.uri.path,
      AppRoutes.inbox,
    );
    expect(find.text('INBOX'), findsOneWidget);
  });
}
