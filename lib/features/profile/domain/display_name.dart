/// Display-name length limits and the client-side validation rule.
///
/// The server applies the same bounds during registration and profile updates.
/// Length is measured in **Unicode code points**, matching Dart's
/// `String.runes`. Counting UTF-16 code units instead could produce different
/// validation results for names containing supplementary characters.
///
/// **The value is not trimmed.** Registration and profile updates preserve the
/// submitted display name, so the client must validate the value as provided.
const int displayNameMinRunes = 2;
const int displayNameMaxRunes = 100;

/// Returns why [value] is outside the display-name bounds, or null if valid.
///
/// Returns a problem identifier rather than presentation copy, allowing the
/// form and its tests to share the same validation rule.
DisplayNameProblem? displayNameProblem(String value) {
  final length = value.runes.length;
  if (length < displayNameMinRunes) return DisplayNameProblem.tooShort;
  if (length > displayNameMaxRunes) return DisplayNameProblem.tooLong;
  return null;
}

/// The possible display-name validation problems.
enum DisplayNameProblem { tooShort, tooLong }
