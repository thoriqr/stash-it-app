import '../domain/saved_item_summary.dart';

/// The three enrichment values **[D8]** allows, on the wire exactly as the
/// backend spells them.
const String _pending = 'pending';
const String _completed = 'completed';
const String _failed = 'failed';

/// Maps the wire enrichment value onto **[D8]**'s three states.
///
/// Extracted from `saved_item_mapper.dart` because `GET /search` reports the
/// same `enrichment_status` field for the same saved items. Both features
/// therefore share one interpretation of the value rather than two that can
/// drift.
///
/// **The fallback is deliberately `pending`.** The backend contract states
/// exactly three values, so the default arm is defensive and unreachable
/// against a conforming server. `pending` is the value a row is *stored* with
/// before enrichment runs: it is the one state that asserts nothing about what
/// enrichment found, so a value this client does not recognise cannot make it
/// claim either success or failure.
EnrichmentStatus enrichmentStatusFrom(String wire) => switch (wire) {
  _completed => EnrichmentStatus.completed,
  _failed => EnrichmentStatus.failed,
  _pending => EnrichmentStatus.pending,
  _ => EnrichmentStatus.pending,
};

/// The saved-time label, as the approved prototype words it.
///
/// Extracted from `saved_item_mapper.dart` because `GET /search` reports the
/// same `created_at` field, and the Inbox and Search rows must word the same
/// elapsed time identically. The rules are unchanged: minutes, hours,
/// "yesterday" between 24 and 48 hours, then whole days.
///
/// **[D22] Flutter owns this string.** The backend sends `created_at` and no
/// formatted label; nothing here is taken from a server `message`.
///
/// **`now` is injected** so the label is deterministic under test rather than
/// depending on the wall clock.
///
/// Returns null when `created_at` cannot be parsed or is in the future. The row
/// then simply has no time label, which it already handles — a missing label is
/// far better than a fabricated one, and **[D15]** requires that an outcome this
/// client cannot establish is never stated as if it could.
///
/// **Not localised yet.** `flutter_localizations` is not a dependency
/// (`AGENTS.md` §4), so this is English-only, exactly as the rest of the app's
/// copy currently is.
String? savedTimeLabelFrom(String createdAt, DateTime now) {
  final saved = DateTime.tryParse(createdAt);
  if (saved == null) return null;

  final elapsed = now.difference(saved.toLocal());

  // A clock skew that puts the item in the future is not evidence about the
  // item, so no label is claimed.
  if (elapsed.isNegative) return null;

  if (elapsed.inMinutes < 1) return 'Saved just now';
  if (elapsed.inHours < 1) return 'Saved ${elapsed.inMinutes} min ago';
  if (elapsed.inHours < 24) {
    return elapsed.inHours == 1
        ? 'Saved 1 hour ago'
        : 'Saved ${elapsed.inHours} hours ago';
  }
  if (elapsed.inHours < 48) return 'Saved yesterday';

  return 'Saved ${elapsed.inDays} days ago';
}
