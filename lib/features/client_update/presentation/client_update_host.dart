import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/application/client_update_download_controller.dart';
import 'package:stash_it_app/features/client_update/data/client_update_providers.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/release_download.dart';

import 'client_update_dialog.dart';

/// Exits the application when a required update leaves no usable version.
void exitApplication() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
    return;
  }
  exit(0);
}

/// Presents the update prompt above every route.
///
/// Mounted once beside the app's feedback host, so a prompt is not tied to the
/// screen that happened to be open when the check finished. The overlay keeps
/// its state while routes change beneath it.
class ClientUpdateHost extends ConsumerWidget {
  const ClientUpdateHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(clientUpdateProvider).prompt;
    final download = ref.watch(clientUpdateDownloadProvider);

    // A new or cleared prompt starts a fresh download state; an old artifact
    // must never be shown against a different release.
    ref.listen<ClientUpdateState>(clientUpdateProvider, (previous, next) {
      if (previous?.prompt?.release.build != next.prompt?.release.build) {
        ref.read(clientUpdateDownloadProvider.notifier).reset();
      }
    });

    return Stack(
      children: [
        child,
        if (prompt != null)
          Positioned.fill(
            child: _ClientUpdateOverlay(prompt: prompt, download: download),
          ),
      ],
    );
  }
}

class _ClientUpdateOverlay extends ConsumerWidget {
  const _ClientUpdateOverlay({required this.prompt, required this.download});

  final ClientUpdatePrompt prompt;
  final ClientUpdateDownloadState download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateController = ref.read(clientUpdateProvider.notifier);
    final downloadController = ref.read(clientUpdateDownloadProvider.notifier);
    final platform = ref.watch(clientPlatformProvider);
    final required = prompt.isRequired;

    void dismiss() {
      downloadController.reset();
      updateController.dismiss();
    }

    void exit() {
      downloadController.reset();
      exitApplication();
    }

    return Stack(
      children: [
        ModalBarrier(
          dismissible: !required,
          onDismiss: required ? null : dismiss,
          color: Colors.black54,
        ),
        Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppMetrics.space4),
              child: ClientUpdateDialog(
                prompt: prompt,
                download: download,
                platform: platform,
                onDownload: () => unawaited(downloadController.start(prompt)),
                onRetry: () => unawaited(downloadController.retry(prompt)),
                onOpenAgain: () => unawaited(downloadController.openAgain()),
                onLater: dismiss,
                onExit: exit,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
