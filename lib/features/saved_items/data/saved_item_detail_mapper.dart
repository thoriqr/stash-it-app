import '../domain/saved_item_summary.dart';
import 'models/get_saved_item_response.dart';
import 'saved_item_display_mapper.dart';

/// Maps a saved item detail response to the presentation model.
///
/// Uses [SavedItemSummary] rather than introducing a detail-specific model.
/// The existing model already represents the collection name, title fallback,
/// enrichment state, description and preview-image availability. Fields such
/// as `platform`, `last_enriched_at` and `updated_at` remain in the response DTO
/// but are not currently needed by the presentation layer.
///
/// The collection ID and name come from the sibling `data.collection` object,
/// not from a nested field in the saved item. Using both values from the same
/// object keeps them consistent.
///
/// Enrichment status and saved-time labels use the shared mapping functions
/// from `saved_item_display_mapper.dart`, keeping their presentation consistent
/// across Inbox, Search and Detail.
SavedItemSummary savedItemDetailFrom(
  GetSavedItemResponse response, {
  required DateTime now,
}) {
  final item = response.data.savedItem;
  final collection = response.data.collection;

  return SavedItemSummary(
    id: item.id,
    collectionId: collection.id,
    url: item.url,
    collectionName: collection.name,
    enrichmentStatus: enrichmentStatusFrom(item.enrichmentStatus),
    // Preserve null titles. A completed item may have no extracted title;
    // the screen falls back to the URL and displays it with neutral styling.
    title: item.title,
    description: item.description,
    // Preserve the image URL or null as received. SavedItemSummary derives
    // hasPreviewImage from this value, and the preview handles image loading.
    imageUrl: item.imageUrl,
    savedTime: savedTimeFrom(item.createdAt, now),
    createdAt: DateTime.tryParse(item.createdAt),
  );
}
