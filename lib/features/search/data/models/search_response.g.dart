// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchSavedItemCollectionResponse _$SearchSavedItemCollectionResponseFromJson(
  Map<String, dynamic> json,
) => _SearchSavedItemCollectionResponse(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$SearchSavedItemCollectionResponseToJson(
  _SearchSavedItemCollectionResponse instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_SearchSavedItemResponse _$SearchSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _SearchSavedItemResponse(
  id: json['id'] as String,
  title: json['title'] as String?,
  url: json['url'] as String,
  domain: json['domain'] as String?,
  imageUrl: json['image_url'] as String?,
  enrichmentStatus: json['enrichment_status'] as String,
  collection: SearchSavedItemCollectionResponse.fromJson(
    json['collection'] as Map<String, dynamic>,
  ),
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$SearchSavedItemResponseToJson(
  _SearchSavedItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'url': instance.url,
  'domain': instance.domain,
  'image_url': instance.imageUrl,
  'enrichment_status': instance.enrichmentStatus,
  'collection': instance.collection,
  'created_at': instance.createdAt,
};

_SearchCollectionResponse _$SearchCollectionResponseFromJson(
  Map<String, dynamic> json,
) => _SearchCollectionResponse(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$SearchCollectionResponseToJson(
  _SearchCollectionResponse instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_SearchDataResponse _$SearchDataResponseFromJson(
  Map<String, dynamic> json,
) => _SearchDataResponse(
  savedItems: (json['saved_items'] as List<dynamic>)
      .map((e) => SearchSavedItemResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  collections: (json['collections'] as List<dynamic>)
      .map((e) => SearchCollectionResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SearchDataResponseToJson(_SearchDataResponse instance) =>
    <String, dynamic>{
      'saved_items': instance.savedItems,
      'collections': instance.collections,
    };

_SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) =>
    _SearchResponse(
      data: SearchDataResponse.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SearchResponseToJson(_SearchResponse instance) =>
    <String, dynamic>{'data': instance.data, 'message': instance.message};
