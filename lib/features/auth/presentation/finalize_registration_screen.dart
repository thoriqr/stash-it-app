import 'dart:async';

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
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Finalizes a manual registration using a continuation token.
///
/// The token is a single-use capability: a `201` is the only proof the account
/// was created, and an uncertain outcome must never be presented as success.
/// The stored copy is cleared only once the server has established that the
/// token can no longer be used — finalization succeeded, it was consumed, or it
/// expired. A transport failure or an unreadable reply keeps it, so a later
/// retry can still either complete the registration or discover that an earlier
/// attempt did.
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

  /// A terminal continuation outcome. Non-null replaces both the form and the
  /// load error, because nothing on this screen can make the token usable again.
  ContinuationOutcome? _terminalOutcome;

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
      _terminalOutcome = null;
    });
    try {
      final continuation = await ref
          .read(authRepositoryProvider)
          .getRegistrationContinuation(
            continuationToken: widget.continuationToken,
          );
      if (!mounted) return;

      // This screen finalizes manual registrations only. A social token would be
      // refused by the endpoint, so do not offer a form it cannot submit.
      if (continuation.registrationType != 'manual') {
        await _clearStoredToken();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _terminalOutcome = ContinuationOutcome.restartRequired;
        });
        return;
      }

      setState(() {
        _continuation = continuation;
        _loading = false;
      });

      // A token that arrived through a route extra may never have been written
      // by the PIN screen (for example a direct entry). Persist it now so a
      // restart can recover the flow. Best effort: a storage failure must not
      // block a finalization that can still complete.
      unawaited(_rememberContinuation(continuation.email));
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = continuationOutcomeFor(failure);
      if (outcome != ContinuationOutcome.unconfirmed) {
        await _clearStoredToken();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _terminalOutcome = outcome;
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

      // A 201 is the only proof the account exists. The token can no longer be
      // used, so the record is cleared before leaving.
      await _clearStoredToken();
      if (!mounted) return;
      context.go(AppRoutes.signIn, extra: 'registration-success');
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      // The account already exists (including a finalize whose commit won a
      // race). Nothing here can be retried; sign-in is the correction.
      if (failure is ApiFailureRegistrationAlreadyCompleted) {
        await _clearStoredToken();
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _terminalOutcome = ContinuationOutcome.consumed;
        });
        return;
      }

      final outcome = continuationOutcomeFor(failure);
      if (outcome != ContinuationOutcome.unconfirmed) {
        await _clearStoredToken();
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _terminalOutcome = outcome;
        });
        return;
      }

      // Known-not-written refusals and genuinely uncertain outcomes share the
      // form and the token; only the copy differs. No retry is automatic.
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

  /// Removes the stored token only when it is the one this screen is using.
  ///
  /// A stale route extra must not erase a newer registration's record.
  Future<void> _clearStoredToken() async {
    try {
      await ref
          .read(registrationContinuationStoreProvider)
          .clearIfToken(widget.continuationToken);
    } catch (_) {
      // Best effort. The token is unusable either way; a storage failure must
      // not change the outcome already established by the server.
    }
  }

  /// Repairs a missing or mismatched stored record after a successful read.
  Future<void> _rememberContinuation(String email) async {
    try {
      final store = ref.read(registrationContinuationStoreProvider);
      final stored = await store.read();
      if (stored != null &&
          stored.token == widget.continuationToken &&
          stored.email == normalizeRegistrationEmail(email)) {
        return;
      }
      await store.write(email: email, token: widget.continuationToken);
    } catch (_) {
      // Recovery across a restart is unavailable; this finalization is not.
    }
  }

  /// Whether the last submit's outcome is genuinely unknown.
  ///
  /// Only these pass the `registration-uncertain` context to sign-in. A failure
  /// that provably did not write must not claim the outcome is in doubt.
  bool get _submitOutcomeUnknown {
    final failure = _submitFailure;
    return failure is ApiFailureTransport ||
        failure is ApiFailureUnreadableResponse ||
        failure is ApiFailureServerFault;
  }

  void _openSignIn({String? extra}) {
    if (extra == null) {
      context.go(AppRoutes.signIn);
    } else {
      context.go(AppRoutes.signIn, extra: extra);
    }
  }

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
                  if (_loading)
                    _buildLoading(tokens)
                  else if (_terminalOutcome != null)
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
          AppLocalizations.of(context).authCompleteYourAccount,
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
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: _loadMessageFor(failure, l10n),
          onDismiss: () => setState(() => _loadFailure = null),
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        // Only an unconfirmed read reaches this state. Retrying reads the token
        // again; it sends no finalization and does not spend or discard anything.
        AppButton(
          label: l10n.authRetry,
          variant: AppButtonVariant.primary,
          onPressed: _loadContinuation,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.quiet,
          onPressed: () => _openSignIn(),
        ),
      ],
    );
  }

  /// A terminal continuation outcome: the token can never be used again.
  ///
  /// A consumed token means finalization completed (possibly on an earlier,
  /// uncertain attempt), so the correction is sign-in. An expired or otherwise
  /// unusable token means a new registration is required. Neither state offers
  /// Retry, because repeating the request cannot change the answer.
  Widget _buildTerminal(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final completed = _terminalOutcome == ContinuationOutcome.consumed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          completed
              ? l10n.authRegistrationAlreadyCompletedTitle
              : l10n.authRegistrationUnavailable,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          completed
              ? l10n.authRegistrationAlreadyCompletedBody
              : l10n.authRegistrationCannotBeCompletedBody,
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space6),
        if (completed)
          AppButton(
            label: l10n.authBackToSignIn,
            variant: AppButtonVariant.primary,
            onPressed: () => _openSignIn(),
          )
        else
          AppButton(
            label: l10n.authStartNewRegistration,
            variant: AppButtonVariant.primary,
            onPressed: _openSignUp,
          ),
        const SizedBox(height: AppMetrics.space3),
        if (completed)
          AppButton(
            label: l10n.authStartNewRegistration,
            variant: AppButtonVariant.secondary,
            onPressed: _openSignUp,
          )
        else
          AppButton(
            label: l10n.authBackToSignIn,
            variant: AppButtonVariant.quiet,
            onPressed: () => _openSignIn(),
          ),
      ],
    );
  }

  Widget _buildForm(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final continuation = _continuation!;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.authCompleteYourAccount,
            style: AppTypography.screenHeading.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            l10n.authAccountForEmail(continuation.email),
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: l10n.authDisplayNameLabel,
            controller: _displayNameController,
            enabled: !_submitting,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return l10n.authEnterDisplayName;
              if (name.length < 2) {
                return l10n.authDisplayNameMin2;
              }
              if (name.length > 100) {
                return l10n.authDisplayNameTooLong;
              }
              return null;
            },
          ),
          const SizedBox(height: AppMetrics.space4),
          AppField(
            label: l10n.authPasswordLabel,
            controller: _passwordController,
            enabled: !_submitting,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              onPressed: _submitting
                  ? null
                  : () => setState(() => _obscurePassword = !_obscurePassword),
              tooltip: _obscurePassword
                  ? l10n.authShowPassword
                  : l10n.authHidePassword,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return l10n.authEnterPassword;
              if (password.length < 8) {
                return l10n.authPasswordMin8;
              }
              return null;
            },
          ),
          const SizedBox(height: AppMetrics.space4),
          AppField(
            label: l10n.authConfirmPasswordLabel,
            controller: _confirmPasswordController,
            enabled: !_submitting,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              if (value != _passwordController.text) {
                return l10n.authPasswordsDoNotMatch;
              }
              return null;
            },
          ),
          if (_submitFailure case final failure?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: _messageFor(failure, l10n),
              onDismiss: () => setState(() => _submitFailure = null),
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: l10n.authCreateAccount,
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authBackToSignIn,
            variant: AppButtonVariant.quiet,
            onPressed: _submitting
                ? null
                : () => _openSignIn(
                    extra: _submitOutcomeUnknown
                        ? 'registration-uncertain'
                        : null,
                  ),
          ),
        ],
      ),
    );
  }

  String _loadMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureTransport() => localizations.authRegistrationCheckTransport,
      ApiFailureUnreadableResponse() =>
        localizations.authRegistrationCheckUnreadable,
      _ => _messageFor(failure, localizations),
    };
  }

  String _messageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureInvalidVerificationCode() => localizations.authPinInvalid,
      ApiFailureVerificationCodeAttemptsExceeded() =>
        localizations.authPinAttemptsExceededRegistration,
      ApiFailureRegistrationRestartRequired() =>
        localizations.authRegistrationRestartRequired,
      ApiFailureRegistrationContinuationRequired() ||
      ApiFailureRegistrationContinuationExpired() ||
      ApiFailureInvalidRegistrationType() =>
        localizations.authRegistrationCannotBeCompletedBody,
      // Finalization is the only consumer of a continuation, so a consumed token
      // means the account was created — including by an earlier attempt whose
      // reply was lost.
      ApiFailureRegistrationContinuationConsumed() =>
        localizations.authRegistrationAlreadyCompletedSignIn,
      ApiFailureRegistrationAlreadyCompleted() =>
        localizations.authRegistrationAlreadyCompleted,
      ApiFailureValidation() => localizations.authCheckDetailsThenTryAgain,
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() =>
        localizations.authRegistrationUnavailableShort,
      // A failed finalization transaction either commits with a representation
      // or loses its commit and rolls back. A 500 therefore does not establish
      // that nothing was written, so it is treated as unconfirmed rather than as
      // a known failure.
      ApiFailureServerFault() => localizations.authRegistrationUncertainSignIn,
      ApiFailureTransport() => localizations.authRegistrationUncertainSignIn,
      ApiFailureUnreadableResponse() =>
        localizations.authRegistrationUncertainSignIn,
      ApiFailurePinEmailDeliveryFailed() =>
        localizations.authPinEmailUnconfirmedShort,
      _ => localizations.authRegistrationCompleteGeneric,
    };
  }
}
