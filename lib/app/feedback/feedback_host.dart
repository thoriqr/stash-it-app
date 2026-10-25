import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// How long a notice stays on screen before it dismisses itself.
///
/// Four seconds, the same window Material's `SnackBar` uses: long enough to read
/// one sentence, short enough that the notice is gone before the user has moved
/// on to anything else. A notice is never the only place an outcome is stated —
/// a feature's own screen still carries it — so this is a limit on how long the
/// notice *lingers*, not on how long the information exists.
const Duration feedbackVisibleDuration = Duration(seconds: 4);

/// `design-system.md` §6.5's feedback table, resolved against the tokens in
/// force.
///
/// Every tone is the same three tokens in the same three roles — fill, border,
/// mark — plus the one thing that is not a colour: whether the mark is **hollow**.
/// §6.5 gives the warning and uncertain rows the same fill and border and
/// separates them only by the mark, so resolving the table has to return both
/// halves or the two rows would be indistinguishable.
///
/// Resolving it against [AppTokens] instead of the Material `ColorScheme` is what
/// makes it correct in both brightnesses: `AppTheme.tokensOf` returns the token
/// set the *active* theme registered, so a notice drawn over the dark canvas uses
/// B-Dark's semantic colours and not B · Inventory's.
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
  // The same fill and border as `warning`, by §6.5's table. The hollow mark is
  // the entire difference, which is what keeps "the budget is spent" from
  // looking like "we do not know what happened".
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

/// §6.5's mark: a 6 × 6 square set against the first line of the copy.
///
/// **Filled for a confirmed outcome, hollow for an uncertain one.** The size and
/// the 1 px ring are `.ds-note__mark`'s own geometry (`components.css`); §6.5
/// decides only that [FeedbackTone.uncertain] draws it hollow. A hollow mark is a
/// ring of the same token at the same size, so the two read as one element in two
/// states rather than as two different notices — and the ring is the whole visual
/// difference §6.5 gives the uncertain row beyond its colours.
///
/// Public because it is the thing a test has to be able to name: "the mark is
/// hollow" is a design-system rule, and asserting it through `Container`
/// decoration archaeology would be a test of this widget's innards instead.
class FeedbackMark extends StatelessWidget {
  const FeedbackMark({super.key, required this.color, required this.hollow});

  /// The mark's token: `--success`, `--warning` or `--danger`.
  final Color color;

  /// Whether to draw a ring instead of a fill.
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppMetrics.noticeMarkSize,
      height: AppMetrics.noticeMarkSize,
      // Exactly one of the two: `Container` asserts if both are given.
      color: hollow ? null : color,
      decoration: hollow
          ? BoxDecoration(
              border: Border.all(color: color, width: AppMetrics.borderWidth),
            )
          : null,
    );
  }
}

