import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/profile/presentation/profile_date.dart';

void main() {
  test('formats a valid date with the profile pattern', () {
    expect(formatProfileDate(DateTime(2026, 4, 12, 12)), '12 Apr 2026');
  });

  test('converts a UTC timestamp to the local date before formatting', () {
    // Pick a local time close enough to midnight that any non-zero UTC offset
    // changes the calendar day. In a UTC environment the date is unchanged;
    // in any other zone this fails if the helper formats the UTC fields.
    final localNoon = DateTime(2026, 10, 7, 12);
    final local = localNoon.timeZoneOffset.isNegative
        ? DateTime(2026, 10, 7, 23, 30)
        : DateTime(2026, 10, 7, 0, 30);

    expect(formatProfileDate(local.toUtc()), '07 Oct 2026');
  });

  test('returns null for a missing date', () {
    expect(formatProfileDate(null), isNull);
  });
}
