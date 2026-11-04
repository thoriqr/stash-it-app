import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Screen for signing in with email and password or Google.
///
/// The router also permits direct entry, so session checks and redirects remain
/// centralized in the router rather than being duplicated here. Registration
/// and password reset are available through their respective routes.
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
    final l10n = AppLocalizations.of(context);
    final extra = widget.contextualMessage;
    if (extra == 'registration-success') {
      _message = l10n.authRegistrationSuccessSignIn;
      _messageTone = AuthMessageTone.warning;
    } else if (extra == 'registration-uncertain') {
      _message = l10n.authRegistrationUncertainSignIn;
      _messageTone = AuthMessageTone.warning;
    } else if (extra == 'password-reset-success') {
      _message = l10n.authPasswordResetSuccessSignIn;
      _messageTone = AuthMessageTone.warning;
    } else if (extra == 'password-reset-uncertain') {
      _message = l10n.authPasswordResetUncertainSignIn;
      _messageTone = AuthMessageTone.warning;
    }
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  bool _googleBusy = false;
  String? _message;

  /// Whether the password is currently masked.
  bool _obscurePassword = true;

  /// Presentation tone for [_message]. Ordinary sign-in failures use danger.
  AuthMessageTone _messageTone = AuthMessageTone.danger;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || _googleBusy) return;

    // Validate common input errors locally before sending the request.
    // The API remains authoritative and its validation failures are handled below.
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
      // Successful sign-in is handled by the router redirect.
      // Reset the loading state if no router redirect takes place.
      if (mounted) setState(() => _submitting = false);
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _message = authSignInMessageFor(failure, AppLocalizations.of(context));

        // Keep sign-in failures visually distinct from informational messages.
        _messageTone = AuthMessageTone.danger;
      });
    } catch (_) {
      // Unexpected failures are shown as an incomplete sign-in attempt.
      // Typed credential-storage failures are handled by the ApiFailure branch.
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _message = AppLocalizations.of(context).authSignInGenericFailure;
        _messageTone = AuthMessageTone.danger;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
      // The brand row provides the identity for this auth screen without an app bar.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppMetrics.screenPadding,
              ),
              child: AuthBackButton(
                onPressed: _submitting || _googleBusy
                    ? null
                    : () => context.go(AppRoutes.auth),
              ),
            ),
            Expanded(
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
                            l10n.authSignInTitle,
                            style: AppTypography.screenHeading.copyWith(
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppMetrics.space1),
                          Text(
                            l10n.authSignInDescription,
                            style: AppTypography.body.copyWith(
                              color: tokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppMetrics.space6),
                          AppField(
                            label: l10n.authEmailLabel,
                            controller: _emailController,
                            enabled: !_submitting && !_googleBusy,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) {
                                return l10n.authEnterEmail;
                              }
                              if (!RegExp(
                                r'^[^@\s]+@[^@\s]+$',
                              ).hasMatch(email)) {
                                return l10n.authInvalidEmail;
                              }
                              if (email.length > 254) {
                                return l10n.authEmailTooLong;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppMetrics.space4),
                          AppField(
                            label: l10n.authPasswordLabel,
                            controller: _passwordController,
                            enabled: !_submitting && !_googleBusy,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            suffixIcon: IconButton(
                              // Keep the visibility toggle inside the field.
                              // It only changes masking and does not submit the form.
                              onPressed: _submitting || _googleBusy
                                  ? null
                                  : _togglePasswordVisibility,
                              tooltip: _obscurePassword
                                  ? l10n.authShowPassword
                                  : l10n.authHidePassword,
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
                              if (password.isEmpty) {
                                return l10n.authEnterPassword;
                              }
                              if (password.length < 8) {
                                return l10n.authPasswordMin8;
                              }
                              if (password.length > 128) {
                                return l10n.authPasswordTooLong;
                              }
                              return null;
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: AppButton(
                              label: l10n.authForgotPassword,
                              variant: AppButtonVariant.quiet,
                              small: true,
                              block: false,
                              onPressed: _submitting || _googleBusy
                                  ? null
                                  : _openForgotPassword,
                            ),
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
                            label: l10n.authSignIn,
                            variant: AppButtonVariant.primary,
                            busy: _submitting,
                            onPressed: _googleBusy ? null : _submit,
                          ),
                          const SizedBox(height: AppMetrics.space3),
                          GoogleSignInButton(
                            enabled: !_submitting,
                            onBusyChanged: _setGoogleBusy,
                          ),
                          const SizedBox(height: AppMetrics.space3),
                          _SignUpPrompt(
                            onPressed: _submitting || _googleBusy
                                ? null
                                : _openSignUp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles password masking without changing the entered value.
  ///
  /// This control does not validate or submit the form.
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  /// Dismisses the current failure message without retrying the request.
  ///
  /// The user can correct the form and submit again when ready.
  void _dismissMessage() {
    setState(() => _message = null);
  }

  /// Tracks Google sign-in activity to prevent overlapping authentication requests.
  void _setGoogleBusy(bool busy) {
    if (!mounted) return;
    setState(() {
      _googleBusy = busy;
      if (busy) _message = null;
    });
  }

  /// Navigates to the registration start screen.
  void _openSignUp() => context.go(AppRoutes.signUp);

  /// Navigates to the password-reset request screen.
  void _openForgotPassword() => context.go(AppRoutes.forgotPassword);
}

/// Provides a route to registration from the sign-in screen.
class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            l10n.authNoAccountPrompt,
            style: AppTypography.meta.copyWith(color: tokens.textSecondary),
          ),
        ),
        AppButton(
          label: l10n.authCreateAccount,
          variant: AppButtonVariant.quiet,
          small: true,
          block: false,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
