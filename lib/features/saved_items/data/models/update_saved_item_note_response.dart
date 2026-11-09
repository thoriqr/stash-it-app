import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_saved_item_note_response.freezed.dart';
part 'update_saved_item_note_response.g.dart';

/// The `data` payload of a successful `PUT /saved-items/{id}/note` response.
///
/// ```json
/// { "note": "My updated context for saving this URL." }
/// ```
///
/// The endpoint reports the note as it was stored. The field is read
/// defensively: if a conforming response omitted it, the caller can still use
/// the text it submitted rather than losing a confirmed save.
@freezed
abstract class UpdateSavedItemNoteDataResponse
    with _$UpdateSavedItemNoteDataResponse {
  const factory UpdateSavedItemNoteDataResponse({String? note}) =
      _UpdateSavedItemNoteDataResponse;

  factory UpdateSavedItemNoteDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateSavedItemNoteDataResponseFromJson(json);
}

/// The complete `200` response body of `PUT /saved-items/{id}/note`.
@freezed
abstract class UpdateSavedItemNoteResponse with _$UpdateSavedItemNoteResponse {
  const factory UpdateSavedItemNoteResponse({
    required UpdateSavedItemNoteDataResponse data,
    String? message,
  }) = _UpdateSavedItemNoteResponse;

  factory UpdateSavedItemNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateSavedItemNoteResponseFromJson(json);
}
