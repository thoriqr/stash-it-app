import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Manual sign-in, following `docs/design-explorations/auth.html`.
///
/// Reached from the auth entry screen. The router also allows a direct entry,
/// so this screen does not check whether a session exists — doing so in both
/// places is how the two drift apart.
///
/// Covers only manual sign-in. Registration, Google sign-in and password reset
/// all exist in the backend and are out of scope for this milestone; none of
/// their routes is registered, so none can be reached.
///
/// The behaviour is unchanged from the prototype: the same validators, the same
/// client-side email and password rules that mirror the server's, the same
/// dismissal-not-retry failure message, and the same `ApiFailure` mapping. Only
/// the presentation follows the approved design system.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.contextualMessage});

  final String? contextualMessage;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _contextualMessageSet = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contextualMessageSet) return;
    _contextualMessageSet = true;
    final extra = widget.contextualMessage;
    if (extra == 'registration-success') {
      _message = 'Registration successful. Please sign in with your new account.';
      _messageTone = AuthMessageTone.warning;
    } else if (extra == 'registration-uncertain') {
      _message =
          'We could not confirm whether registration completed. '
          'Try signing in; if it fails, start again.';
      _messageTone = AuthMessageTone.warning;
    }
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _message;

  /// Whether the password is masked. The field starts obscured, and only this
  /// screen controls it: the toggle is a view of the entered value, not a
  /// change to it.
  bool _obscurePassword = true;

  /// How [_message] is presented. Defaults to danger so every ordinary
  /// sign-in failure keeps the treatment it had before tones existed.
  AuthMessageTone _messageTone = AuthMessageTone.danger;

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

        // Explicit even though it is the default: this is the branch that must
        // keep the danger treatment, and saying so here stops a later default
        // change from quietly re-toning every sign-in failure.
        _messageTone = AuthMessageTone.danger;
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
        _messageTone = AuthMessageTone.danger;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
      // The brand row replaces the app bar: auth sits outside the four
      // destinations, so it carries the wordmark rather than a screen title.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMetrics.screenPadding,
              vertical: AppMetrics.space6,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthBrandRow(),
                    const SizedBox(height: AppMetrics.space5),
                    Text(
                      'Sign in to Stash It',
                      style: AppTypography.screenHeading.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppMetrics.space1),
                    Text(
                      'Use the email and password on your Stash It account.',
                      style: AppTypography.body.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppMetrics.space6),
                    AppField(
                      label: 'Email',
                      controller: _emailController,
                      enabled: !_submitting,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: AppMetrics.space4),
                    AppField(
                      label: 'Password',
                      controller: _passwordController,
                      enabled: !_submitting,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        // Inline and inside the field: a separate control outside
                        // would read as another form action. It only flips the
                        // mask, so it can neither submit nor validate.
                        onPressed: _submitting
                            ? null
                            : _togglePasswordVisibility,
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        iconSize: AppMetrics.iconSize,
                        color: tokens.textTertiary,
                        padding: EdgeInsets.zero,
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
                    if (_message case final message?) ...[
                      const SizedBox(height: AppMetrics.space4),
                      AuthMessageBand(
                        message: message,
                        onDismiss: _dismissMessage,
                        tone: _messageTone,
                      ),
                    ],
                    const SizedBox(height: AppMetrics.space6),
                    AppButton(
                      label: 'Sign in',
                      variant: AppButtonVariant.primary,
                      busy: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppMetrics.space3),
                    _SignUpPrompt(onPressed: _submitting ? null : _openSignUp),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows or masks the entered password without touching its value.
  ///
  /// Deliberately not part of [_submit]: the control is an inspection aid, so
  /// it never validates or posts the form.
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  /// Clears a failure message so the form can be corrected and resubmitted.
  ///
  /// A dismissal, not a retry button: retrying the same credentials immediately
  /// would spend another attempt against the per-email budget that produced the
  /// failure in the first place. The user edits and submits deliberately.
  void _dismissMessage() {
    setState(() => _message = null);
  }

  /// Replaces this form with the registration start screen, as a peer.
  void _openSignUp() => context.go(AppRoutes.signUp);
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

    // `ApiFailureNotFound` is unreachable on these routes: none of them answers
    // `RESOURCE_NOT_FOUND`. `ApiFailureCollectionNameAlreadyExists`,
    // `ApiFailureCollectionNotEmpty`, `ApiFailureUnsortedCollectionProtected`
    // and `ApiFailureCollectionDeleteTargetNotFound` are likewise
    // collection-route outcomes. The profile and password variants belong to
    // `GET`/`PATCH /users/me` and `PUT /users/me/password`, none of which sign-in
    // calls. All are grouped with the unreadable replies rather than given
    // sign-in copy for an outcome sign-in cannot produce, and the closed
    // taxonomy stays exhaustive.
    ApiFailureNotFound() ||
    ApiFailureUserNotFound() ||
    ApiFailureCurrentPasswordInvalid() ||
    ApiFailureCurrentPasswordRequired() ||
    ApiFailureUnexpectedCurrentPassword() ||
    ApiFailurePasswordCredentialAlreadyExists() ||
    ApiFailurePasswordAlreadyChanged() ||
    ApiFailureCollectionNameAlreadyExists() ||
    ApiFailureCollectionNotEmpty() ||
    ApiFailureUnsortedCollectionProtected() ||
    ApiFailureCollectionDeleteTargetNotFound() ||
    ApiFailureMalformedRequest() ||
    ApiFailurePinEmailDeliveryFailed() ||
    ApiFailureRegistration() ||
    ApiFailureUnreadableResponse() =>
      "We couldn't read the server's reply. Try again.",

    // The one uncertain case. States plainly that the attempt is unconfirmed
    // rather than implying the account is untouched — the request may have been
    // applied even though no answer arrived.
    ApiFailureTransport() =>
      'No connection to the server. We could not confirm this sign-in.',

    ApiFailureSessionEnded() => sessionEndedMessage,

    ApiFailureRefreshUncertain() =>
      'We could not confirm your session. Try again.',

    ApiFailureCredentialStorage() =>
      'Your sign-in could not be saved securely. Try again.',
  };
}

/// The quiet route to registration, kept on the sign-in screen so a new account
/// is never stranded.
class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            "Don't have an account?",
            style: AppTypography.meta.copyWith(color: tokens.textSecondary),
          ),
        ),
        AppButton(
          label: 'Create account',
          variant: AppButtonVariant.quiet,
          small: true,
          block: false,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
