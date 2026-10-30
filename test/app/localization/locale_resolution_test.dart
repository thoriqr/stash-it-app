import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/localization/locale_resolution.dart';

void main() {
  group('resolveAppLocale', () {
    test('an English device locale resolves to English', () {
      expect(
        resolveAppLocale([const Locale('en')], supportedAppLocales),
        const Locale('en'),
      );
    });

    test('an Indonesian device locale resolves to Indonesian', () {
      expect(
        resolveAppLocale([const Locale('id')], supportedAppLocales),
        const Locale('id'),
      );
    });

    test('an unsupported device locale resolves to English', () {
      expect(
        resolveAppLocale([const Locale('fr')], supportedAppLocales),
        const Locale('en'),
      );
    });

    test('multiple device locales selects the first supported', () {
      expect(
        resolveAppLocale([
          const Locale('fr'),
          const Locale('id'),
        ], supportedAppLocales),
        const Locale('id'),
      );
    });

    test('an empty device locale list resolves to English', () {
      expect(resolveAppLocale([], supportedAppLocales), const Locale('en'));
    });

    test('a null device locale list resolves to English', () {
      expect(resolveAppLocale(null, supportedAppLocales), const Locale('en'));
    });

    test('English is preferred over Indonesian in the device list', () {
      expect(
        resolveAppLocale([
          const Locale('en'),
          const Locale('id'),
        ], supportedAppLocales),
        const Locale('en'),
      );
    });

    test('a region code is matched by language code', () {
      expect(
        resolveAppLocale([const Locale('id', 'ID')], supportedAppLocales),
        const Locale('id'),
      );
    });
  });
}
