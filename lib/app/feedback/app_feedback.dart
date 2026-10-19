import 'package:flutter/foundation.dart';

/// The semantic tone of one piece of feedback — `design-system.md` §6.5.
///
/// **Four tones, and the fifth row is still unimplemented.** §6.5 also
/// specifies a *neutral information* row (`--surface-inset` + `--border`, a
/// neutral mark). It has no caller: every outcome this client currently
/// publishes is either known or explicitly uncertain, and a "neutral" band would
/// be a fifth way of saying nothing in particular.
///
/// Adding one is a new value here plus one arm in `feedbackTreatment` — the
/// band's geometry does not change, which is exactly why the tone is a value and
/// not a layout choice. The one thing a tone *does* change beyond its colours is
/// the mark: [uncertain] draws it hollow, and that distinction lives in
/// `feedback_host.dart` with the rest of the treatment.
enum FeedbackTone {
  /// A save that was confirmed. `--success-soft` + `--success-border`.
  success,

  /// A budget spent, or something that lapsed without the user attempting it.
  /// `--warning-soft` + `--warning-border`.
  ///
  /// **A known outcome.** Not to be used for anything the client could not
  /// establish — [uncertain] exists for that, and §6.5 requires the two to look
  /// different.
  warning,

  /// **No answer, or an answer the client cannot read.** The warning fill and
  /// border, with a **hollow** mark.
  ///
  /// §6.5's reason is one-directional: this is *the only state that may not
  /// claim the item was not saved*, so it must not be painted as a confirmed
  /// failure (**D15** groups G and H, **D16**). It is also the honest treatment
  /// for a reply whose body the client could not decode: `core/error` cannot
  /// distinguish a `2xx` whose body failed to decode — which means the write
  /// committed — from a non-2xx body it could not read, so the outcome is
  /// unestablished rather than known.
  uncertain,

  /// A known failure. `--danger-soft` + `--danger-border`.
  danger,
}

/// One piece of feedback: a tone, and copy this client owns.
///
/// **[D22] There is no backend message here, and no field for one.** The
/// taxonomy in `core/error` deliberately carries none either, so leaking server
/// prose into the UI is not merely discouraged — it is unrepresentable. The
/// caller selects the copy, per outcome, in the client.
///
/// **No `==`, deliberately — and it is load-bearing.** Riverpod compares state
/// with `==` to decide whether to notify. Two *separate* notices may legitimately
/// carry identical copy: saving two links that fail the same way must notify
/// twice, not once. Identity equality gives that, because each `show` call site
/// constructs its own value.
///
/// Publishing the *same instance* twice is consequently a no-op, and that is
/// correct rather than a gap: nothing changed.
@immutable
class AppFeedback {
  const AppFeedback({required this.tone, required this.copy});

  /// How it is painted. The mapping to tokens lives in `feedback_host.dart`,
  /// because colour is presentation and this type is not.
  final FeedbackTone tone;

  /// The sentence shown to the user.
  ///
  /// English-only for now, like the rest of the app's copy: `flutter_localizations`
  /// is not a dependency yet (`AGENTS.md` §4), and **D20/D21** will move these
  /// strings to ARB without changing this type.
  final String copy;

  @override
  String toString() => 'AppFeedback($tone, $copy)';
}
