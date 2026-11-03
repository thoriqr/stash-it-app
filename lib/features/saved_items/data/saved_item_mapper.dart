import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import 'models/listed_saved_item.dart';
import 'saved_item_display_mapper.dart';

/// Maps a saved item response row to the presentation model.
///
/// Uses a function because the mapping has one input and one output.
///
/// Enrichment status and saved-time labels use the shared mapping functions
/// from `saved_item_display_mapper.dart`, keeping their presentation consistent
/// between the saved items and Search features.
SavedItemSummary savedItemFrom(
  ListedSavedItemResponse dto, {
  required DateTime now,
}) {
  return SavedItemSummary(
    id: dto.id,
    collectionId: dto.collection.id,
    url: dto.url,
    collectionName: dto.collection.name,
    enrichmentStatus: enrichmentStatusFrom(dto.enrichmentStatus),
    // Preserve null titles. A completed item may have no extracted title;
    // the row falls back to the URL and displays it with neutral styling.
    title: dto.title,
    description: dto.description,
    // Preserve the image URL or null as received. SavedItemSummary derives
    // hasPreviewImage from this value, and the preview handles image loading.
    imageUrl: dto.imageUrl,
    savedTime: savedTimeFrom(dto.createdAt, now),
  );
}
