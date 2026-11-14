import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// Formats a release size for display, or returns null when it is unknown.
String? formatReleaseSize(int? bytes) {
  if (bytes == null || bytes <= 0) return null;

  const kilobyte = 1024;
  const megabyte = kilobyte * 1024;

  if (bytes >= megabyte) {
    final value = bytes / megabyte;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} MB';
  }
  if (bytes >= kilobyte) {
    final value = bytes / kilobyte;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} KB';
  }
  return '$bytes B';
}

/// Presents a pending update.
///
/// An optional update can be postponed. A required update offers only download
/// and exit, and its barrier cannot be dismissed.
class ClientUpdateDialog extends StatelessWidget {
  const ClientUpdateDialog({
    required this.prompt,
    required this.onDownload,
    required this.onLater,
    required this.onExit,
    super.key,
  });

  final ClientUpdatePrompt prompt;
  final VoidCallback onDownload;
  final VoidCallback onLater;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final release = prompt.release;
    final required = prompt.isRequired;
    final notes = release.releaseNotes;
    final size = formatReleaseSize(release.fileSizeBytes);

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppMetrics.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                required
                    ? l10n.clientUpdateRequiredTitle
                    : l10n.clientUpdateOptionalTitle,
                style: AppTypography.screenHeading.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.space2),
              Text(
                required
                    ? l10n.clientUpdateRequiredBody
                    : l10n.clientUpdateOptionalBody,
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppMetrics.space4),
              Text(
                l10n.clientUpdateVersion(release.version),
                style: AppTypography.itemTitle.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
              if (notes != null) ...[
                const SizedBox(height: AppMetrics.space3),
                Text(
                  l10n.clientUpdateReleaseNotes,
                  style: AppTypography.sectionLabel.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
                const SizedBox(height: AppMetrics.space1),
                Text(
                  notes,
                  style: AppTypography.body.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
              ],
              if (size != null) ...[
                const SizedBox(height: AppMetrics.space3),
                Text(
                  l10n.clientUpdateFileSize(size),
                  style: AppTypography.meta.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: AppMetrics.space5),
              AppButton(
                label: l10n.clientUpdateDownload,
                variant: AppButtonVariant.primary,
                onPressed: onDownload,
              ),
              const SizedBox(height: AppMetrics.space2),
              AppButton(
                label: required
                    ? l10n.clientUpdateExit
                    : l10n.clientUpdateLater,
                variant: AppButtonVariant.secondary,
                onPressed: required ? onExit : onLater,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
