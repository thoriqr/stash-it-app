import 'package:flutter/widgets.dart';

/// Locales supported by the application.
///
/// Shared by app configuration and locale resolution.
const supportedAppLocales = [Locale('en'), Locale('id')];

/// Resolves the locale used when no explicit locale is selected.
///
/// Checks the device's preferred locales in order and returns the first
/// supported language. Falls back to English if none are supported.
///
/// Accepts the device locales as an argument so the resolution logic can be
/// tested independently of platform APIs.
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
