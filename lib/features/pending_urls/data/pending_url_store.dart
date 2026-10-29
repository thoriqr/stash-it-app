import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/pending_url.dart';

/// How long a locally kept URL survives after it was created or refreshed.
///
/// A client policy constant, not a backend rule: the server has no pending-URL
/// concept. Expiry is enforced on every read and write rather than by a timer,
/// because mobile operating systems do not guarantee background execution.
const Duration pendingUrlRetention = Duration(days: 7);

/// A shared-preferences write that did not persist.
///
/// Thrown rather than swallowed so the share flow can report that the URL was
/// **not** safely kept. This is the opposite of the theme preference, where a
/// failed write is a recoverable convenience; here a false claim of local safety
/// would lose the user's link.
class PendingUrlStorageException implements Exception {
  const PendingUrlStorageException(this.message);

  final String message;

  @override
  String toString() => 'PendingUrlStorageException: $message';
}

/// Persists the device-local fallback list in `shared_preferences`.
///
/// **This store is intentionally not account-scoped.** It has no user id, no
/// session dependency, and no relationship to `SessionBoundary`. Anyone using
/// the installation can read it, including a user who has never signed in.
/// Credentials and auth continuations remain in `flutter_secure_storage`; these
/// URLs are non-secret application data and are stored where the app already
/// keeps its small device-local preferences.
///
/// The value is one JSON array so a read does not need several keys and a write
/// replaces the whole list atomically at the preferences level. A malformed
/// array, or a malformed member, never makes the store unusable: valid members
/// survive.
class PendingUrlStore {
  const PendingUrlStore(
    SharedPreferences preferences, {
    this.now = DateTime.now,
  }) : _preferences = preferences;

  /// The namespaced key, shared with tests and future migrations.
  static const String storageKey = 'stash_it.pending_urls.entries';

  /// Set when a read or write prunes entries, consumed by the UI provider.
  ///
  /// It lives beside the list rather than only in the store's return value
  /// because a share can prune the list while no screen is reading it. The
  /// notice must survive until the app next reads the list, and must not be
  /// emitted twice for the same prune.
  static const String expiryNoticeKey = 'stash_it.pending_urls.expiry_notice';

  final SharedPreferences _preferences;

  /// The clock used for retention and for the entry timestamp.
  ///
  /// Injected so seven-day behaviour is deterministic under test; production
  /// passes the default.
  final DateTime Function() now;

  /// The unexpired entries, newest first, plus how many expired entries were
  /// removed during this read.
  ///
  /// A platform read failure propagates. A malformed value or member is skipped
  /// rather than treated as a failure, and expired members are pruned from the
  /// returned list. The pruned list is persisted best-effect: a failed cleanup
  /// write does not hide the still-valid entries, and the next read retries.
  Future<PendingUrlSnapshot> readAll() async {
    final raw = _preferences.get(storageKey);
    if (raw is! String || raw.isEmpty) return PendingUrlSnapshot.empty;

    final decoded = _decode(raw);
    final cutoff = now().toUtc().subtract(pendingUrlRetention);

    final kept = <PendingUrl>[];
    var expired = 0;
    for (final entry in decoded) {
      if (entry.addedAt.isBefore(cutoff) ||
          entry.addedAt.isAtSameMomentAs(cutoff)) {
        expired++;
        continue;
      }
      kept.add(entry);
    }

    kept.sort((a, b) => b.addedAt.compareTo(a.addedAt));

    if (expired > 0) {
      try {
        await writeEntries(kept);
        // Record the prune so the app can announce it even when this read came
        // from a share's write rather than from a screen. The notice is consumed
        // once, in `consumeExpiryNotice`.
        await _preferences.setBool(expiryNoticeKey, true);
      } catch (_) {
        // The valid entries are still readable. The expired rows remain on disk
        // and the next read will try the cleanup again.
      }
    }

    return PendingUrlSnapshot(
      entries: List<PendingUrl>.unmodifiable(kept),
      expiredCount: expired,
    );
  }

  /// Returns whether a prune is owed a notice, and clears the flag.
  ///
  /// The caller is the `PendingUrls` provider, which publishes the one-time
  /// warning. Clearing before returning makes repeated provider builds silent
  /// for the same prune.
  Future<bool> consumeExpiryNotice() async {
    final pending = _preferences.getBool(expiryNoticeKey) ?? false;
    if (!pending) return false;
    try {
      await _preferences.remove(expiryNoticeKey);
    } catch (_) {
      // The notice is still owed; a cleanup failure must not turn a successful
      // local-list read into an error screen. The next successful remove clears
      // it, so a repeat is preferable to hiding the entries.
    }
    return true;
  }

