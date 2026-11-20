import '../../../core/error/api_failure.dart';

/// What one feedback submission produced.
sealed class UserFeedbackSubmitResult {
  const UserFeedbackSubmitResult();
}

/// The report was accepted by the server.
final class UserFeedbackSubmitted extends UserFeedbackSubmitResult {
  const UserFeedbackSubmitted();
}

/// The submission was refused or could not be completed.
final class UserFeedbackSubmitFailed extends UserFeedbackSubmitResult {
  const UserFeedbackSubmitFailed(this.failure);

  final ApiFailure failure;
}

/// A submission was already in flight, so this call did nothing.
final class UserFeedbackSubmitIgnored extends UserFeedbackSubmitResult {
  const UserFeedbackSubmitIgnored();
}
