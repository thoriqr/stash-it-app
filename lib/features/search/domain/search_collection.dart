/// A collection result from `GET /search`.
///
/// **Only the two fields Search returns.** The endpoint does not report a
/// collection's type, system identity, saved-item count or timestamps, so this
/// model has no property for them. It is deliberately not `CollectionSummary`:
/// that model requires values Search never sends, and reusing it would force
/// this feature to invent them.
///
/// [id] is retained for a future navigation destination. No route exists yet,
/// and this feature adds none.
class SearchCollection {
  const SearchCollection({required this.id, required this.name});

  final String id;

  final String name;
}
