/// One URL kept on this device after a shared save could not be confirmed.
///
/// **Device-local and account-independent.** The entry carries no user id,
/// session id, or collection; it is public to anyone using this installation.
/// The URL is stored exactly as it was sent to the API (trimmed, not otherwise
/// normalised), so two URLs that differ in any character remain distinct.
class PendingUrl {
  const PendingUrl({
    required this.url,
    required this.addedAt,
    required this.uncertain,
  });

  /// The exact trimmed URL submitted to `POST /saved-items`.
  final String url;

  /// When the local entry was created or last refreshed, in UTC.
  final DateTime addedAt;

  /// Whether the remote save outcome could not be established.
  ///
  /// True for a transport failure or an unreadable response: the write may have
  /// committed even though the client has no confirmation. False for a known
  /// failure, where the request demonstrably did not create the item.
  final bool uncertain;
}

/// The store's current view, including how many expired entries were pruned.
///
/// [expiredCount] is what lets the app publish the one-time expiry notice
/// without the store depending on Riverpod or UI copy.
class PendingUrlSnapshot {
  const PendingUrlSnapshot({required this.entries, required this.expiredCount});

  static const PendingUrlSnapshot empty = PendingUrlSnapshot(
    entries: [],
    expiredCount: 0,
  );

  /// Unexpired entries, newest first.
  final List<PendingUrl> entries;

  /// Entries removed because they were at least seven days old.
  final int expiredCount;
}
