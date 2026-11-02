import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/models/verification_status_response.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// PIN entry and verification status for a registration.
///
/// Reached after the first two registration steps succeed. It reads the
/// backend's verification status, offers a resend, verifies the PIN, and — when
/// the registration email was carried from sign-up — persists the raw
/// continuation token before continuing to finalization. The backend stores only
/// the token's hash, so losing it means the verified registration cannot be
/// finished from this device.
///
/// The same screen serves manual and social registrations. [socialRegistration]
/// only changes the finalization route; status, cooldown, resend and PIN
/// verification are the same backend contract for both.
class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({
    super.key,
    required this.verificationId,
    this.email,
    this.socialRegistration = false,
    this.suggestedDisplayName,
  });

  final String verificationId;

  /// The address this verification belongs to, carried from sign-up so the
  /// continuation token can be scoped to it.
  ///
  /// Null for a direct entry: verification still works, but the token cannot be
  /// persisted and the flow survives only while the app does.
  final String? email;

  /// Whether successful verification continues to social finalization instead
  /// of the manual display-name/password form.
  final bool socialRegistration;

  /// The Google profile name, used only to pre-fill the social finalization
  /// form. It is not identity proof and may be absent.
  final String? suggestedDisplayName;

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen>
    with WidgetsBindingObserver {
  VerificationStatusResponse? _status;
  ApiFailure? _loadFailure;

  bool _loading = true;
  bool _statusInFlight = false;
  bool _resending = false;
  ApiFailure? _resendFailure;

  bool _verifying = false;
  ApiFailure? _verifyFailure;

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
    if (state == AppLifecycleState.resumed && !_loading && !_resending) {
      _loadStatus();
    }
  }

  Future<void> _loadStatus() async {
    if (_statusInFlight) {
      // A refresh is already in flight; ignore the redundant request.
      return;
    }
    _statusInFlight = true;
    setState(() {
      _loading = true;
      _loadFailure = null;
    });

    try {
      final status = await ref
          .read(authRepositoryProvider)
          .getVerification(verificationId: widget.verificationId);
      if (!mounted) return;
      setState(() {
        _status = status;
        // A refreshed status is authoritative, but never shorten a cooldown that
        // is still active locally (for example after an uncertain delivery
        // failure that carried a longer Retry-After).
        if (status.resendInSeconds > _remainingSeconds) {
          _remainingSeconds = status.resendInSeconds;
        }
        _loading = false;
      });
      _startCountdown();
    } on ApiFailure catch (failure) {
      if (!mounted) return;
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
          .resendVerification(verificationId: widget.verificationId);
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
        // Refresh status where safe, but the max above keeps a longer active
        // cooldown from being cleared by a stale response.
        await _loadStatus();
      } else if (failure is ApiFailureVerificationResendCooldown ||
          failure is ApiFailureRegistrationRestartRequired ||
          failure is ApiFailureNotFound) {
        // Refresh to learn the actual remaining cooldown after a cooldown refusal.
        await _loadStatus();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _resendFailure = const ApiFailureTransport());
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _openSignIn() => context.go(AppRoutes.signIn);

  void _openSignUp() => context.go(AppRoutes.signUp);

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
                  if (_loading && _status == null)
                    _buildLoading(tokens)
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

  Widget _buildLoadError(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final failure = _loadFailure!;
    final message = _loadMessage(failure, l10n);
    final canRetry =
        failure is! ApiFailureRegistrationRestartRequired &&
        failure is! ApiFailureNotFound &&
        failure is! ApiFailureMalformedRequest;

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
          message: message,
          onDismiss: () => setState(() => _loadFailure = null),
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        if (canRetry)
          AppButton(
            label: l10n.authRetry,
            variant: AppButtonVariant.primary,
            onPressed: _loadStatus,
          ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: _recoveryLabel(failure, l10n),
          variant: AppButtonVariant.secondary,
          onPressed: _recoveryAction(failure),
        ),
      ],
    );
  }

  Widget _buildContent(AppTokens tokens) {
    final status = _status!;
    if (status.status != 'pending') {
      return _buildInvalid(tokens);
    }
    return _buildPending(tokens, status);
  }

  /// Terminal verification state.
  ///
  /// The backend never returns `verified` from this endpoint: a completed
  /// verification answers `409 VERIFICATION_NOT_PENDING`, which reaches this
  /// screen as a restart-required failure. If a status other than `pending` ever
  /// arrives, the honest guidance is the same — this step is closed, and the
  /// user continues by re-entering the same email at sign-up, where the
  /// `verified` response and the stored continuation take over.
  Widget _buildInvalid(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authRegistrationUnavailable,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          l10n.authRegistrationStepClosed,
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: l10n.authStartOver,
          variant: AppButtonVariant.primary,
          onPressed: _openSignUp,
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

  Widget _buildPending(AppTokens tokens, VerificationStatusResponse status) {
    final l10n = AppLocalizations.of(context);
    final resendEnabled =
        !_verifying &&
        !_resending &&
        _remainingSeconds == 0 &&
        status.status == 'pending';

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
          l10n.authPinInstructions,
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppField(
          label: l10n.authPinLabel,
          controller: _pinController,
          enabled: !_verifying && !_resending,
          keyboardType: TextInputType.number,
        ),
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
            message: authRegistrationMessageFor(failure, l10n),
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

  Future<void> _verifyPin() async {
    if (_verifying) return;

    final pin = _pinController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() => _verifyFailure = const ApiFailureValidation([]));
      return;
    }

    setState(() {
      _verifying = true;
      _verifyFailure = null;
    });

    try {
      final token = await ref
          .read(authRepositoryProvider)
          .verifyRegistration(verificationId: widget.verificationId, pin: pin);
      if (!mounted) return;

      // Persist before navigating. The token is returned exactly once and the
      // backend stores only its hash, so a crash between here and finalization
      // would otherwise make the verified registration unrecoverable.
      final email = widget.email;
      if (email != null) {
        try {
          await ref
              .read(registrationContinuationStoreProvider)
              .write(email: email, token: token);
        } catch (_) {
          if (!mounted) return;
          // A valid token can still finish now; only recovery after a restart is
          // lost. The verification itself succeeded, so this must not block the
          // flow or claim otherwise.
          ref
              .read(feedbackProvider.notifier)
              .show(
                AppFeedback.localized(
                  tone: FeedbackTone.warning,
                  message: (localizations) =>
                      localizations.pinVerifiedProgressNotSaved,
                ),
              );
        }
      }

      if (!mounted) return;

      if (GoRouter.maybeOf(context) != null) {
        if (widget.socialRegistration) {
          context.go(
            AppRoutes.finalizeSocialRegistration,
            extra: FinalizeSocialRegistrationArgs(
              continuationToken: token,
              suggestedDisplayName: widget.suggestedDisplayName,
            ),
          );
          return;
        }

        context.go(AppRoutes.finalizeRegistration, extra: token);
        return;
      }

      setState(() {
        _verifying = false;
        _verifyFailure = null;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _verifyFailure = failure;
      });
      if (failure is ApiFailureRegistrationRestartRequired ||
          failure is ApiFailureNotFound ||
          failure is ApiFailureMalformedRequest) {
        await _loadStatus();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _verifyFailure = const ApiFailureTransport();
      });
    }
  }

  String _verifyMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureInvalidVerificationCode() => localizations.authPinInvalid,
      ApiFailureVerificationCodeAttemptsExceeded() =>
        localizations.authPinAttemptsExceededRegistration,
      ApiFailureRegistrationRestartRequired() =>
        localizations.authRegistrationRestartRequired,
      ApiFailureNotFound() => localizations.authRegistrationNotFound,
      ApiFailureMalformedRequest() => localizations.authRegistrationUnreadable,
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

  String _loadMessage(ApiFailure failure, AppLocalizations localizations) {
    if (failure is ApiFailureRegistrationRestartRequired) {
      // A verified request answers 409 VERIFICATION_NOT_PENDING here. "Start
      // over" is right, but the copy must not imply the registration was never
      // verified: re-entering the same email resumes from the verified state.
      return localizations.authRegistrationStepClosed;
    }
    if (failure is ApiFailureNotFound) {
      return localizations.authRegistrationNotFound;
    }
    if (failure is ApiFailureMalformedRequest) {
      return localizations.authRegistrationUnreadable;
    }
    return authRegistrationMessageFor(failure, localizations);
  }

  String _recoveryLabel(ApiFailure failure, AppLocalizations localizations) {
    if (failure is ApiFailureRegistrationRestartRequired ||
        failure is ApiFailureNotFound ||
        failure is ApiFailureMalformedRequest) {
      return localizations.authStartOver;
    }
    return localizations.authBackToSignIn;
  }

  VoidCallback _recoveryAction(ApiFailure failure) {
    if (failure is ApiFailureRegistrationRestartRequired ||
        failure is ApiFailureNotFound ||
        failure is ApiFailureMalformedRequest) {
      return _openSignUp;
    }
    return _openSignIn;
  }
}
