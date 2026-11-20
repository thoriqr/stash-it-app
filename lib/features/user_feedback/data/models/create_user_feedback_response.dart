import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_user_feedback_response.freezed.dart';
part 'create_user_feedback_response.g.dart';

/// The report created by `POST /feedback`.
///
/// The client does not display either value; they are parsed so the success
/// response is understood.
@freezed
abstract class CreatedUserFeedbackResponse with _$CreatedUserFeedbackResponse {
  const factory CreatedUserFeedbackResponse({
    required String id,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _CreatedUserFeedbackResponse;

  factory CreatedUserFeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatedUserFeedbackResponseFromJson(json);
}

/// The complete `201` response for `POST /feedback`.
///
/// The report's status is not returned and no user action depends on it.
@freezed
abstract class CreateUserFeedbackResponse with _$CreateUserFeedbackResponse {
  const factory CreateUserFeedbackResponse({
    required CreatedUserFeedbackResponse data,
    String? message,
  }) = _CreateUserFeedbackResponse;

  factory CreateUserFeedbackResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateUserFeedbackResponseFromJson(json);
}
