import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/models/verification_status_response.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// PIN entry and verification for a password reset.
///
/// Mirrors the registration verification screen's lifecycle (status, cooldown,
/// resend, verify, duplicate guards) but uses the password-reset endpoints and
/// persists the returned continuation token in its own secure store. On success
/// it navigates to the password form without putting the token in the location.
class PasswordResetPinScreen extends ConsumerStatefulWidget {
  const PasswordResetPinScreen({
    super.key,
    required this.verificationId,
    this.email,
  });

  final String verificationId;

  /// The address carried from the request screen. Used to scope the continuation
  /// record. A direct entry can still verify; the email is then recovered from
  /// the continuation endpoint before persisting.
  final String? email;

  @override
  ConsumerState<PasswordResetPinScreen> createState() =>
      _PasswordResetPinScreenState();
}

enum _PinTerminal { alreadyVerified, inactive, unavailable, storageFailure }

class _PasswordResetPinScreenState extends ConsumerState<PasswordResetPinScreen>
    with WidgetsBindingObserver {
  VerificationStatusResponse? _status;
  ApiFailure? _loadFailure;
  _PinTerminal? _terminal;

  bool _loading = true;
  bool _statusInFlight = false;
  bool _resending = false;
  ApiFailure? _resendFailure;

  bool _verifying = false;
  ApiFailure? _verifyFailure;
  String? _localVerifyFailure;

  /// Set once the user has confirmed that a successful verification for another
  /// email may replace the saved record. A retry after a wrong PIN does not ask
  /// again; leaving and re-entering the screen does.
  bool _replacementConfirmed = false;

  /// Guards the pre-verification store read and disclosure.
  ///
  /// `_verifying` is set only after the user confirms, so the busy spinner does
  /// not animate behind the modal dialog while the user decides. This guard
  /// still prevents a double tap from opening two reads or two dialogs.
  bool _verifyGuard = false;

  int _remainingSeconds = 0;
  Timer? _timer;

  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_loading &&
        !_resending &&
        !_verifying) {
      _loadStatus();
    }
  }

  Future<void> _loadStatus() async {
    if (_statusInFlight || _verifying) return;
    _statusInFlight = true;
    setState(() {
      _loading = true;
      _loadFailure = null;
    });

    try {
      final status = await ref
          .read(authRepositoryProvider)
          .getPasswordResetVerification(verificationId: widget.verificationId);
      if (!mounted) return;

      if (status.status != 'pending') {
        setState(() {
          _loading = false;
          _status = null;
          _terminal = status.status == 'verified'
              ? _PinTerminal.alreadyVerified
              : _PinTerminal.inactive;
        });
        return;
      }

      setState(() {
        _status = status;
        if (status.resendInSeconds > _remainingSeconds) {
          _remainingSeconds = status.resendInSeconds;
        }
        _loading = false;
      });
      _startCountdown();
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      // In this flow the shared registration-restart variant is produced only by
      // VERIFICATION_NOT_PENDING: the reset endpoints never return registration
      // codes. It means the PIN step is already complete.
      if (failure is ApiFailureRegistrationRestartRequired) {
        setState(() {
          _loading = false;
          _status = null;
          _terminal = _PinTerminal.alreadyVerified;
        });
        return;
      }
      if (failure is ApiFailurePasswordResetNotPending ||
          failure is ApiFailurePasswordResetExpired) {
        setState(() {
          _loading = false;
          _status = null;
          _terminal = _PinTerminal.inactive;
        });
        return;
      }
      if (failure is ApiFailureNotFound) {
        setState(() {
          _loading = false;
          _status = null;
          _terminal = _PinTerminal.unavailable;
        });
        return;
      }

      setState(() {
        _loadFailure = failure;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailure = const ApiFailureTransport();
        _loading = false;
      });
    } finally {
      _statusInFlight = false;
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resend() async {
    if (_resending) return;
    if (_status == null || _status!.status != 'pending') return;
    if (_remainingSeconds > 0) return;

    setState(() {
      _resending = true;
      _resendFailure = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .resendPasswordResetPin(verificationId: widget.verificationId);
      if (!mounted) return;

      ref
          .read(feedbackProvider.notifier)
          .show(
            AppFeedback.localized(
              tone: FeedbackTone.success,
              message: (localizations) => localizations.newPinSent,
            ),
          );
      await _loadStatus();
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _resendFailure = failure);

      if (failure is ApiFailurePinEmailDeliveryFailed) {
        final retryAfter = failure.retryAfter?.inSeconds ?? 0;
        if (retryAfter > _remainingSeconds) {
          setState(() => _remainingSeconds = retryAfter);
          _startCountdown();
        }
        await _loadStatus();
      } else if (failure is ApiFailureVerificationResendCooldown ||
          failure is ApiFailureRegistrationRestartRequired ||
          failure is ApiFailurePasswordResetNotPending ||
          failure is ApiFailurePasswordResetExpired ||
          failure is ApiFailureNotFound) {
        await _loadStatus();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _resendFailure = const ApiFailureTransport());
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _verifyPin() async {
    if (_verifyGuard || _verifying) return;

    final pin = _pinController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() => _verifyFailure = const ApiFailureValidation([]));
      return;
    }

    _verifyGuard = true;
    setState(() {
      _verifyFailure = null;
      _localVerifyFailure = null;
    });

    try {
      final store = ref.read(passwordResetContinuationStoreProvider);
      StoredPasswordResetContinuation? saved;

      try {
        saved = await store.read();
      } catch (_) {
        if (!mounted) return;
        // Do not verify when the saved record cannot be inspected: a successful
        // verification would otherwise replace a record without the required
        // disclosure.
        setState(() {
          _localVerifyFailure = AppLocalizations.of(
            context,
          ).authResetSavedCheckLocalFailure;
        });
        return;
      }

      if (!mounted) return;

      if (saved != null &&
          !_replacementConfirmed &&
          _requiresReplacementDisclosure(saved)) {
        final l10n = AppLocalizations.of(context);
        final confirmed = await showAppConfirmDialog(
          context: context,
          title: l10n.authReplaceSavedResetTitle,
          message: _replacementMessage(saved.email, l10n),
          cancelLabel: l10n.authKeepSavedReset,
          confirmLabel: l10n.authReplaceAndVerify,
          destructive: true,
        );
        if (!mounted) return;

        if (confirmed != true) {
          // No verification was sent, so both the saved reset and this pending
          // verification remain usable.
          return;
        }

        _replacementConfirmed = true;
      }

      if (!mounted) return;
      setState(() => _verifying = true);

      final repository = ref.read(authRepositoryProvider);

      try {
        final token = await repository.verifyPasswordReset(
          verificationId: widget.verificationId,
          pin: pin,
        );
        if (!mounted) return;

        // The raw token is returned once and is the only capability that can
        // finish the reset. Recover the address for the record if a direct entry
        // did not carry one.
        var email = widget.email;
        if (email == null) {
          try {
            final continuation = await repository.getPasswordResetContinuation(
              continuationToken: token,
            );
            email = continuation.email;
          } catch (_) {
            if (!mounted) return;
            setState(() {
              _verifying = false;
              _terminal = _PinTerminal.storageFailure;
            });
            return;
          }
        }

        try {
          await store.write(email: email, token: token);
        } catch (_) {
          if (!mounted) return;
          // The password form reads the token back from secure storage, so it
          // cannot continue without this write. Do not claim success or
          // navigate.
          setState(() {
            _verifying = false;
            _terminal = _PinTerminal.storageFailure;
          });
          return;
        }

        if (!mounted) return;

        if (GoRouter.maybeOf(context) != null) {
          context.go(AppRoutes.forgotPasswordFinalize);
          return;
        }

        setState(() => _verifying = false);
      } on ApiFailure catch (failure) {
        if (!mounted) return;

        if (failure is ApiFailureRegistrationRestartRequired) {
          setState(() {
            _verifying = false;
            _terminal = _PinTerminal.alreadyVerified;
          });
          return;
        }
        if (failure is ApiFailurePasswordResetNotPending ||
            failure is ApiFailurePasswordResetExpired) {
          setState(() {
            _verifying = false;
            _terminal = _PinTerminal.inactive;
          });
          return;
        }
        if (failure is ApiFailureNotFound) {
          setState(() {
            _verifying = false;
            _terminal = _PinTerminal.unavailable;
          });
          return;
        }

        setState(() {
          _verifying = false;
          _verifyFailure = failure;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _verifying = false;
          _verifyFailure = const ApiFailureTransport();
        });
      }
    } finally {
      _verifyGuard = false;
    }
  }

  void _openSignIn() => context.go(AppRoutes.signIn);

  void _openResetStart() => context.go(AppRoutes.forgotPassword);

  /// A stored record for the same address is the normal replacement of that
  /// reset's own token, not a different account losing its saved reset.
  bool _requiresReplacementDisclosure(StoredPasswordResetContinuation saved) {
    final incoming = widget.email;
    if (incoming == null) return true;

    return normalizePasswordResetEmail(incoming) != saved.email;
  }

  String _replacementMessage(
    String savedEmail,
    AppLocalizations localizations,
  ) {
    final incoming = widget.email;
    return incoming == null
        ? localizations.authResetReplacementUnknownIncoming(savedEmail)
        : localizations.authResetReplacementKnownIncoming(incoming, savedEmail);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final terminal = _terminal;

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
                  if (_loading && _status == null && terminal == null)
                    _buildLoading(tokens)
                  else if (terminal != null)
                    _buildTerminal(tokens, terminal)
                  else if (_loadFailure != null && _status == null)
                    _buildLoadError(tokens)
                  else
                    _buildContent(tokens),
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
          AppLocalizations.of(context).authCheckYourEmail,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space6),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildTerminal(AppTokens tokens, _PinTerminal terminal) {
    final l10n = AppLocalizations.of(context);
    final copy = switch (terminal) {
      _PinTerminal.alreadyVerified => (
        title: l10n.authResetAlreadyVerifiedTitle,
        body: l10n.authResetAlreadyVerifiedBody,
      ),
      _PinTerminal.inactive => (
        title: l10n.authResetNoLongerActiveTitle,
        body: l10n.authResetNoLongerActiveBody,
      ),
      _PinTerminal.unavailable => (
        title: l10n.authResetNotAvailableTitle,
        body: l10n.authResetNotAvailableBody,
      ),
      _PinTerminal.storageFailure => (
        title: l10n.authResetVerifiedNotSavedTitle,
        body: l10n.authResetVerifiedNotSavedBody,
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          copy.title,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          copy.body,
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: l10n.authBackToPasswordReset,
          variant: AppButtonVariant.primary,
          onPressed: _openResetStart,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.quiet,
          onPressed: _openSignIn,
        ),
      ],
    );
  }

  Widget _buildLoadError(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final failure = _loadFailure!;
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
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: _loadMessageFor(failure, l10n),
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: l10n.authRetry,
          variant: AppButtonVariant.primary,
          onPressed: _loadStatus,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authBackToPasswordReset,
          variant: AppButtonVariant.secondary,
          onPressed: _openResetStart,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.quiet,
          onPressed: _openSignIn,
        ),
      ],
    );
  }

  Widget _buildContent(AppTokens tokens) {
    final status = _status!;
    if (status.status != 'pending') {
      return _buildTerminal(
        tokens,
        status.status == 'verified'
            ? _PinTerminal.alreadyVerified
            : _PinTerminal.inactive,
      );
    }
    return _buildPending(tokens, status);
  }

  Widget _buildPending(AppTokens tokens, VerificationStatusResponse status) {
    final l10n = AppLocalizations.of(context);
    final resendEnabled =
        !_verifying &&
        !_resending &&
        _remainingSeconds == 0 &&
        status.status == 'pending';

    final email = widget.email;
    final sentCopy = status.pinIssued
        ? (email == null
              ? l10n.authResetPinSentGenericIssued
              : l10n.authResetPinSentToEmailIssued(email))
        : (email == null
              ? l10n.authResetPinSentGeneric
              : l10n.authResetPinSentToEmail(email));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authEnterYourPin,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          sentCopy,
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppField(
          label: l10n.authPinLabel,
          controller: _pinController,
          enabled: !_verifying && !_resending,
          keyboardType: TextInputType.number,
        ),
        if (_localVerifyFailure case final message?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: message,
            onDismiss: () => setState(() => _localVerifyFailure = null),
            tone: AuthMessageTone.danger,
          ),
        ],
        if (_verifyFailure case final failure?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: _verifyMessageFor(failure, l10n),
            onDismiss: () => setState(() => _verifyFailure = null),
            tone: AuthMessageTone.danger,
          ),
        ],
        if (_resendFailure case final failure?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: _resendMessageFor(failure, l10n),
            onDismiss: () => setState(() => _resendFailure = null),
            tone: AuthMessageTone.danger,
          ),
        ],
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: l10n.authVerifyPin,
          variant: AppButtonVariant.primary,
          busy: _verifying,
          onPressed: _verifying ? null : _verifyPin,
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: _resending
              ? l10n.authSending
              : (_remainingSeconds > 0
                    ? l10n.authResendPinIn(_remainingSeconds)
                    : l10n.authResendPin),
          variant: AppButtonVariant.secondary,
          busy: _resending,
          onPressed: resendEnabled ? _resend : null,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.quiet,
          onPressed: _verifying ? null : _openSignIn,
        ),
      ],
    );
  }

  String _loadMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureTransport() => localizations.authResetLoadTransport,
      ApiFailureUnreadableResponse() => localizations.genericReadUnreadable,
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() => localizations.authResetUnavailableShort,
      ApiFailureServerFault() => localizations.authResetLoadServerFault,
      _ => localizations.authResetLoadGeneric,
    };
  }

  String _verifyMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureInvalidVerificationCode() => localizations.authPinInvalid,
      ApiFailureVerificationCodeAttemptsExceeded() =>
        localizations.authPinAttemptsExceededReset,
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() =>
        localizations.authVerificationUnavailable,
      ApiFailureServerFault() => localizations.authPinVerifyServerFault,
      ApiFailureTransport() => localizations.authPinVerifyTransport,
      ApiFailureUnreadableResponse() => localizations.genericReadUnreadable,
      ApiFailureValidation() => localizations.authEnterSixDigitPin,
      _ => localizations.authPinVerifyGeneric,
    };
  }

  String _resendMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureVerificationResendCooldown() =>
        localizations.authPinRecentlySent,
      ApiFailurePinEmailDeliveryFailed() =>
        localizations.authPinEmailUnconfirmed,
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() => localizations.authResetResendUnavailable,
      ApiFailureTransport() => localizations.authResetResendTransport,
      _ => localizations.authResetResendGeneric,
    };
  }
}
