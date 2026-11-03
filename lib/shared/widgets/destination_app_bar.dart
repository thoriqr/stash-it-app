import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_metrics.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Shared app bar for the four primary destinations.
///
/// Each destination owns its own `Scaffold`, while the shell manages bottom
/// navigation. This widget provides a consistent title and a Settings action
/// without adding Settings as another primary destination.
///
/// Titles are passed in uppercase because Flutter does not support
/// `text-transform`. Visual styling is inherited from `AppBarTheme`.
class DestinationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DestinationAppBar({
    required this.title,
    this.actions = const [],
    super.key,
  });

  final String title;

  /// Optional destination-specific actions shown before Settings.
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      title: Text(title),
      actions: [
        ...actions,
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: AppMetrics.iconSize),
          tooltip: l10n.settingsTooltip,
          // Push Settings above the shell so popping it returns to the same
          // destination without resetting its branch state.
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }
}