/// One feedback notice — `design-system.md` §6.5, drawn as `components.html`'s
/// `.ds-note`.
///
/// **A band, not a card.** The component reference is a compact rectangle: a
/// hairline `<tone>-border` on three sides, a **3 px leading edge in the tone's
/// own token**, a tone fill, 9 × 11 px of padding, a 6 × 6 mark squared to the
/// first line, and [AppTypography.meta] copy in `textPrimary`. No shadow and no
/// elevation — §6.5 gives each tone a fill and a border and nothing else, and a
/// lift here would be a treatment the design system does not have.
///
/// The leading edge and the mark carry the same token on purpose: the edge is
/// what a glance catches, the mark is what survives when the band is scanned.
/// [FeedbackTone.uncertain] is the one row where the two differ from an ordinary
/// warning only by the mark's **hollow** ring (see [feedbackTreatment]).
///
/// **The transparent `Material` is part of the treatment, not boilerplate.** The
/// host is mounted above the router, so this is the one text in the app with no
/// `Material` ancestor — and `MaterialApp` gives `WidgetsApp` a deliberate
/// *error* text style for exactly that case: 48 px red monospace with a double
/// yellow underline (`material/app.dart`, `_errorTextStyle`). `Text` merges its
/// own style *over* the ambient one, so the band's face and size were honoured
/// while that underline leaked through on every tone. A transparent `Material`
/// installs `theme.textTheme.bodyMedium` as the ambient style and paints
/// nothing, which is the SDK's own remedy for the fallback style and the text
/// environment every other widget in the app already has.
///
/// Pure presentation: it has no opinion about being dismissed. `FeedbackHost`
/// supplies the gesture, which is what lets a test pump this widget on its own
/// to check the tokens.
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
      type: MaterialType.transparency,
      child: ClipRRect(
        // The radius is a clip rather than part of the decoration because
        // `BoxBorder` refuses a radius on a border whose sides are not all the
        // same colour — and the leading edge deliberately is a different token.
        // Clipping rounds the painted border, which is what `.ds-note`'s
        // `border-radius` does to a border that varies by side.
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        child: Container(
          // The switcher's layout builder is a loose `Stack`, so without this a
          // short message would render as a narrow centred chip rather than a
          // band.
          width: double.infinity,
          padding: AppMetrics.noticePadding,
          decoration: BoxDecoration(
            color: treatment.fill,
            border: Border(
              top: hairline,
              right: hairline,
              bottom: hairline,
              // `.ds-note`'s `border-left-width: 3px` in the tone's own token.
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
                // Sits on the first line of copy rather than on the band's top
                // padding — `.ds-note__mark`'s `margin-top`.
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

/// The app's one feedback presenter: positioning, lifecycle and dismissal.
///
/// ## Why the top, and why a `Stack` rather than an `Overlay`
///
/// The shell is a `Scaffold` with a `NavigationBar` and each destination sits in
/// its own `Scaffold` inside it (`app_router.dart`). A Material `SnackBar` docks
/// to the bottom, where it competes with the navigation bar for the same band,
/// and repositioning one to the top is not supported: `margin` is measured from
/// the docked edge, so a top position would depend on the notice's height
/// changing with its copy.
///
/// An `OverlayEntry` cannot reach the place this needs to be either. The host
/// must sit **above the router** — that is what makes one notice serve every
/// route, including the auth screens outside the shell, and what stops a route
/// change from taking the notice with it. Above the router there is no `Overlay`
/// ancestor at all: the `Navigator` creates the overlay, and it is *below* this
/// point, so `Overlay.of(context)` could not be called from here. A `Stack` is
/// therefore not the simpler of two options; it is the only one that works at
/// this position.
///
/// ## Placement, and what it is a decision about
///
/// The notice is anchored to the top of the **content area**: `SafeArea` clears
/// the status bar, and one toolbar height clears the app bar. All four
/// destinations carry the theme's standard `AppBar` with no `toolbarHeight`
/// override, so `kToolbarHeight` is the exact band they occupy, and the notice
/// lands just below whichever destination is showing.
///
/// `AuthEntryScreen` and `SignInScreen` are the exceptions — they have no app
/// bar, because the brand row replaces one — so there the notice starts a
/// toolbar height below the status bar instead. That is the deliberate trade:
/// **one fixed band, so the notice never jumps between routes and never collides
/// with an app bar**, at the cost of a gap on the routes without one. Measuring
/// the app bar per route would mean this widget knowing each route's chrome,
/// which is the coupling the app-level position exists to avoid.
///
/// ## Lifecycle
///
/// The host is mounted once, in `MaterialApp.router`'s `builder`, and outlives
/// every route. It listens to [feedbackProvider] for the *side effect* of arming
/// the dismissal timer, and watches it for what to draw. `ref.listen` fires on
/// change, never on rebuild, so an app-level rebuild — a brightness change, a
/// locale change, `StashItApp` rebuilt by its parent — neither re-arms the timer
/// nor replays a notice that has already gone.
class FeedbackHost extends ConsumerStatefulWidget {
  const FeedbackHost({super.key, required this.child});

  /// The application's own widget tree: the router and everything under it.
  final Widget child;

  @override
  ConsumerState<FeedbackHost> createState() => _FeedbackHostState();
}

class _FeedbackHostState extends ConsumerState<FeedbackHost> {
  /// The pending auto-dismissal, or null when nothing is scheduled.
  ///
  /// A notice's *lifetime* is presentation, so the timer lives with the
  /// presenter rather than in the controller: the controller is the channel
  /// other features publish to and has no business holding a clock.
  Timer? _dismissal;

  /// The notice's transition. Long enough to read as a change, short enough not
  /// to be an animation the user waits for.
  static const Duration _transition = Duration(milliseconds: 180);

  @override
  void dispose() {
    // A notice still on screen must not outlive the tree that draws it. Without
    // this the timer fires into a disposed element.
    _dismissal?.cancel();
    super.dispose();
  }

  void _armDismissal() {
    _dismissal?.cancel();
    _dismissal = Timer(feedbackVisibleDuration, () {
      // The host is app-level and outlives every route, so this guard covers a
      // torn-down tree rather than a state the app reaches on its own.
      if (!mounted) return;
      ref.read(feedbackProvider.notifier).dismiss();
    });
  }

  void _dismiss() => ref.read(feedbackProvider.notifier).dismiss();

  @override
  Widget build(BuildContext context) {
    ref.listen<AppFeedback?>(feedbackProvider, (previous, next) {
      if (next == null) {
        // Dismissed, by tap or by its own timer. Dropping the handle here is
        // what keeps a *replaced* notice from cancelling the new one's timer:
        // a replacement goes through `_armDismissal`, which cancels first.
        _dismissal?.cancel();
        _dismissal = null;
        return;
      }
      _armDismissal();
    });

    final feedback = ref.watch(feedbackProvider);

    return Stack(
      children: [
        widget.child,
        Positioned(
          // Pinned to the top edge; the insets below it do the placing. The
          // notice's own height never enters the calculation, so it cannot reach
          // the navigation bar however long its copy is — and the `Positioned`
          // is only as tall as the notice, so every tap outside it falls through
          // to the screen underneath.
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            // Only the top inset is relevant: the notice is anchored to the top
            // edge and cannot reach the bottom of the screen.
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                // One standard app bar, plus the gap below it.
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
                        // Keyed by the value's *identity*, which is what makes a
                        // repeated message a new notice rather than an update to
                        // the one on screen (`app_feedback.dart`).
                        key: ValueKey<AppFeedback>(feedback),
                        // Opaque so the band itself is tappable; the hit area is
                        // the notice's own rectangle, so the screen around and
                        // below it stays usable.
                        behavior: HitTestBehavior.opaque,
                        onTap: _dismiss,
                        child: Semantics(
                          // Transient content is announced rather than only
                          // drawn — it is gone in four seconds, so a screen
                          // reader that never announces it never reports it.
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
