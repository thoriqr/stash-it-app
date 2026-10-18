import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import 'models/listed_saved_item.dart';

/// The three enrichment values **[D8]** allows, on the wire exactly as the
/// backend spells them.
const String _pending = 'pending';
const String _completed = 'completed';
const String _failed = 'failed';

/// Maps one wire row onto the presentation model.
///
/// A plain function rather than a mapper class: there is one input and one
/// output, and `AGENTS.md` §2 prefers functions.
SavedItemSummary savedItemFrom(
  ListedSavedItemResponse dto, {
  required DateTime now,
}) {
  return SavedItemSummary(
    id: dto.id,
    url: dto.url,
    collectionName: dto.collection.name,
    enrichmentStatus: _enrichmentFrom(dto.enrichmentStatus),
    // Null stays null. A page that exposed no title is `completed` with no
    // title, which **[D17]** confirms is normal — the row falls back to the URL
    // and colours it as neutral copy, never as a fault.
    title: dto.title,
    description: dto.description,
    // The contract sends a URL or `null`. An empty string is not a usable image
    // and would render a slot that claims to have one.
    hasPreviewImage: dto.imageUrl != null && dto.imageUrl!.trim().isNotEmpty,
    savedTimeLabel: _savedTimeLabel(dto.createdAt, now),
  );
}

/// Maps the wire value onto **[D8]**'s three states.
///
/// The backend contract states exactly three values, so the default arm is
/// defensive and unreachable against a conforming server. It resolves to
/// `pending` rather than `completed` or `failed` because `pending` is the value
/// a row is *stored* with before enrichment runs: it is the one state that
/// asserts nothing about what enrichment found, so a value this client does not
/// recognise cannot make it claim either success or failure.
EnrichmentStatus _enrichmentFrom(String wire) => switch (wire) {
  _completed => EnrichmentStatus.completed,
  _failed => EnrichmentStatus.failed,
  _pending => EnrichmentStatus.pending,
  _ => EnrichmentStatus.pending,
};

/// The saved-time label, as the approved prototype words it.
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
String? _savedTimeLabel(String createdAt, DateTime now) {
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
