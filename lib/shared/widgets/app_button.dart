import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// Defines the button variants shared across the app.
///
/// Button colors and borders come from the corresponding [ThemeData] button
/// themes. This widget selects the variant and handles the additional
/// [busy] state and [small] size.
enum AppButtonVariant {
  /// Accent-filled button for the primary action.
  primary,

  /// Surface-filled button with a visible border.
  secondary,

  /// Transparent button with accent-colored text.
  quiet,

  /// Danger-colored button for destructive actions.
  danger,
}

/// A shared button with consistent variants, sizing, and loading behavior.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.busy = false,
    this.block = true,
    this.small = false,
    super.key,
  });

  /// Button label, replaced by a progress indicator while [busy].
  final String label;

  /// Called when the button is pressed.
  ///
  /// A null callback disables the button. The button is also disabled while
  /// [busy] is true.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;

  /// Shows a progress indicator and disables interaction while an action runs.
  ///
  /// Kept separate from [onPressed] because a busy button communicates that
  /// an operation is in progress, while a disabled button is simply
  /// unavailable.
  final bool busy;

  /// Expands the button to fill the available width.
  final bool block;

  /// Uses the compact 24 px button height for dense layouts.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final disabled = onPressed == null || busy;

    final style = ButtonStyle(
      // Keep the minimum width at zero. Size.fromHeight would set an
      // infinite width, which can overflow in constrained layouts.
      minimumSize: WidgetStatePropertyAll(
        Size(0, small ? AppMetrics.buttonHeightSmall : AppMetrics.buttonHeight),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppMetrics.space3),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppMetrics.controlRadius),
        ),
      ),
      textStyle: WidgetStatePropertyAll(AppTypography.button),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final child = busy
        ? SizedBox(
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foreground(tokens),
            ),
          )
        : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: disabled ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.quiet => TextButton(
        onPressed: disabled ? null : onPressed,
        style: style,
        child: child,
      ),
      AppButtonVariant.danger => OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: style.copyWith(
          backgroundColor: WidgetStatePropertyAll(tokens.dangerSoft),
          foregroundColor: WidgetStatePropertyAll(tokens.danger),
          side: WidgetStatePropertyAll(BorderSide(color: tokens.dangerBorder)),
        ),
        child: child,
      ),
    };

    if (!block) return button;

    return SizedBox(width: double.infinity, child: button);
  }

  /// Returns the foreground color used by the loading indicator.
  Color _foreground(AppTokens tokens) => switch (variant) {
    AppButtonVariant.primary => tokens.accentContrast,
    AppButtonVariant.danger => tokens.danger,
    AppButtonVariant.quiet => tokens.accent,
    AppButtonVariant.secondary => tokens.textPrimary,
  };
}
