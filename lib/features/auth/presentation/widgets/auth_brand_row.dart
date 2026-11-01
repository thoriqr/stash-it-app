import 'package:flutter/material.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';

/// Displays the brand mark and wordmark on authentication screens.
///
/// Shared by [AuthEntryScreen] and [SignInScreen] to keep their branding
/// consistent.
class AuthBrandRow extends StatelessWidget {
  const AuthBrandRow({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Row(
      children: [
        Container(
          width: AppMetrics.brandMarkSize,
          height: AppMetrics.brandMarkSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: tokens.accent,
              width: AppMetrics.borderWidthEmphasis,
            ),
            borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.accent,
                borderRadius: BorderRadius.circular(1),
              ),
              child: const SizedBox.expand(),
            ),
          ),
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
