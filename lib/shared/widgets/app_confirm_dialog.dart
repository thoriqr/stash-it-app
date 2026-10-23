import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// Shows the shared confirmation dialog and returns `true` only when the
/// confirm action was chosen.
///
/// A barrier tap, Back, or any other dismissal returns `null`. Callers that treat
/// dismissal as the safe choice must check for `true` rather than `false ==
/// result`, so a new dismissal path cannot accidentally confirm a destructive
/// action.
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AppConfirmDialog(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      destructive: destructive,
    ),
  );
}

/// The theme-aware confirmation treatment for a destructive or irreversible
/// action.
///
/// **Not an `AlertDialog`.** The app has no global `dialogTheme`, and adding one
/// to style two dialogs would make every future Material dialog inherit a
/// decision made here. This widget reads the existing tokens directly, so it is
/// correct in both brightnesses without a second palette or a theme override.
///
/// The surface is [AppTokens.surfaceRaised] — the token documented for sheets and
/// dialogs — with the same hairline border as the rest of the app. Corners stay
/// on the 4 px radius scale; nothing here introduces a new radius or elevation.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String message;

  /// The safe action. Dismissing the route is equivalent to choosing this.
  final String cancelLabel;

  /// The action that commits the change.
  final String confirmLabel;

  /// Uses the danger-soft button treatment. Both dialogs in the saved-item flow
  /// are destructive; the flag keeps the widget reusable for a non-destructive
  /// confirmation without inventing a second dialog.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Dialog(
      backgroundColor: tokens.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // 16 px horizontal rather than Material's 40: the dialog still clears the
      // screen edge on a 320 px device, and the action row stacks below 260 px of
      // content width rather than truncating "Delete collection".
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.space4,
        vertical: AppMetrics.space6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(AppMetrics.radius3),
        ),
        side: BorderSide(color: tokens.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.screenHeading.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.space3),
              Text(
                message,
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppMetrics.space5),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cancel = AppButton(
                    label: cancelLabel,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  );
                  final confirm = AppButton(
                    label: confirmLabel,
                    variant: destructive
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                  );

                  // Two block buttons need roughly 130 px each for their labels.
                  // Below that they stack rather than ellipsizing the destructive
                  // action into something the user cannot read.
                  if (constraints.maxWidth < 260) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        cancel,
                        const SizedBox(height: AppMetrics.space2),
                        confirm,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: cancel),
                      const SizedBox(width: AppMetrics.space3),
                      Expanded(child: confirm),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
