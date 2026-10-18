import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request.freezed.dart';
part 'refresh_request.g.dart';

/// Body of `POST /auth/refresh`.
///
/// ```json
/// { "refresh_token": "..." }
/// ```
///
/// The refresh token is the *entire* credential here. The endpoint carries no
/// bearer guard — the token in this body is what authorizes the call, and no
/// user or session id is accepted from the request
/// (`internal/api/auth/session/routes.go:43`).
@freezed
abstract class RefreshRequest with _$RefreshRequest {
  const factory RefreshRequest({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}
