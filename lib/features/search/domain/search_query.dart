/// The backend's query bounds, measured in **runes after trimming**.
///
/// These mirror `internal/api/search/constants.go` (`QueryMinLength` and
/// `QueryMaxLength`). They are duplicated here deliberately: the client must
/// refuse an invalid query without spending one of the endpoint's rate-limited
/// requests, and the backend remains the authority if the two ever disagree.
const int searchQueryMinRunes = 2;
const int searchQueryMaxRunes = 128;

/// Why a query cannot be submitted, or null when it can.
enum SearchQueryProblem {
  /// Nothing but whitespace remained after trimming.
  empty,

  /// Fewer than [searchQueryMinRunes] runes remained.
  tooShort,

  /// More than [searchQueryMaxRunes] runes remained.
  tooLong,
}

/// The submitted query, with surrounding whitespace removed.
///
/// Uses `String.trim`, which removes Unicode whitespace at both ends — the same
/// convention the backend applies with `strings.TrimSpace`.
String normalizeSearchQuery(String query) => query.trim();

/// Validates [query] under the backend's own rules.
///
/// **The length is counted in Unicode runes, never UTF-16 code units or UTF-8
/// bytes.** `String.runes` yields code points, matching Go's
/// `utf8.RuneCountInString`. A two-emoji query is two runes even though it
/// occupies four UTF-16 units, and a 128-emoji query is 128 runes (256 UTF-16
/// units) and remains within the limit; one more rune is over it.
///
/// Returns null when the trimmed query may be sent.
SearchQueryProblem? validateSearchQuery(String query) {
  final trimmed = normalizeSearchQuery(query);
  final length = trimmed.runes.length;

  if (length == 0) return SearchQueryProblem.empty;
  if (length < searchQueryMinRunes) return SearchQueryProblem.tooShort;
  if (length > searchQueryMaxRunes) return SearchQueryProblem.tooLong;
  return null;
}
