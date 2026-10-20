import '../domain/collection_summary.dart';
import 'models/listed_collection.dart';

/// Maps wire DTO to domain model.
CollectionSummary collectionFrom(ListedCollectionResponse dto) {
  // Identify Unsorted by system_key (D2) - never by display name
  final isUnsorted = dto.systemKey == 'unsorted';

  // Parse dates
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
