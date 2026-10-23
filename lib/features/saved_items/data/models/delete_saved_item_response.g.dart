// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_saved_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeleteSavedItemDataResponse _$DeleteSavedItemDataResponseFromJson(
  Map<String, dynamic> json,
) => _DeleteSavedItemDataResponse(
  collectionId: json['collection_id'] as String,
  collectionEmpty: json['collection_empty'] as bool,
  collectionDeletable: json['collection_deletable'] as bool,
);

Map<String, dynamic> _$DeleteSavedItemDataResponseToJson(
  _DeleteSavedItemDataResponse instance,
) => <String, dynamic>{
  'collection_id': instance.collectionId,
  'collection_empty': instance.collectionEmpty,
  'collection_deletable': instance.collectionDeletable,
};

_DeleteSavedItemResponse _$DeleteSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _DeleteSavedItemResponse(
  data: DeleteSavedItemDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$DeleteSavedItemResponseToJson(
  _DeleteSavedItemResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
