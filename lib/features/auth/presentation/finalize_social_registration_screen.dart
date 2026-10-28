import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/registration_recovery.dart';
import 'package:stash_it_app/features/auth/data/models/registration_continuation_response.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Completes a social registration using the continuation token from the
/// existing registration PIN verification.
///
/// A social account has no password. The only input is the display name; a
/// successful finalization returns an authenticated session, which is written to
/// secure storage and adopted through the same path as manual sign-in.
class FinalizeSocialRegistrationScreen extends ConsumerStatefulWidget {
  const FinalizeSocialRegistrationScreen({
    super.key,
    required this.continuationToken,
    this.suggestedDisplayName,
  });

  final String continuationToken;

  /// The Google profile name, when it is a valid display name. It only
  /// pre-fills the field; the user may change it.
  final String? suggestedDisplayName;

  @override
  ConsumerState<FinalizeSocialRegistrationScreen> createState() =>
      _FinalizeSocialRegistrationScreenState();
}

enum _SocialFinalizeTerminal { completed, inactive, storageFailure }

class _FinalizeSocialRegistrationScreenState
    extends ConsumerState<FinalizeSocialRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();

  RegistrationContinuationResponse? _continuation;
  ApiFailure? _loadFailure;
  ApiFailure? _submitFailure;
  _SocialFinalizeTerminal? _terminal;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final suggested = widget.suggestedDisplayName?.trim() ?? '';
    if (suggested.length >= 2 && suggested.length <= 100) {
      _displayNameController.text = suggested;
    }
    _load();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final store = ref.read(registrationContinuationStoreProvider);
    setState(() {
      _loading = true;
      _loadFailure = null;
      _terminal = null;
    });

    try {
      final continuation = await ref
          .read(authRepositoryProvider)
          .getRegistrationContinuation(
            continuationToken: widget.continuationToken,
          );
      if (!mounted) return;

      if (continuation.registrationType != 'social') {
        await _clearStored(store);
        if (!mounted) return;
        setState(() {
          _loading = false;
          _terminal = _SocialFinalizeTerminal.inactive;
        });
        return;
      }

      setState(() {
        _continuation = continuation;
        _loading = false;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = continuationOutcomeFor(failure);

      if (outcome != ContinuationOutcome.unconfirmed) {
        await _clearStored(store);
        if (!mounted) return;
        setState(() {
          _loading = false;
          _terminal = outcome == ContinuationOutcome.consumed
              ? _SocialFinalizeTerminal.completed
              : _SocialFinalizeTerminal.inactive;
        });
        return;
      }

      setState(() {
        _loading = false;
        _loadFailure = failure;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailure = const ApiFailureTransport();
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final store = ref.read(registrationContinuationStoreProvider);
    setState(() {
      _submitting = true;
      _submitFailure = null;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .finalizeSocialRegistration(
            continuationToken: widget.continuationToken,
            displayName: _displayNameController.text.trim(),
          );

      // The session is persisted and adopted by AuthState. The token is now
      // consumed server-side, so remove the local copy before leaving. The store
      // is captured above so this still runs if navigation disposes the screen.
      await _clearStored(store);
      if (mounted) context.go(AppRoutes.initial);
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      if (failure is ApiFailureRegistrationAlreadyCompleted) {
        await _clearStored(store);
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _terminal = _SocialFinalizeTerminal.completed;
        });
        return;
      }

      final outcome = continuationOutcomeFor(failure);
      if (outcome != ContinuationOutcome.unconfirmed) {
        await _clearStored(store);
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _terminal = outcome == ContinuationOutcome.consumed
              ? _SocialFinalizeTerminal.completed
              : _SocialFinalizeTerminal.inactive;
        });
        return;
      }

      // Known-not-written refusals and genuinely uncertain outcomes keep the
      // form and the token; only the copy differs. No retry is automatic.
      setState(() {
        _submitting = false;
        _submitFailure = failure;
      });
    } catch (_) {
      // The repository returned successfully but the credential write failed,
      // or an unexpected client fault occurred. The account may exist
      // server-side; never claim the user is signed in here. The continuation is
      // consumed in that case, so clear the matching local copy too.
      await _clearStored(store);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _terminal = _SocialFinalizeTerminal.storageFailure;
      });
    }
  }

  Future<void> _clearStored(RegistrationContinuationStore store) async {
    try {
      await store.clearIfToken(widget.continuationToken);
    } catch (_) {
      // Best effort. The server has already decided the token's outcome.
    }
  }

  void _backToAuth() => context.go(AppRoutes.auth);

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
                  else if (_terminal != null)
                    _buildTerminal(tokens)
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
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: _loadMessageFor(_loadFailure!),
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Retry',
          variant: AppButtonVariant.primary,
          onPressed: _load,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.quiet,
          onPressed: _backToAuth,
        ),
      ],
    );
  }

  Widget _buildTerminal(AppTokens tokens) {
    final copy = switch (_terminal!) {
      _SocialFinalizeTerminal.completed => (
        title: 'Account already created',
        body:
            'This social registration was already completed. Continue with '
            'Google or sign in to use the account.',
      ),
      _SocialFinalizeTerminal.inactive => (
        title: 'Registration unavailable',
        body:
            'This social registration can no longer be completed. Start again '
            'with Google to create the account.',
      ),
      _SocialFinalizeTerminal.storageFailure => (
        title: 'Account created, sign-in not saved',
        body:
            'Your account is ready, but this device could not save the '
            'sign-in. Continue with Google or sign in to use it.',
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
          label: 'Back to sign in',
          variant: AppButtonVariant.primary,
          onPressed: _backToAuth,
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
            'Your Google account is verified. Choose the name to show in '
            'Stash-it for ${continuation.email}.',
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: 'Display name',
            controller: _displayNameController,
            enabled: !_submitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
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
          if (_submitFailure case final failure?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: _submitMessageFor(failure),
              onDismiss: () => setState(() => _submitFailure = null),
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: 'Create account',
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: 'Back to sign in',
            variant: AppButtonVariant.quiet,
            onPressed: _submitting ? null : _backToAuth,
          ),
        ],
      ),
    );
  }

  String _loadMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureTransport() =>
        'No connection to the server. We could not check this registration. '
            'Try again.',
      ApiFailureUnreadableResponse() =>
        'We could not read the server\'s reply. Try again.',
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Registration is temporarily unavailable. Try again shortly.',
      _ => 'We could not check this registration. Try again.',
    };
  }

  String _submitMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureValidation() => 'Check your display name, then try again.',
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Registration is temporarily unavailable. Try again shortly.',
      ApiFailureTransport() ||
      ApiFailureUnreadableResponse() ||
      ApiFailureServerFault() =>
        'We could not confirm whether registration completed. Continue with '
            'Google or sign in; if the account was not created, try again.',
      _ => 'We could not complete your registration. Try again.',
    };
  }
}
