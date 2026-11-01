import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// How long a notice stays visible before dismissing automatically.
const Duration feedbackVisibleDuration = Duration(seconds: 4);

/// Resolves the visual treatment for each feedback tone using the active
/// theme's semantic color tokens.
///
/// Returns the fill, border, mark color, and whether the mark is hollow.
/// Warning and uncertain notices share the same colors; the hollow mark
/// distinguishes an uncertain outcome from a known warning.
({Color fill, Color border, Color mark, bool hollowMark}) feedbackTreatment(
  AppTokens tokens,
  FeedbackTone tone,
) => switch (tone) {
  FeedbackTone.success => (
    fill: tokens.successSoft,
    border: tokens.successBorder,
    mark: tokens.success,
    hollowMark: false,
  ),
  FeedbackTone.warning => (
    fill: tokens.warningSoft,
    border: tokens.warningBorder,
    mark: tokens.warning,
    hollowMark: false,
  ),
  FeedbackTone.uncertain => (
    fill: tokens.warningSoft,
    border: tokens.warningBorder,
    mark: tokens.warning,
    hollowMark: true,
  ),
  FeedbackTone.danger => (
    fill: tokens.dangerSoft,
    border: tokens.dangerBorder,
    mark: tokens.danger,
    hollowMark: false,
  ),
};

/// Small visual mark displayed beside the feedback message.
class FeedbackMark extends StatelessWidget {
  const FeedbackMark({super.key, required this.color, required this.hollow});

  /// Color used to draw the mark.
  final Color color;

  /// Whether to draw an outline instead of a filled square.
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppMetrics.noticeMarkSize,
      height: AppMetrics.noticeMarkSize,
      // Container cannot use both color and decoration simultaneously.
      color: hollow ? null : color,
      decoration: hollow
          ? BoxDecoration(
              border: Border.all(color: color, width: AppMetrics.borderWidth),
            )
          : null,
    );
  }
}

/// Displays a feedback notice using the active theme's semantic tokens.
///
/// This widget handles presentation only. Dismissal and lifecycle management
/// are handled by [FeedbackHost].
class FeedbackNotice extends StatelessWidget {
  const FeedbackNotice({super.key, required this.feedback});

  final AppFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final treatment = feedbackTreatment(tokens, feedback.tone);

    final hairline = BorderSide(
      color: treatment.border,
      width: AppMetrics.borderWidth,
    );

    return Material(
      // FeedbackHost is mounted above the router and has no Material ancestor.
      // A transparent Material provides the app's normal text theme without
      // painting an additional surface.
      type: MaterialType.transparency,
      child: ClipRRect(
        // Clip the border because its leading edge uses a different color
        // from the other three sides.
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        child: Container(
          // AnimatedSwitcher uses a loose Stack; expand to fill its available
          // width instead of sizing the notice to its message.
          width: double.infinity,
          padding: AppMetrics.noticePadding,
          decoration: BoxDecoration(
            color: treatment.fill,
            border: Border(
              top: hairline,
              right: hairline,
              bottom: hairline,
              left: BorderSide(
                color: treatment.mark,
                width: AppMetrics.noticeEdgeWidth,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                // Align the mark with the first line of the message.
                padding: const EdgeInsets.only(top: AppMetrics.noticeMarkTop),
                child: FeedbackMark(
                  color: treatment.mark,
                  hollow: treatment.hollowMark,
                ),
              ),
              const SizedBox(width: AppMetrics.space2),
              Expanded(
                child: Text(
                  feedback.copy,
                  style: AppTypography.meta.copyWith(color: tokens.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// App-wide feedback presenter.
///
/// Displays feedback above the routed content and manages its automatic
/// dismissal. It is mounted once above the router so notices remain visible
/// across route changes.
class FeedbackHost extends ConsumerStatefulWidget {
  const FeedbackHost({super.key, required this.child});

  /// The application's widget tree, including the router.
  final Widget child;

  @override
  ConsumerState<FeedbackHost> createState() => _FeedbackHostState();
}

class _FeedbackHostState extends ConsumerState<FeedbackHost> {
  /// Timer for the currently displayed notice.
  Timer? _dismissal;

  static const Duration _transition = Duration(milliseconds: 180);

  @override
  void dispose() {
    _dismissal?.cancel();
    super.dispose();
  }

  void _armDismissal() {
    _dismissal?.cancel();
    _dismissal = Timer(feedbackVisibleDuration, () {
      if (!mounted) return;
      ref.read(feedbackProvider.notifier).dismiss();
    });
  }

  void _dismiss() => ref.read(feedbackProvider.notifier).dismiss();

  @override
  Widget build(BuildContext context) {
    ref.listen<AppFeedback?>(feedbackProvider, (previous, next) {
      if (next == null) {
        _dismissal?.cancel();
        _dismissal = null;
        return;
      }

      // Restart the timer whenever a new notice is published.
      _armDismissal();
    });

    final feedback = ref.watch(feedbackProvider);

    return Stack(
      children: [
        widget.child,
        Positioned(
          // Anchor the notice independently of its height. This keeps it
          // below the app bar without affecting the content or navigation bar.
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + AppMetrics.space2,
                left: AppMetrics.screenPadding,
                right: AppMetrics.screenPadding,
              ),
              child: AnimatedSwitcher(
                duration: _transition,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: feedback == null
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        // AppFeedback uses identity equality, so a new notice
                        // with identical content still gets its own transition.
                        key: ValueKey<AppFeedback>(feedback),
                        behavior: HitTestBehavior.opaque,
                        onTap: _dismiss,
                        child: Semantics(
                          // Announce transient feedback to screen readers.
                          liveRegion: true,
                          container: true,
                          child: FeedbackNotice(feedback: feedback),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
