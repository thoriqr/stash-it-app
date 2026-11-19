import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/application/client_update_download_controller.dart';
import 'package:stash_it_app/features/client_update/data/client_update_providers.dart';
import 'package:stash_it_app/features/client_update/presentation/client_update_screen.dart';

/// Presents the update screen above every route.
///
/// A full-screen widget in the app builder, not a route or a dialog. The
/// update surface therefore cannot be covered, duplicated or popped by the
/// router while the user signs in or opens Settings. The app's back observer
/// ([WidgetsBindingObserver.didPopRoute]) consumes the system back while this
/// overlay is visible.
///
/// The overlay owns a local [Overlay] because it sits above the app's
/// Navigator. Overlay-dependent widgets in the screen, such as the close
/// button's tooltip and the selectable release notes, need one; without it
/// Flutter replaces the affected header subtree with the app's error widget.
class ClientUpdateHost extends ConsumerWidget {
  const ClientUpdateHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(clientUpdateProvider).prompt;

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
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  opaque: true,
                  builder: (_) => const _ClientUpdateOverlay(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ClientUpdateOverlay extends ConsumerWidget {
  const _ClientUpdateOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(clientUpdateProvider).prompt;
    if (prompt == null) return const SizedBox.shrink();

    final download = ref.watch(clientUpdateDownloadProvider);
    final platform = ref.watch(clientPlatformProvider);
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
