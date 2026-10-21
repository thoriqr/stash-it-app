import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

import 'models/listed_saved_item.dart';
import 'saved_item_display_mapper.dart';

/// Maps one wire row onto the presentation model.
///
/// A plain function rather than a mapper class: there is one input and one
/// output, and `AGENTS.md` §2 prefers functions.
///
/// The enrichment state and saved-time label come from
/// `saved_item_display_mapper.dart`, which the Search feature shares so both
/// screens cannot word the same wire values differently.
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
    // Null stays null. A page that exposed no title is `completed` with no
    // title, which **[D17]** confirms is normal — the row falls back to the URL
    // and colours it as neutral copy, never as a fault.
    title: dto.title,
    description: dto.description,
    // The contract sends a URL or `null`. An empty string is not a usable image
    // and would render a slot that claims to have one.
    hasPreviewImage: dto.imageUrl != null && dto.imageUrl!.trim().isNotEmpty,
    savedTimeLabel: savedTimeLabelFrom(dto.createdAt, now),
  );
}
