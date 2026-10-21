import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_it_app/features/settings/data/theme_preference_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ThemePreferenceStore> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return ThemePreferenceStore(await SharedPreferences.getInstance());
  }

  group('read', () {
    test('a fresh installation falls back to system', () async {
      final store = await storeWith({});

      expect(store.read(), ThemeMode.system);
    });

    test('each supported value restores its mode', () async {
      for (final entry in const {
        'light': ThemeMode.light,
        'dark': ThemeMode.dark,
        'system': ThemeMode.system,
      }.entries) {
        final store = await storeWith({
          ThemePreferenceStore.storageKey: entry.key,
        });

        expect(store.read(), entry.value, reason: 'stored ${entry.key}');
      }
    });

    test('a malformed value falls back to system', () async {
      for (final value in const <Object>['', 'Light', 'sepia', 1, true]) {
        final store = await storeWith({ThemePreferenceStore.storageKey: value});

        expect(
          store.read(),
          ThemeMode.system,
          reason: 'unsupported value $value',
        );
      }
    });
  });

  group('write', () {
    test('persists a stable value and restores it after a restart', () async {
      final store = await storeWith({});

      expect(await store.write(ThemeMode.dark), isTrue);
      expect(store.read(), ThemeMode.dark);

      // Reset the cached singleton without replacing the in-memory platform
      // store: the next read is the same shape as a process restart.
      SharedPreferences.resetStatic();
      final restarted = ThemePreferenceStore(
        await SharedPreferences.getInstance(),
      );

      expect(restarted.read(), ThemeMode.dark);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(ThemePreferenceStore.storageKey), 'dark');
    });

    test('writes every mode using its stable word', () async {
      final store = await storeWith({});
      const words = {
        ThemeMode.light: 'light',
        ThemeMode.dark: 'dark',
        ThemeMode.system: 'system',
      };

      for (final entry in words.entries) {
        expect(await store.write(entry.key), isTrue);
        expect(store.read(), entry.key);

        final preferences = await SharedPreferences.getInstance();
        expect(
          preferences.getString(ThemePreferenceStore.storageKey),
          entry.value,
        );
      }
    });
  });
}
