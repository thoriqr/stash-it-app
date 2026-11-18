import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';

/// Opens the update screen when the release check reports a prompt.
///
/// The prompt is presented as a route instead of an overlay above the router.
/// The route owns its back behavior: a required update cannot be popped, while
/// an optional update can be closed and returns to the previous screen with
/// its navigation state intact.
class ClientUpdateHost extends ConsumerStatefulWidget {
  const ClientUpdateHost({
    required this.router,
    required this.child,
    super.key,
  });

  /// The router mounted by the application, so the prompt is pushed onto the
  /// same navigation stack that renders the app.
  final GoRouter router;

  final Widget child;

  @override
  ConsumerState<ClientUpdateHost> createState() => _ClientUpdateHostState();
}

class _ClientUpdateHostState extends ConsumerState<ClientUpdateHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openIfNeeded(ref.read(clientUpdateProvider).prompt);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ClientUpdateState>(clientUpdateProvider, (previous, next) {
      _openIfNeeded(next.prompt);
    });

    return widget.child;
  }

  void _openIfNeeded(ClientUpdatePrompt? prompt) {
    if (prompt == null) return;

    if (_currentPath == AppRoutes.clientUpdate) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentPath == AppRoutes.clientUpdate) return;
      widget.router.push(AppRoutes.clientUpdate);
    });
  }

  String get _currentPath =>
      widget.router.routerDelegate.currentConfiguration.uri.path;
}
