// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_saved_items_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListedSavedItemsCollectionResponse
_$ListedSavedItemsCollectionResponseFromJson(Map<String, dynamic> json) =>
    _ListedSavedItemsCollectionResponse(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$ListedSavedItemsCollectionResponseToJson(
  _ListedSavedItemsCollectionResponse instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_CollectionSavedItemResponse _$CollectionSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _CollectionSavedItemResponse(
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

Map<String, dynamic> _$CollectionSavedItemResponseToJson(
  _CollectionSavedItemResponse instance,
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

_ListCollectionSavedItemsDataResponse
_$ListCollectionSavedItemsDataResponseFromJson(Map<String, dynamic> json) =>
    _ListCollectionSavedItemsDataResponse(
      collection: ListedSavedItemsCollectionResponse.fromJson(
        json['collection'] as Map<String, dynamic>,
      ),
      savedItems: (json['saved_items'] as List<dynamic>)
          .map(
            (e) =>
                CollectionSavedItemResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$ListCollectionSavedItemsDataResponseToJson(
  _ListCollectionSavedItemsDataResponse instance,
) => <String, dynamic>{
  'collection': instance.collection,
  'saved_items': instance.savedItems,
};

_ListCollectionSavedItemsResponse _$ListCollectionSavedItemsResponseFromJson(
  Map<String, dynamic> json,
) => _ListCollectionSavedItemsResponse(
  data: ListCollectionSavedItemsDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
  meta: json['meta'] == null
      ? null
      : ListSavedItemsMetaResponse.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ListCollectionSavedItemsResponseToJson(
  _ListCollectionSavedItemsResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'meta': instance.meta,
};
