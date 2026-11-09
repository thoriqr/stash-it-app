import 'saved_time.dart';

/// Enrichment state of a saved item.
///
/// The API defines exactly three values: `pending`, `completed` and `failed`.
/// There are no intermediate states such as `processing` or `retrying`.
///
/// `completed` means the enrichment process finished successfully. It does not
/// guarantee that metadata was found.
enum EnrichmentStatus { pending, completed, failed }

/// A saved item in the presentation model used by Inbox and Search.
///
/// This is a presentation model rather than an API DTO. Mappers convert API
/// responses into this model, keeping the wire format separate from display
/// behavior. It contains no HTTP or serialization concerns.
///
/// Fields represent the data needed to render a row, along with the collection
/// ID needed for collection navigation. Values are not inferred: a missing
/// title remains null and is handled by [displayTitle].
class SavedItemSummary {
  const SavedItemSummary({
    required this.id,
    required this.collectionId,
    required this.url,
    required this.collectionName,
    required this.enrichmentStatus,
    this.title,
    this.description,
    this.imageUrl,
    this.note,
    this.priceAmount,
    this.priceCurrency,
    this.savedTime,
    this.createdAt,
  });

  /// The item's ID as reported by the API.
  final String id;

  /// The ID of the collection the item currently belongs to.
  ///
  /// Preserved as reported by the API. The ID is used for collection
  /// navigation, not to identify the Unsorted collection. That distinction
  /// comes from the collection's system identifier.
  final String collectionId;

  /// The saved URL as reported by the API.
  final String url;

  /// The name of the collection the item currently belongs to.
  ///
  /// This identifies where the item is currently filed. It does not describe
  /// why the item was moved or indicate a future destination.
  final String collectionName;

  final EnrichmentStatus enrichmentStatus;

  /// The title extracted from the page, or null when no title was found.
  ///
  /// Preserved without rewriting or translation.
  final String? title;

  /// The description excerpt extracted from the page, or null when unavailable.
  final String? description;

  /// The preview image URL as reported by the API.
  ///
  /// Preserved verbatim, including null and blank strings. The URL may refer
  /// to third-party content and is not guaranteed to be reachable. The preview
  /// decides whether it can be rendered; this model does not fetch, resolve or
  /// derive an image URL from the page URL.
  ///
  /// An image loading failure does not change this value. Loading is a
  /// presentation outcome, not evidence that enrichment found no image.
  final String? imageUrl;

  /// Whether the API reported a non-blank preview image URL.
  ///
  /// This indicates that an image URL was provided, not that the image loaded
  /// successfully. An unreachable image still counts as a reported image.
  bool get hasPreviewImage {
    final value = imageUrl?.trim();
    return value != null && value.isNotEmpty;
  }

  /// The note the user attached to the saved item, or null when there is none.
  ///
  /// This is user-authored copy, not metadata extracted from the page. It is
  /// preserved verbatim so the full-note viewer keeps its line breaks.
  final String? note;

  /// The price amount exactly as the API reported it.
  ///
  /// The API sends the numeric amount as JSON text. It remains a string here so
  /// decimal precision is never lost to a floating-point conversion.
  final String? priceAmount;

  /// The ISO 4217 currency code the API reported with [priceAmount].
  final String? priceCurrency;

  /// Whether a non-empty note exists to preview.
  ///
  /// A note containing only whitespace carries no readable content and is
  /// treated as absent.
  bool get hasNote {
    final value = note?.trim();
    return value != null && value.isNotEmpty;
  }

  /// The locale-independent elapsed time since the item was saved.
  ///
  /// Derived from the API's `created_at` value by the mapper. Presentation
  /// converts this value into localized copy; it does not perform time
  /// calculations using this field.
  ///
  /// Null when the timestamp cannot be parsed or is in the future. This field
  /// does not determine the ordering of items.
  final SavedTime? savedTime;

  /// The item's `created_at` value parsed as a point in time, or null when it
  /// cannot be parsed.
  ///
  /// Kept alongside [savedTime] because polling eligibility needs the actual
  /// age rather than an elapsed-time bucket. The value is server time, so the
  /// consumer must tolerate clock skew; see the enrichment polling rules.
  final DateTime? createdAt;

  /// Returns this item with its collection information replaced.
  ///
  /// Only the collection ID and name change. All other values remain from the
  /// existing model because moving an item does not re-run enrichment. The
  /// caller supplies the stored collection name exactly as reported by the
  /// API, without trimming, changing its casing or interpreting its display name.
  SavedItemSummary copyWithCollection({
    required String collectionId,
    required String collectionName,
  }) {
    return SavedItemSummary(
      id: id,
      collectionId: collectionId,
      url: url,
      collectionName: collectionName,
      enrichmentStatus: enrichmentStatus,
      title: title,
      description: description,
      imageUrl: imageUrl,
      note: note,
      priceAmount: priceAmount,
      priceCurrency: priceCurrency,
      savedTime: savedTime,
      createdAt: createdAt,
    );
  }

  /// Returns this item with only its note replaced.
  ///
  /// An explicit null clears the note. Everything else — including the item's
  /// identity, collection, URL and enrichment fields — is preserved because a
  /// note mutation changes nothing else about the item.
  SavedItemSummary copyWithNote(String? note) {
    return SavedItemSummary(
      id: id,
      collectionId: collectionId,
      url: url,
      collectionName: collectionName,
      enrichmentStatus: enrichmentStatus,
      title: title,
      description: description,
      imageUrl: imageUrl,
      note: note,
      priceAmount: priceAmount,
      priceCurrency: priceCurrency,
      savedTime: savedTime,
      createdAt: createdAt,
    );
  }

  /// Returns this item with its enrichment fields replaced.
  ///
  /// This is replacement, not merging. All parameters are required, including
  /// nullable fields, so an explicit null clears the previous value. This
  /// preserves the latest extraction result instead of retaining metadata
  /// that may no longer be present on the page.
  ///
  /// Item identity, URL, collection information and saved-time label remain
  /// unchanged because enrichment does not modify them.
  SavedItemSummary copyWithEnrichment({
    required String? title,
    required String? description,
    required String? imageUrl,
    required EnrichmentStatus enrichmentStatus,
  }) {
    return SavedItemSummary(
      id: id,
      collectionId: collectionId,
      url: url,
      collectionName: collectionName,
      enrichmentStatus: enrichmentStatus,
      title: title,
      description: description,
      imageUrl: imageUrl,
      note: note,
      priceAmount: priceAmount,
      priceCurrency: priceCurrency,
      savedTime: savedTime,
      createdAt: createdAt,
    );
  }

  /// Whether enrichment completed without producing any usable metadata.
  ///
  /// This is a normal successful outcome, not an enrichment error.
  bool get hasNoMetadata =>
      enrichmentStatus == EnrichmentStatus.completed &&
      title == null &&
      description == null &&
      !hasPreviewImage;

  /// Whether the display title must fall back to another value.
  bool get usesFallbackTitle => title == null || title!.trim().isEmpty;

  /// The title displayed using the `title → URL → domain` fallback chain.
  ///
  /// A missing title is not an error. The widget is responsible for styling
  /// the resulting text.
  String get displayTitle {
    if (!usesFallbackTitle) return title!.trim();
    if (url.trim().isNotEmpty) return url.trim();
    return _host;
  }

  /// The compact source label containing the host and path.
  ///
  /// The scheme and `www.` prefix are omitted. When the title already falls
  /// back to the URL, only the host is shown to avoid repeating the URL path.
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
