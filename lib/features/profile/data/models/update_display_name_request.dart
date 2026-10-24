import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_display_name_request.freezed.dart';
part 'update_display_name_request.g.dart';

/// The body of `PATCH /users/me`.
///
/// `display_name` is the only field the endpoint accepts. Email is deliberately
/// absent: a field that can be submitted and ignored teaches a client it was
/// changed.
///
/// **The value is sent exactly as the form holds it.** The backend neither trims
/// nor case-folds it, and registration stores a display name verbatim, so trimming
/// here would make this client disagree with the other path into the same column.
/// The length rule is 2–100 Unicode code points on the server; the form checks the
/// same bound before submitting.
@freezed
abstract class UpdateDisplayNameRequest with _$UpdateDisplayNameRequest {
  const factory UpdateDisplayNameRequest({
    @JsonKey(name: 'display_name') required String displayName,
  }) = _UpdateDisplayNameRequest;

  factory UpdateDisplayNameRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDisplayNameRequestFromJson(json);
}
