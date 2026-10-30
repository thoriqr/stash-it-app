import 'package:flutter/widgets.dart';

/// The locales this app can present.
///
/// Declared as a constant so [supportedLocales] in `app.dart` and the
/// [resolveAppLocale] tests share one source of truth.
const supportedAppLocales = [Locale('en'), Locale('id')];

/// Resolves which [Locale] to use when [MaterialApp.locale] is null.
///
/// Called from `MaterialApp.localeResolutionCallback`, which fires only when
/// the System preference is active. The device's preferred locales are iterated
/// in order and the first one this app supports is returned; an unsupported or
/// empty device list falls back to English (D20).
///
/// Pure: the device locale list is passed as a parameter so this function is
/// unit-testable without a platform channel or widget tree.
Locale resolveAppLocale(
  List<Locale>? deviceLocales,
  Iterable<Locale> supportedLocales,
) {
  final supported = {
    for (final locale in supportedLocales) locale.languageCode,
  };
  for (final locale in deviceLocales ?? const <Locale>[]) {
    if (supported.contains(locale.languageCode)) {
      return Locale(locale.languageCode);
    }
  }
  return const Locale('en');
}
