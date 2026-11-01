import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// Represents the authenticated user returned by `POST /auth/login`.
///
/// This model is not persisted. Only the credential pair is stored, so user
/// profile data must be retrieved again after a cold start.
///
/// The `display_name` field uses an explicit JSON key because the API response
/// uses snake_case while the Dart property uses camelCase.
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
