/// Collection-name validation and comparison helpers.
///
/// These helpers validate the name's shape and compare names already available
/// to the client. The server remains authoritative for uniqueness and other
/// validation rules.
library;

/// Maximum accepted collection-name length in Unicode code points.
const int collectionNameMaxRunes = 100;

/// Why a collection name cannot be submitted, or null when it is valid.
enum CollectionNameProblem {
  /// Empty after trimming.
  blank,

  /// Exceeds [collectionNameMaxRunes] Unicode code points after trimming.
  tooLong,
}

/// Checks whether [raw] satisfies the collection-name shape rules.
///
/// Returns null when the name is non-empty and within the length limit after
/// trimming. Uniqueness and other validation rules are checked by the server.
CollectionNameProblem? collectionNameProblem(String raw) {
  final name = raw.trim();
  if (name.isEmpty) return CollectionNameProblem.blank;
  if (name.runes.length > collectionNameMaxRunes) {
    return CollectionNameProblem.tooLong;
  }
  return null;
}

/// Trims surrounding whitespace while preserving the original casing.
String normalizedCollectionName(String raw) => raw.trim();

/// Compares collection names after trimming whitespace and ignoring casing.
///
/// This is for matching names already known to the client, not for checking
/// uniqueness. Names that do not match a loaded collection are still submitted
/// to the server for validation.
bool sameCollectionName(String left, String right) =>
    normalizedCollectionName(left).toLowerCase() ==
    normalizedCollectionName(right).toLowerCase();
