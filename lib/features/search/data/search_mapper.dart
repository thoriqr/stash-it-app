import '../../saved_items/data/saved_item_display_mapper.dart';
import '../../saved_items/domain/saved_item_summary.dart';
import '../domain/search_collection.dart';
import '../domain/search_results.dart';
import 'models/search_response.dart';

/// Maps one Search saved-item DTO onto the shared presentation model.
///
/// **The existing model can represent exactly what Search returns**, so no
/// second saved-item model is needed:
///
/// - `title`, `url`, `image_url`, the nested collection id and name, `created_at`
///   and `enrichment_status` are all present and map one-for-one.
/// - `description` is absent from the Search contract. It stays `null`, which
///   the row already understands as "no description to show"; no text is
///   invented for it.
/// - `domain` is present on the wire but the presentation model derives the
///   source line from `url`, exactly as the Inbox row does. Keeping that one
///   fallback chain in one place is why the model is reused rather than cloned.
///
/// The enrichment and saved-time helpers are the shared ones from
/// `saved_item_display_mapper.dart`, so Search cannot word the same wire values
/// differently from the Inbox.
SavedItemSummary searchSavedItemFrom(
  SearchSavedItemResponse dto, {
  required DateTime now,
}) {
  return SavedItemSummary(
    id: dto.id,
    collectionId: dto.collection.id,
    url: dto.url,
    collectionName: dto.collection.name,
    enrichmentStatus: enrichmentStatusFrom(dto.enrichmentStatus),
    title: dto.title,
    // `/search` does not return a description. Null is the honest value: it
    // means "nothing to display", never "the page had none".
    description: null,
    // The contract sends a URL or null. An empty string is not a usable image,
    // but the value is carried through untouched: `SavedItemSummary` derives
    // `hasPreviewImage` from it and the preview decides whether to load it.
    imageUrl: dto.imageUrl,
    savedTimeLabel: savedTimeLabelFrom(dto.createdAt, now),
  );
}

/// Maps one Search collection DTO onto its narrow domain model.
///
/// **Only the fields the endpoint actually returns.** Counts, type, system
/// identity and timestamps are absent from `/search`; nothing is derived for
/// them here.
SearchCollection searchCollectionFrom(SearchCollectionResponse dto) {
  return SearchCollection(id: dto.id, name: dto.name);
}

/// Maps the whole `data` object, preserving both server-produced orders.
///
/// Neither list is sorted, merged or deduplicated. The backend ranks each group
/// independently, and the presentation renders Collections first without
/// changing the order inside either group.
SearchResults searchResultsFrom(
  SearchDataResponse data, {
  required DateTime now,
}) {
  return SearchResults(
    collections: data.collections
        .map(searchCollectionFrom)
        .toList(growable: false),
    savedItems: data.savedItems
        .map((item) => searchSavedItemFrom(item, now: now))
        .toList(growable: false),
  );
}
