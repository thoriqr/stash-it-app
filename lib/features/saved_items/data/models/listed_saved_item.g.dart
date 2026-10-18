// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listed_saved_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedItemCollectionResponse _$SavedItemCollectionResponseFromJson(
  Map<String, dynamic> json,
) => _SavedItemCollectionResponse(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$SavedItemCollectionResponseToJson(
  _SavedItemCollectionResponse instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_ListedSavedItemResponse _$ListedSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _ListedSavedItemResponse(
  id: json['id'] as String,
  url: json['url'] as String,
  domain: json['domain'] as String?,
  platform: json['platform'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  collectionId: json['collection_id'] as String,
  enrichmentStatus: json['enrichment_status'] as String,
  lastEnrichedAt: json['last_enriched_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  collection: SavedItemCollectionResponse.fromJson(
    json['collection'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ListedSavedItemResponseToJson(
  _ListedSavedItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'domain': instance.domain,
  'platform': instance.platform,
  'title': instance.title,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'collection_id': instance.collectionId,
  'enrichment_status': instance.enrichmentStatus,
  'last_enriched_at': instance.lastEnrichedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'collection': instance.collection,
};
