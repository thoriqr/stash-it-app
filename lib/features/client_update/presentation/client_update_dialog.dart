import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/release_download.dart';
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

/// Presents a pending update, including download progress and handoff state.
///
/// An optional update can be postponed. A required update offers download and
/// exit, and its barrier cannot be dismissed.
class ClientUpdateDialog extends StatelessWidget {
  const ClientUpdateDialog({
    required this.prompt,
    required this.download,
    required this.platform,
    required this.onDownload,
    required this.onRetry,
    required this.onOpenAgain,
    required this.onLater,
    required this.onExit,
    super.key,
  });

  final ClientUpdatePrompt prompt;
  final ClientUpdateDownloadState download;
  final String platform;
  final VoidCallback onDownload;
  final VoidCallback onRetry;
  final VoidCallback onOpenAgain;
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
              if (_statusFor(l10n, tokens) case final status?) ...[
                const SizedBox(height: AppMetrics.space4),
                status,
              ],
              const SizedBox(height: AppMetrics.space5),
              ..._actions(l10n, required: required),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _statusFor(AppLocalizations l10n, AppTokens tokens) {
    switch (download.stage) {
      case ClientUpdateDownloadStage.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: download.progress,
              minHeight: 4,
              backgroundColor: tokens.surfaceSunken,
              color: tokens.accent,
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.clientUpdateDownloading,
              style: AppTypography.meta.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space1),
            Text(
              _downloadDetail(l10n),
              style: AppTypography.meta.copyWith(color: tokens.textTertiary),
            ),
          ],
        );

      case ClientUpdateDownloadStage.verifying:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: tokens.surfaceSunken,
              color: tokens.accent,
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.clientUpdateVerifying,
              style: AppTypography.meta.copyWith(color: tokens.textSecondary),
            ),
          ],
        );

      case ClientUpdateDownloadStage.opening:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: tokens.surfaceSunken,
              color: tokens.accent,
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.clientUpdateOpening,
              style: AppTypography.meta.copyWith(color: tokens.textSecondary),
            ),
          ],
        );

      case ClientUpdateDownloadStage.failed:
        return Text(
          _errorCopy(l10n),
          style: AppTypography.body.copyWith(color: tokens.danger),
        );

      case ClientUpdateDownloadStage.opened:
        return Text(
          platform == 'windows'
              ? l10n.clientUpdateInstallOpenedWindows
              : l10n.clientUpdateInstallOpenedAndroid,
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        );

      case ClientUpdateDownloadStage.idle:
        return null;
    }
  }

  String _downloadDetail(AppLocalizations l10n) {
    final received = _sizeLabel(download.receivedBytes);
    final total = download.totalBytes;
    if (total != null && total > 0) {
      return l10n.clientUpdateDownloadProgress(received, _sizeLabel(total));
    }
    return l10n.clientUpdateDownloadedBytes(received);
  }

  String _sizeLabel(int bytes) {
    return formatReleaseSize(bytes) ?? '$bytes B';
  }

  String _errorCopy(AppLocalizations l10n) {
    return switch (download.error) {
      ClientUpdateDownloadError.checksumMismatch =>
        l10n.clientUpdateChecksumMismatch,
      ClientUpdateDownloadError.checksumMissing =>
        l10n.clientUpdateChecksumMissing,
      ClientUpdateDownloadError.hostRejected => l10n.clientUpdateUnsafeDownload,
      ClientUpdateDownloadError.unsupportedPlatform =>
        l10n.clientUpdateInstallUnsupported,
      ClientUpdateDownloadError.installerFailed =>
        l10n.clientUpdateInstallerFailed,
      ClientUpdateDownloadError.installPermission =>
        l10n.clientUpdateInstallPermission,
      ClientUpdateDownloadError.network ||
      null => l10n.clientUpdateDownloadFailed,
    };
  }

  List<Widget> _actions(AppLocalizations l10n, {required bool required}) {
    final actions = <Widget>[];

    switch (download.stage) {
      case ClientUpdateDownloadStage.idle:
        actions.add(_primary(l10n.clientUpdateDownload, onDownload));

      case ClientUpdateDownloadStage.failed:
        if (_canRetry) {
          actions.add(_primary(l10n.clientUpdateRetry, onRetry));
        }

      case ClientUpdateDownloadStage.opened:
        actions.add(_primary(l10n.clientUpdateOpenAgain, onOpenAgain));

      case ClientUpdateDownloadStage.downloading:
      case ClientUpdateDownloadStage.verifying:
      case ClientUpdateDownloadStage.opening:
        break;
    }

    if (actions.isNotEmpty) {
      actions.add(const SizedBox(height: AppMetrics.space2));
    }

    actions.add(
      AppButton(
        label: required ? l10n.clientUpdateExit : l10n.clientUpdateLater,
        variant: AppButtonVariant.secondary,
        onPressed: required ? onExit : onLater,
      ),
    );

    return actions;
  }

  bool get _canRetry {
    return download.error != ClientUpdateDownloadError.unsupportedPlatform &&
        download.error != ClientUpdateDownloadError.hostRejected;
  }

  Widget _primary(String label, VoidCallback onPressed) {
    return AppButton(
      label: label,
      variant: AppButtonVariant.primary,
      onPressed: onPressed,
    );
  }
}
