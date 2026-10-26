import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_brand_row.dart';
import 'package:stash_it_app/features/auth/presentation/widgets/auth_message_band.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// The start of manual registration.
///
/// Reached from the auth entry screen, and allowed as a direct entry while signed
/// out for the same reason as [AppRoutes.signIn]: the entry screen's
/// account-creation action navigates here, and allow-listing only the entry
/// screen would send that navigation straight back.
///
/// **This screen covers steps 1 and 2 of an eight-step flow.** It submits
/// `POST /auth/register/manual` and, only if that succeeds, requests the first
/// emailed PIN with `POST .../verification/{id}/pin`. It creates no session and
/// no account: manual finalization happens later and returns no tokens
/// (`ux-discovery.md` §A.4). The success state therefore says a PIN was sent, and
/// does not claim registration is finished.
///
/// No PIN-entry screen exists in this client, so the success state ends here
/// rather than navigating to a route that does not exist or inventing a
/// verification flow. PIN entry, resend, continuation and finalization are the
/// next milestone.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// True from the first request until both calls settle.
  ///
  /// Guards the double submission the disabled button also prevents: a keyboard
  /// "done" action and a tap can otherwise overlap, and the two calls must never
  /// run twice for one press.
  bool _submitting = false;

  /// Client-owned copy for the failure that stopped this attempt.
  String? _failureMessage;

  /// The address a PIN was sent to, or null while registration has not completed
  /// both calls. Non-null is the success state.
  String? _pinSentTo;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    // Empty and malformed input only. The backend owns the address rule and its
    // normalization (`required,email,max=255`), so this deliberately does not
    // mirror a length bound or rewrite the value beyond trimming the field's own
    // whitespace.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final repository = ref.read(authRepositoryProvider);

    setState(() {
      _submitting = true;
      _failureMessage = null;
    });

    try {
      // The two calls are one user action and must stay ordered: the PIN request
      // needs the id this call creates. A retry starts from step 1 again because
      // no id is persisted, and the backend resumes an existing registration
      // rather than creating a second one.
      final verificationId = await repository.registerManual(email: email);
      await repository.createPin(verificationId: verificationId);

      if (!mounted) return;
      if (GoRouter.maybeOf(context) != null) {
        context.go('/sign-up/verify/$verificationId');
        return;
      }
      setState(() {
        _submitting = false;
        _pinSentTo = email;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage = registrationMessageFor(failure);
      });
    } catch (_) {
      // Every expected outcome is an `ApiFailure`. Anything else is a defect, and
      // the user is told the attempt did not complete rather than shown a stack
      // trace.
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage =
            'Something went wrong starting your registration. Try again.';
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
            // The whole screen scrolls, so a keyboard inset on a short device
            // does not clip the form or the failure band.
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
                  if (_pinSentTo case final email?)
                    _buildPinSent(tokens, email)
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

  /// The email form, before either call has completed.
  Widget _buildForm(AppTokens tokens) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create your account',
            style: AppTypography.screenHeading.copyWith(
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppMetrics.space1),
          Text(
            'Enter your email address. We will send you a PIN to confirm it.',
            style: AppTypography.body.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppMetrics.space6),
          AppField(
            label: 'Email',
            controller: _emailController,
            enabled: !_submitting,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Enter your email address.';
              if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          if (_failureMessage case final message?) ...[
            const SizedBox(height: AppMetrics.space4),
            AuthMessageBand(
              message: message,
              onDismiss: _dismissFailure,
              tone: AuthMessageTone.danger,
            ),
          ],
          const SizedBox(height: AppMetrics.space6),
          AppButton(
            label: 'Send PIN',
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppMetrics.space3),
          _SignInPrompt(onPressed: _openSignIn),
        ],
      ),
    );
  }

  /// The success state: both calls completed and a PIN was issued by email.
  ///
  /// It states only what the two successful responses establish — a PIN was sent
  /// — and does not say the account exists. The note about PIN entry is honest
  /// rather than decorative: there is no verification screen in this client, and
  /// telling the user to enter a PIN they cannot enter would be a dead end
  /// presented as progress.
  Widget _buildPinSent(AppTokens tokens, String email) {
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
        const SizedBox(height: AppMetrics.space1),
        Text(
          'We sent a PIN to $email. You will need it to finish creating your '
          'account.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppMetrics.space4),
        Text(
          'PIN verification is not available in this version yet.',
          style: AppTypography.meta.copyWith(color: tokens.textSecondary),
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

  /// Leaves registration for the existing sign-in form.
  ///
  /// A replacement rather than a push, exactly as the entry screen reaches its
  /// two auth actions: the auth screens are peers, and stacking them would leave
  /// a stale form underneath.
  void _openSignIn() => context.go(AppRoutes.signIn);

  /// Clears a failure so the form can be corrected and resubmitted.
  ///
  /// A dismissal, not a retry button. A retry of the same request would repeat an
  /// outcome the server has already refused, and the user edits and submits
  /// deliberately.
  void _dismissFailure() => setState(() => _failureMessage = null);
}

/// The quiet route to the sign-in form, kept on the sign-up screen so an existing
/// account is never stranded.
class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Already have an account?',
            style: AppTypography.meta.copyWith(color: tokens.textSecondary),
          ),
        ),
        AppButton(
          label: 'Sign in',
          variant: AppButtonVariant.quiet,
          small: true,
          block: false,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

/// Client-owned copy for a registration start that did not reach PIN issuance.
///
/// **[D22] Selected from the typed [ApiFailure], never from `error.message`.**
/// Each registration variant has a different correction, so collapsing them into
/// one "registration failed" sentence would hide the only actionable part.
///
/// **[D15] The uncertain outcomes stay uncertain.** A transport failure, an
/// unreadable reply and an unconfirmed email delivery all say what is *not*
/// known. In particular, an unreadable `201` from `createPin` is not evidence
/// that no PIN was issued or emailed — the server persisted the code before
/// answering — so the copy points at the inbox instead of claiming failure.
String registrationMessageFor(ApiFailure failure) {
  return switch (failure) {
    // The registration is already finished. Retrying cannot help; the correction
    // is the sign-in form, which this screen keeps on screen.
    ApiFailureRegistrationAlreadyCompleted() =>
      'An account already exists for this email. Sign in instead.',

    // Another request won the unique-constraint race. Nothing about the address
    // is wrong, so the copy asks for the same call again rather than an edit.
    ApiFailureRegistrationRetryable() =>
      'Another sign-up attempt was already in progress. Try again.',

    ApiFailureRegistrationRestartRequired() =>
      'That registration can no longer continue. Start a new one.',

    // The server states no remaining wait on this refusal, so no countdown is
    // offered. It is a cooldown, not a rate-limit budget: there is no
    // `Retry-After` to report.
    ApiFailureVerificationResendCooldown() =>
      'A PIN was sent to this email recently. Try again shortly.',

    // The PIN was persisted; only handing it to the email sender failed. The
    // copy must not say registration failed, because it did not.
    ApiFailurePinEmailDeliveryFailed() =>
      'We could not confirm the PIN email was sent. Check your inbox before '
          'trying again.',

    ApiFailureRateLimited(:final retryAfter) =>
      retryAfter != null
          ? 'Too many attempts. Try again in ${retryAfter.inSeconds} seconds.'
          : 'Too many attempts. Try again shortly.',

    ApiFailureServerUnavailable() =>
      'Sign-up is temporarily unavailable. Try again shortly.',

    ApiFailureServerFault() =>
      'The server could not start your registration. Try again shortly.',

    // The one case that may say the outcome is unconfirmed. The request may have
    // been applied even though no answer arrived.
    ApiFailureTransport() =>
      'No connection to the server. We could not confirm whether your '
          'registration started.',

    // A reply arrived but its body could not be read. For a write that is not
    // proof the write failed: the two shapes this variant covers mean opposite
    // things, so the user is told to check the inbox rather than that no PIN was
    // sent.
    ApiFailureUnreadableResponse() =>
      'We could not read the server\'s reply, so we cannot confirm whether your '
          'registration started or a PIN was sent. Check your inbox before '
          'trying again.',

    ApiFailureValidation() => 'Check your email address, then try again.',

    // None of these can be produced by the two unauthenticated registration-start
    // routes: they are resource, profile, collection, session and storage
    // outcomes. Grouped with the malformed-request case rather than given copy
    // for a state this screen cannot reach, which keeps the taxonomy exhaustive
    // without inventing a correction.
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
    ApiFailureAuthRequired() ||
    ApiFailureInvalidVerificationCode() ||
    ApiFailureVerificationCodeAttemptsExceeded() ||
    ApiFailureRegistrationContinuationRequired() ||
    ApiFailureRegistrationContinuationConsumed() ||
    ApiFailureRegistrationContinuationExpired() ||
    ApiFailureInvalidRegistrationType() ||
    ApiFailureSessionEnded() ||
    ApiFailureRefreshUncertain() ||
    ApiFailureCredentialStorage() =>
      'We could not start your registration. Try again.',
  };
}
