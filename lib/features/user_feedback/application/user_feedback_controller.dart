import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/feedback/app_feedback.dart';
import '../../../app/feedback/feedback_controller.dart';
import '../../../core/error/api_failure.dart';
import '../../settings/application/package_info_provider.dart';
import '../data/models/create_user_feedback_request.dart';
import '../data/user_feedback_providers.dart';
import '../domain/user_feedback_type.dart';
import 'user_feedback_submission_state.dart';

part 'user_feedback_controller.g.dart';

/// Riverpod's automatic retry, refused for this write.
Duration? _neverRetry(int retryCount, Object error) => null;

/// Submits one user feedback report and publishes its success notice.
///
/// The state is only the in-flight flag. Failures are returned to the screen
/// as typed [ApiFailure] values so it can keep the draft and show the correct
/// inline message. No automatic retry is performed: a retried report could be
/// stored twice.
@Riverpod(keepAlive: true, retry: _neverRetry)
class UserFeedbackController extends _$UserFeedbackController {
  @override
  bool build() => false;

  Future<UserFeedbackSubmitResult> submit({
    required UserFeedbackType type,
    required String message,
  }) async {
    if (state) return const UserFeedbackSubmitIgnored();

    state = true;

    try {
      final info = await _packageInfo();
      if (!ref.mounted) return const UserFeedbackSubmitIgnored();

      final version = info?.version.trim();
      final build = info == null ? null : int.tryParse(info.buildNumber.trim());

      await ref
          .read(userFeedbackRepositoryProvider)
          .submit(
            CreateUserFeedbackRequest(
              type: type.wireValue,
              message: message.trim(),
              appVersion: version != null && version.isNotEmpty
                  ? version
                  : null,
              appBuild: build != null && build >= 1 ? build : null,
            ),
          );

      if (!ref.mounted) return const UserFeedbackSubmitted();

      ref
          .read(feedbackProvider.notifier)
          .show(
            AppFeedback.localized(
              tone: FeedbackTone.success,
              message: (l10n) => l10n.userFeedbackSent,
            ),
          );

      return const UserFeedbackSubmitted();
    } on ApiFailure catch (failure) {
      return UserFeedbackSubmitFailed(failure);
    } catch (_) {
      return const UserFeedbackSubmitFailed(ApiFailureUnreadableResponse());
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// The installed package, or null when its platform channel is unavailable.
  ///
  /// The version and build are optional in the request, so a failed lookup
  /// must not stop the report itself.
  Future<PackageInfo?> _packageInfo() async {
    try {
      return await ref.read(packageInfoProvider);
    } catch (_) {
      return null;
    }
  }
}
