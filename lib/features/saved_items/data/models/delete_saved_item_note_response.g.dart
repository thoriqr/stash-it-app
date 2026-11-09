// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_saved_item_note_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeleteSavedItemNoteDataResponse _$DeleteSavedItemNoteDataResponseFromJson(
  Map<String, dynamic> json,
) => _DeleteSavedItemNoteDataResponse();

Map<String, dynamic> _$DeleteSavedItemNoteDataResponseToJson(
  _DeleteSavedItemNoteDataResponse instance,
) => <String, dynamic>{};

_DeleteSavedItemNoteResponse _$DeleteSavedItemNoteResponseFromJson(
  Map<String, dynamic> json,
) => _DeleteSavedItemNoteResponse(
  data: DeleteSavedItemNoteDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$DeleteSavedItemNoteResponseToJson(
  _DeleteSavedItemNoteResponse instance,
) => <String, dynamic>{'data': instance.data, 'message': instance.message};
