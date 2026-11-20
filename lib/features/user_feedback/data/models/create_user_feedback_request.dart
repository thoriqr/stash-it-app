import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user_feedback_request.freezed.dart';
part 'create_user_feedback_request.g.dart';

/// Request body for `POST /feedback`.
///
/// The platform is deliberately absent: the server takes it from the
/// `X-Platform` header that `appDio` already adds.
///
/// `message` is required, trimmed by the server, and limited to 5,000 runes.
/// `app_version` and `app_build` are optional so an older build that cannot
/// read them can still file a report.
@freezed
abstract class CreateUserFeedbackRequest with _$CreateUserFeedbackRequest {
  const factory CreateUserFeedbackRequest({
    required String type,
    required String message,
    @JsonKey(name: 'app_version', includeIfNull: false) String? appVersion,
    @JsonKey(name: 'app_build', includeIfNull: false) int? appBuild,
  }) = _CreateUserFeedbackRequest;

  factory CreateUserFeedbackRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserFeedbackRequestFromJson(json);
}
