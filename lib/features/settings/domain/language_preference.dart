import 'package:flutter/widgets.dart';

/// The app-wide language preference.
///
/// Only English and Indonesian are supported (D20, D21, D22). The System
/// preference delegates to the platform locale, resolved by
/// `lib/app/localization/locale_resolution.dart`.
enum LanguagePreference {
  /// Follow the device's preferred locales; the first supported one wins.
  system,

  /// Use English regardless of the device locale.
  english,

  /// Use Indonesian regardless of the device locale.
  indonesian;

  /// The BCP-47 language code this preference maps to, or `null` for System.
  ///
  /// `null` for System lets [MaterialApp.locale] stay `null`, at which point
  /// the framework invokes the `localeResolutionCallback` and the device's
  /// ordered locale list is iterated there.
  String? get languageCode => switch (this) {
    LanguagePreference.system => null,
    LanguagePreference.english => 'en',
    LanguagePreference.indonesian => 'id',
  };

  /// The [Locale] this preference resolves to for [MaterialApp.locale].
  ///
  /// `null` for System default — `MaterialApp` then follows the device, and the
  /// `localeResolutionCallback` installed in `app.dart` picks the first supported
  /// locale from the device's ordered list.
  Locale? get locale => switch (this) {
    LanguagePreference.system => null,
    LanguagePreference.english => const Locale('en'),
    LanguagePreference.indonesian => const Locale('id'),
  };

  /// The stable word persisted to `SharedPreferences`.
  ///
  /// A word rather than the enum index, so reordering this enum cannot change
  /// what an existing installation restores.
  String get storageValue => switch (this) {
    LanguagePreference.system => 'system',
    LanguagePreference.english => 'en',
    LanguagePreference.indonesian => 'id',
  };

  /// Restores a preference from its stored word.
  ///
  /// Falls back to [system] for any missing, malformed, or future value — the
  /// same safe default [ThemePreferenceStore.read] applies to its mode.
  static LanguagePreference fromStorage(Object? value) => switch (value) {
    'system' => LanguagePreference.system,
    'en' => LanguagePreference.english,
    'id' => LanguagePreference.indonesian,
    _ => LanguagePreference.system,
  };
}
