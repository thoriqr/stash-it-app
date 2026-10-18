import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// The authenticated user as returned by `POST /auth/login`.
///
/// ```json
/// { "id": "...", "email": "...", "display_name": "..." }
/// ```
///
/// **Not persisted.** Only the token pair is stored, so a cold start carries no
/// user and the app cannot render a name it did not re-read. `GET /users/me` is
/// the authority for the profile (D10); the login response happens to carry a
/// summary of it, and duplicating that into storage would create a second
/// representation to keep in step.
///
/// `display_name` is named explicitly: the wire format is snake_case and the
/// generated decoder would otherwise look for `displayName`.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') required String displayName,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}
