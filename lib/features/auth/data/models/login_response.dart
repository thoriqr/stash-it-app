import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// `data` of a successful sign-in-shaped response.
///
/// Used by `POST /auth/login`, `POST /auth/login/google` when authenticated, and
/// `POST /auth/register/finalize/social`. All three return exactly the same three
/// keys:
///
/// ```json
/// { "access_token": "...", "refresh_token": "...", "user": { ... } }
/// ```
///
/// Nothing is read from the request context — the backend derives the user from
/// the verified credentials, never from a body field a caller could choose.
///
/// **Every field names its wire key explicitly.** The backend's JSON is
/// snake_case; without `@JsonKey` the generated decoder looks for camelCase and
/// fails on a `null` cast at runtime, which surfaces as an unreadable response
/// rather than as a decode bug. The Dart names stay camelCase.
@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    required AuthUser user,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
