import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user.dart';

part 'login_google_response.freezed.dart';
part 'login_google_response.g.dart';

/// `data` of `POST /auth/login/google` and the account-link confirm route.
///
/// The backend returns one of three outcomes in the same envelope:
///
/// - `authenticated` — tokens and user are present.
/// - `account_link_required` — `provider` and `confirmation_id` are present.
/// - `registration_required` — `verification_id` is present.
///
/// The actual Go handler/mapper includes `outcome` on every outcome. The
/// generated Swagger success type does not, so this model follows the code.
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
