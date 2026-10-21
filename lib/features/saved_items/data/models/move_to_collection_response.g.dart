// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_to_collection_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoveToCollectionCollectionResponse
_$MoveToCollectionCollectionResponseFromJson(Map<String, dynamic> json) =>
    _MoveToCollectionCollectionResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$MoveToCollectionCollectionResponseToJson(
  _MoveToCollectionCollectionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_MoveToCollectionSavedItemResponse _$MoveToCollectionSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _MoveToCollectionSavedItemResponse(
  id: json['id'] as String,
  url: json['url'] as String,
  domain: json['domain'] as String?,
  platform: json['platform'] as String?,
  title: json['title'] as String?,
  collectionId: json['collection_id'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$MoveToCollectionSavedItemResponseToJson(
  _MoveToCollectionSavedItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'domain': instance.domain,
  'platform': instance.platform,
  'title': instance.title,
  'collection_id': instance.collectionId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_MoveToCollectionDataResponse _$MoveToCollectionDataResponseFromJson(
  Map<String, dynamic> json,
) => _MoveToCollectionDataResponse(
  collection: MoveToCollectionCollectionResponse.fromJson(
    json['collection'] as Map<String, dynamic>,
  ),
  savedItem: MoveToCollectionSavedItemResponse.fromJson(
    json['saved_item'] as Map<String, dynamic>,
  ),
  collectionCreated: json['collection_created'] as bool,
  alreadyInCollection: json['already_in_collection'] as bool,
);

Map<String, dynamic> _$MoveToCollectionDataResponseToJson(
  _MoveToCollectionDataResponse instance,
) => <String, dynamic>{
  'collection': instance.collection,
  'saved_item': instance.savedItem,
  'collection_created': instance.collectionCreated,
  'already_in_collection': instance.alreadyInCollection,
};

_MoveToCollectionResponse _$MoveToCollectionResponseFromJson(
  Map<String, dynamic> json,
) => _MoveToCollectionResponse(
  data: MoveToCollectionDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$MoveToCollectionResponseToJson(
  _MoveToCollectionResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
