import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/data/saved_item_display_mapper.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

/// The two rules shared by the Inbox and Search rows.
///
/// Extracted from `saved_item_mapper.dart` without changing their behaviour, so
/// these pin the exact wording and boundaries that were previously only covered
/// through the Inbox mapper.
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

  group('savedTimeLabelFrom', () {
    String? labelAt(String createdAt) => savedTimeLabelFrom(createdAt, now);

    test('uses the approved wording and boundaries', () {
      expect(labelAt('2026-10-02T11:59:30Z'), 'Saved just now');
      expect(labelAt('2026-10-02T11:59:00Z'), 'Saved 1 min ago');
      expect(labelAt('2026-10-02T11:00:00Z'), 'Saved 1 hour ago');
      expect(labelAt('2026-10-02T10:00:00Z'), 'Saved 2 hours ago');
      expect(labelAt('2026-10-01T12:00:00Z'), 'Saved yesterday');
      expect(labelAt('2026-10-01T12:00:01Z'), 'Saved 23 hours ago');
      expect(labelAt('2026-09-30T12:00:00Z'), 'Saved 2 days ago');
    });

    test('an unparseable timestamp produces no label', () {
      expect(labelAt('not a date'), isNull);
      expect(labelAt(''), isNull);
    });

    test('a future timestamp produces no label rather than a negative one', () {
      expect(labelAt('2026-10-02T12:00:01Z'), isNull);
      expect(labelAt('2026-10-03T12:00:00Z'), isNull);
    });
  });
}
