import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_manual_request.freezed.dart';
part 'register_manual_request.g.dart';

/// Request body for `POST /auth/register/manual`.
///
/// Sends the email address used to start or resume manual registration.
/// Email validation and normalization are handled by the API.
@freezed
abstract class RegisterManualRequest with _$RegisterManualRequest {
  const factory RegisterManualRequest({required String email}) =
      _RegisterManualRequest;

  factory RegisterManualRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterManualRequestFromJson(json);
}
