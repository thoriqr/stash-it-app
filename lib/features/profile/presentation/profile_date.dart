import 'package:intl/intl.dart';

/// The compact date used by every Profile date.
///
/// The API sends UTC timestamps, so each value is converted to the device's
/// local timezone before a short day-month-year label is applied. Without the
/// conversion, a timestamp just after local midnight could display the previous
/// day.
final DateFormat _profileDateFormat = DateFormat('dd MMM yyyy');

/// Formats a server date in the device's local timezone, or returns null when
/// there is no usable date.
///
/// A null result means the API sent a value this client could not parse. The
/// caller must omit the date: it is never replaced with the current date,
/// because that would present fabricated account data as fact.
String? formatProfileDate(DateTime? date) {
  if (date == null) return null;

  return _profileDateFormat.format(date.toLocal());
}
