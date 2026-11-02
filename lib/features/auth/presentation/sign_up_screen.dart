import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/registration_recovery.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Starts manual account registration.
///
/// The response determines whether the user must verify an email address or can
/// continue an already-verified registration. Recovery is always an explicit
/// user action; it is never triggered by a rebuild, missing token, or error.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

/// Explains why the verified registration cannot continue yet.
enum _BlockedReason {
  /// No matching continuation is available on this device; recovery is required.
  noToken,

  /// A matching continuation exists, but its status could not be confirmed.
  /// It is retained until a later check or explicit recovery.
  savedCodeUnconfirmed,
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// Prevents overlapping registration submissions.
  bool _submitting = false;

  /// Whether Google sign-in is in progress.
  bool _googleBusy = false;

  /// Message shown when the registration attempt fails.
  String? _failureMessage;

  /// Email address awaiting PIN verification, used when no router is available.
  String? _pinSentTo;

  /// Email address shown while the verified registration needs recovery.
  String? _verifiedBlockedEmail;

  /// Reason the recovery state is displayed.
  _BlockedReason? _blockedReason;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || _googleBusy) return;

    // Validate only empty and malformed input here. The API remains authoritative
    // for email validation and normalization.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _start(_emailController.text.trim());
  }

  /// Starts registration for [email] and follows the response state.
  ///
  /// A PIN is requested only when verification is pending. An already-verified
  /// registration continues with a saved token or waits for explicit recovery.
  Future<void> _start(String email, {bool allowReplacement = true}) async {
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(registrationContinuationStoreProvider);

    setState(() {
      _submitting = true;
      _failureMessage = null;
      _pinSentTo = null;
      _verifiedBlockedEmail = null;
      _blockedReason = null;
    });

    try {
      final response = await repository.registerManual(email: email);
      if (!mounted) return;

      final stored = await _readStored(store);
      if (!mounted) return;

      final start = registrationStartFor(
        response: response,
        stored: stored,
        email: email,
      );

      switch (start) {
        case RegistrationStart.requestPin:
          // Keep any matching continuation. A pending response does not necessarily
          // invalidate it; successful verification replaces the saved token.
          await _requestPinAndContinue(
            repository,
            response.verificationId,
            email,
          );
          return;

        case RegistrationStart.openFinalize:
          await _continueToFinalize(
            repository,
            store,
            stored!,
            email,
            allowReplacement: allowReplacement,
          );
          return;

        case RegistrationStart.verifiedWithoutToken:
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _verifiedBlockedEmail = email;
            _blockedReason = _BlockedReason.noToken;
          });
          return;
      }
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      // A completed registration makes any saved continuation for this address stale.
      if (failure is ApiFailureRegistrationAlreadyCompleted) {
        await _clearMatching(store, email);
      }
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = null;
        _blockedReason = null;
        _failureMessage = authRegistrationMessageFor(
          failure,
          AppLocalizations.of(context),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = null;
        _blockedReason = null;
        _failureMessage = AppLocalizations.of(context).authSignUpGenericFailure;
      });
    }
  }

  /// Requests the first PIN and enters the verification flow.
  ///
  /// If the request is still within the resend cooldown, continue to the PIN
  /// screen because the previously issued code remains valid. The verification
  /// screen retrieves the current cooldown for its countdown.
  Future<void> _requestPinAndContinue(
    AuthRepository repository,
    String verificationId,
    String email,
  ) async {
    try {
      await repository.createPin(verificationId: verificationId);
    } on ApiFailureVerificationResendCooldown {
      // The existing PIN is still valid; continue to verification.
    }

    if (!mounted) return;

    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.signUpVerifyFor(verificationId), extra: email);
      return;
    }

    setState(() {
      _submitting = false;
      _verifiedBlockedEmail = null;
      _pinSentTo = email;
    });
  }

  /// Checks the saved continuation before opening registration finalization.
  ///
  /// A terminally invalid token can be replaced during the same user action.
  Future<void> _continueToFinalize(
    AuthRepository repository,
    RegistrationContinuationStore store,
    StoredRegistrationContinuation stored,
    String email, {
    bool allowReplacement = true,
  }) async {
    try {
      final continuation = await repository.getRegistrationContinuation(
        continuationToken: stored.token,
      );
      if (!mounted) return;

      // Never use a continuation for a different email address. Discard an
      // inconsistent record rather than guessing which address is correct.
      if (normalizeRegistrationEmail(continuation.email) !=
          normalizeRegistrationEmail(email)) {
        await _clearStored(store, stored.token);
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _verifiedBlockedEmail = email;
          _blockedReason = _BlockedReason.noToken;
          _failureMessage = AppLocalizations.of(
            context,
          ).authRegistrationMismatch;
        });
        return;
      }

      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.finalizeRegistration, extra: stored.token);
        return;
      }

      // Without a router, show the recovery state rather than implying navigation
      // to finalization succeeded.
      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = email;
        _blockedReason = _BlockedReason.noToken;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = continuationOutcomeFor(failure);

      switch (outcome) {
        case ContinuationOutcome.consumed:
          await _clearStored(store, stored.token);
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _verifiedBlockedEmail = null;
            _blockedReason = null;
            _failureMessage = AppLocalizations.of(
              context,
            ).authRegistrationAlreadyCompletedSignIn;
          });
          return;

        case ContinuationOutcome.restartRequired:
          await _clearStored(store, stored.token);
          if (!mounted) return;
          if (!allowReplacement) {
            // Do not make another replacement request after the single allowed attempt.
            setState(() {
              _submitting = false;
              _verifiedBlockedEmail = null;
              _blockedReason = null;
              _failureMessage = authRegistrationMessageFor(
                failure,
                AppLocalizations.of(context),
              );
            });
            return;
          }
          await _requestReplacement(repository, store, email);
          return;

        case ContinuationOutcome.unconfirmed:
          // Keep the token so the user can retry the check or explicitly choose recovery.
          setState(() {
            _submitting = false;
            _verifiedBlockedEmail = email;
            _blockedReason = _BlockedReason.savedCodeUnconfirmed;
            _failureMessage = _recoveryMessageFor(
              failure,
              AppLocalizations.of(context),
            );
          });
          return;
      }
    }
  }

  /// Requests one replacement registration after a saved continuation is
  /// rejected as terminally invalid.
  ///
  /// The replacement is attempted at most once. If it is still verified, the
  /// screen returns to the recovery state rather than retrying again.
  Future<void> _requestReplacement(
    AuthRepository repository,
    RegistrationContinuationStore store,
    String email,
  ) async {
    try {
      final replacement = await repository.registerManual(email: email);
      if (!mounted) return;

      if (replacement.isVerified) {
        setState(() {
          _submitting = false;
          _verifiedBlockedEmail = email;
          _blockedReason = _BlockedReason.noToken;
        });
        return;
      }

      // Keep a matching continuation because a pending response may leave it valid.
      await _requestPinAndContinue(
        repository,
        replacement.verificationId,
        email,
      );
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = null;
        _blockedReason = null;
        _failureMessage = authRegistrationMessageFor(
          failure,
          AppLocalizations.of(context),
        );
      });
    }
  }

  /// Retries the saved continuation check without restarting registration.
  ///
  /// The token remains saved until the result is terminal or the user chooses
  /// recovery explicitly.
  Future<void> _retrySavedCode() async {
    final email = _verifiedBlockedEmail;
    if (email == null || _submitting) return;

    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(registrationContinuationStoreProvider);
    final stored = await _readStored(store);
    if (!mounted) return;

    if (stored == null || stored.email != normalizeRegistrationEmail(email)) {
      // The saved continuation is unavailable or belongs to another address.
      // Offer recovery instead of treating it as usable.
      setState(() {
        _blockedReason = _BlockedReason.noToken;
        _failureMessage = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _failureMessage = null;
    });
    await _continueToFinalize(repository, store, stored, email);
  }

  /// Starts recovery only after the user explicitly chooses that action.
  Future<void> _recoverRegistration() async {
    final email = _verifiedBlockedEmail;
    if (email == null || _submitting) return;

    final reason = _blockedReason;
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(registrationContinuationStoreProvider);

    setState(() {
      _submitting = true;
      _failureMessage = null;
    });

    if (reason == _BlockedReason.savedCodeUnconfirmed) {
      // The user chose recovery instead of retrying the unconfirmed continuation.
      // Clearing is best effort; successful verification replaces the saved token.
      await _clearMatching(store, email);
      if (!mounted) return;
      // The saved code is no longer available, even if recovery later fails.
      setState(() => _blockedReason = _BlockedReason.noToken);
    }

    try {
      final recovery = await repository.initiateManualRecovery(email: email);
      if (!mounted) return;

      if (recovery.isVerified) {
        // A verified response provides no continuation token, so it cannot
        // proceed through PIN verification or registration finalization.
        setState(() {
          _submitting = false;
          _failureMessage = AppLocalizations.of(
            context,
          ).authRecoveryCouldNotStart;
        });
        return;
      }

      // Use the same PIN request handling and pass the email to the verification route.
      await _requestPinAndContinue(repository, recovery.verificationId, email);
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      if (failure is ApiFailureRegistrationAlreadyPending) {
        // Verification is already pending, so resume the normal registration flow.
        // Disable replacement to keep this fallback from starting another attempt.
        await _start(email, allowReplacement: false);
        return;
      }

      if (failure is ApiFailureRegistrationAlreadyCompleted) {
        await _clearMatching(store, email);
        if (!mounted) return;
      }

      final terminal =
          failure is ApiFailureRegistrationAlreadyCompleted ||
          failure is ApiFailureRegistrationRestartRequired ||
          failure is ApiFailureInvalidRegistrationType ||
          failure is ApiFailureValidation;

      setState(() {
        _submitting = false;
        if (terminal) {
          _verifiedBlockedEmail = null;
          _blockedReason = null;
        }
        _failureMessage = _recoveryStartMessageFor(
          failure,
          AppLocalizations.of(context),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage = AppLocalizations.of(
          context,
        ).authRecoveryGenericFailure;
      });
    }
  }

  Future<StoredRegistrationContinuation?> _readStored(
    RegistrationContinuationStore store,
  ) async {
    // If local storage cannot be read, continue without a saved continuation.
    try {
      return await store.read();
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearStored(
    RegistrationContinuationStore store,
    String token,
  ) async {
    try {
      await store.clearIfToken(token);
    } catch (_) {
      // Clearing is best effort and must not block the replacement flow.
    }
  }

  Future<void> _clearMatching(
    RegistrationContinuationStore store,
    String email,
  ) async {
    final stored = await _readStored(store);
    if (stored != null && stored.email == normalizeRegistrationEmail(email)) {
      await _clearStored(store, stored.token);
    }
  }

  String _recoveryMessageFor(
    ApiFailure failure,
    AppLocalizations localizations,
  ) {
    return switch (failure) {
      ApiFailureTransport() => localizations.authRegistrationCheckTransport,
      ApiFailureUnreadableResponse() =>
        localizations.authRegistrationCheckUnreadable,
      ApiFailureServerUnavailable() ||
      ApiFailureServerFault() => localizations.authRegistrationCheckUnavailable,
      _ => authRegistrationMessageFor(failure, localizations),
    };
  }

  String _recoveryStartMessageFor(
    ApiFailure failure,
    AppLocalizations localizations,
  ) {
    return switch (failure) {
      ApiFailureTransport() => localizations.authRecoveryTransport,
      ApiFailureUnreadableResponse() => localizations.authRecoveryUnreadable,
      ApiFailureServerUnavailable() => localizations.authRecoveryUnavailable,
      ApiFailureServerFault() => localizations.authRecoveryServerFault,
      ApiFailureValidation() => localizations.authCheckEmailThenTryAgain,
      _ => authRegistrationMessageFor(failure, localizations),
    };
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
      // Use the brand row instead of an app bar on this authentication screen.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppMetrics.screenPadding,
              ),
              child: AuthBackButton(
                onPressed: _submitting || _googleBusy
                    ? null
                    : () => context.go(AppRoutes.auth),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  // Keep the form and failure message accessible when the keyboard is open.
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
                        if (_pinSentTo case final email?)
                          _buildPinSent(tokens, email)
                        else if (_verifiedBlockedEmail case final email?)
                          _buildVerifiedBlocked(tokens, email)
                        else
                          _buildForm(tokens),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Email form shown before registration progresses.
  Widget _buildForm(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authSignUpTitle,
            style: AppTypography.screenHeading.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            l10n.authSignUpDescription,
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: l10n.authEmailLabel,
            controller: _emailController,
            enabled: !_submitting && !_googleBusy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return l10n.authEnterEmail;
              if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(email)) {
                return l10n.authInvalidEmail;
              }
              return null;
            },
          ),
          if (_failureMessage case final message?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: message,
              onDismiss: _dismissFailure,
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: l10n.authSendPin,
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _googleBusy ? null : _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          GoogleSignInButton(
            enabled: !_submitting,
            onBusyChanged: _setGoogleBusy,
          ),
          const SizedBox(height: AppMetrics.space3),
          _SignInPrompt(
            onPressed: _submitting || _googleBusy ? null : _openSignIn,
          ),
        ],
      ),
    );
  }

  /// Fallback success state shown when no router is available.
  ///
  /// It confirms only that a PIN was sent, not that an account has been created.
  Widget _buildPinSent(AppTokens tokens, String email) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authCheckYourEmail,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          l10n.authPinSentToEmail(email),
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.secondary,
          onPressed: _openSignIn,
        ),
      ],
    );
  }

  /// Recovery state for a verified registration that cannot continue on this device.
  ///
  /// A missing token requires recovery. An unconfirmed saved token can be checked
  /// again or replaced through explicit recovery. This view never starts recovery
  /// automatically.
  Widget _buildVerifiedBlocked(AppTokens tokens, String email) {
    final l10n = AppLocalizations.of(context);
    final savedCodeUnconfirmed =
        _blockedReason == _BlockedReason.savedCodeUnconfirmed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authVerificationComplete,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          savedCodeUnconfirmed
              ? l10n.authVerifiedSavedCodeUnconfirmed(email)
              : l10n.authVerifiedNoToken(email),
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        if (_failureMessage case final message?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: message,
            onDismiss: _dismissFailure,
            tone: AuthMessageTone.danger,
          ),
        ],
        const SizedBox(height: AppMetrics.space6),
        if (savedCodeUnconfirmed) ...[
          AppButton(
            label: l10n.authTryAgain,
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _retrySavedCode,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authRecoverRegistration,
            variant: AppButtonVariant.secondary,
            onPressed: _submitting ? null : _recoverRegistration,
          ),
        ] else ...[
          AppButton(
            label: l10n.authRecoverRegistration,
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _recoverRegistration,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authUseDifferentEmail,
            variant: AppButtonVariant.secondary,
            onPressed: _submitting ? null : _useDifferentEmail,
          ),
        ],
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.quiet,
          onPressed: _submitting ? null : _openSignIn,
        ),
      ],
    );
  }

  /// Returns to the email form while preserving the address for editing.
  void _useDifferentEmail() {
    setState(() {
      _verifiedBlockedEmail = null;
      _blockedReason = null;
      _failureMessage = null;
    });
  }

  /// Replaces the registration screen with the sign-in screen.
  void _openSignIn() => context.go(AppRoutes.signIn);

  /// Dismisses the failure message without retrying the request.
  void _dismissFailure() => setState(() => _failureMessage = null);

  /// Prevents registration submission while Google sign-in is in progress.
  void _setGoogleBusy(bool busy) {
    if (!mounted) return;
    setState(() {
      _googleBusy = busy;
      if (busy) _failureMessage = null;
    });
  }
}

/// Provides a route to sign-in for users who already have an account.
class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            l10n.authAlreadyHaveAccount,
            style: AppTypography.meta.copyWith(color: tokens.textSecondary),
          ),
        ),
        AppButton(
          label: l10n.authSignIn,
          variant: AppButtonVariant.quiet,
          small: true,
          block: false,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
