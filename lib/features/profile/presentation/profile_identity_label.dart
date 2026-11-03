import 'package:stash_it_app/features/profile/domain/user_profile.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Resolves the visible label for [identity].
///
/// Provider brand names are identifiers and remain unchanged. The email
/// credential family and an empty provider use localized UI concepts; an
/// unrecognised non-empty provider is displayed with its first letter
/// capitalized without being translated.
String identityDisplayLabel(
  UserIdentity identity,
  AppLocalizations localizations,
) {
  switch (identity.provider.toLowerCase()) {
    case 'google':
      return 'Google';
    case 'apple':
      return 'Apple';
    case 'github':
      return 'GitHub';
    case 'facebook':
      return 'Facebook';
    case 'twitter':
    case 'x':
      return 'X';
    case 'email':
    case 'password':
    case 'local':
    case 'credentials':
      return localizations.profileIdentityEmailPassword;
    default:
      if (identity.provider.isEmpty) {
        return localizations.profileIdentityUnknown;
      }
      return identity.provider[0].toUpperCase() +
          identity.provider.substring(1);
  }
}
