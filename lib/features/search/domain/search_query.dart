/// Query length limits, measured in Unicode runes after trimming.
///
/// These limits are enforced locally to avoid sending queries that would be
/// rejected by the endpoint. The backend remains authoritative if its rules
/// ever differ from the client.
const int searchQueryMinRunes = 2;
const int searchQueryMaxRunes = 128;

/// Describes why a query cannot be submitted, or null when it is valid.
enum SearchQueryProblem {
  /// The query contains only whitespace after trimming.
  empty,

  /// The trimmed query contains fewer than [searchQueryMinRunes] runes.
  tooShort,

  /// The trimmed query contains more than [searchQueryMaxRunes] runes.
  tooLong,
}

/// Removes surrounding whitespace from [query].
///
/// Uses `String.trim`, which removes Unicode whitespace from both ends.
String normalizeSearchQuery(String query) => query.trim();

/// Validates [query] against the supported query length limits.
///
/// Length is measured in Unicode runes, not UTF-16 code units or UTF-8 bytes.
/// `String.runes` counts Unicode code points, so a two-emoji query has a
/// length of two runes even though it occupies four UTF-16 code units.
/// Similarly, 128 emoji characters remain within the limit.
///
/// Returns null when the trimmed query is valid for submission.
SearchQueryProblem? validateSearchQuery(String query) {
  final trimmed = normalizeSearchQuery(query);
  final length = trimmed.runes.length;

  if (length == 0) return SearchQueryProblem.empty;
  if (length < searchQueryMinRunes) return SearchQueryProblem.tooShort;
  if (length > searchQueryMaxRunes) return SearchQueryProblem.tooLong;
  return null;
}
