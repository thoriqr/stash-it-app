// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_saved_item_note_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateSavedItemNoteDataResponse _$UpdateSavedItemNoteDataResponseFromJson(
  Map<String, dynamic> json,
) => _UpdateSavedItemNoteDataResponse(note: json['note'] as String?);

Map<String, dynamic> _$UpdateSavedItemNoteDataResponseToJson(
  _UpdateSavedItemNoteDataResponse instance,
) => <String, dynamic>{'note': instance.note};

_UpdateSavedItemNoteResponse _$UpdateSavedItemNoteResponseFromJson(
  Map<String, dynamic> json,
) => _UpdateSavedItemNoteResponse(
  data: UpdateSavedItemNoteDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$UpdateSavedItemNoteResponseToJson(
  _UpdateSavedItemNoteResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
