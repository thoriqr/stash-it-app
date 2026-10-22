// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_to_collection_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MoveToCollectionRequest _$MoveToCollectionRequestFromJson(
  Map<String, dynamic> json,
) => _MoveToCollectionRequest(
  collectionName: json['collection_name'] as String,
  collectionIntent: json['collection_intent'] as String,
);

Map<String, dynamic> _$MoveToCollectionRequestToJson(
  _MoveToCollectionRequest instance,
) => <String, dynamic>{
  'collection_name': instance.collectionName,
  'collection_intent': instance.collectionIntent,
};
