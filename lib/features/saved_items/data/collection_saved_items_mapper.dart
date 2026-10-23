import '../domain/saved_item_summary.dart';
import 'models/collection_saved_items_response.dart';
import 'saved_item_display_mapper.dart';

/// Maps one page of a collection's saved items onto the presentation model.
///
/// A plain function rather than a mapper class, for the same reason the other
/// mappers here are: one input, one output, and `AGENTS.md` §2 prefers functions.
///
/// **The collection name and id come from the page, not from the row.** This
/// listing names the collection once in `data.collection`; each row carries only
/// `collection_id`. Reading the name per row is what would have to be invented, so
/// it is passed in from the one place the contract reports it.
///
/// The enrichment state and the saved-time label come from
/// `saved_item_display_mapper.dart`, which the Inbox and Search share, so three
/// listings cannot word the same wire values differently.
///
/// A row whose `collection_id` disagrees with the page's collection is not
/// repaired. The backend states the two are always equal; a disagreement would
/// mean the response is not describing one collection, and inventing agreement
/// would hide it.
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
        // Null stays null. A page that exposed no title is `completed` with no
        // title, which **[D17]** confirms is normal — the row falls back to the
        // URL and colours it as neutral copy, never as a fault.
        title: item.title,
        description: item.description,
        // The contract sends a URL or `null`. An empty string is not a usable
        // image, but the value is carried through untouched: `SavedItemSummary`
        // derives `hasPreviewImage` from it and the preview decides whether to
        // load it.
        imageUrl: item.imageUrl,
        savedTimeLabel: savedTimeLabelFrom(item.createdAt, now),
      ),
  ];
}
