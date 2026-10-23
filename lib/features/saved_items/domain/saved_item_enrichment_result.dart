import 'saved_item_summary.dart';

/// What one completed `POST /saved-items/{id}/enrich` established about an item.
///
/// **Only the four fields enrichment can change.** The response carries the whole
/// twelve-field item, but `url`, `domain`, `platform`, `collection_id`,
/// `created_at` and `updated_at` are either immutable or have no presentation
/// here, and the collection's *name* is not in the response at all. Promoting the
/// full item into a `SavedItemSummary` would therefore mean inventing a
/// collection name. This result carries what the write actually decides, and the
/// caller patches an existing row with it.
///
/// **A result is not always a success.** [enrichmentStatus] is the server's
/// post-attempt state, and `failed` arrives in a `200` like any other recorded
/// outcome. Nothing here is derived from the HTTP status.
///
/// The three nullable fields preserve the wire values exactly, including an
/// explicit `null`: a successful extraction that finds no title **clears** a
/// previous title rather than retaining it.
class SavedItemEnrichmentResult {
  const SavedItemEnrichmentResult({
    required this.savedItemId,
    required this.enrichmentStatus,
    this.title,
    this.description,
    this.imageUrl,
  });

  /// The item this result describes, exactly as the response reported it.
  ///
  /// Callers match on it before patching a cache row: an id that does not match
  /// the row being displayed means the result belongs to something else.
  final String savedItemId;

  /// `completed` or `failed` on a conforming server. The wire value is mapped by
  /// the shared display helper, so this cannot word the three states differently
  /// from the listing and detail mappers (**D8**).
  final EnrichmentStatus enrichmentStatus;

  /// The title the attempt found, or null when it found none.
  final String? title;

  /// The description the attempt found, or null when it found none.
  final String? description;

  /// The preview image URL the attempt found, or null when it found none.
  ///
  /// Preserved verbatim, including a blank string. [SavedItemSummary] owns the
  /// "is this a usable preview?" question; this type does not reinterpret the
  /// value.
  final String? imageUrl;

  /// `true` when the attempt records success but found nothing to display.
  ///
  /// Mirrors [SavedItemSummary.hasNoMetadata]: the claim belongs to `completed`
  /// only, and a blank image URL is not metadata. A failed attempt is not the
  /// empty state — it preserves whatever metadata the item already had.
  bool get hasNoMetadata =>
      enrichmentStatus == EnrichmentStatus.completed &&
      title == null &&
      description == null &&
      !_hasImage;

  bool get _hasImage {
    final value = imageUrl?.trim();
    return value != null && value.isNotEmpty;
  }
}
