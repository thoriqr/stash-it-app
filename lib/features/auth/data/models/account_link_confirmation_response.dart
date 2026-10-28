import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_link_confirmation_response.freezed.dart';
part 'account_link_confirmation_response.g.dart';

/// `data` of `GET /auth/login/google/account-link/{confirmationId}`.
///
/// The existing account's address is masked and the Google profile name is the
/// snapshot captured when the confirmation was created. Both may be empty; the
/// UI must provide neutral fallbacks and must not ask the backend for the full
/// address.
@freezed
abstract class AccountLinkConfirmationResponse
    with _$AccountLinkConfirmationResponse {
  const factory AccountLinkConfirmationResponse({
    required String id,
    required String provider,
    @JsonKey(name: 'display_name_snapshot') required String displayNameSnapshot,
    @JsonKey(name: 'masked_user_email') required String maskedUserEmail,
  }) = _AccountLinkConfirmationResponse;

  factory AccountLinkConfirmationResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountLinkConfirmationResponseFromJson(json);
}
