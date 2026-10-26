import 'package:freezed_annotation/freezed_annotation.dart';

part 'finalize_manual_registration_request.freezed.dart';
part 'finalize_manual_registration_request.g.dart';

/// Request body for `POST /auth/register/finalize/manual`.
@freezed
abstract class FinalizeManualRegistrationRequest
    with _$FinalizeManualRegistrationRequest {
  const factory FinalizeManualRegistrationRequest({
    @JsonKey(name: 'display_name') required String displayName,
    required String password,
  }) = _FinalizeManualRegistrationRequest;

  factory FinalizeManualRegistrationRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FinalizeManualRegistrationRequestFromJson(json);
}
