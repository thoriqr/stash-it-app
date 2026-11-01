import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_feedback.dart';

part 'feedback_controller.g.dart';

/// App-wide feedback state.
///
/// Keeps the latest notice available independently of the route that
/// triggered it. Callers provide the feedback content; this controller
/// manages only its visibility.
@Riverpod(keepAlive: true)
class Feedback extends _$Feedback {
  @override
  AppFeedback? build() => null;

  /// Shows [feedback], replacing the current notice.
  ///
  /// Only the latest notice is retained. This avoids displaying outdated
  /// feedback after a newer action has occurred.
  void show(AppFeedback feedback) {
    state = feedback;
  }

  /// Clears the current notice.
  ///
  /// Safe to call when no notice is showing. Both manual dismissal and
  /// automatic timeout use this method.
  void dismiss() {
    state = null;
  }
}
