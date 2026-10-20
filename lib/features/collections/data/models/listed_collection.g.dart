// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listed_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListedCollectionResponse _$ListedCollectionResponseFromJson(
  Map<String, dynamic> json,
) => _ListedCollectionResponse(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  systemKey: json['system_key'] as String?,
  savedItemsCount: (json['saved_items_count'] as num).toInt(),
  savedItemsCountOverflow: json['saved_items_count_overflow'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$ListedCollectionResponseToJson(
  _ListedCollectionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'system_key': instance.systemKey,
  'saved_items_count': instance.savedItemsCount,
  'saved_items_count_overflow': instance.savedItemsCountOverflow,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_ListCollectionsDataResponse _$ListCollectionsDataResponseFromJson(
  Map<String, dynamic> json,
) => _ListCollectionsDataResponse(
  collections: (json['collections'] as List<dynamic>)
      .map((e) => ListedCollectionResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ListCollectionsDataResponseToJson(
  _ListCollectionsDataResponse instance,
) => <String, dynamic>{'collections': instance.collections};

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

_ListCollectionsMetaResponse _$ListCollectionsMetaResponseFromJson(
  Map<String, dynamic> json,
) => _ListCollectionsMetaResponse(
  cursor: CursorPageMetaResponse.fromJson(
    json['cursor'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ListCollectionsMetaResponseToJson(
  _ListCollectionsMetaResponse instance,
) => <String, dynamic>{'cursor': instance.cursor};

_ListCollectionsResponse _$ListCollectionsResponseFromJson(
  Map<String, dynamic> json,
) => _ListCollectionsResponse(
  data: ListCollectionsDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
  meta: json['meta'] == null
      ? null
      : ListCollectionsMetaResponse.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ListCollectionsResponseToJson(
  _ListCollectionsResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'meta': instance.meta,
};
