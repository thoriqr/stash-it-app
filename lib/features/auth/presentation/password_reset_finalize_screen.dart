import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/password_reset_recovery.dart';
import 'package:stash_it_app/features/auth/data/models/password_reset_continuation_response.dart';
import 'package:stash_it_app/features/auth/data/password_reset_continuation_store.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Chooses and submits the new password for a verified reset.
///
/// The continuation token is read from secure storage and never travels in the
/// route or any user-visible value. Only a `200` from the finalize endpoint is
/// success; a transport failure or unreadable reply leaves the token in storage
/// so a later visit can either resume or discover that the reset completed.
class PasswordResetFinalizeScreen extends ConsumerStatefulWidget {
  const PasswordResetFinalizeScreen({super.key});

  @override
  ConsumerState<PasswordResetFinalizeScreen> createState() =>
      _PasswordResetFinalizeScreenState();
}

enum _FinalizeTerminal { completed, inactive, noReset }

class _PasswordResetFinalizeScreenState
    extends ConsumerState<PasswordResetFinalizeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  StoredPasswordResetContinuation? _stored;
  PasswordResetContinuationResponse? _continuation;
  ApiFailure? _loadFailure;
  ApiFailure? _submitFailure;
  _FinalizeTerminal? _terminal;

  bool _loading = true;
  bool _submitting = false;
  bool _obscurePassword = true;

  /// The secure store could not be read. Distinct from a server failure: the
  /// token may still be there, so nothing is cleared and the copy names the
  /// device rather than the network.
  bool _storageReadFailure = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailure = null;
      _terminal = null;
      _storageReadFailure = false;
    });

    final store = ref.read(passwordResetContinuationStoreProvider);
    StoredPasswordResetContinuation? stored;

    try {
      stored = await store.read();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _storageReadFailure = true;
      });
      return;
    }

    if (!mounted) return;

    if (stored == null) {
      setState(() {
        _loading = false;
        _terminal = _FinalizeTerminal.noReset;
      });
      return;
    }

    setState(() => _stored = stored);

    try {
      final continuation = await ref
          .read(authRepositoryProvider)
          .getPasswordResetContinuation(continuationToken: stored.token);
      if (!mounted) return;
      setState(() {
        _continuation = continuation;
        _loading = false;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = passwordResetContinuationOutcomeFor(failure);

      switch (outcome) {
        case PasswordResetContinuationOutcome.consumed:
          await _clearStored(stored.token);
          if (!mounted) return;
          setState(() {
            _loading = false;
            _terminal = _FinalizeTerminal.completed;
          });
          return;

        case PasswordResetContinuationOutcome.restartRequired:
          await _clearStored(stored.token);
          if (!mounted) return;
          setState(() {
            _loading = false;
            _terminal = _FinalizeTerminal.inactive;
          });
          return;

        case PasswordResetContinuationOutcome.unconfirmed:
          setState(() {
            _loading = false;
            _loadFailure = failure;
          });
          return;
      }
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

    final stored = _stored;
    if (stored == null) {
      setState(() => _terminal = _FinalizeTerminal.noReset);
      return;
    }

    setState(() {
      _submitting = true;
      _submitFailure = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .finalizePasswordReset(
            continuationToken: stored.token,
            password: _passwordController.text,
          );
      if (!mounted) return;

      // A 200 is the only proof the password changed. The token is single-use and
      // now consumed, so the local copy is removed before leaving.
      await _clearStored(stored.token);
      if (!mounted) return;
      context.go(AppRoutes.signIn, extra: 'password-reset-success');
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = passwordResetContinuationOutcomeFor(failure);

      if (outcome == PasswordResetContinuationOutcome.consumed) {
        await _clearStored(stored.token);
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _terminal = _FinalizeTerminal.completed;
        });
        return;
      }

      if (outcome == PasswordResetContinuationOutcome.restartRequired) {
        await _clearStored(stored.token);
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _terminal = _FinalizeTerminal.inactive;
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
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitFailure = const ApiFailureTransport();
      });
    }
  }

  Future<void> _clearStored(String token) async {
    try {
      await ref
          .read(passwordResetContinuationStoreProvider)
          .clearIfToken(token);
    } catch (_) {
      // Best effort. The server has already decided the outcome; a storage
      // failure does not change it.
    }
  }

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

  void _openResetStart() => context.go(AppRoutes.forgotPassword);

  /// Returns to the email form without clearing the saved continuation.
  ///
  /// The in-memory mode extra is not a token; the request screen reads the
  /// continuation from secure storage.
  void _openEmailSelection() {
    context.go(
      AppRoutes.forgotPassword,
      extra: const PasswordResetEmailSelection(),
    );
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
                  else if (_terminal != null)
                    _buildTerminal(tokens)
                  else if (_storageReadFailure)
                    _buildStorageReadError(tokens)
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
          AppLocalizations.of(context).authChooseNewPassword,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space6),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildStorageReadError(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authResetUnavailable,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: l10n.authResetStorageReadFailure,
          tone: AuthMessageTone.danger,
        ),
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: l10n.authRetry,
          variant: AppButtonVariant.primary,
          onPressed: _load,
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

  Widget _buildLoadError(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final failure = _loadFailure!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authResetUnavailable,
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
          onPressed: _load,
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

  Widget _buildTerminal(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final terminal = _terminal!;
    final completed = terminal == _FinalizeTerminal.completed;

    final copy = switch (terminal) {
      _FinalizeTerminal.completed => (
        title: l10n.authResetCompletedTitle,
        body: l10n.authResetCompletedBody,
      ),
      _FinalizeTerminal.inactive => (
        title: l10n.authResetUnavailable,
        body: l10n.authResetNoLongerActiveBody,
      ),
      _FinalizeTerminal.noReset => (
        title: l10n.authNoResetInProgressTitle,
        body: l10n.authNoResetInProgressBody,
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
        if (completed) ...[
          AppButton(
            label: l10n.authBackToSignIn,
            variant: AppButtonVariant.primary,
            onPressed: () => _openSignIn(),
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authStartNewReset,
            variant: AppButtonVariant.secondary,
            onPressed: _openResetStart,
          ),
        ] else ...[
          AppButton(
            label: l10n.authStartNewReset,
            variant: AppButtonVariant.primary,
            onPressed: _openResetStart,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authBackToSignIn,
            variant: AppButtonVariant.quiet,
            onPressed: () => _openSignIn(),
          ),
        ],
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
            l10n.authChooseNewPassword,
            style: AppTypography.screenHeading.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            continuation.hasPasswordCredential
                ? l10n.authChooseNewPasswordForEmail(continuation.email)
                : l10n.authSetPasswordForEmail(continuation.email),
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: l10n.authNewPasswordLabel,
            controller: _passwordController,
            enabled: !_submitting,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.newPassword],
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
              if (password.isEmpty) return l10n.authEnterNewPassword;
              final length = password.runes.length;
              if (length < 8 || length > 128) {
                return l10n.authPasswordRange;
              }
              return null;
            },
          ),
          const SizedBox(height: AppMetrics.space4),
          AppField(
            label: l10n.authConfirmNewPasswordLabel,
            controller: _confirmController,
            enabled: !_submitting,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              if ((value ?? '') != _passwordController.text) {
                return l10n.authPasswordsDoNotMatch;
              }
              return null;
            },
          ),
          if (_submitFailure case final failure?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: _submitMessageFor(failure, l10n),
              onDismiss: () => setState(() => _submitFailure = null),
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: l10n.authResetPassword,
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authUseDifferentEmail,
            variant: AppButtonVariant.secondary,
            onPressed: _submitting ? null : _openEmailSelection,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: l10n.authBackToSignIn,
            variant: AppButtonVariant.quiet,
            onPressed: _submitting
                ? null
                : () => _openSignIn(
                    extra: _submitOutcomeUnknown
                        ? 'password-reset-uncertain'
                        : null,
                  ),
          ),
        ],
      ),
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

  String _submitMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      // Capacity-neutral: this variant covers both a spent client budget and
      // exhausted password-work capacity, and the latter must not blame the
      // user for a server condition. The countdown comes from `Retry-After`.
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authResetSubmitRateLimitedWithWait(
                retryAfter.inSeconds,
              )
            : localizations.authResetSubmitRateLimitedNoWait,
      ApiFailureServerUnavailable() => localizations.authResetUnavailableShort,
      // A failed finalize transaction either commits with a receipt or rolls
      // back. A 500 does not establish that nothing changed, so it is
      // unconfirmed rather than presented as a known failure.
      ApiFailureServerFault() => localizations.authResetOutcomeUnconfirmed,
      ApiFailureTransport() => localizations.authResetOutcomeUnconfirmed,
      ApiFailureUnreadableResponse() =>
        localizations.authResetOutcomeUnconfirmed,
      ApiFailureValidation() => localizations.authPasswordRange,
      _ => localizations.authResetSubmitGeneric,
    };
  }
}
