import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// The approved button set — `design-system.md` §6.1.
///
/// Exists because **two** screens need it: sign-in submits, and the Inbox intake
/// needs both a secondary and a primary. A chip, a feedback note and an inventory
/// slot each have one consumer and therefore stay with their owning feature.
///
/// The fills and borders come from the `ThemeData` button themes; this widget
/// only chooses which one and carries the two states a `ButtonStyle` cannot
/// express: [busy] and the shape of [small].
enum AppButtonVariant {
  /// The accent fill. **The only filled button on a screen** — on the Inbox that
  /// is Save URL, so pasting can never be mistaken for saving (D25).
  primary,

  /// A surface fill with a strong border.
  secondary,

  /// No fill, no border, accent text.
  quiet,

  /// A danger-soft fill, for a destructive action.
  danger,
}

/// A button in the approved set.
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

  /// The label. Replaced by a spinner while [busy].
  final String label;

  /// `null` disables the button. A [busy] button is disabled whatever this says.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;

  /// Replaces the label with a spinner and disables the button.
  ///
  /// Separate from [onPressed] being `null` because the two mean different
  /// things: a disabled control cannot be used, while a busy one is mid-action
  /// and the user needs to see that something is happening.
  final bool busy;

  /// Fills the available width. The specification's block variant.
  final bool block;

  /// The 24 px variant, for an action inside a dense row.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final disabled = onPressed == null || busy;

    final style = ButtonStyle(
      // `Size(0, h)`, never `Size.fromHeight(h)`: the latter carries an
      // infinite width, which a button in a `Row` or an unbounded `Column`
      // cannot satisfy.
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

  /// The colour a busy spinner takes from whatever fills its button.
  Color _foreground(AppTokens tokens) => switch (variant) {
    AppButtonVariant.primary => tokens.accentContrast,
    AppButtonVariant.danger => tokens.danger,
    AppButtonVariant.quiet => tokens.accent,
    AppButtonVariant.secondary => tokens.textPrimary,
  };
}
