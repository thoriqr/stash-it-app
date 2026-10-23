import '../domain/saved_item_enrichment_result.dart';
import 'models/enrich_saved_item_response.dart';
import 'saved_item_display_mapper.dart';

/// Maps the enrich response onto the four fields the write can change.
///
/// A plain function rather than a mapper class, following `savedItemDetailFrom`
/// and `AGENTS.md` §2.
///
/// **The values are copied, never derived.** A null title stays null so it can
/// clear an older title, and a blank image URL stays blank. The only
/// interpretation is the enrichment status, which goes through
/// [enrichmentStatusFrom] so this route words `pending`, `completed` and `failed`
/// exactly as the Inbox, Search and Detail mappers do.
///
/// **Nothing about the collection is mapped.** The response does not carry its
/// name, and enrichment cannot move an item; the existing row keeps both.
SavedItemEnrichmentResult savedItemEnrichmentFrom(
  EnrichSavedItemResponse response,
) {
  final item = response.data.savedItem;

  return SavedItemEnrichmentResult(
    savedItemId: item.id,
    enrichmentStatus: enrichmentStatusFrom(item.enrichmentStatus),
    title: item.title,
    description: item.description,
    imageUrl: item.imageUrl,
  );
}
