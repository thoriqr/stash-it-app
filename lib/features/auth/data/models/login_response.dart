import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

/// Represents the response data returned after successful authentication.
///
/// Used by:
/// - `POST /auth/login`
/// - `POST /auth/login/google` when authenticated
/// - `POST /auth/register/finalize/social`
///
/// All three endpoints return the same access token, refresh token, and user
/// fields.
///
/// Explicit JSON keys map the API's snake_case fields to Dart's camelCase
/// properties.
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
