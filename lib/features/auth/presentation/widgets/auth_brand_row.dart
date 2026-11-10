import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// Displays the approved Stash It icon and wordmark on authentication screens.
///
/// Shared by every Authentication screen to keep their branding consistent.
class AuthBrandRow extends StatelessWidget {
  const AuthBrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Row(
      children: [
        Image.asset(
          'assets/branding/derived/stash-it-icon-final.png',
          width: AppMetrics.brandMarkSize,
          height: AppMetrics.brandMarkSize,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        const SizedBox(width: AppMetrics.space2),
        // Written uppercase at the call site: Flutter has no text-transform.
        Text(
          'STASH-IT',
          style: AppTypography.wordmark.copyWith(
            fontSize: 12,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
  }
}
