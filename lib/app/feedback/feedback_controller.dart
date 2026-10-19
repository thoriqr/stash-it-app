import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_feedback.dart';

part 'feedback_controller.g.dart';

/// The app's one feedback channel: what is showing, if anything.
///
/// A plain notifier, not an `AsyncNotifier` — publishing is a synchronous value
/// assignment, so nothing here can fail and Riverpod's automatic retry has
/// nothing to act on. `keepAlive` because feedback is app-wide and must outlive
/// the route that raised it.
///
/// Deliberately free of any feature concept. A caller decides what to say and
/// hands over an [AppFeedback]; this type only decides what is on screen.
@Riverpod(keepAlive: true)
class Feedback extends _$Feedback {
  // Why the generated default is refused, in full.
  //
  // `@riverpod` produces an *auto-dispose* provider. A notice published just
  // before the user switches destination is still the answer to something they
  // did, so it must not be thrown away by the disposal of the screen that
  // happened to be showing. In the shipped tree `FeedbackHost` watches this
  // provider for the life of the process, so auto-dispose would never actually
  // fire — `keepAlive` states the intent instead of depending on that accident.
  //
  // Why there is no `retry:` here, in full.
  //
  // `SavedItems` overrides the policy because a failed *build* there would
  // resubmit a write. This build is `=> null`: it performs no I/O and cannot
  // fail, so there is no failure for the retry to see, and a `retry:` override
  // would be a policy guarding nothing.
  @override
  AppFeedback? build() => null;

  /// Shows [feedback], replacing whatever is showing.
  ///
  /// **Replaces rather than queues.** The useful notice is the newest one: a
  /// queue would replay a stale outcome after the user has moved on, and a burst
  /// of taps would leave the last message trailing behind the state that
  /// produced it. The presenter animates the change, so a replacement reads as
  /// one notice changing rather than two stacked.
  void show(AppFeedback feedback) {
    state = feedback;
  }

  /// Clears the current feedback, if any.
  ///
  /// Idempotent: dismissing nothing is not an error. The presenter calls this
  /// both when the notice is tapped and when its time on screen runs out, so the
  /// two dismissal paths land in one place rather than one of them reaching into
  /// the widget tree.
  void dismiss() {
    state = null;
  }
}
