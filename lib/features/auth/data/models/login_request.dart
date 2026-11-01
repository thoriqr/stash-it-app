import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

/// Request body for `POST /auth/login`.
///
/// Both email and password are required. Their input constraints are also
/// validated by the sign-in screen so common mistakes can be caught before
/// submitting the request. The server remains the final authority for
/// validation, and the client handles `VALIDATION_ERROR` responses.
@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
