import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/app/theme/app_tokens.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';

/// Manual sign-in.
///
/// Reached only through the router redirect, so this screen does not check
/// whether a session exists — doing so in both places is how the two drift
/// apart.
///
/// Covers only manual sign-in. Registration, Google sign-in and password reset
/// all exist in the backend and are out of scope for this milestone; none of
/// their routes is registered, so none can be reached.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    // Client-side validation mirrors the server's rules
    // (`login/request.go`: `required,email,max=254` and `required,min=8,max=128`)
    // so the common mistakes never cost a round trip. The server stays the
    // authority — its `VALIDATION_ERROR` is still handled below.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .signIn(_emailController.text.trim(), _passwordController.text);

      if (!mounted) return;
      // The router redirect moves the user on a successful sign-in; this only
      // covers the case where the app has no router attached.
      if (mounted) setState(() => _submitting = false);
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _message = messageFor(failure);
      });
    } catch (_) {
      // A credential-storage failure surfaces here as
      // `ApiFailureCredentialStorage`, which is an `ApiFailure` and is handled
      // above. Anything else is a defect, and the user is told the attempt did
      // not complete rather than being shown a stack trace.
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _message = 'Something went wrong signing in. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTheme.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign in to Stash It',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the email and password on your Stash It account.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_submitting,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your email address.';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }
                        if (email.length > 254) {
                          return 'That email address is too long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_submitting,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return 'Enter your password.';
                        if (password.length < 8) {
                          return 'Your password is at least 8 characters.';
                        }
                        if (password.length > 128) {
                          return 'That password is too long.';
                        }
                        return null;
                      },
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      _SignInMessage(
                        message: _message!,
                        onDismiss: _dismissMessage,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Clears a failure message so the form can be corrected and resubmitted.
  ///
  /// A dismissal, not a retry button: retrying the same credentials immediately
  /// would spend another attempt against the per-email budget that produced the
  /// failure in the first place. The user edits and submits deliberately.
  void _dismissMessage() {
    setState(() => _message = null);
  }
}

/// Client-owned copy for a failed sign-in.
///
/// **[D22] Selected from the typed [ApiFailure], never from `error.message`.**
/// The backend's messages are English prose that is not part of any contract.
///
/// **[D15] The three server states stay distinct.** A `429` reports a countdown
/// because the server sent one; a `503` and an offline device both say
/// "unavailable" but are reached differently and must not be collapsed. No
/// variant below ever claims the account or the service is broken.
String messageFor(ApiFailure failure) {
  return switch (failure) {
    // Deliberately identical for a wrong password and an unknown address: the
    // backend answers both with `INVALID_CREDENTIALS` so the endpoint cannot be
    // used to discover which addresses are registered, and this client must not
    // undo that by describing them differently.
    ApiFailureAuthRequired() =>
      "That doesn't look like a valid email or password.",

    ApiFailureValidation() =>
      'Check your email address and password, then try again.',

    ApiFailureRateLimited(:final retryAfter) =>
      retryAfter != null
          ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
          : 'Too many attempts. Try again shortly.',

    ApiFailureServerUnavailable() =>
      'Sign in is temporarily unavailable. Try again shortly.',

    // Known not saved / not signed in — but for sign-in this means the server
    // failed, not that anything is uncertain, so it does not use the
    // "we can't confirm" wording reserved for a lost request.
    ApiFailureServerFault() =>
      'We could not reach the server. Try again shortly.',

    ApiFailureMalformedRequest() || ApiFailureUnreadableResponse() =>
      "We couldn't read the server's reply. Try again.",

    // The one uncertain case. States plainly that the attempt is unconfirmed
    // rather than implying the account is untouched — the request may have been
    // applied even though no answer arrived.
    ApiFailureTransport() =>
      'No connection to the server. We could not confirm this sign-in.',

    ApiFailureSessionEnded() =>
      'Your session has ended. Sign in again to continue.',

    ApiFailureRefreshUncertain() =>
      'We could not confirm your session. Try again.',

    ApiFailureCredentialStorage() =>
      'Your sign-in could not be saved securely. Try again.',
  };
}

/// A failure message the user can dismiss.
class _SignInMessage extends StatelessWidget {
  const _SignInMessage({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>() ?? AppTheme.tokens;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.danger.withValues(alpha: 0.08),
        border: Border.all(color: tokens.danger),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
        ],
      ),
    );
  }
}
