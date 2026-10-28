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
          'Link your Google account',
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
    final copy = switch (_terminal!) {
      _AccountLinkTerminal.invalid => (
        title: 'Link unavailable',
        body:
            'This account-link request is no longer active. It may have expired '
            'or already been used. Start again with Google to sign in.',
      ),
      _AccountLinkTerminal.identityMismatch => (
        title: 'Different Google account',
        body:
            'The Google account used here does not match the one this link was '
            'started with. Start again and choose the account you originally '
            'used.',
      ),
      _AccountLinkTerminal.expiredToken => (
        title: 'Google sign-in expired',
        body:
            'Google no longer accepts the sign-in used for this link. Start '
            'again with Google to continue.',
      ),
      _AccountLinkTerminal.sessionFailed => (
        title: 'Accounts linked',
        body:
            'Your Google account is now linked, but signing in did not finish. '
            'Continue with Google again to sign in.',
      ),
      _AccountLinkTerminal.alreadyLinked => (
        title: 'Google account already linked',
        body:
            'This Google account is already linked to a Stash-it account. '
            'Continue with Google to sign in.',
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
          onPressed: _startAgain,
        ),
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
          'Link your Google account',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space4),
        AuthMessageBand(
          message: _loadMessageFor(failure),
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
          onPressed: _startAgain,
        ),
      ],
    );
  }

  Widget _buildConfirmation(AppTokens tokens) {
    final confirmation = _confirmation!;
    final displayName = confirmation.displayNameSnapshot.trim();
    final maskedEmail = confirmation.maskedUserEmail.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Link your Google account',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          maskedEmail.isEmpty
              ? 'Stash-it found an existing account for this email. Link the '
                    'Google account you just verified to it?'
              : 'Stash-it found an existing account for $maskedEmail. Link the '
                    'Google account you just verified to it?',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        if (displayName.isNotEmpty) ...[
          const SizedBox(height: AppMetrics.space3),
          Text(
            'Google profile: $displayName',
            style: AppTypography.meta.copyWith(color: tokens.textSecondary),
          ),
        ],
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
          label: 'Link account',
          variant: AppButtonVariant.primary,
          busy: _submitting,
          onPressed: _submitting ? null : _confirm,
        ),
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.quiet,
          onPressed: _submitting ? null : _startAgain,
        ),
      ],
    );
  }

  String _loadMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Account linking is temporarily unavailable. Try again shortly.',
      ApiFailureTransport() =>
        'No connection to the server. We could not check this link.',
      ApiFailureUnreadableResponse() =>
        'We could not read the server\'s reply. Try again.',
      _ => 'We could not check this link. Try again.',
    };
  }

  String _submitMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter != null
            ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
            : 'Too many attempts. Try again shortly.',
      ApiFailureServerUnavailable() =>
        'Account linking is temporarily unavailable. Try again shortly.',
      ApiFailureTransport() =>
        'We could not confirm whether the link completed. Continue with Google '
            'to sign in; if it was not linked, start again.',
      ApiFailureUnreadableResponse() =>
        'We could not confirm whether the link completed. Continue with Google '
            'to sign in; if it was not linked, start again.',
      ApiFailureServerFault() =>
        'We could not confirm whether the link completed. Continue with Google '
            'to sign in; if it was not linked, start again.',
      _ => 'We could not link this account. Try again.',
    };
  }
}
