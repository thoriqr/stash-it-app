import '../domain/saved_item_summary.dart';
import 'models/collection_saved_items_response.dart';
import 'saved_item_display_mapper.dart';

/// Maps a page of collection saved items to presentation models.
///
/// Uses a function because the mapping has one input and one output.
///
/// The collection ID and name come from `data.collection`, not from individual
/// rows. Each row contains only `collection_id`, so the page-level collection
/// provides the collection information needed by the presentation model.
///
/// Enrichment status and saved-time labels use the shared display mapping
/// functions from `saved_item_display_mapper.dart`, keeping their presentation
/// consistent across Inbox, Search, and collection listings.
///
/// A row whose `collection_id` differs from the page's collection ID is not
/// corrected. Such a mismatch means the response does not consistently describe
/// the requested collection and should not be silently normalized.
List<SavedItemSummary> collectionSavedItemsFrom(
  ListCollectionSavedItemsDataResponse data, {
  required DateTime now,
}) {
  final collection = data.collection;

  return [
    for (final item in data.savedItems)
      SavedItemSummary(
        id: item.id,
        collectionId: collection.id,
        url: item.url,
        collectionName: collection.name,
        enrichmentStatus: enrichmentStatusFrom(item.enrichmentStatus),
        // Preserve null titles. A completed item may have no extracted title;
        // the presentation model falls back to the URL and uses neutral styling.
        title: item.title,
        description: item.description,
        // Preserve the URL or null as received. SavedItemSummary derives
        // hasPreviewImage from this value, and the preview handles image loading.
        imageUrl: item.imageUrl,
        savedTime: savedTimeFrom(item.createdAt, now),
      ),
  ];
}
