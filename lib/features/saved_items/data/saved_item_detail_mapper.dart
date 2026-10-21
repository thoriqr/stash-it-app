import '../domain/saved_item_summary.dart';
import 'models/get_saved_item_response.dart';
import 'saved_item_display_mapper.dart';

/// Maps the detail response onto the presentation model the screen renders.
///
/// A plain function rather than a mapper class, following `savedItemFrom` and
/// `AGENTS.md` §2.
///
/// **Reuses [SavedItemSummary] rather than adding a detail-only model.** The
/// approved detail layout needs the collection name, the title fallback chain,
/// the enrichment state, the description and the preview-image flag — all of
/// which the existing model already represents. `platform`, `last_enriched_at`
/// and `updated_at` are declared on the DTO but have no approved presentation,
/// so they are not promoted onto the domain model and no UI is invented for them.
///
/// The collection fields come from the **sibling** `data.collection` object, not
/// from a nested item field. `collection_id` and `collection.id` are guaranteed
/// equal by the backend; reading both from the collection object keeps the pair
/// internally consistent.
///
/// The enrichment state and saved-time label come from
/// `saved_item_display_mapper.dart`, so the Inbox, Search and Detail screens
/// cannot word the same wire values differently.
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
    // Null stays null. A page that exposed no title is `completed` with no
    // title, which **[D17]** confirms is normal — the screen falls back to the
    // URL and renders it as neutral copy, never as a fault.
    title: item.title,
    description: item.description,
    // The contract sends a URL or `null`. An empty string is not a usable image
    // and would claim a preview the item does not have.
    hasPreviewImage: item.imageUrl != null && item.imageUrl!.trim().isNotEmpty,
    savedTimeLabel: savedTimeLabelFrom(item.createdAt, now),
  );
}
