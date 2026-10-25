import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// The landing screen for a signed-out user.
///
/// It sits outside the four destinations (D1), like `SignInScreen`, and carries
/// the wordmark instead of an app bar. The router allows both this screen and
/// the sign-in form while signed out; everything else redirects here.
///
/// The screen owns one decision only: whether to explain an ended session. The
/// sign-in form owns the credentials. Registration and Google sign-in are not
/// implemented, so the account-creation control is deliberately disabled rather
/// than wired to a destination that does not exist.
class AuthEntryScreen extends ConsumerStatefulWidget {
  const AuthEntryScreen({super.key});

  @override
  ConsumerState<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends ConsumerState<AuthEntryScreen> {
  /// Whether the one-time explanation of an ended session is showing.
  ///
  /// Set from `SessionController.consumeSessionEnded` in `initState`, so it
  /// appears on the visit produced by the expiry and never on a later rebuild
  /// or a later visit. This is local widget state, not a second source of truth:
  /// the fact itself stays in the session controller, which clears it as it is
  /// read.
  bool _showSessionEnded = false;

  @override
  void initState() {
    super.initState();

    // A session can end while the user is somewhere else entirely: a renewal the
    // backend refuses terminally clears the credentials, the router sends them
    // here, and nothing else would say why. The reason is *consumed* rather than
    // stored, so it appears once — see `SessionController.consumeSessionEnded`.
    //
    // A deliberate sign-out does not set it: `AuthState.signOut` discards the
    // session directly rather than ending it, so asking to be signed out is never
    // reported back as an expiry. An ambiguous renewal failure does not set it
    // either, because nothing ended the session — only `_endSession` does.
    if (ref.read(sessionControllerProvider.notifier).consumeSessionEnded()) {
      _showSessionEnded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
      // The brand row replaces the app bar, as on the sign-in form: auth sits
      // outside the four destinations, so it carries the wordmark rather than a
      // screen title.
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
                    'A place for things you find on the internet.',
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space1),
                  Text(
                    'Save a link from any browser, then find it again here.',
                    style: AppTypography.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  if (_showSessionEnded) ...[
                    const SizedBox(height: AppMetrics.space4),
                    AuthMessageBand(
                      message: sessionEndedMessage,
                      // Warning, not danger: `design-system.md` §6.5 files expiry
                      // under Warning. Nothing the user did failed here — a
                      // session simply lapsed — and a danger band would read as
                      // a mistake of theirs.
                      tone: AuthMessageTone.warning,
                      onDismiss: _dismissSessionEnded,
                    ),
                  ],
                  const SizedBox(height: AppMetrics.space6),
                  AppButton(
                    label: 'Sign in',
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.go(AppRoutes.signIn),
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  // Deliberately disabled: there is no registration flow to
                  // reach, and an enabled control would promise one.
                  const AppButton(
                    label: 'Create an account',
                    variant: AppButtonVariant.secondary,
                    onPressed: null,
                  ),
                  const SizedBox(height: AppMetrics.space1),
                  Text(
                    'Account creation is coming soon.',
                    style: AppTypography.meta.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hides the explanation of an ended session.
  ///
  /// A dismissal, not a retry: there is no action to retry until the user opens
  /// the sign-in form. The flag is already consumed, so the message cannot
  /// return on a rebuild or a later visit.
  void _dismissSessionEnded() {
    setState(() => _showSessionEnded = false);
  }
}
