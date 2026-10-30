import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/features/settings/data/language_preference_store.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LanguagePreferenceStore> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return LanguagePreferenceStore(await SharedPreferences.getInstance());
  }

  group('read', () {
    test('a fresh installation falls back to system', () async {
      final store = await storeWith({});

      expect(store.read(), LanguagePreference.system);
    });

    test('each supported value restores its preference', () async {
      for (final entry in const {
        'system': LanguagePreference.system,
        'en': LanguagePreference.english,
        'id': LanguagePreference.indonesian,
      }.entries) {
        final store = await storeWith({
          LanguagePreferenceStore.storageKey: entry.key,
        });

        expect(store.read(), entry.value, reason: 'stored ${entry.key}');
      }
    });

    test('a malformed value falls back to system', () async {
      for (final value in const <Object>['', 'EN', 'Deutsch', 1, true]) {
        final store = await storeWith({
          LanguagePreferenceStore.storageKey: value,
        });

        expect(
          store.read(),
          LanguagePreference.system,
          reason: 'unsupported value $value',
        );
      }
    });
  });

  group('write', () {
    test('persists a stable value and restores it after a restart', () async {
      final store = await storeWith({});

      expect(await store.write(LanguagePreference.indonesian), isTrue);
      expect(store.read(), LanguagePreference.indonesian);

      // Reset the cached singleton without replacing the in-memory platform
      // store: the next read is the same shape as a process restart.
      SharedPreferences.resetStatic();
      final restarted = LanguagePreferenceStore(
        await SharedPreferences.getInstance(),
      );

      expect(restarted.read(), LanguagePreference.indonesian);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(LanguagePreferenceStore.storageKey), 'id');
    });

    test('writes every preference using its stable word', () async {
      final store = await storeWith({});
      const words = {
        LanguagePreference.system: 'system',
        LanguagePreference.english: 'en',
        LanguagePreference.indonesian: 'id',
      };

      for (final entry in words.entries) {
        expect(await store.write(entry.key), isTrue);
        expect(store.read(), entry.key);

        final preferences = await SharedPreferences.getInstance();
        expect(
          preferences.getString(LanguagePreferenceStore.storageKey),
          entry.value,
        );
      }
    });
  });
}
