import '../domain/collection_summary.dart';
import 'models/listed_collection.dart';

/// Converts a collection response DTO into a domain model.
CollectionSummary collectionFrom(ListedCollectionResponse dto) {
  // Identify Unsorted by its system key, never by its display name.
  final isUnsorted = dto.systemKey == 'unsorted';

  // Parse timestamps, falling back to the current time if parsing fails.
  final createdAt = DateTime.tryParse(dto.createdAt) ?? DateTime.now();
  final updatedAt = DateTime.tryParse(dto.updatedAt) ?? DateTime.now();

  return CollectionSummary(
    id: dto.id,
    name: dto.name,
    type: dto.type,
    isUnsorted: isUnsorted,
    savedItemsCount: dto.savedItemsCount,
    savedItemsCountOverflow: dto.savedItemsCountOverflow,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

List<CollectionSummary> collectionsFrom(List<ListedCollectionResponse> dtos) {
  return dtos.map(collectionFrom).toList(growable: false);
}
