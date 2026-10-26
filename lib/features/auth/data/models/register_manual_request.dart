import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_manual_request.freezed.dart';
part 'register_manual_request.g.dart';

/// Body of `POST /auth/register/manual`.
///
/// ```json
/// { "email": "user@example.com" }
/// ```
///
/// The backend owns email validation (`required,email,max=255`) and normalizes
/// accepted values while creating the registration. This DTO deliberately sends
/// only the contract field; it does not duplicate normalization or validation.
@freezed
abstract class RegisterManualRequest with _$RegisterManualRequest {
  const factory RegisterManualRequest({required String email}) =
      _RegisterManualRequest;

  factory RegisterManualRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterManualRequestFromJson(json);
}
