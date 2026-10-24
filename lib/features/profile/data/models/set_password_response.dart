import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_password_response.freezed.dart';
part 'set_password_response.g.dart';

/// The whole `200` body of `PUT /users/me/password`.
///
/// The backend sends `data: null` and a message that names which branch ran
/// ("password created successfully" or "password changed successfully"). Neither
/// is needed to establish success: the `200` means the operation committed.
///
/// **`data` is deliberately not modelled.** It is null on this route, and giving
/// it a type would make a success depend on a payload this client never reads. The
/// message is modelled only so the envelope decodes; it is never rendered
/// (`AGENTS.md` §1, D22).
@freezed
abstract class SetPasswordResponse with _$SetPasswordResponse {
  const factory SetPasswordResponse({String? message}) = _SetPasswordResponse;

  factory SetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordResponseFromJson(json);
}
