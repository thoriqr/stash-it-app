import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/models/verification_status_response.dart';
import 'package:stash_it_app/features/auth/presentation/sign_up_screen.dart'
    show registrationMessageFor;
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// PIN entry and verification status for a manual registration.
///
/// Reached after the first two registration steps succeed. It reads the
/// backend's verification status and offers a resend; it does not perform PIN
/// verification, continuation, or finalization, none of which is implemented in
/// this milestone.
class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key, required this.verificationId});

  final String verificationId;

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
          'Check your email',
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
    final failure = _loadFailure!;
    final message = _loadMessage(failure);
    final canRetry =
        failure is! ApiFailureRegistrationRestartRequired &&
        failure is! ApiFailureNotFound &&
        failure is! ApiFailureMalformedRequest;

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
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: message,
          onDismiss: () => setState(() => _loadFailure = null),
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        if (canRetry)
          AppButton(
            label: 'Retry',
            variant: AppButtonVariant.primary,
            onPressed: _loadStatus,
          ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: _recoveryLabel(failure),
          variant: AppButtonVariant.secondary,
          onPressed: _recoveryAction(failure),
        ),
      ],
    );
  }

  Widget _buildContent(AppTokens tokens) {
    final status = _status!;
    if (status.status == 'verified') {
      return _buildVerified(tokens);
    }
    if (status.status != 'pending') {
      return _buildInvalid(tokens);
    }
    return _buildPending(tokens, status);
  }

  Widget _buildVerified(AppTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PIN verified',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'Your PIN has been verified. You can now sign in to your account.',
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

  Widget _buildInvalid(AppTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Registration unavailable',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'This registration can no longer continue. Start a new one.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Start over',
          variant: AppButtonVariant.primary,
          onPressed: _openSignUp,
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

  Widget _buildPending(AppTokens tokens, VerificationStatusResponse status) {
    final resendEnabled =
        !_resending && _remainingSeconds == 0 && status.status == 'pending';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter your PIN',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'We sent a PIN to your email address. Enter it below to continue.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppField(
          label: 'PIN',
          controller: _pinController,
          enabled: !_resending,
          keyboardType: TextInputType.number,
        ),
        if (_resendFailure case final failure?) ...[
          const SizedBox(height: AppMetrics.space4),
          AuthMessageBand(
            message: registrationMessageFor(failure),
            onDismiss: () => setState(() => _resendFailure = null),
            tone: AuthMessageTone.danger,
          ),
        ],
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Verify PIN',
          variant: AppButtonVariant.primary,
          onPressed: _verifyNotImplemented,
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          'PIN verification is not available in this version yet.',
          style: AppTypography.meta.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: _resending
              ? 'Sending...'
              : (_remainingSeconds > 0
                    ? 'Resend PIN in $_remainingSeconds s'
                    : 'Resend PIN'),
          variant: AppButtonVariant.secondary,
          busy: _resending,
          onPressed: resendEnabled ? _resend : null,
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

  void _verifyNotImplemented() {
    setState(() {
      _resendFailure = null;
    });
    // No PIN verification API is wired in this milestone.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PIN verification is not available in this version yet.'),
      ),
    );
  }

  String _loadMessage(ApiFailure failure) {
    if (failure is ApiFailureRegistrationRestartRequired) {
      return registrationMessageFor(failure);
    }
    if (failure is ApiFailureNotFound) {
      return 'We could not find that registration. Start a new one.';
    }
    if (failure is ApiFailureMalformedRequest) {
      return 'We could not read that registration. Start a new one.';
    }
    return registrationMessageFor(failure);
  }

  String _recoveryLabel(ApiFailure failure) {
    if (failure is ApiFailureRegistrationRestartRequired ||
        failure is ApiFailureNotFound ||
        failure is ApiFailureMalformedRequest) {
      return 'Start over';
    }
    return 'Back to sign in';
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
