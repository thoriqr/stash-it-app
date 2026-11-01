import '../domain/saved_item_enrichment_result.dart';
import 'models/enrich_saved_item_response.dart';
import 'saved_item_display_mapper.dart';

/// Maps an enrichment response to the fields updated by enrichment.
///
/// Uses a function because the mapping has one input and one output.
///
/// Values are copied directly from the response without additional
/// normalization. A null title remains null so it can clear an existing title,
/// and a blank image URL remains unchanged.
///
/// Enrichment status is mapped through [enrichmentStatusFrom] to keep its
/// interpretation consistent with Inbox, Search and Detail.
///
/// Collection information is not mapped because the response does not include
/// the collection name and enrichment does not change collection membership.
/// The existing collection information remains unchanged.
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
