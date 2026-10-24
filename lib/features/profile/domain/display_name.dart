/// The backend's display-name bounds, and the one client-side check that mirrors
/// them.
///
/// `PATCH /users/me` validates `display_name` with `required,min=2,max=100`, and
/// the same tag is applied to the column at registration. The bounds are counted
/// in **Unicode code points**, which is what Go's validator counts and what Dart's
/// `String.runes` exposes. Counting UTF-16 code units instead would refuse a name
/// the server accepts and accept one it refuses.
///
/// **The value is not trimmed.** Registration stores a display name verbatim and
/// the update endpoint does the same, so trimming here would make this client the
/// only place that disagrees about what the column holds.
const int displayNameMinRunes = 2;
const int displayNameMaxRunes = 100;

/// Why [value] is outside the display-name bounds, or null when it is acceptable.
///
/// Returns a reason rather than copy: the sentence is presentation's, and this
/// rule is shared by the form's local check and its tests.
DisplayNameProblem? displayNameProblem(String value) {
  final length = value.runes.length;
  if (length < displayNameMinRunes) return DisplayNameProblem.tooShort;
  if (length > displayNameMaxRunes) return DisplayNameProblem.tooLong;
  return null;
}

/// The two ways a display name misses its bounds.
enum DisplayNameProblem { tooShort, tooLong }
