import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/localization/locale_resolution.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Resolves the localized Toast copy for [outcome].
String shareOutcomeMessage(
  ShareSaveOutcome outcome,
  AppLocalizations localizations,
) => switch (outcome) {
  ShareSaveOutcome.saved => localizations.shareSaved,
  ShareSaveOutcome.storedAfterFailure => localizations.shareStoredAfterFailure,
  ShareSaveOutcome.storedAfterUncertain =>
    localizations.shareStoredAfterUncertain,
  ShareSaveOutcome.invalid => localizations.shareInvalid,
  ShareSaveOutcome.notStored => localizations.shareNotStored,
  ShareSaveOutcome.ignored => '',
};

/// Resolves the language used by a share Toast.
///
/// An explicit preference wins. System default follows the ordered device
/// locales and falls back to English, matching the rest of the app. The
/// caller supplies [deviceLocales] when it is not running in a widget tree.
AppLocalizations shareIntakeLocalizations(
  LanguagePreference preference, {
  List<Locale>? deviceLocales,
}) {
  final locale =
      preference.locale ??
      resolveAppLocale(
        deviceLocales ?? WidgetsBinding.instance.platformDispatcher.locales,
        AppLocalizations.supportedLocales,
      );
  return lookupAppLocalizations(locale);
}

/// Resolves share Toast localization from the restored preference in
/// [container]. This path does not require a widget tree.
AppLocalizations shareIntakeLocalizationsForContainer(
  ProviderContainer container, {
  List<Locale>? deviceLocales,
}) => shareIntakeLocalizations(
  container.read(languagePreferenceControllerProvider),
  deviceLocales: deviceLocales,
);
