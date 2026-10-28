import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/google_auth_service.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/sign_up_screen.dart'
    show registrationMessageFor;
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// The landing screen for a signed-out user.
///
/// It sits outside the four destinations (D1), like `SignInScreen` and
/// `SignUpScreen`, and carries the wordmark instead of an app bar. The router
/// allows all signed-out auth screens while signed out; everything else
/// redirects here.
///
/// The screen owns the explanation of an ended session and the Google
/// authentication entry point. The sign-in form owns manual credentials, and the
/// sign-up form owns manual registration; both remain separate peer flows.
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

  bool _googleBusy = false;
  String? _googleMessage;

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

  void _dismissGoogleMessage() {
    setState(() => _googleMessage = null);
  }

  Future<void> _continueWithGoogle() async {
    if (_googleBusy) return;

    setState(() {
      _googleBusy = true;
      _googleMessage = null;
    });

    try {
      final credential = await ref.read(googleAuthServiceProvider).signIn();

      // A user cancellation is not an error and sends nothing.
      if (credential == null) return;

      final result = await ref
          .read(authStateProvider.notifier)
          .signInWithGoogle(credential.idToken);

      if (!mounted) return;

      switch (result) {
        case GoogleSignInAuthenticated():
          // AuthState has written and adopted the pair. The router's auth
          // redirect moves the user into the app; no manual navigation.
          return;

        case GoogleAccountLinkRequired():
          context.go(
            AppRoutes.googleAccountLinkFor(result.confirmationId),
            extra: GoogleAccountLinkArgs(idToken: credential.idToken),
          );
          return;

        case GoogleRegistrationRequired():
          await _openSocialPin(result.verificationId, credential);
          return;
      }
    } on GoogleAuthException catch (failure) {
      if (!mounted) return;
      setState(() => _googleMessage = _googleAuthMessage(failure));
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _googleMessage = _googleFailureMessage(failure));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _googleMessage =
            'Google sign-in could not be completed. Try again.',
      );
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  /// Requests the first PIN for a newly created social registration and enters
  /// the existing PIN route with the social marker.
  Future<void> _openSocialPin(
    String verificationId,
    GoogleAuthCredential credential,
  ) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      await repository.createPin(verificationId: verificationId);
    } on ApiFailureVerificationResendCooldown {
      // A code was already issued for this verification. The PIN screen reads
      // the authoritative cooldown; entering it is the correct continuation.
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _googleMessage = registrationMessageFor(failure));
      return;
    }

    if (!mounted) return;

    context.go(
      AppRoutes.signUpVerifyFor(verificationId),
      extra: SocialRegistrationVerification(
        email: credential.email,
        displayName: credential.displayName,
      ),
    );
  }

  String _googleAuthMessage(GoogleAuthException failure) {
    return switch (failure.failure) {
      GoogleAuthFailure.notConfigured =>
        'Google sign-in is not configured for this build.',
      GoogleAuthFailure.unavailable =>
        'Google sign-in could not start. Try again.',
      GoogleAuthFailure.missingIdToken =>
        'Google did not return a sign-in token. Try again.',
    };
  }

  String _googleFailureMessage(ApiFailure failure) {
    return switch (failure) {
      ApiFailureInvalidGoogleToken() =>
        'Google could not verify that sign-in. Try again.',
      ApiFailureRegistrationIdentityMismatch() =>
        'A registration for this email is already in progress under a '
            'different account. Try again after it expires.',
      ApiFailureAccountLinkSessionFailed() =>
        'Your accounts were linked, but sign-in did not finish. Continue with '
            'Google again.',
      ApiFailureAccountLinkIdentityMismatch() =>
        'That Google account does not match the account being linked.',
      ApiFailureAccountLinkConfirmationInvalid() =>
        'This account-link request is no longer active. Start again.',
      ApiFailureRegistrationAlreadyCompleted() =>
        'This account already exists. Continue with Google or sign in.',
      ApiFailurePinEmailDeliveryFailed() =>
        'We could not confirm the PIN email was sent. Check your inbox before '
            'trying again.',
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Google sign-in is temporarily unavailable. Try again shortly.',
      ApiFailureServerFault() =>
        'We could not start Google sign-in. Try again shortly.',
      ApiFailureTransport() =>
        'No connection to the server. We could not start Google sign-in.',
      ApiFailureUnreadableResponse() =>
        'We could not read the server\'s reply, so we could not start Google '
            'sign-in. Try again.',
      ApiFailureValidation() => 'Check your details, then try again.',
      _ => 'Google sign-in could not be completed. Try again.',
    };
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
                  if (_googleMessage case final message?) ...[
                    const SizedBox(height: AppMetrics.space4),
                    AuthMessageBand(
                      message: message,
                      onDismiss: _dismissGoogleMessage,
                      tone: AuthMessageTone.danger,
                    ),
                  ],
                  const SizedBox(height: AppMetrics.space6),
                  AppButton(
                    label: 'Continue with Google',
                    variant: AppButtonVariant.secondary,
                    busy: _googleBusy,
                    onPressed: _googleBusy ? null : _continueWithGoogle,
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  AppButton(
                    label: 'Sign in',
                    variant: AppButtonVariant.primary,
                    onPressed: _googleBusy
                        ? null
                        : () => context.go(AppRoutes.signIn),
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  AppButton(
                    label: 'Create an account',
                    variant: AppButtonVariant.secondary,
                    onPressed: _googleBusy
                        ? null
                        : () => context.go(AppRoutes.signUp),
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
