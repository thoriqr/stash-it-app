// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_saved_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatedSavedItemResponse _$CreatedSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _CreatedSavedItemResponse(
  id: json['id'] as String,
  url: json['url'] as String,
  collectionId: json['collection_id'] as String,
  enrichmentStatus: json['enrichment_status'] as String,
);

Map<String, dynamic> _$CreatedSavedItemResponseToJson(
  _CreatedSavedItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'collection_id': instance.collectionId,
  'enrichment_status': instance.enrichmentStatus,
};

_CreateSavedItemDataResponse _$CreateSavedItemDataResponseFromJson(
  Map<String, dynamic> json,
) => _CreateSavedItemDataResponse(
  savedItem: CreatedSavedItemResponse.fromJson(
    json['saved_item'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CreateSavedItemDataResponseToJson(
  _CreateSavedItemDataResponse instance,
) => <String, dynamic>{'saved_item': instance.savedItem};

_CreateSavedItemResponse _$CreateSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _CreateSavedItemResponse(
  data: CreateSavedItemDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$CreateSavedItemResponseToJson(
  _CreateSavedItemResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
