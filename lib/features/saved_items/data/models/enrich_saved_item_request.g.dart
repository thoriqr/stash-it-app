// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrich_saved_item_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnrichSavedItemRequest _$EnrichSavedItemRequestFromJson(
  Map<String, dynamic> json,
) => _EnrichSavedItemRequest(
  metadata: json['metadata'] == null
      ? null
      : ClientMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EnrichSavedItemRequestToJson(
  _EnrichSavedItemRequest instance,
) => <String, dynamic>{'metadata': ?clientMetadataToJson(instance.metadata)};
