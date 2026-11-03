import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/saved_item_display_mapper.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_time.dart';

/// The two rules shared by the Inbox, Search and collection rows.
///
/// These pin the enrichment mapping and the saved-time buckets without relying
/// on localized display copy.
void main() {
  final now = DateTime.utc(2026, 10, 2, 12, 0);

  group('enrichmentStatusFrom', () {
    test('maps the three documented values', () {
      expect(enrichmentStatusFrom('pending'), EnrichmentStatus.pending);
      expect(enrichmentStatusFrom('completed'), EnrichmentStatus.completed);
      expect(enrichmentStatusFrom('failed'), EnrichmentStatus.failed);
    });

    test('an unknown value asserts nothing about the page', () {
      // Not completed and not failed: either would claim an outcome the client
      // cannot establish from a value it does not recognise.
      expect(enrichmentStatusFrom('processing'), EnrichmentStatus.pending);
      expect(enrichmentStatusFrom(''), EnrichmentStatus.pending);
    });
  });

  group('savedTimeFrom', () {
    SavedTime? timeAt(String createdAt) => savedTimeFrom(createdAt, now);

    test('preserves the approved bucket boundaries', () {
      expect(timeAt('2026-10-02T11:59:30Z'), const SavedTime.justNow());
      expect(timeAt('2026-10-02T11:59:00Z'), const SavedTime.minutes(1));
      expect(timeAt('2026-10-02T11:00:00Z'), const SavedTime.hours(1));
      expect(timeAt('2026-10-02T10:00:00Z'), const SavedTime.hours(2));
      expect(timeAt('2026-10-01T12:00:00Z'), const SavedTime.yesterday());
      expect(timeAt('2026-10-01T12:00:01Z'), const SavedTime.hours(23));
      expect(timeAt('2026-09-30T12:00:00Z'), const SavedTime.days(2));
    });

    test('keeps whole-count values at each boundary', () {
      expect(timeAt('2026-10-02T11:01:00Z'), const SavedTime.minutes(59));
      expect(timeAt('2026-10-02T12:00:00Z'), const SavedTime.justNow());
      expect(timeAt('2026-10-01T12:00:01Z'), const SavedTime.hours(23));
      expect(timeAt('2026-10-01T12:00:00Z'), const SavedTime.yesterday());
      expect(timeAt('2026-09-30T11:59:59Z'), const SavedTime.days(2));
    });

    test('an unparseable timestamp produces no time value', () {
      expect(timeAt('not a date'), isNull);
      expect(timeAt(''), isNull);
    });

    test('a future timestamp produces no time value', () {
      expect(timeAt('2026-10-02T12:00:01Z'), isNull);
      expect(timeAt('2026-10-03T12:00:00Z'), isNull);
    });
  });
}
