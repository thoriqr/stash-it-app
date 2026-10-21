/// Enrichment state of a saved item.
///
/// D8 [Confirmed]: exactly three values — `pending`, `completed`, `failed`. There is
/// deliberately no `processing` and no `retrying`, and the client must not invent an
/// intermediate state.
///
/// A `completed` item means the enrichment *process* succeeded. It does not mean
/// metadata was found (D17 [Confirmed]).
enum EnrichmentStatus { pending, completed, failed }

/// One saved item as the Inbox and Search rows present it.
///
/// **The presentation model, not a DTO.** It is built by `saved_item_mapper.dart`
/// for the Inbox and by `search_mapper.dart` for Search, so the wire shape and
/// the display shape stay separate: a backend field cannot silently become a
/// rendering rule. It carries no HTTP concern and no serialization.
///
/// Fields mirror what a row needs to render, plus the collection id a future
/// destination would need. **Nothing is inferred**: a missing title stays missing
/// here and is resolved by [displayTitle], not filled in with a placeholder the
/// model invents.
class SavedItemSummary {
  const SavedItemSummary({
    required this.id,
    required this.collectionId,
    required this.url,
    required this.collectionName,
    required this.enrichmentStatus,
    this.title,
    this.description,
    this.hasPreviewImage = false,
    this.savedTimeLabel,
  });

  /// The item's id, exactly as the backend sent it.
  final String id;

  /// The id of the collection the item belongs to **now**.
  ///
  /// Carried exactly as the backend sent it. The row renders the collection's
  /// name, but keeping the id lets a future collection-contents route open the
  /// item's current collection without fetching the item again. It is never
  /// used to identify Unsorted: that is `system_key`, from `GET /collections`.
  final String collectionId;

  /// The saved URL, exactly as the page supplied it.
  final String url;

  /// The collection the item belongs to **now**.
  ///
  /// D26 [Confirmed]: the Inbox may show where an item is, never why it moved or
  /// where it will end up.
  final String collectionName;

  final EnrichmentStatus enrichmentStatus;

  /// Page-derived title. `null` when enrichment found none. Never rewritten or
  /// translated (D21).
  final String? title;

  /// Page-derived description excerpt. `null` when unavailable.
  final String? description;

  /// Whether a preview image exists for this item.
  ///
  /// Derived from the response's `image_url`: a URL means one, `null` (or an
  /// empty string) means none. There is no image loading in this milestone, so
  /// the row draws a placeholder either way.
  final bool hasPreviewImage;

  /// A pre-formatted saved-time string, such as `Saved 12 min ago`.
  ///
  /// **A display string, not a timestamp.** The mapper derives it from the
  /// response's `created_at`; keeping it a `String` means this model cannot imply
  /// a timestamp format, a timezone policy, or an ordering contract, and the row
  /// renders copy rather than doing arithmetic. `null` when the timestamp could
  /// not be parsed, in which case the row simply shows no label.
  ///
  /// It does not define the list order; nothing here sorts by it. **[D4]**
  final String? savedTimeLabel;

  /// `true` when enrichment produced no usable metadata at all.
  ///
  /// D8 [Confirmed]: this is a normal, successful state and must never be presented
  /// as an error.
  bool get hasNoMetadata =>
      enrichmentStatus == EnrichmentStatus.completed &&
      title == null &&
      description == null &&
      !hasPreviewImage;

  /// `true` when the display title is a fallback rather than a real page title.
  bool get usesFallbackTitle => title == null || title!.trim().isEmpty;

  /// The title line, following the `title → URL → domain` fallback chain.
  ///
  /// `ux-discovery` §C.2 / decisions §2: the chain is a documented [Rec]; rendering a
  /// missing title as an error or a fault-implying placeholder is [Confirmed]
  /// forbidden. The widget decides the styling, not this class.
  String get displayTitle {
    if (!usesFallbackTitle) return title!.trim();
    if (url.trim().isNotEmpty) return url.trim();
    return _host;
  }

  /// The compact source line: host and path, with `www.` and the scheme dropped.
  ///
  /// When the title has already fallen back to the URL, this shows the host alone —
  /// repeating the path underneath the URL would print the same string twice. This
  /// matches the fallback row in `docs/wireframes/02-item-presentation.html`.
  String get displaySource {
    if (usesFallbackTitle) return _host;
    return _host + _pathAndQuery;
  }

  String get _host {
    final uri = Uri.tryParse(url.trim());
    final host = uri?.host ?? '';
    if (host.isEmpty) return url.trim();
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  String get _pathAndQuery {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return '';
    final path = uri.path;
    final query = uri.hasQuery ? '?${uri.query}' : '';
    if (path.isEmpty || path == '/') return query;
    return '$path$query';
  }
}
