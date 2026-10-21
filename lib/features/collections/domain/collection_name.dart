/// The backend's collection-name shape rule, and the one comparison the move
/// sheet needs.
///
/// **Only shape.** `internal/api/collection/service.go` trims with
/// `strings.TrimSpace`, rejects blank or more than 100 runes, preserves the
/// stored casing, and resolves an existing collection with
/// `lower(btrim(name))`. This file mirrors the first half so a value the server
/// would certainly reject never becomes a request. It deliberately does **not**
/// mirror uniqueness: whether a name already exists depends on the user's
/// collections, is case-insensitive, and is the backend's answer to give.
library;

/// Longest accepted collection name, counted in Unicode code points — the same
/// unit as Go's `utf8.RuneCountInString`, not Dart's UTF-16 `String.length`.
const int collectionNameMaxRunes = 100;

/// Why a collection name cannot be submitted, or null when it can.
enum CollectionNameProblem {
  /// Empty after trimming.
  blank,

  /// More than [collectionNameMaxRunes] runes after trimming.
  tooLong,
}

/// Checks a raw input against the backend's trimmed, 100-rune rule.
///
/// Returns null when [raw] would pass the server's shape check. The caller still
/// submits the name because the server remains authoritative for uniqueness and
/// every other rule.
CollectionNameProblem? collectionNameProblem(String raw) {
  final name = raw.trim();
  if (name.isEmpty) return CollectionNameProblem.blank;
  if (name.runes.length > collectionNameMaxRunes) {
    return CollectionNameProblem.tooLong;
  }
  return null;
}

/// The value sent to the server: surrounding whitespace removed, casing kept.
///
/// Backend storage does the same trim, so sending the untrimmed value would only
/// move the same operation across the wire. Casing is preserved because the
/// collection's stored name is user-visible.
String normalizedCollectionName(String raw) => raw.trim();

/// Whether two names denote the same collection under the server's
/// case-insensitive, whitespace-trimmed comparison.
///
/// Used only to resolve a typed name against names the server has already shown
/// us, and to recognise the item's current collection. It is **not** a
/// uniqueness check: a name that matches nothing loaded is still submitted, and
/// the backend decides whether it already exists.
bool sameCollectionName(String left, String right) =>
    normalizedCollectionName(left).toLowerCase() ==
    normalizedCollectionName(right).toLowerCase();
