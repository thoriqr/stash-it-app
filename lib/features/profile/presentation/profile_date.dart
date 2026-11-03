import 'package:intl/intl.dart';

/// Formats a server date in the device's local timezone and the active locale.
///
/// [localeName] is the locale supplied by [AppLocalizations.localeName] at the
/// presentation boundary. It is passed explicitly so the result does not depend
/// on `Intl.defaultLocale`.
///
/// A null result means the API sent a value this client could not parse. The
/// caller must omit the date: it is never replaced with the current date,
/// because that would present fabricated account data as fact.
String? formatProfileDate(DateTime? date, String localeName) {
  if (date == null) return null;

  return DateFormat('dd MMM yyyy', localeName).format(date.toLocal());
}
