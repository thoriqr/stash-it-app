import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';
import 'package:stash_it_app/features/settings/data/theme_preference_store.dart';

class _FailingThemePreferenceStore extends ThemePreferenceStore {
  _FailingThemePreferenceStore(super._preferences);

  @override
  Future<bool> write(ThemeMode mode) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> emptyPreferences() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  ProviderContainer containerWith({
    required ThemePreferenceStore store,
    ThemeMode initial = ThemeMode.system,
  }) {
    final container = ProviderContainer(
      overrides: [
        themePreferenceStoreProvider.overrideWithValue(store),
        initialThemeModeProvider.overrideWithValue(initial),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a fresh installation starts in system mode', () {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);

    expect(container.read(themeModeControllerProvider), ThemeMode.system);
  });

  test('uses the mode bootstrap restored', () async {
    final store = ThemePreferenceStore(await emptyPreferences());
    final container = containerWith(store: store, initial: ThemeMode.dark);

    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  test('selecting a mode updates state immediately and persists it', () async {
    final preferences = await emptyPreferences();
    final store = ThemePreferenceStore(preferences);
    final container = containerWith(store: store);

    final controller = container.read(themeModeControllerProvider.notifier);
    final pending = controller.select(ThemeMode.dark);

    expect(
      container.read(themeModeControllerProvider),
      ThemeMode.dark,
      reason: 'the theme must change before the disk write completes',
    );

    await pending;
    expect(store.read(), ThemeMode.dark);
  });

  test('a failed write keeps the theme and publishes a warning', () async {
    final preferences = await emptyPreferences();
    final container = containerWith(
      store: _FailingThemePreferenceStore(preferences),
    );

    await container
        .read(themeModeControllerProvider.notifier)
        .select(ThemeMode.light);

    expect(container.read(themeModeControllerProvider), ThemeMode.light);
    final feedback = container.read(feedbackProvider);
    expect(feedback?.tone, FeedbackTone.warning);
    expect(
      feedback?.copy,
      'Theme changed, but the preference could not be saved.',
    );
  });
}
