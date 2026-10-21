// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_saved_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedItemDetailResponse _$SavedItemDetailResponseFromJson(
  Map<String, dynamic> json,
) => _SavedItemDetailResponse(
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
);

Map<String, dynamic> _$SavedItemDetailResponseToJson(
  _SavedItemDetailResponse instance,
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
};

_GetSavedItemDataResponse _$GetSavedItemDataResponseFromJson(
  Map<String, dynamic> json,
) => _GetSavedItemDataResponse(
  savedItem: SavedItemDetailResponse.fromJson(
    json['saved_item'] as Map<String, dynamic>,
  ),
  collection: SavedItemCollectionResponse.fromJson(
    json['collection'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$GetSavedItemDataResponseToJson(
  _GetSavedItemDataResponse instance,
) => <String, dynamic>{
  'saved_item': instance.savedItem,
  'collection': instance.collection,
};

_GetSavedItemResponse _$GetSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _GetSavedItemResponse(
  data: GetSavedItemDataResponse.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$GetSavedItemResponseToJson(
  _GetSavedItemResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
