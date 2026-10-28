import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_account_link_request.freezed.dart';
part 'confirm_account_link_request.g.dart';

/// `POST /auth/login/google/account-link/{confirmationId}/confirm`.
///
/// The confirmation id only names the flow. The ID token proves the caller still
/// controls the Google identity the confirmation was created for.
@freezed
abstract class ConfirmAccountLinkRequest with _$ConfirmAccountLinkRequest {
  const factory ConfirmAccountLinkRequest({
    @JsonKey(name: 'id_token') required String idToken,
  }) = _ConfirmAccountLinkRequest;

  factory ConfirmAccountLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmAccountLinkRequestFromJson(json);
}
