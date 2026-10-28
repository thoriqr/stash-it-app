import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/password_reset_recovery.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Starts, resumes, or explains a password reset.
///
/// Entry point from Sign In. It has four jobs:
///
/// - If this device holds a saved continuation, offer to continue that reset
///   instead of starting a second one. The token is validated only when the user
///   chooses to continue.
/// - Otherwise, submit the email and — after the status read — request the first
///   PIN or go straight to the PIN screen when one was already issued.
/// - Distinguish a verification that is already complete from one that is merely
///   pending. A complete verification cannot issue another PIN; the user must
///   wait for the reset to expire or continue a saved token.
/// - Preserve the backend's non-enumerating response. An address with no account
///   yields a placeholder id, so a `RESOURCE_NOT_FOUND` is answered with neutral
///   copy rather than "no account".
class PasswordResetRequestScreen extends ConsumerStatefulWidget {
  const PasswordResetRequestScreen({
    super.key,
    this.startWithEmailForm = false,
  });

  /// Opens directly on the email form even when a continuation is stored.
  ///
  /// Set by the finalization screen's **Use a different email** action. It is a
  /// launch mode, not a token: the stored continuation is read from secure
  /// storage and retained.
  final bool startWithEmailForm;

  @override
  ConsumerState<PasswordResetRequestScreen> createState() =>
      _PasswordResetRequestScreenState();
}

enum _RequestMode {
  loading,
  form,
  continueReset,
  waitingForExpiry,
  neutral,
  pinSent,
}

