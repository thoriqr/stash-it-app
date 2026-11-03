import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_localization.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/domain/language_preference.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final indonesian = lookupAppLocalizations(const Locale('id'));

  test('localizes every outcome in English and Indonesian', () {
    expect(
      shareOutcomeMessage(ShareSaveOutcome.saved, english),
      'Saved to your account.',
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.saved, indonesian),
      'Disimpan ke akun Anda.',
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.storedAfterFailure, english),
      "Couldn't save it. Kept on this device.",
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.storedAfterFailure, indonesian),
      'Gagal disimpan. Tetap disimpan di perangkat ini.',
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.storedAfterUncertain, english),
      'Save not confirmed. Kept on this device.',
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.storedAfterUncertain, indonesian),
      'Belum terkonfirmasi. Tetap disimpan di perangkat ini.',
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.invalid, english),
      "That's not a link, so nothing was saved.",
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.invalid, indonesian),
      'Itu bukan tautan, jadi tidak ada yang disimpan.',
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.notStored, english),
      "Couldn't save or keep this link.",
    );
    expect(
      shareOutcomeMessage(ShareSaveOutcome.notStored, indonesian),
      'Tidak dapat menyimpan atau mempertahankan tautan ini.',
    );
    expect(shareOutcomeMessage(ShareSaveOutcome.ignored, english), isEmpty);
    expect(shareOutcomeMessage(ShareSaveOutcome.ignored, indonesian), isEmpty);
  });

  test('keeps Toast copy brief and uncertainty-safe', () {
    for (final localizations in [english, indonesian]) {
      for (final outcome in ShareSaveOutcome.values) {
        expect(
          shareOutcomeMessage(outcome, localizations).length,
          lessThanOrEqualTo(60),
          reason: '${outcome.name} must fit comfortably in a brief Toast',
        );
      }
    }

    expect(
      shareOutcomeMessage(ShareSaveOutcome.storedAfterUncertain, indonesian),
      isNot(contains('Gagal')),
    );
  });

  test('headless path resolves the restored explicit preference', () {
    final container = ProviderContainer(
      overrides: [
        initialLanguagePreferenceProvider.overrideWithValue(
          LanguagePreference.indonesian,
        ),
      ],
    );
    addTearDown(container.dispose);

    final localizations = shareIntakeLocalizationsForContainer(
      container,
      deviceLocales: const [Locale('en')],
    );

    expect(localizations.localeName, 'id');
    expect(
      shareOutcomeMessage(ShareSaveOutcome.saved, localizations),
      'Disimpan ke akun Anda.',
    );
  });

  test('system preference follows ordered device locales', () {
    expect(
      shareIntakeLocalizations(
        LanguagePreference.system,
        deviceLocales: const [Locale('fr'), Locale('id')],
      ).localeName,
      'id',
    );
    expect(
      shareIntakeLocalizations(
        LanguagePreference.system,
        deviceLocales: const [Locale('fr')],
      ).localeName,
      'en',
    );
  });

  test('serializes the unchanged protocol with a localized message', () {
    expect(shareIntakeChannelName, 'stash_it/share_intake');

    expect(ShareSaveOutcome.saved.toChannelMap('Disimpan ke akun Anda.'), {
      'outcome': 'saved',
      'message': 'Disimpan ke akun Anda.',
      'stored': false,
    });
    expect(
      ShareSaveOutcome.storedAfterFailure.toChannelMap(
        'Gagal disimpan. Tetap disimpan di perangkat ini.',
      ),
      {
        'outcome': 'storedAfterFailure',
        'message': 'Gagal disimpan. Tetap disimpan di perangkat ini.',
        'stored': true,
      },
    );
    expect(
      ShareSaveOutcome.storedAfterUncertain.toChannelMap(
        'Belum terkonfirmasi. Tetap disimpan di perangkat ini.',
      ),
      {
        'outcome': 'storedAfterUncertain',
        'message': 'Belum terkonfirmasi. Tetap disimpan di perangkat ini.',
        'stored': true,
      },
    );
    expect(
      ShareSaveOutcome.notStored.toChannelMap(
        'Tidak dapat menyimpan atau mempertahankan tautan ini.',
      ),
      {
        'outcome': 'notStored',
        'message': 'Tidak dapat menyimpan atau mempertahankan tautan ini.',
        'stored': false,
      },
    );
  });
}
