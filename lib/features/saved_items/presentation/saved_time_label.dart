import 'package:stash_it_app/features/saved_items/domain/saved_time.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Resolves the active localized copy for [time].
String savedTimeLabel(AppLocalizations localizations, SavedTime time) {
  return switch (time.kind) {
    SavedTimeKind.justNow => localizations.savedTimeJustNow,
    SavedTimeKind.minutes => localizations.savedTimeMinutesAgo(time.value),
    SavedTimeKind.hours => localizations.savedTimeHoursAgo(time.value),
    SavedTimeKind.yesterday => localizations.savedTimeYesterday,
    SavedTimeKind.days => localizations.savedTimeDaysAgo(time.value),
  };
}
