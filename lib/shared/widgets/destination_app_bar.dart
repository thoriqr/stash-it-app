import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_metrics.dart';

/// The app bar shared by the four primary destinations.
///
/// Each destination still owns its own `Scaffold`; the shell only owns the bottom
/// navigation. This widget gives every destination the same screen title and one
/// Settings action, without making Settings a fifth destination.
///
/// The title is written uppercase at the call site because Flutter has no
/// text-transform. Styling comes from `AppBarTheme`, so no colour or typography is
/// restated here.
class DestinationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DestinationAppBar({required this.title, super.key});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: AppMetrics.iconSize),
          tooltip: 'Settings',
          // `push`, not `go`: Settings sits above the shell, so returning pops
          // back to the same destination with its branch state intact.
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }
}
