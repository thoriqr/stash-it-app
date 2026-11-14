import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';

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

    return Stack(
      children: [
        child,
        if (prompt != null)
          Positioned.fill(child: _ClientUpdateOverlay(prompt: prompt)),
      ],
    );
  }
}

class _ClientUpdateOverlay extends ConsumerWidget {
  const _ClientUpdateOverlay({required this.prompt});

  final ClientUpdatePrompt prompt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientUpdateProvider.notifier);
    final required = prompt.isRequired;

    return Stack(
      children: [
        ModalBarrier(
          dismissible: !required,
          onDismiss: required ? null : controller.dismiss,
          color: Colors.black54,
        ),
        Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppMetrics.space4),
              child: ClientUpdateDialog(
                prompt: prompt,
                onDownload: controller.requestDownload,
                onLater: controller.dismiss,
                onExit: exitApplication,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
