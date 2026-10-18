import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens_response.freezed.dart';
part 'auth_tokens_response.g.dart';

/// `data` of a successful `POST /auth/refresh`.
///
/// ```json
/// { "access_token": "...", "refresh_token": "..." }
/// ```
///
/// Both tokens rotate on every success, which is why there is no "keep the
/// existing refresh token" branch anywhere in the client.
///
/// Wire keys are named explicitly; the backend's JSON is snake_case.
@freezed
abstract class AuthTokensResponse with _$AuthTokensResponse {
  const factory AuthTokensResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _AuthTokensResponse;

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensResponseFromJson(json);
}
