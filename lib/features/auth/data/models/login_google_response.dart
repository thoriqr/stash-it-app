import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'login_google_response.freezed.dart';
part 'login_google_response.g.dart';

/// Represents the response data from Google login and account-link confirmation.
///
/// The `outcome` field identifies one of three possible results:
///
/// - `authenticated`: access token, refresh token, and user are available.
/// - `account_link_required`: provider and confirmation ID are available.
/// - `registration_required`: verification ID is available.
///
/// The `outcome` field is part of the API response and is required for
/// distinguishing these flows.
@freezed
abstract class LoginGoogleResponse with _$LoginGoogleResponse {
  const factory LoginGoogleResponse({
    required String outcome,
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    AuthUser? user,
    String? provider,
    @JsonKey(name: 'confirmation_id') String? confirmationId,
    @JsonKey(name: 'verification_id') String? verificationId,
  }) = _LoginGoogleResponse;

  factory LoginGoogleResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginGoogleResponseFromJson(json);
}
