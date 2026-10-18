// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_saved_items_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CursorPageMetaResponse _$CursorPageMetaResponseFromJson(
  Map<String, dynamic> json,
) => _CursorPageMetaResponse(
  hasMore: json['has_more'] as bool,
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$CursorPageMetaResponseToJson(
  _CursorPageMetaResponse instance,
) => <String, dynamic>{
  'has_more': instance.hasMore,
  'next_cursor': instance.nextCursor,
};

_ListSavedItemsMetaResponse _$ListSavedItemsMetaResponseFromJson(
  Map<String, dynamic> json,
) => _ListSavedItemsMetaResponse(
  cursor: CursorPageMetaResponse.fromJson(
    json['cursor'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ListSavedItemsMetaResponseToJson(
  _ListSavedItemsMetaResponse instance,
) => <String, dynamic>{'cursor': instance.cursor};

_ListSavedItemsDataResponse _$ListSavedItemsDataResponseFromJson(
  Map<String, dynamic> json,
) => _ListSavedItemsDataResponse(
  savedItems: (json['saved_items'] as List<dynamic>)
      .map((e) => ListedSavedItemResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListSavedItemsDataResponseToJson(
  _ListSavedItemsDataResponse instance,
) => <String, dynamic>{'saved_items': instance.savedItems};

_ListSavedItemsResponse _$ListSavedItemsResponseFromJson(
  Map<String, dynamic> json,
) => _ListSavedItemsResponse(
  data: ListSavedItemsDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
  meta: json['meta'] == null
      ? null
      : ListSavedItemsMetaResponse.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ListSavedItemsResponseToJson(
  _ListSavedItemsResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'meta': instance.meta,
};
