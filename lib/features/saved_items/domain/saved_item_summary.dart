/// Enrichment state of a saved item.
///
/// D8 [Confirmed]: exactly three values — `pending`, `completed`, `failed`. There is
/// deliberately no `processing` and no `retrying`, and the client must not invent an
/// intermediate state.
///
/// A `completed` item means the enrichment *process* succeeded. It does not mean
/// metadata was found (D17 [Confirmed]).
enum EnrichmentStatus { pending, completed, failed }

/// One saved item as the Inbox row presents it.
///
/// **This is a mock presentation model for the visual prototype. It is not a DTO and
/// it is not an API contract.** No endpoint lists recently saved items across
/// collections; D26 records a product-level requirement only, so no field set here has
/// been agreed with the backend. Fields mirror what the approved wireframes show a
/// row needing, and nothing more.
///
/// Shape follows `docs/wireframes/02-item-presentation.html`: optional title,
/// optional description, optional preview image, a URL, the item's *current*
/// collection, and an enrichment status.
class SavedItemSummary {
  const SavedItemSummary({
    required this.id,
    required this.url,
    required this.collectionName,
    required this.enrichmentStatus,
    this.title,
    this.description,
    this.hasPreviewImage = false,
    this.savedTimeLabel,
  });

  /// Mock identifier. Not a backend id contract.
  final String id;

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

  /// Whether the backend would have supplied a preview image.
  final bool hasPreviewImage;

  /// A pre-formatted, presentation-only saved-time string, such as
  /// `Saved 12 min ago`.
  ///
  /// **Prototype data. Not a timestamp and not a backend field.** It is deliberately a
  /// `String` rather than a `DateTime` so this model cannot imply a timestamp format,
  /// a timezone policy, or an ordering contract. Real `created_at` integration waits
  /// for the Inbox API contract, which does not exist (D26). These strings also do
  /// not define the list order; nothing here sorts by them.
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
