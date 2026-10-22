/// What the caller means by the collection name submitted to the move endpoint.
///
/// Mirrors the backend's `CollectionIntent` exactly. The name alone cannot
/// express the operation: the same name that is already taken is a destination
/// under [existing] and a conflict under [create], so the two intents have
/// opposite outcomes and the backend deliberately defaults neither.
enum MoveToCollectionIntent {
  /// The name identifies a collection the user selected as a destination.
  ///
  /// The backend reuses a collection of either type that holds the name, and
  /// keeps its create-or-get fallback when the name no longer resolves.
  existing('existing'),

  /// The user asked for a new collection with this name.
  ///
  /// A name already held by one of the user's collections is refused with
  /// `COLLECTION_NAME_ALREADY_EXISTS`; nothing is created or moved.
  create('create');

  const MoveToCollectionIntent(this.wireValue);

  /// The exact string sent as `collection_intent`.
  ///
  /// The wire values are stated here rather than derived from the Dart enum
  /// names, so renaming a value cannot silently change the request contract.
  final String wireValue;
}
