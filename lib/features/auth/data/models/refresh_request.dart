import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_request.freezed.dart';
part 'refresh_request.g.dart';

/// Request body for `POST /auth/refresh`.
///
/// The refresh token is the credential used to authorize this request.
/// No bearer token or separate user or session identifier is required.
@freezed
abstract class RefreshRequest with _$RefreshRequest {
  const factory RefreshRequest({
    @JsonKey(name: 'refresh_token') required String refreshToken,
  }) = _RefreshRequest;

  factory RefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshRequestFromJson(json);
}