class _PasswordResetRequestScreenState
    extends ConsumerState<PasswordResetRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  _RequestMode _mode = _RequestMode.loading;
  StoredPasswordResetContinuation? _stored;

  bool _checkingStored = false;
  bool _submitting = false;
  String? _failureMessage;

  /// A neutral explanation shown when the email form is submitted with the
  /// saved continuation's own address. It replaces the default Continue body;
  /// it is not a failure and is never rendered through the danger band.
  String? _savedResetNotice;

  /// The address the user submitted, kept for the bounded retry and the states
  /// that are reached after the form has been replaced.
  String? _submittedEmail;

  @override
  void initState() {
    super.initState();
    _readStored();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _readStored() async {
    try {
      final stored = await ref
          .read(passwordResetContinuationStoreProvider)
          .read();
      if (!mounted) return;
      setState(() {
        _stored = stored;
        _mode = stored == null || widget.startWithEmailForm
            ? _RequestMode.form
            : _RequestMode.continueReset;
      });
    } catch (_) {
      if (!mounted) return;
      // The token is not discarded: a later visit can read it again. The form is
      // safe because a new request never clears the saved record.
      setState(() {
        _mode = _RequestMode.form;
        _failureMessage =
            'We could not check for a saved password reset. You can request a '
            'new one.';
      });
    }
  }

  Future<void> _continueStored() async {
    final stored = _stored;
    if (stored == null || _checkingStored) return;

    final repository = ref.read(authRepositoryProvider);
    setState(() {
      _checkingStored = true;
      _failureMessage = null;
    });

    try {
      await repository.getPasswordResetContinuation(
        continuationToken: stored.token,
      );
      if (!mounted) return;

      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.forgotPasswordFinalize);
        return;
      }

      setState(() => _checkingStored = false);
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = passwordResetContinuationOutcomeFor(failure);

      switch (outcome) {
        case PasswordResetContinuationOutcome.consumed:
          await _clearStored(stored.token);
          if (!mounted) return;
          setState(() {
            _checkingStored = false;
            _stored = null;
            _mode = _RequestMode.form;
            _savedResetNotice = null;
            _failureMessage =
                'This password reset was already completed. Sign in with your '
                'new password, or request a new reset.';
          });
          return;

        case PasswordResetContinuationOutcome.restartRequired:
          await _clearStored(stored.token);
          if (!mounted) return;
          setState(() {
            _checkingStored = false;
            _stored = null;
            _mode = _RequestMode.form;
            _savedResetNotice = null;
            _failureMessage =
                'Your previous password reset is no longer active. Request a '
                'new one.';
          });
          return;

        case PasswordResetContinuationOutcome.unconfirmed:
          setState(() {
            _checkingStored = false;
            _failureMessage = _continuationCheckMessageFor(failure);
          });
          return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _checkingStored = false;
        _failureMessage =
            'We could not check your saved password reset. Try again.';
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final stored = _stored;

    // The form was reached from the stored continuation's switch, or from
    // finalization. Entering the same address again must not open a redundant
    // server reset: the saved reset is the only actionable flow while the
    // server still considers it active. No request and no validation happen
    // here; the user must tap Continue explicitly.
    if (stored != null && normalizePasswordResetEmail(email) == stored.email) {
      setState(() {
        _mode = _RequestMode.continueReset;
        _savedResetNotice = _savedResetMessage(stored.email);
        _failureMessage = null;
      });
      return;
    }

    await _start(email);
  }

  Future<void> _retryWaiting() async {
    final email = _submittedEmail;
    if (email == null || _submitting) return;
    await _start(email);
  }

  /// One bounded request action: reset request, status, then at most one PIN
  /// issuance. A retry is always a new user tap.
  Future<void> _start(String email) async {
    final repository = ref.read(authRepositoryProvider);

    setState(() {
      _submitting = true;
      _failureMessage = null;
      _savedResetNotice = null;
      _submittedEmail = email;
    });

    try {
      final verificationId = await repository.requestPasswordReset(
        email: email,
      );
      if (!mounted) return;

      // The status is the intended first validation step. It distinguishes a
      // pending reset, an already-verified one, and a placeholder/unknown id
      // without spending a PIN issuance call.
      final status = await repository.getPasswordResetVerification(
        verificationId: verificationId,
      );
      if (!mounted) return;

      if (status.status != 'pending') {
        // The body is only returned for pending; treat anything else as the
        // terminal verification state rather than requesting a PIN.
        setState(() {
          _submitting = false;
          _mode = _RequestMode.waitingForExpiry;
        });
        return;
      }

      // A previously issued code is not re-requested: the PIN screen can show
      // its status and the user can resend after the server cooldown.
      if (!status.pinIssued) {
        try {
          await repository.createPasswordResetPin(
            verificationId: verificationId,
          );
        } on ApiFailureVerificationResendCooldown {
          // A code was issued between the status read and this call. The PIN
          // screen reports the real remaining cooldown.
        }
      }

      if (!mounted) return;

      if (GoRouter.maybeOf(context) != null) {
        context.go(
          AppRoutes.forgotPasswordVerifyFor(verificationId),
          extra: email,
        );
        return;
      }

      setState(() {
        _submitting = false;
        _mode = _RequestMode.pinSent;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      await _handleStartFailure(failure);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage =
            'Something went wrong starting the password reset. Try again.';
      });
    }
  }

  Future<void> _handleStartFailure(ApiFailure failure) async {
    // In this flow the shared registration-restart variant is produced only by
    // `VERIFICATION_NOT_PENDING`: the reset endpoint never returns the
    // registration lifecycle codes. The PIN step is already complete, so another
    // issuance call is not a valid recovery.
    if (failure is ApiFailureRegistrationRestartRequired) {
      var stored = _stored;

      // Defensive path for a store read that failed when this screen opened, or
      // for a record written while it stayed mounted. The normal same-email case
      // is caught before the request in `_submit`; this single read only runs
      // after the backend says the verification is already complete and no
      // record is loaded.
      if (stored == null) {
        try {
          stored = await ref
              .read(passwordResetContinuationStoreProvider)
              .read();
        } catch (_) {
          stored = null;
        }
        if (!mounted) return;
      }

      final submitted = _submittedEmail;
      final saved = stored;

      if (saved != null &&
          submitted != null &&
          normalizePasswordResetEmail(submitted) == saved.email) {
        setState(() {
          _submitting = false;
          _stored = saved;
          _mode = _RequestMode.continueReset;
          _savedResetNotice = _savedResetMessage(saved.email);
          _failureMessage = null;
        });
        return;
      }

      setState(() {
        _submitting = false;
        _mode = _RequestMode.waitingForExpiry;
      });
      return;
    }

    if (failure is ApiFailurePasswordResetNotPending ||
        failure is ApiFailurePasswordResetExpired) {
      setState(() {
        _submitting = false;
        _mode = _RequestMode.form;
        _failureMessage =
            'This password reset is no longer active. Request a new one.';
      });
      return;
    }

    // An unknown address is answered with a placeholder id whose status does not
    // resolve. The UI must not turn that into an account-existence signal.
    if (failure is ApiFailureNotFound) {
      setState(() {
        _submitting = false;
        _mode = _RequestMode.neutral;
      });
      return;
    }

    if (failure is ApiFailurePasswordResetAlreadyPending) {
      setState(() {
        _submitting = false;
        _failureMessage =
            'A password reset is already in progress. Try again shortly.';
      });
      return;
    }

    setState(() {
      _submitting = false;
      _failureMessage = _startMessageFor(failure);
    });
  }

  Future<void> _clearStored(String token) async {
    try {
      await ref
          .read(passwordResetContinuationStoreProvider)
          .clearIfToken(token);
    } catch (_) {
      // Best effort; the stale record will be rejected by the next check.
    }
  }

  String _startMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Password reset is temporarily unavailable. Try again shortly.',
      ApiFailureServerFault() =>
        'We could not start the password reset. Try again shortly.',
      ApiFailureTransport() =>
        'No connection to the server. We could not start the password reset.',
      ApiFailureUnreadableResponse() =>
        'We could not read the server\'s reply, so we could not start the '
            'password reset. Try again.',
      ApiFailurePinEmailDeliveryFailed() =>
        'We could not confirm the PIN email was sent. Check your inbox before '
            'trying again.',
      ApiFailureValidation() => 'Check your email address, then try again.',
      _ => 'We could not start the password reset. Try again.',
    };
  }

  String _continuationCheckMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureTransport() =>
        'No connection to the server. We could not check your saved password '
            'reset. Try again.',
      ApiFailureUnreadableResponse() =>
        'We could not confirm whether your saved password reset is still '
            'active. Try again.',
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Password reset is temporarily unavailable. Try again shortly.',
      ApiFailureServerFault() =>
        'We could not check your saved password reset. Try again shortly.',
      _ => 'We could not check your saved password reset. Try again.',
    };
  }

  String _savedResetMessage(String email) =>
      'A saved password reset for $email is available on this device. '
      'Continue it, or use a different email.';

  void _openSignIn() => context.go(AppRoutes.signIn);

  void _useDifferentEmail() {
    setState(() {
      _mode = _RequestMode.form;
      _failureMessage = null;
      _savedResetNotice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
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
                  switch (_mode) {
                    _RequestMode.loading => _buildLoading(tokens),
                    _RequestMode.form => _buildForm(tokens),
                    _RequestMode.continueReset => _buildContinue(tokens),
                    _RequestMode.waitingForExpiry => _buildWaiting(tokens),
                    _RequestMode.neutral => _buildNeutral(tokens),
                    _RequestMode.pinSent => _buildPinSent(tokens),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(AppTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reset your password',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space6),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildForm(AppTokens tokens) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset your password',
            style: AppTypography.screenHeading.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            'Enter your email address. If an account exists, we will send a '
            'PIN to confirm it.',
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: 'Email',
            controller: _emailController,
            enabled: !_submitting,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Enter your email address.';
              if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address.';
              }
              if (email.length > 255) {
                return 'That email address is too long.';
              }
              return null;
            },
          ),
          if (_failureMessage case final message?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: message,
              onDismiss: () => setState(() => _failureMessage = null),
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: 'Send reset PIN',
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: 'Back to sign in',
            variant: AppButtonVariant.quiet,
            onPressed: _submitting ? null : _openSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildContinue(AppTokens tokens) {
    final stored = _stored!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Continue password reset',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          _savedResetNotice ??
              'A password reset is in progress for ${stored.email}.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        if (_failureMessage case final message?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: message,
            onDismiss: () => setState(() => _failureMessage = null),
            tone: AuthMessageTone.danger,
          ),
        ],
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Continue',
          variant: AppButtonVariant.primary,
          busy: _checkingStored,
          onPressed: _checkingStored ? null : _continueStored,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Use a different email',
          variant: AppButtonVariant.secondary,
          onPressed: _checkingStored ? null : _useDifferentEmail,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.quiet,
          onPressed: _checkingStored ? null : _openSignIn,
        ),
      ],
    );
  }

  Widget _buildWaiting(AppTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reset already verified',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'This password reset was already verified, but this device does not '
          'have a usable saved reset for this email. Requesting another PIN is '
          'not possible. The reset expires within 15 minutes; after that you can '
          'request a new one.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        if (_failureMessage case final message?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: message,
            onDismiss: () => setState(() => _failureMessage = null),
            tone: AuthMessageTone.danger,
          ),
        ],
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Try again',
          variant: AppButtonVariant.primary,
          busy: _submitting,
          onPressed: _submitting ? null : _retryWaiting,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.quiet,
          onPressed: _submitting ? null : _openSignIn,
        ),
      ],
    );
  }

  Widget _buildNeutral(AppTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Check your email',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'If an account exists for that address, we have sent a password '
          'reset PIN.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Use a different email',
          variant: AppButtonVariant.secondary,
          onPressed: _useDifferentEmail,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.quiet,
          onPressed: _openSignIn,
        ),
      ],
    );
  }

  Widget _buildPinSent(AppTokens tokens) {
    final email = _submittedEmail ?? _emailController.text.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Check your email',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'We sent a password reset PIN to $email.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.secondary,
          onPressed: _openSignIn,
        ),
      ],
    );
  }
}
