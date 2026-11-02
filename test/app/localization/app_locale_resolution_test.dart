import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/app.dart';
import 'package:stash_it_app/app/network/network_providers.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/core/storage/secure_credential_store.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/data/language_preference_store.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';

import '../../support/fake_http.dart';
import '../../support/pending_urls.dart';
import '../../support/saved_items_fixtures.dart';

/// Locale resolution in the real app root.
///
/// These tests exercise the `MaterialApp` callback in `app.dart` rather than
/// only the pure resolver, because the defect was that the callback ignored the
/// explicitly supplied locale and re-read the device list.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    required List<Locale> deviceLocales,
    LanguagePreference? language,
  }) async {
    tester.platformDispatcher.localesTestValue = deviceLocales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final adapter = FakeHttpAdapter();
    adapter.on('/saved-items', body: SavedItemsFixtures.emptyPage());
    final pendingStore = await testPendingUrlStore();

    final container = ProviderContainer(
      overrides: [
        credentialStoreProvider.overrideWithValue(
          SecureCredentialStore(InMemorySecureStorage()),
        ),
        pendingUrlStoreProvider.overrideWithValue(pendingStore),
        languagePreferenceStoreProvider.overrideWithValue(
          LanguagePreferenceStore(preferences),
        ),
        if (language != null)
          initialLanguagePreferenceProvider.overrideWithValue(language),
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
    return container;
  }

  Locale activeLocale(WidgetTester tester) =>
      Localizations.localeOf(tester.element(find.byType(NavigationBar)));

  testWidgets(
    'a restored Indonesian preference wins over an English device locale',
    (tester) async {
      await pumpApp(
        tester,
        deviceLocales: const [Locale('en')],
        language: LanguagePreference.indonesian,
      );

      expect(activeLocale(tester), const Locale('id'));
      expect(find.text('Koleksi'), findsOneWidget);
      expect(find.text('Collections'), findsNothing);
    },
  );

  testWidgets(
    'a restored English preference wins over an Indonesian device locale',
    (tester) async {
      await pumpApp(
        tester,
        deviceLocales: const [Locale('id')],
        language: LanguagePreference.english,
      );

      expect(activeLocale(tester), const Locale('en'));
      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('Koleksi'), findsNothing);
    },
  );

  testWidgets('selecting a language at runtime overrides the device locale', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      deviceLocales: const [Locale('en')],
    );
    expect(activeLocale(tester), const Locale('en'));

    await container
        .read(languagePreferenceControllerProvider.notifier)
        .select(LanguagePreference.indonesian);
    await tester.pumpAndSettle();

    expect(activeLocale(tester), const Locale('id'));
    expect(find.text('Koleksi'), findsOneWidget);
  });

  testWidgets('System follows the first supported device locale', (
    tester,
  ) async {
    await pumpApp(tester, deviceLocales: const [Locale('fr'), Locale('id')]);

    expect(activeLocale(tester), const Locale('id'));
    expect(find.text('Koleksi'), findsOneWidget);
  });

  testWidgets('System prefers English when it appears first', (tester) async {
    await pumpApp(tester, deviceLocales: const [Locale('en'), Locale('id')]);

    expect(activeLocale(tester), const Locale('en'));
    expect(find.text('Collections'), findsOneWidget);
  });

  testWidgets(
    'System falls back to English when no device locale is supported',
    (tester) async {
      await pumpApp(tester, deviceLocales: const [Locale('fr')]);

      expect(activeLocale(tester), const Locale('en'));
      expect(find.text('Collections'), findsOneWidget);
    },
  );
}
