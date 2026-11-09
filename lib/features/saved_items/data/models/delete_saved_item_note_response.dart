import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_saved_item_note_response.freezed.dart';
part 'delete_saved_item_note_response.g.dart';

/// The `data` payload of a successful `DELETE /saved-items/{id}/note` response.
///
/// The contract defines an empty object. The client only needs the successful
/// status, because the operation's result is that the note is now null.
@freezed
abstract class DeleteSavedItemNoteDataResponse
    with _$DeleteSavedItemNoteDataResponse {
  const factory DeleteSavedItemNoteDataResponse() =
      _DeleteSavedItemNoteDataResponse;

  factory DeleteSavedItemNoteDataResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSavedItemNoteDataResponseFromJson(json);
}

/// The complete `200` response body of `DELETE /saved-items/{id}/note`.
@freezed
abstract class DeleteSavedItemNoteResponse with _$DeleteSavedItemNoteResponse {
  const factory DeleteSavedItemNoteResponse({
    required DeleteSavedItemNoteDataResponse data,
    String? message,
  }) = _DeleteSavedItemNoteResponse;

  factory DeleteSavedItemNoteResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteSavedItemNoteResponseFromJson(json);
}
