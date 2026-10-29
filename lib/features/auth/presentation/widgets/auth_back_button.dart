import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The top-left route back to the signed-out landing screen.
///
/// Shared by the two credential forms. It is a navigation affordance, not a
/// form action: tapping it never validates, submits, or clears a field. The
/// caller disables it while a request is in flight, matching the way the forms
/// already disable their other navigation actions during submission.
///
/// The auth screens sit outside the destination shell and carry the brand row
/// instead of an app bar, so this is deliberately an inline control rather than
/// an `AppBar.leading`.
///
/// **Compact and left-aligned on purpose.** A default `IconButton` reserves a
/// 48 px square, which reads as a separate toolbar row above the brand. The
/// 32 px box and zero padding let the arrow sit against the content's left edge
/// directly above `AuthBrandRow`, while still being a real button with its
/// tooltip, disabled state, and tap target.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  /// Null disables the control. It stays visible so the layout does not shift
  /// while a request is in flight.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
        tooltip: 'Back to welcome',
        color: tokens.textSecondary,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        constraints: const BoxConstraints(
          minWidth: 32,
          maxWidth: 32,
          minHeight: 32,
          maxHeight: 32,
        ),
        // Without this, Material 3 inflates the hit area to its 48 px padded
        // target and the visual row stays as tall as before.
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
