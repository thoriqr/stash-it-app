import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/google_auth_service.dart';
import 'package:stash_it_app/features/auth/presentation/sign_up_screen.dart'
    show registrationMessageFor;
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// The shared Google authentication entry point.
///
/// Extracted from the auth entry screen so the sign-in and sign-up forms can
/// offer the same action without restating the flow. The behaviour is unchanged:
/// the picker result branches into the existing session redirect, the account
/// link confirmation route, or the social registration PIN route, and every
/// failure keeps its client-owned copy.
///
/// The widget owns its busy state and its failure message so a caller cannot
/// diverge from that mapping. [onBusyChanged] lets the surrounding form disable
/// its own actions while the picker or a request is in flight, mirroring the
/// entry screen's former behaviour.
class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({
    this.enabled = true,
    this.onBusyChanged,
    super.key,
  });

  /// Whether the surrounding form is currently able to start this action.
  final bool enabled;

  /// Reports changes to this widget's in-flight state.
  final ValueChanged<bool>? onBusyChanged;

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  bool _busy = false;
  String? _message;

  void _setBusy(bool busy) {
    if (!mounted) return;
    setState(() => _busy = busy);
    widget.onBusyChanged?.call(busy);
  }

  void _dismissMessage() {
    setState(() => _message = null);
  }

  Future<void> _continueWithGoogle() async {
    if (_busy || !widget.enabled) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    widget.onBusyChanged?.call(true);

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
      setState(() => _message = _googleAuthMessage(failure));
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _message = _googleFailureMessage(failure));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _message = 'Google sign-in could not be completed. Try again.',
      );
    } finally {
      _setBusy(false);
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
      setState(() => _message = registrationMessageFor(failure));
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_message case final message?) ...[
          AuthMessageBand(
            message: message,
            onDismiss: _dismissMessage,
            tone: AuthMessageTone.danger,
          ),
          const SizedBox(height: AppMetrics.space4),
        ],
        AppButton(
          label: 'Continue with Google',
          variant: AppButtonVariant.secondary,
          busy: _busy,
          onPressed: (_busy || !widget.enabled) ? null : _continueWithGoogle,
        ),
      ],
    );
  }
}
