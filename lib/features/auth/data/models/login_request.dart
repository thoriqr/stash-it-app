import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

/// Body of `POST /auth/login`.
///
/// ```json
/// { "email": "user@example.com", "password": "..." }
/// ```
///
/// Both fields are `required` server-side
/// (`internal/api/auth/login/request.go`), with `email` capped at 254 and
/// `password` between 8 and 128. Those bounds are mirrored in `SignInScreen`'s
/// validation so the common mistake is caught without a round trip; the server
/// remains the authority and its `VALIDATION_ERROR` is still handled.
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
