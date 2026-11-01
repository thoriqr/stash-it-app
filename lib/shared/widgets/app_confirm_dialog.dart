import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// Shows a confirmation dialog and returns the selected action.
///
/// Returns `true` only when the confirm action is selected. Choosing cancel
/// returns `false`, while dismissing the dialog through Back or a barrier tap
/// returns `null`.
///
/// Callers should proceed only when the result is explicitly `true`, so any
/// dismissal path remains a safe outcome.
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

/// A theme-aware confirmation dialog for consequential actions.
///
/// Reads colors directly from [AppTokens] so its appearance follows the
/// current theme without changing the global Material dialog theme.
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

  /// The safe action. Dismissing the dialog has the same effect.
  final String cancelLabel;

  /// The action that confirms the operation.
  final String confirmLabel;

  /// Uses the danger button variant instead of the primary variant.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Dialog(
      backgroundColor: tokens.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
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

                  // Stack the actions when there is not enough width for both
                  // buttons and their labels to remain readable.
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
