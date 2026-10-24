import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_password_request.freezed.dart';
part 'set_password_request.g.dart';

/// The body of `PUT /users/me/password`.
///
/// The endpoint serves two operations, and the backend decides which one runs by
/// reading the stored credential — never by what this body says. The two request
/// shapes are therefore statements about the credential state the form was
/// rendered from:
///
/// - First password: `new_password` alone.
/// - Change: `new_password` and `current_password`.
///
/// **[currentPassword] is omitted, not sent as null or an empty string, when the
/// account has no credential.** An omitted field and `""` are equivalent to the
/// backend, but omitting it keeps the body an honest statement of the create
/// operation and avoids putting an empty secret on the wire.
///
/// `new_password` is bounded at 8–128 code points by the backend. There is no
/// composition rule and no confirmation field; the confirmation is client-only.
@freezed
abstract class SetPasswordRequest with _$SetPasswordRequest {
  const factory SetPasswordRequest({
    @JsonKey(name: 'current_password', includeIfNull: false)
    String? currentPassword,
    @JsonKey(name: 'new_password') required String newPassword,
  }) = _SetPasswordRequest;

  factory SetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordRequestFromJson(json);
}
