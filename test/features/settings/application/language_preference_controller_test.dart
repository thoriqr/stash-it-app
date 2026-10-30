import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/data/language_preference_store.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';

class _FailingLanguagePreferenceStore extends LanguagePreferenceStore {
  _FailingLanguagePreferenceStore(super._preferences);

  @override
  Future<bool> write(LanguagePreference preference) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> emptyPreferences() async {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }

  ProviderContainer containerWith({
    required LanguagePreferenceStore store,
    LanguagePreference initial = LanguagePreference.system,
  }) {
    final container = ProviderContainer(
      overrides: [
        languagePreferenceStoreProvider.overrideWithValue(store),
        initialLanguagePreferenceProvider.overrideWithValue(initial),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a fresh installation starts in system mode', () {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);

    expect(
      container.read(languagePreferenceControllerProvider),
      LanguagePreference.system,
    );
  });

  test('uses the preference bootstrap restored', () async {
    final store = LanguagePreferenceStore(await emptyPreferences());
    final container = containerWith(
      store: store,
      initial: LanguagePreference.indonesian,
    );

    expect(
      container.read(languagePreferenceControllerProvider),
      LanguagePreference.indonesian,
    );
  });

  test(
    'selecting a preference updates state immediately and persists it',
    () async {
      final preferences = await emptyPreferences();
      final store = LanguagePreferenceStore(preferences);
      final container = containerWith(store: store);

      final controller = container.read(
        languagePreferenceControllerProvider.notifier,
      );
      final pending = controller.select(LanguagePreference.indonesian);

      expect(
        container.read(languagePreferenceControllerProvider),
        LanguagePreference.indonesian,
        reason: 'the language must change before the disk write completes',
      );

      await pending;
      expect(store.read(), LanguagePreference.indonesian);
    },
  );

  test('selecting the same preference is a no-op', () async {
    final preferences = await emptyPreferences();
    final store = LanguagePreferenceStore(preferences);
    final container = containerWith(store: store);

    final controller = container.read(
      languagePreferenceControllerProvider.notifier,
    );
    await controller.select(LanguagePreference.system);
    // Selecting System when already System should return immediately.
    expect(
      container.read(languagePreferenceControllerProvider),
      LanguagePreference.system,
    );
  });

  test('a failed write keeps the preference and publishes a warning', () async {
    final preferences = await emptyPreferences();
    final container = containerWith(
      store: _FailingLanguagePreferenceStore(preferences),
    );

    await container
        .read(languagePreferenceControllerProvider.notifier)
        .select(LanguagePreference.english);

    expect(
      container.read(languagePreferenceControllerProvider),
      LanguagePreference.english,
    );
    final feedback = container.read(feedbackProvider);
    expect(feedback?.tone, FeedbackTone.warning);
    expect(
      feedback?.copy,
      'Language changed, but the preference could not be saved.',
    );
  });
}
