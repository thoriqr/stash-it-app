import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// How a message band presents itself.
///
/// `design-system.md` §6.5 gives five feedback treatments. Only two of them can
/// appear on the auth screens, and the distinction is the point rather than
/// decoration:
///
/// | Situation | Treatment | Mark |
/// | --- | --- | --- |
/// | **Warning** (budget spent, **expiry**) | `warning-soft` + `warning-border` | filled |
/// | **Failure** (known) | `danger-soft` + `danger-border` | filled |
///
/// An expiry is filed under Warning by the specification, so it must not wear
/// the Failure colours: the user did not do anything wrong, and a danger band
/// reads as a mistake they made. The fifth row — **Uncertain**, the same warning
/// colours with a *hollow* mark — is deliberately not modelled here. No auth
/// screen currently asks for it, so adding a third tone now would be a case with
/// no caller.
enum AuthMessageTone {
  /// A confirmed failure of something the user attempted.
  danger,

  /// Something lapsed without the user attempting it.
  warning,
}

/// A message the user can dismiss.
///
/// Shared by the auth entry screen and the sign-in form so the session-expiry
/// notice and an ordinary sign-in failure are the same band, differing only in
/// tone. The tone decides the fill, border and mark; the layout is identical
/// either way, so a change of treatment never changes the band's height or its
/// wrapping.
///
/// The message and Dismiss share one row. They were stacked, and because
/// Material gives a `TextButton` a 48 px minimum target the dismiss row alone
/// was taller than the sentence above it, so a one-line failure occupied roughly
/// a hundred pixels with an empty gap under the text. Inline, the band is as
/// tall as the message it has to show — and a longer message still wraps, because
/// the text is the flexible child and Dismiss is not.
class AuthMessageBand extends StatelessWidget {
  const AuthMessageBand({
    required this.message,
    required this.onDismiss,
    this.tone = AuthMessageTone.danger,
    super.key,
  });

  final String message;
  final VoidCallback onDismiss;

  /// Defaults to [AuthMessageTone.danger], so an ordinary sign-in failure keeps
  /// the treatment it has always had without each call site naming it.
  final AuthMessageTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    final fill = switch (tone) {
      AuthMessageTone.danger => tokens.dangerSoft,
      AuthMessageTone.warning => tokens.warningSoft,
    };
    final border = switch (tone) {
      AuthMessageTone.danger => tokens.dangerBorder,
      AuthMessageTone.warning => tokens.warningBorder,
    };
    final mark = switch (tone) {
      AuthMessageTone.danger => tokens.danger,
      AuthMessageTone.warning => tokens.warning,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.space3),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Row(
        // Centred, so a single-line message and its dismiss action read as one
        // unit rather than as two unrelated rows.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The flexible child: this is what wraps when a message is long.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Sits on the first line's baseline rather than the row's top.
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 5, height: 5, color: mark),
                ),
                const SizedBox(width: AppMetrics.space2),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.meta.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              // 32 px rather than Material's 48: the band is a confirmation of
              // a failure, not the primary action, and its own target still
              // clears WCAG 2.5.8's 24 px minimum by a comfortable margin.
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(
                horizontal: AppMetrics.space2,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
