import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/application/client_update_download_controller.dart';
import 'package:stash_it_app/features/client_update/data/client_update_providers.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/release_download.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// Exits the application when a required update leaves no usable version.
void exitApplication() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
    return;
  }
  exit(0);
}

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

/// The full-screen update surface.
///
/// The release notes scroll independently while the actions stay pinned at the
/// bottom. A required update cannot be popped; an optional update can be
/// closed from the app bar or the system back action.
class ClientUpdateScreen extends StatelessWidget {
  const ClientUpdateScreen({
    required this.prompt,
    required this.download,
    required this.platform,
    required this.onDownload,
    required this.onRetry,
    required this.onOpenAgain,
    required this.onExit,
    this.onLater,
    this.onBack,
    super.key,
  });

  final ClientUpdatePrompt prompt;
  final ClientUpdateDownloadState download;
  final String platform;
  final VoidCallback onDownload;
  final VoidCallback onRetry;
  final VoidCallback onOpenAgain;
  final VoidCallback onExit;

  /// Closes an optional update. Null for a required update.
  final VoidCallback? onLater;

  /// Runs after the system back action closed an optional update.
  ///
  /// The route has already been popped, so this only clears the prompt state.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final release = prompt.release;
    final required = prompt.isRequired;
    final notes = release.releaseNotes;
    final size = formatReleaseSize(release.fileSizeBytes);

    return PopScope(
      canPop: !required,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !required) onBack?.call();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            required
                ? l10n.clientUpdateRequiredTitle
                : l10n.clientUpdateOptionalTitle,
          ),
          actions: [
            if (!required && onLater != null)
              IconButton(
                icon: const Icon(Icons.close, size: AppMetrics.iconSize),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: onLater,
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppMetrics.space4,
                        AppMetrics.space4,
                        AppMetrics.space4,
                        AppMetrics.space4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            required
                                ? l10n.clientUpdateRequiredBody
                                : l10n.clientUpdateOptionalBody,
                            style: AppTypography.body.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppMetrics.space4),
                          Text(
                            l10n.clientUpdateVersion(release.version),
                            style: AppTypography.itemTitle.copyWith(
                              color: tokens.textPrimary,
                            ),
                          ),
                          if (notes != null) ...[
                            const SizedBox(height: AppMetrics.space4),
                            Text(
                              l10n.clientUpdateReleaseNotes,
                              style: AppTypography.sectionLabel.copyWith(
                                color: tokens.textTertiary,
                              ),
                            ),
                            const SizedBox(height: AppMetrics.space2),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppMetrics.space3),
                              decoration: BoxDecoration(
                                color: tokens.surfaceInset,
                                border: Border.all(color: tokens.border),
                                borderRadius: const BorderRadius.all(
                                  AppMetrics.controlRadius,
                                ),
                              ),
                              child: SelectableText(
                                notes,
                                style: AppTypography.body.copyWith(
                                  color: tokens.textSecondary,
                                ),
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
                        ],
                      ),
                    ),
                  ),
                  _ActionBar(
                    primary: _primaryAction(l10n),
                    secondaryLabel: required
                        ? l10n.clientUpdateExit
                        : l10n.clientUpdateLater,
                    onSecondary: required ? onExit : onLater,
                  ),
                ],
              ),
            ),
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

  Widget? _primaryAction(AppLocalizations l10n) {
    switch (download.stage) {
      case ClientUpdateDownloadStage.idle:
        return AppButton(
          label: l10n.clientUpdateDownload,
          variant: AppButtonVariant.primary,
          onPressed: onDownload,
        );

      case ClientUpdateDownloadStage.failed:
        if (!_canRetry) return null;
        return AppButton(
          label: l10n.clientUpdateRetry,
          variant: AppButtonVariant.primary,
          onPressed: onRetry,
        );

      case ClientUpdateDownloadStage.opened:
        return AppButton(
          label: l10n.clientUpdateOpenAgain,
          variant: AppButtonVariant.primary,
          onPressed: onOpenAgain,
        );

      case ClientUpdateDownloadStage.downloading:
      case ClientUpdateDownloadStage.verifying:
      case ClientUpdateDownloadStage.opening:
        return null;
    }
  }

  bool get _canRetry {
    return download.error != ClientUpdateDownloadError.unsupportedPlatform &&
        download.error != ClientUpdateDownloadError.hostRejected;
  }
}

/// The pinned actions below the scrollable update content.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.primary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final Widget? primary;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space4,
        AppMetrics.space3,
        AppMetrics.space4,
        AppMetrics.space3,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(top: BorderSide(color: tokens.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (primary case final primary?) ...[
            primary,
            const SizedBox(height: AppMetrics.space2),
          ],
          AppButton(
            label: secondaryLabel,
            variant: AppButtonVariant.secondary,
            onPressed: onSecondary,
          ),
        ],
      ),
    );
  }
}

/// The route that presents [ClientUpdateScreen] over the app.
class ClientUpdateRoute extends ConsumerStatefulWidget {
  const ClientUpdateRoute({super.key});

  @override
  ConsumerState<ClientUpdateRoute> createState() => _ClientUpdateRouteState();
}

class _ClientUpdateRouteState extends ConsumerState<ClientUpdateRoute> {
  bool _closing = false;
  ClientUpdatePrompt? _lastPrompt;

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrompt = ref.watch(clientUpdateProvider).prompt;
    if (currentPrompt != null) _lastPrompt = currentPrompt;
    // Keep rendering the release while the route pops, so clearing the prompt
    // does not flash an empty page during the transition.
    final prompt = currentPrompt ?? _lastPrompt;
    final download = ref.watch(clientUpdateDownloadProvider);
    final platform = ref.watch(clientPlatformProvider);

    ref.listen<ClientUpdateState>(clientUpdateProvider, (previous, next) {
      if (previous?.prompt?.release.build != next.prompt?.release.build) {
        ref.read(clientUpdateDownloadProvider.notifier).reset();
      }
      if (next.prompt == null && !_closing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _close();
        });
      }
    });

    if (prompt == null) return const SizedBox.shrink();

    final required = prompt.isRequired;
    final downloadController = ref.read(clientUpdateDownloadProvider.notifier);
    final updateController = ref.read(clientUpdateProvider.notifier);

    return ClientUpdateScreen(
      prompt: prompt,
      download: download,
      platform: platform,
      onDownload: () => unawaited(downloadController.start(prompt)),
      onRetry: () => unawaited(downloadController.retry(prompt)),
      onOpenAgain: () => unawaited(downloadController.openAgain()),
      onLater: required
          ? null
          : () {
              _close();
              downloadController.reset();
              updateController.dismiss();
            },
      onBack: required
          ? null
          : () {
              // The route has already been popped. Only clear the prompt so it
              // is not offered again on the next navigation.
              _closing = true;
              downloadController.reset();
              updateController.dismiss();
            },
      onExit: () {
        downloadController.reset();
        exitApplication();
      },
    );
  }
}
