// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_collection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeleteCollectionRequest _$DeleteCollectionRequestFromJson(
  Map<String, dynamic> json,
) => _DeleteCollectionRequest(
  savedItemsAction: json['saved_items_action'] as String,
  targetCollectionId: json['target_collection_id'] as String?,
);

Map<String, dynamic> _$DeleteCollectionRequestToJson(
  _DeleteCollectionRequest instance,
) => <String, dynamic>{
  'saved_items_action': instance.savedItemsAction,
  'target_collection_id': instance.targetCollectionId,
};
