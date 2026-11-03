import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';
import 'package:stash_it_app/features/profile/presentation/profile_identity_label.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final indonesian = lookupAppLocalizations(const Locale('id'));

  String label(String provider, AppLocalizations localizations) =>
      identityDisplayLabel(
        UserIdentity(provider: provider, linkedAt: null),
        localizations,
      );

  test('keeps provider brand names unchanged', () {
    for (final (provider, expected) in const [
      ('google', 'Google'),
      ('apple', 'Apple'),
      ('github', 'GitHub'),
      ('facebook', 'Facebook'),
      ('twitter', 'X'),
      ('x', 'X'),
    ]) {
      expect(label(provider, english), expected);
      expect(label(provider, indonesian), expected);
    }
  });

  test('localizes the email credential family', () {
    for (final provider in const [
      'email',
      'password',
      'local',
      'credentials',
    ]) {
      expect(label(provider, english), 'Email & password');
      expect(label(provider, indonesian), 'Email & kata sandi');
    }
  });

  test('localizes an empty provider', () {
    expect(label('', english), 'Unknown');
    expect(label('', indonesian), 'Tidak diketahui');
  });

  test('capitalizes an unknown provider without translating it', () {
    expect(label('discord', english), 'Discord');
    expect(label('discord', indonesian), 'Discord');
  });
}
