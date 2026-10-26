import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/models/registration_continuation_response.dart';
// (no registrationMessageFor import needed)
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Finalizes a manual registration using a continuation token.
class FinalizeRegistrationScreen extends ConsumerStatefulWidget {
  const FinalizeRegistrationScreen({
    super.key,
    required this.continuationToken,
  });

  final String continuationToken;

  @override
  ConsumerState<FinalizeRegistrationScreen> createState() =>
      _FinalizeRegistrationScreenState();
}

class _FinalizeRegistrationScreenState
    extends ConsumerState<FinalizeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegistrationContinuationResponse? _continuation;
  ApiFailure? _loadFailure;
  ApiFailure? _submitFailure;

  bool _loading = true;
  bool _submitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadContinuation();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadContinuation() async {
    setState(() {
      _loading = true;
      _loadFailure = null;
    });
    try {
      final continuation = await ref
          .read(authRepositoryProvider)
          .getRegistrationContinuation(
            continuationToken: widget.continuationToken,
          );
      if (!mounted) return;
      setState(() {
        _continuation = continuation;
        _loading = false;
      });
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
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _submitFailure = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .finalizeManualRegistration(
            continuationToken: widget.continuationToken,
            displayName: _displayNameController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.signIn, extra: 'registration-success');
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitFailure = failure;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitFailure = const ApiFailureTransport();
      });
    }
  }

  void _openSignIn({String? extra}) {
    if (extra == null) {
      context.go(AppRoutes.signIn);
    } else {
      context.go(AppRoutes.signIn, extra: extra);
    }
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
                  if (_loading)
                    _buildLoading(tokens)
                  else if (_loadFailure != null)
                    _buildLoadError(tokens)
                  else
                    _buildForm(tokens),
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
          'Complete your account',
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
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: _messageFor(failure),
          onDismiss: () => setState(() => _loadFailure = null),
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Back to sign up',
          variant: AppButtonVariant.primary,
          onPressed: () => context.go(AppRoutes.signUp),
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.quiet,
          onPressed: () => _openSignIn(),
        ),
      ],
    );
  }

  Widget _buildForm(AppTokens tokens) {
    final continuation = _continuation!;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Complete your account',
            style: AppTypography.screenHeading.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            'Account for ${continuation.email}',
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: 'Display name',
            controller: _displayNameController,
            enabled: !_submitting,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'Enter a display name.';
              if (name.length < 2) {
                return 'Display name is at least 2 characters.';
              }
              if (name.length > 100) {
                return 'Display name is too long.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppMetrics.space4),
          AppField(
            label: 'Password',
            controller: _passwordController,
            enabled: !_submitting,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: _submitting
                  ? null
                  : () => setState(() => _obscurePassword = !_obscurePassword),
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return 'Enter a password.';
              if (password.length < 8) {
                return 'Password is at least 8 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppMetrics.space4),
          AppField(
            label: 'Confirm password',
            controller: _confirmPasswordController,
            enabled: !_submitting,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
          if (_submitFailure case final failure?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: _messageFor(failure),
              onDismiss: () => setState(() => _submitFailure = null),
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: 'Create account',
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: 'Back to sign in',
            variant: AppButtonVariant.quiet,
            onPressed: _submitting
                ? null
                : () => _openSignIn(extra: 'registration-uncertain'),
          ),
        ],
      ),
    );
  }

  String _messageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureInvalidVerificationCode() => 'That PIN is not valid.',
      ApiFailureVerificationCodeAttemptsExceeded() =>
        'Too many incorrect PINs. Start a new registration.',
      ApiFailureRegistrationRestartRequired() =>
        'That registration can no longer continue. Start a new one.',
      ApiFailureRegistrationContinuationRequired() ||
      ApiFailureRegistrationContinuationConsumed() ||
      ApiFailureRegistrationContinuationExpired() =>
        'Registration cannot be completed. Start again.',
      ApiFailureInvalidRegistrationType() =>
        'Registration cannot be completed. Start again.',
      ApiFailureRegistrationAlreadyCompleted() =>
        'An account already exists for this email. Sign in instead.',
      ApiFailureValidation() => 'Check your details, then try again.',
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Registration is temporarily unavailable. Try again shortly.',
      ApiFailureServerFault() =>
        'We could not complete your registration. Try again shortly.',
      ApiFailureTransport() =>
        'We could not confirm whether registration completed. Try signing in; '
            'if it fails, start again.',
      ApiFailureUnreadableResponse() =>
        'We could not confirm whether registration completed. Try signing in; '
            'if it fails, start again.',
      ApiFailurePinEmailDeliveryFailed() =>
        'We could not confirm the PIN email was sent. Check your inbox.',
      _ => 'We could not complete your registration. Try again.',
    };
  }
}
