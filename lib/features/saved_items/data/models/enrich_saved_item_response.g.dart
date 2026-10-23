// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrich_saved_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnrichSavedItemDataResponse _$EnrichSavedItemDataResponseFromJson(
  Map<String, dynamic> json,
) => _EnrichSavedItemDataResponse(
  savedItem: SavedItemDetailResponse.fromJson(
    json['saved_item'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$EnrichSavedItemDataResponseToJson(
  _EnrichSavedItemDataResponse instance,
) => <String, dynamic>{'saved_item': instance.savedItem};

_EnrichSavedItemResponse _$EnrichSavedItemResponseFromJson(
  Map<String, dynamic> json,
) => _EnrichSavedItemResponse(
  data: EnrichSavedItemDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$EnrichSavedItemResponseToJson(
  _EnrichSavedItemResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
