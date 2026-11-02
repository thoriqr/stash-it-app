import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/data/models/account_link_confirmation_response.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// Confirms linking a Google identity to an existing Stash-it account.
///
/// The confirmation id in the path only names the flow. The Google ID token in
/// route `extra` proves control of the identity and is required to confirm. The
/// backend returns only the existing account's masked address; the full address
/// is never shown or requested.
class GoogleAccountLinkScreen extends ConsumerStatefulWidget {
  const GoogleAccountLinkScreen({
    super.key,
    required this.confirmationId,
    required this.idToken,
  });

  final String confirmationId;

  /// In-memory proof of the Google identity that started the link. Never put
  /// this in the location, logs or user-facing copy.
  final String idToken;

  @override
  ConsumerState<GoogleAccountLinkScreen> createState() =>
      _GoogleAccountLinkScreenState();
}

enum _AccountLinkTerminal {
  invalid,
  identityMismatch,
  expiredToken,
  sessionFailed,
  alreadyLinked,
}

class _GoogleAccountLinkScreenState
    extends ConsumerState<GoogleAccountLinkScreen> {
  AccountLinkConfirmationResponse? _confirmation;
  ApiFailure? _loadFailure;
  ApiFailure? _submitFailure;
  _AccountLinkTerminal? _terminal;

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailure = null;
      _terminal = null;
    });

    try {
      final confirmation = await ref
          .read(authRepositoryProvider)
          .getGoogleAccountLinkConfirmation(
            confirmationId: widget.confirmationId,
          );
      if (!mounted) return;
      setState(() {
        _confirmation = confirmation;
        _loading = false;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (failure is ApiFailureAccountLinkConfirmationInvalid ||
            failure is ApiFailureMalformedRequest ||
            failure is ApiFailureNotFound) {
          _terminal = _AccountLinkTerminal.invalid;
        } else {
          _loadFailure = failure;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailure = const ApiFailureTransport();
      });
    }
  }

  Future<void> _confirm() async {
    if (_submitting) return;

    setState(() {
      _submitting = true;
      _submitFailure = null;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .confirmGoogleAccountLink(
            confirmationId: widget.confirmationId,
            idToken: widget.idToken,
          );
      // The AuthState has persisted and adopted the pair. The router's auth
      // redirect moves the user into the app.
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      final terminal = switch (failure) {
        ApiFailureAccountLinkConfirmationInvalid() =>
          _AccountLinkTerminal.invalid,
        ApiFailureAccountLinkIdentityMismatch() =>
          _AccountLinkTerminal.identityMismatch,
        ApiFailureInvalidGoogleToken() => _AccountLinkTerminal.expiredToken,
        ApiFailureAccountLinkSessionFailed() =>
          _AccountLinkTerminal.sessionFailed,
        ApiFailureRegistrationAlreadyCompleted() =>
          _AccountLinkTerminal.alreadyLinked,
        _ => null,
      };

      setState(() {
        _submitting = false;
        if (terminal != null) {
          _terminal = terminal;
        } else {
          _submitFailure = failure;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitFailure = const ApiFailureTransport();
      });
    }
  }

  void _startAgain() => context.go(AppRoutes.auth);

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
                    _buildConfirmation(tokens),
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
          AppLocalizations.of(context).authLinkYourGoogleAccount,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space6),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildTerminal(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final copy = switch (_terminal!) {
      _AccountLinkTerminal.invalid => (
        title: l10n.authLinkInvalidTitle,
        body: l10n.authLinkInvalidBody,
      ),
      _AccountLinkTerminal.identityMismatch => (
        title: l10n.authLinkDifferentAccountTitle,
        body: l10n.authLinkDifferentAccountBody,
      ),
      _AccountLinkTerminal.expiredToken => (
        title: l10n.authGoogleSignInExpiredTitle,
        body: l10n.authGoogleSignInExpiredBody,
      ),
      _AccountLinkTerminal.sessionFailed => (
        title: l10n.authAccountsLinkedTitle,
        body: l10n.authAccountsLinkedBody,
      ),
      _AccountLinkTerminal.alreadyLinked => (
        title: l10n.authGoogleAlreadyLinkedTitle,
        body: l10n.authGoogleAlreadyLinkedBody,
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
          label: l10n.authBackToSignIn,
          variant: AppButtonVariant.primary,
          onPressed: _startAgain,
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
          l10n.authLinkYourGoogleAccount,
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
          onPressed: _startAgain,
        ),
      ],
    );
  }

  Widget _buildConfirmation(AppTokens tokens) {
    final l10n = AppLocalizations.of(context);
    final confirmation = _confirmation!;
    final displayName = confirmation.displayNameSnapshot.trim();
    final maskedEmail = confirmation.maskedUserEmail.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.authLinkYourGoogleAccount,
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          maskedEmail.isEmpty
              ? l10n.authLinkExistingAccount
              : l10n.authLinkExistingAccountForEmail(maskedEmail),
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        if (displayName.isNotEmpty) ...[
          const SizedBox(height: AppMetrics.space3),
          Text(
            l10n.authGoogleProfile(displayName),
            style: AppTypography.meta.copyWith(color: tokens.textSecondary),
          ),
        ],
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
          label: l10n.authLinkAccount,
          variant: AppButtonVariant.primary,
          busy: _submitting,
          onPressed: _submitting ? null : _confirm,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: l10n.authCancel,
          variant: AppButtonVariant.quiet,
          onPressed: _submitting ? null : _startAgain,
        ),
      ],
    );
  }

  String _loadMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() => localizations.authLinkUnavailableShort,
      ApiFailureTransport() => localizations.authLinkCheckTransport,
      ApiFailureUnreadableResponse() => localizations.genericReadUnreadable,
      _ => localizations.authLinkCheckGeneric,
    };
  }

  String _submitMessageFor(ApiFailure failure, AppLocalizations localizations) {
    return switch (failure) {
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? localizations.authTooManyAttemptsWithWait(retryAfter.inSeconds)
            : localizations.genericReadRateLimited,
      ApiFailureServerUnavailable() => localizations.authLinkUnavailableShort,
      ApiFailureTransport() ||
      ApiFailureUnreadableResponse() ||
      ApiFailureServerFault() => localizations.authLinkOutcomeUnconfirmed,
      _ => localizations.authLinkFailed,
    };
  }
}
