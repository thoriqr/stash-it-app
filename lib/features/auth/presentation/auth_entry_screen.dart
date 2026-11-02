import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/presentation/widgets/pending_urls_entry.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// The landing screen for signed-out users.
///
/// Displays the app branding and entry points for sign-in and registration.
/// The explanation of an ended session is also shown here, while each
/// authentication form handles its own sign-in or registration flow.
class AuthEntryScreen extends ConsumerStatefulWidget {
  const AuthEntryScreen({super.key});

  @override
  ConsumerState<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends ConsumerState<AuthEntryScreen> {
  /// Whether the one-time explanation of an ended session is visible.
  ///
  /// Initialized by consuming the session-ended notice. The notice is consumed
  /// once, so it does not reappear on subsequent rebuilds or visits.
  bool _showSessionEnded = false;

  @override
  void initState() {
    super.initState();

    // A session may end while the user is on another screen. When they return
    // here, show the reason once so the redirect does not appear unexplained.
    //
    // A deliberate sign-out does not show this notice. An uncertain renewal
    // failure does not show it either, because neither means the session has
    // definitively ended.
    if (ref.read(sessionControllerProvider.notifier).consumeSessionEnded()) {
      _showSessionEnded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final pendingCount = ref.watch(pendingUrlCountProvider);

    return Scaffold(
      // Authentication screens use the brand row instead of an app bar.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMetrics.screenPadding,
              vertical: AppMetrics.space6,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthBrandRow(),
                  const SizedBox(height: AppMetrics.space5),
                  Text(
                    l10n.authEntryHeadline,
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space1),
                  Text(
                    l10n.authEntryDescription,
                    style: AppTypography.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  if (_showSessionEnded) ...[
                    const SizedBox(height: AppMetrics.space4),
                    AuthMessageBand(
                      message: l10n.sessionEnded,
                      // A session expiry is a warning, not a user-caused failure.
                      tone: AuthMessageTone.warning,
                      onDismiss: _dismissSessionEnded,
                    ),
                  ],
                  const SizedBox(height: AppMetrics.space6),
                  AppButton(
                    label: l10n.authSignIn,
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.go(AppRoutes.signIn),
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  AppButton(
                    label: l10n.authCreateAnAccount,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.go(AppRoutes.signUp),
                  ),
                  if (pendingCount > 0) ...[
                    const SizedBox(height: AppMetrics.space4),
                    PendingUrlsEntry(
                      count: pendingCount,
                      onTap: () => context.push(AppRoutes.savedOnDevice),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hides the session-ended explanation.
  ///
  /// Dismissing the notice does not retry anything. The notice has already
  /// been consumed and will not return on a rebuild or later visit.
  void _dismissSessionEnded() {
    setState(() => _showSessionEnded = false);
  }
}
