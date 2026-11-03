import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_time.dart';
import 'package:stash_it_app/features/saved_items/presentation/saved_time_label.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final indonesian = lookupAppLocalizations(const Locale('id'));

  group('savedTimeLabel', () {
    test('renders just now in both locales', () {
      expect(
        savedTimeLabel(english, const SavedTime.justNow()),
        'Saved just now',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.justNow()),
        'Baru saja disimpan',
      );
    });

    test('renders minute counts and the English singular', () {
      expect(
        savedTimeLabel(english, const SavedTime.minutes(1)),
        'Saved 1 min ago',
      );
      expect(
        savedTimeLabel(english, const SavedTime.minutes(12)),
        'Saved 12 min ago',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.minutes(1)),
        'Disimpan 1 menit lalu',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.minutes(12)),
        'Disimpan 12 menit lalu',
      );
    });

    test('renders hour counts and the English singular', () {
      expect(
        savedTimeLabel(english, const SavedTime.hours(1)),
        'Saved 1 hour ago',
      );
      expect(
        savedTimeLabel(english, const SavedTime.hours(2)),
        'Saved 2 hours ago',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.hours(1)),
        'Disimpan 1 jam lalu',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.hours(2)),
        'Disimpan 2 jam lalu',
      );
    });

    test('renders yesterday in both locales', () {
      expect(
        savedTimeLabel(english, const SavedTime.yesterday()),
        'Saved yesterday',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.yesterday()),
        'Disimpan kemarin',
      );
    });

    test('renders day counts and the English singular', () {
      expect(
        savedTimeLabel(english, const SavedTime.days(2)),
        'Saved 2 days ago',
      );
      expect(
        savedTimeLabel(indonesian, const SavedTime.days(2)),
        'Disimpan 2 hari lalu',
      );
    });
  });
}
