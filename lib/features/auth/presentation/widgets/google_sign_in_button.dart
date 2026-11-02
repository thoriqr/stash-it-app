import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/google_auth_service.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
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
      setState(
        () => _message = _googleAuthMessage(
          failure,
          AppLocalizations.of(context),
        ),
      );
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(
        () => _message = _googleFailureMessage(
          failure,
          AppLocalizations.of(context),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _message = AppLocalizations.of(context).authGoogleGenericFailure,
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
      setState(
        () => _message = authRegistrationMessageFor(
          failure,
          AppLocalizations.of(context),
        ),
      );
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

  String _googleAuthMessage(
    GoogleAuthException failure,
    AppLocalizations localizations,
  ) {
    return switch (failure.failure) {
      GoogleAuthFailure.notConfigured => localizations.authGoogleNotConfigured,
      GoogleAuthFailure.unavailable => localizations.authGoogleCouldNotStart,
      GoogleAuthFailure.missingIdToken => localizations.authGoogleMissingToken,
    };
  }

  String _googleFailureMessage(
    ApiFailure failure,
    AppLocalizations localizations,
  ) {
    return switch (failure) {
      ApiFailureInvalidGoogleToken() => localizations.authGoogleInvalidToken,
      ApiFailureRegistrationIdentityMismatch() =>
        localizations.authGoogleRegistrationIdentityMismatch,
      ApiFailureAccountLinkSessionFailed() =>
        localizations.authGoogleLinkSessionFailed,
      ApiFailureAccountLinkIdentityMismatch() =>
        localizations.authGoogleLinkIdentityMismatch,
      ApiFailureAccountLinkConfirmationInvalid() =>
        localizations.authGoogleLinkConfirmationInactive,
      ApiFailureRegistrationAlreadyCompleted() =>
        localizations.authGoogleAccountExists,
      ApiFailurePinEmailDeliveryFailed() =>
        localizations.authPinEmailUnconfirmed,
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() => localizations.authGoogleUnavailable,
      ApiFailureServerFault() => localizations.authGoogleServerFault,
      ApiFailureTransport() => localizations.authGoogleTransport,
      ApiFailureUnreadableResponse() => localizations.authGoogleUnreadable,
      ApiFailureValidation() => localizations.authCheckDetailsThenTryAgain,
      _ => localizations.authGoogleGenericFailure,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          label: l10n.authContinueWithGoogle,
          variant: AppButtonVariant.secondary,
          busy: _busy,
          onPressed: (_busy || !widget.enabled) ? null : _continueWithGoogle,
        ),
      ],
    );
  }
}
