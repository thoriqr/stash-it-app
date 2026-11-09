import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_saved_item_note_request.freezed.dart';
part 'update_saved_item_note_request.g.dart';

/// The body of `PUT /saved-items/{id}/note`.
///
/// ```json
/// { "note": "My personal note" }
/// ```
///
/// The note is required by the endpoint. The client sends the text exactly as
/// the user entered it, including line breaks; only the empty check trims.
@freezed
abstract class UpdateSavedItemNoteRequest with _$UpdateSavedItemNoteRequest {
  const factory UpdateSavedItemNoteRequest({required String note}) =
      _UpdateSavedItemNoteRequest;

  factory UpdateSavedItemNoteRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSavedItemNoteRequestFromJson(json);
}