  /// Adds or refreshes [url], replacing any entry with the exact same string.
  ///
  /// The stored URL is the trimmed value the caller submitted. Comparison is
  /// exact: different paths or query strings are different entries. The new
  /// timestamp is the top of the list, so a repeat share refreshes both its age
  /// and its [uncertain] state.
  ///
  /// A write failure throws [PendingUrlStorageException] (or the underlying
  /// platform error) so the caller cannot claim the URL was kept.
  Future<void> upsert({required String url, required bool uncertain}) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(url, 'url', 'must not be empty');
    }

    final current = await readAll();
    final entries =
        current.entries
            .where((entry) => entry.url != trimmed)
            .toList(growable: true)
          ..insert(
            0,
            PendingUrl(
              url: trimmed,
              addedAt: now().toUtc(),
              uncertain: uncertain,
            ),
          );

    await writeEntries(entries);
  }

  /// Removes the entry whose URL is exactly [url], if there is one.
  ///
  /// Used after a later confirmed save: the share intake treats a failure as
  /// best-effort cleanup, while a bulk run stops so it cannot accumulate more
  /// unremovable copies. The remote save already succeeded either way, so the
  /// caller decides whether to report the local failure.
  Future<void> removeExact(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final current = await readAll();
    final remaining = current.entries
        .where((entry) => entry.url != trimmed)
        .toList(growable: false);
    if (remaining.length == current.entries.length) return;

    await writeEntries(remaining);
  }

  /// Marks the entry whose URL is exactly [url] as uncertain.
  ///
  /// **Does not refresh [PendingUrl.addedAt].** The seven-day retention window
  /// belongs to when the URL was kept; an ambiguous bulk attempt is not a new
  /// share. [upsert] refreshes both values, so it cannot be used here.
  ///
  /// A missing or already-uncertain entry is a no-op. A failed write throws, as
  /// [upsert] does, so the caller cannot claim the flag was persisted.
  Future<void> markUncertain(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final current = await readAll();
    var changed = false;
    final entries = <PendingUrl>[];
    for (final entry in current.entries) {
      if (entry.url == trimmed && !entry.uncertain) {
        changed = true;
        entries.add(
          PendingUrl(url: entry.url, addedAt: entry.addedAt, uncertain: true),
        );
      } else {
        entries.add(entry);
      }
    }

    if (!changed) return;
    await writeEntries(entries);
  }

  /// Writes [entries] as one JSON array, deleting the key when the list is empty.
  ///
  /// Public as the persistence seam: a focused test can override it to simulate
  /// a failed write without reaching into the preferences plugin. Every mutation
  /// in this class goes through it.
  @visibleForTesting
  Future<void> writeEntries(List<PendingUrl> entries) async {
    if (entries.isEmpty) {
      await _preferences.remove(storageKey);
      return;
    }

    final value = jsonEncode([
      for (final entry in entries)
        {
          'url': entry.url,
          'added_at': entry.addedAt.toUtc().toIso8601String(),
          'uncertain': entry.uncertain,
        },
    ]);

    final written = await _preferences.setString(storageKey, value);
    if (!written) {
      throw const PendingUrlStorageException(
        'shared_preferences did not persist the pending URL list',
      );
    }
  }

  List<PendingUrl> _decode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      // Exact-URL uniqueness is a store invariant, but a corrupted or
      // externally-written value could still contain duplicates. Keep the
      // newest record for each URL so a read cannot expose two entries that the
      // store would otherwise collapse.
      final byUrl = <String, PendingUrl>{};
      for (final item in decoded) {
        if (item is! Map) continue;

        final url = item['url'];
        final addedAt = item['added_at'];
        if (url is! String || addedAt is! String) continue;

        final trimmedUrl = url.trim();
        if (trimmedUrl.isEmpty) continue;

        final parsedAt = DateTime.tryParse(addedAt);
        if (parsedAt == null) continue;

        final entry = PendingUrl(
          url: trimmedUrl,
          addedAt: parsedAt.toUtc(),
          uncertain: item['uncertain'] == true,
        );

        final previous = byUrl[trimmedUrl];
        if (previous == null || entry.addedAt.isAfter(previous.addedAt)) {
          byUrl[trimmedUrl] = entry;
        }
      }

      return byUrl.values.toList(growable: false);
    } on FormatException {
      return const [];
    }
  }
}

/// The device-local pending URL store, overridden by `bootstrap` and tests.
///
/// A plain [Provider] for the same reason as the other local stores: the value
/// never changes, and the deliberate default keeps a platform channel out of a
/// test that has not substituted a store.
final Provider<PendingUrlStore> pendingUrlStoreProvider =
    Provider<PendingUrlStore>(
      (ref) => throw UnimplementedError(
        'pendingUrlStoreProvider must be overridden with a real or fake store',
      ),
    );
