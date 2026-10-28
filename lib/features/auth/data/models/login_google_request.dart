import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_google_request.freezed.dart';
part 'login_google_request.g.dart';

/// `POST /auth/login/google`.
///
/// Only the Google ID token is sent. The backend verifies its signature,
/// audience, subject and verified email; the client never sends the local email
/// or display name as identity data.
@freezed
abstract class LoginGoogleRequest with _$LoginGoogleRequest {
  const factory LoginGoogleRequest({
    @JsonKey(name: 'id_token') required String idToken,
  }) = _LoginGoogleRequest;

  factory LoginGoogleRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginGoogleRequestFromJson(json);
}
