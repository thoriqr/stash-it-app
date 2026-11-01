import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// Defines the visual treatment of an authentication message.
enum AuthMessageTone {
  /// A confirmed failure of an action the user attempted.
  danger,

  /// A condition that expired or lapsed without a user action.
  warning,
}

/// A message band with optional dismissal.
////
//// Shared by authentication screens for displaying failures and notices.
/// The tone determines the fill, border, and mark color without changing the
/// layout or message wrapping.
///
/// When [onDismiss] is null, the band remains visible until the underlying
/// state changes. This is useful when the user must resolve the state through
/// another action, such as Retry.
class AuthMessageBand extends StatelessWidget {
  const AuthMessageBand({
    required this.message,
    this.onDismiss,
    this.tone = AuthMessageTone.danger,
    super.key,
  });

  final String message;

  /// Null when the message must remain visible until its state changes.
  final VoidCallback? onDismiss;

  /// Defaults to [AuthMessageTone.danger] for ordinary sign-in failures.
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
        // Keeps a single-line message and its dismiss action vertically aligned.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The message takes the available width and wraps when necessary.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Aligns the mark with the first line of text.
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
          if (onDismiss case final onDismiss?) ...[
            const SizedBox(width: AppMetrics.space2),
            TextButton(
              onPressed: onDismiss,
              style: TextButton.styleFrom(
                // Compact target while remaining above the 24 px WCAG minimum.
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
        ],
      ),
    );
  }
}
