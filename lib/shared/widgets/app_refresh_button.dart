import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// App-bar refresh action with a compact in-place loading state.
class AppRefreshButton extends StatelessWidget {
  const AppRefreshButton({
    required this.refreshing,
    required this.onPressed,
    super.key,
  });

  final bool refreshing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return IconButton(
      tooltip: l10n.refreshTooltip,
      onPressed: refreshing ? null : onPressed,
      icon: refreshing
          ? SizedBox(
              width: AppMetrics.iconSize,
              height: AppMetrics.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: tokens.accent,
              ),
            )
          : const Icon(Icons.refresh, size: AppMetrics.iconSize),
    );
  }
}
