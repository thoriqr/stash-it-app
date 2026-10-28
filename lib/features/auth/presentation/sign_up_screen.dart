import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/registration_recovery.dart';
import 'package:stash_it_app/features/auth/data/auth_repository.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';
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
/// **This screen branches on `verification_status`.** A `pending` response (or a
/// missing/unknown status from an older backend) requests the first emailed PIN
/// and enters the verification flow. A `verified` response means PIN verification
/// has already completed and **no PIN may be requested**: the screen either
/// recovers the continuation token this device persisted after verification and
/// goes straight to finalization, or offers an explicit recovery through
/// `POST /auth/register/recovery/manual` when this device has no usable token.
///
/// **Recovery is never automatic.** Merely receiving `verified`, finding no
/// token, rebuilding the widget or hitting an error does not call the recovery
/// endpoint. The user must tap `Recover this registration`, because that action
/// is what sends the recovery PIN.
///
/// It creates no session and no account: manual finalization happens later and
/// returns no tokens (`ux-discovery.md` §A.4).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

/// Why the verified-registration state is showing.
enum _BlockedReason {
  /// The registration is verified but this device holds no matching continuation
  /// token. Explicit recovery is the only way forward.
  noToken,

  /// A matching continuation exists, but checking it produced an unconfirmed or
  /// ambiguous result. The token is retained until the user explicitly chooses
  /// recovery or a later check returns a terminal outcome.
  savedCodeUnconfirmed,
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// True from the first request until the submission settles.
  ///
  /// Guards the double submission the disabled button also prevents: a keyboard
  /// "done" action and a tap can otherwise overlap, and the requests must never
  /// run twice for one press.
  bool _submitting = false;

  /// Client-owned copy for the failure that stopped this attempt.
  String? _failureMessage;

  /// The address a PIN was sent to, or null while registration has not completed
  /// both calls. Non-null is the no-router success fallback used by tests; a
  /// routed app navigates to the PIN screen instead.
  String? _pinSentTo;

  /// The address whose registration is verified but cannot be finished from the
  /// state this device holds. Non-null shows the recovery state instead of the
  /// form.
  String? _verifiedBlockedEmail;

  /// Why the recovery state is showing, or null when it is not.
  _BlockedReason? _blockedReason;

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

    await _start(_emailController.text.trim());
  }

  /// Runs one registration decision for [email].
  ///
  /// The sequence is fixed by the response: `register/manual` always comes first,
  /// because its `verification_status` decides whether a PIN is even a valid
  /// request. At most two `register/manual` calls happen per user action: this one,
  /// and one replacement when a stored continuation is refused terminally.
  Future<void> _start(String email, {bool allowReplacement = true}) async {
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(registrationContinuationStoreProvider);

    setState(() {
      _submitting = true;
      _failureMessage = null;
      _pinSentTo = null;
      _verifiedBlockedEmail = null;
      _blockedReason = null;
    });

    try {
      final response = await repository.registerManual(email: email);
      if (!mounted) return;

      final stored = await _readStored(store);
      if (!mounted) return;

      final start = registrationStartFor(
        response: response,
        stored: stored,
        email: email,
      );

      switch (start) {
        case RegistrationStart.requestPin:
          // Do **not** clear a matching record here. A `pending` response can
          // now mean an open recovery request while the old continuation is
          // still valid; the successful verification writes the new token over
          // the single slot, and a terminal refusal clears it where it occurs.
          await _requestPinAndContinue(
            repository,
            response.verificationId,
            email,
          );
          return;

        case RegistrationStart.openFinalize:
          await _continueToFinalize(
            repository,
            store,
            stored!,
            email,
            allowReplacement: allowReplacement,
          );
          return;

        case RegistrationStart.verifiedWithoutToken:
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _verifiedBlockedEmail = email;
            _blockedReason = _BlockedReason.noToken;
          });
          return;
      }
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      // A completed registration invalidates any continuation this device still
      // holds for that address.
      if (failure is ApiFailureRegistrationAlreadyCompleted) {
        await _clearMatching(store, email);
      }
      if (!mounted) return;

      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = null;
        _blockedReason = null;
        _failureMessage = registrationMessageFor(failure);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = null;
        _blockedReason = null;
        _failureMessage =
            'Something went wrong starting your registration. Try again.';
      });
    }
  }

  /// Requests the first PIN and enters the verification flow.
  ///
  /// One refusal is deliberately advanced through rather than reported: a
  /// `VERIFICATION_RESEND_COOLDOWN` means a PIN for this still-pending
  /// verification was issued moments ago. The cooldown is checked before any
  /// budget is spent or code written, so no email was sent and the code the user
  /// already holds is the one that applies. The PIN screen's status read reports
  /// the real `resend_in_seconds`, so its countdown is correct.
  Future<void> _requestPinAndContinue(
    AuthRepository repository,
    String verificationId,
    String email,
  ) async {
    try {
      await repository.createPin(verificationId: verificationId);
    } on ApiFailureVerificationResendCooldown {
      // Enter the PIN flow; the existing code is the one that applies.
    }

    if (!mounted) return;

    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.signUpVerifyFor(verificationId), extra: email);
      return;
    }

    setState(() {
      _submitting = false;
      _verifiedBlockedEmail = null;
      _pinSentTo = email;
    });
  }

  /// Validates and follows a stored continuation for an already-verified
  /// registration.
  ///
  /// The token is checked before leaving sign-up so a dead one can be replaced in
  /// the same user action. A live one is handed to the finalization screen, which
  /// reads it again as it already did.
  Future<void> _continueToFinalize(
    AuthRepository repository,
    RegistrationContinuationStore store,
    StoredRegistrationContinuation stored,
    String email, {
    bool allowReplacement = true,
  }) async {
    try {
      final continuation = await repository.getRegistrationContinuation(
        continuationToken: stored.token,
      );
      if (!mounted) return;

      // Defense in depth: a token must never be applied to another address. The
      // store already matched the entered address, so a different server-side
      // address means the record is inconsistent; discard it rather than guess.
      if (normalizeRegistrationEmail(continuation.email) !=
          normalizeRegistrationEmail(email)) {
        await _clearStored(store, stored.token);
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _verifiedBlockedEmail = email;
          _blockedReason = _BlockedReason.noToken;
          _failureMessage =
              'We could not match that registration to this email. Try again '
              'with the same address.';
        });
        return;
      }

      if (GoRouter.maybeOf(context) != null) {
        context.go(AppRoutes.finalizeRegistration, extra: stored.token);
        return;
      }

      // No router is a test-only configuration: nothing can advance, so show the
      // recovery state instead of claiming the flow moved on.
      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = email;
        _blockedReason = _BlockedReason.noToken;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      final outcome = continuationOutcomeFor(failure);

      switch (outcome) {
        case ContinuationOutcome.consumed:
          await _clearStored(store, stored.token);
          if (!mounted) return;
          setState(() {
            _submitting = false;
            _verifiedBlockedEmail = null;
            _blockedReason = null;
            _failureMessage =
                'This registration was already completed. Sign in instead.';
          });
          return;

        case ContinuationOutcome.restartRequired:
          await _clearStored(store, stored.token);
          if (!mounted) return;
          if (!allowReplacement) {
            // The recovery fallback is bounded to one `/register/manual` call.
            // A terminally dead saved token therefore returns to the form
            // instead of issuing the replacement call a normal submission may
            // make.
            setState(() {
              _submitting = false;
              _verifiedBlockedEmail = null;
              _blockedReason = null;
              _failureMessage = registrationMessageFor(failure);
            });
            return;
          }
          await _requestReplacement(repository, store, email);
          return;

        case ContinuationOutcome.unconfirmed:
          // The token is retained. The user can retry the check, or explicitly
          // choose recovery (which discards this device's saved code).
          setState(() {
            _submitting = false;
            _verifiedBlockedEmail = email;
            _blockedReason = _BlockedReason.savedCodeUnconfirmed;
            _failureMessage = _recoveryMessageFor(failure);
          });
          return;
      }
    }
  }

  /// Requests one replacement registration after a stored continuation was
  /// refused terminally.
  ///
  /// This is the only second `register/manual` call a submission can make. A
  /// still-`verified` answer ends in the blocked state — there is no loop and no
  /// third request.
  Future<void> _requestReplacement(
    AuthRepository repository,
    RegistrationContinuationStore store,
    String email,
  ) async {
    try {
      final replacement = await repository.registerManual(email: email);
      if (!mounted) return;

      if (replacement.isVerified) {
        setState(() {
          _submitting = false;
          _verifiedBlockedEmail = email;
          _blockedReason = _BlockedReason.noToken;
        });
        return;
      }

      // Do not clear a matching record here: a `pending` response can mean an
      // open recovery request whose predecessor continuation is still valid.
      await _requestPinAndContinue(
        repository,
        replacement.verificationId,
        email,
      );
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _verifiedBlockedEmail = null;
        _blockedReason = null;
        _failureMessage = registrationMessageFor(failure);
      });
    }
  }

  /// Retries the saved continuation from the `savedCodeUnconfirmed` state.
  ///
  /// Only the continuation check is repeated; `/register/manual` is not called
  /// again. The token stays in the store until this check returns a terminal
  /// outcome or the user explicitly chooses recovery.
  Future<void> _retrySavedCode() async {
    final email = _verifiedBlockedEmail;
    if (email == null || _submitting) return;

    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(registrationContinuationStoreProvider);
    final stored = await _readStored(store);
    if (!mounted) return;

    if (stored == null || stored.email != normalizeRegistrationEmail(email)) {
      // The record disappeared or no longer belongs to this address. Offer
      // recovery rather than pretending the saved code still exists.
      setState(() {
        _blockedReason = _BlockedReason.noToken;
        _failureMessage = null;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _failureMessage = null;
    });
    await _continueToFinalize(repository, store, stored, email);
  }

  /// Starts an explicit recovery for the blocked registration.
  ///
  /// This is the only place that calls `POST /auth/register/recovery/manual`.
  /// It is reached only from a user tap, never from a probe, a rebuild or a
  /// failure.
  Future<void> _recoverRegistration() async {
    final email = _verifiedBlockedEmail;
    if (email == null || _submitting) return;

    final reason = _blockedReason;
    final repository = ref.read(authRepositoryProvider);
    final store = ref.read(registrationContinuationStoreProvider);

    setState(() {
      _submitting = true;
      _failureMessage = null;
    });

    if (reason == _BlockedReason.savedCodeUnconfirmed) {
      // The user explicitly chose recovery over an unverifiable saved code.
      // Best effort: a failure to clear must not block the recovery, and a
      // successful verification overwrites the single slot anyway.
      await _clearMatching(store, email);
      if (!mounted) return;
      // The saved code has been discarded, so even a failure below leaves the
      // no-token state rather than claiming a saved code still exists.
      setState(() => _blockedReason = _BlockedReason.noToken);
    }

    try {
      final recovery = await repository.initiateManualRecovery(email: email);
      if (!mounted) return;

      if (recovery.isVerified) {
        // The route is implemented and documented to answer `pending`. A
        // `verified` answer names no raw token, so it must not enter the PIN
        // flow or claim the registration can continue.
        setState(() {
          _submitting = false;
          _failureMessage = 'Recovery could not be started. Try again.';
        });
        return;
      }

      // Reuses the existing cooldown tolerance and the email route extra.
      await _requestPinAndContinue(repository, recovery.verificationId, email);
    } on ApiFailure catch (failure) {
      if (!mounted) return;

      if (failure is ApiFailureRegistrationAlreadyPending) {
        // The normal verification is still pending, so the recovery route
        // refuses this state without creating anything. The normal registration
        // flow is the continuation. This is the only fallback call, and
        // `allowReplacement: false` keeps it from issuing a second
        // `/register/manual` when a saved token turns out terminally dead.
        await _start(email, allowReplacement: false);
        return;
      }

      if (failure is ApiFailureRegistrationAlreadyCompleted) {
        await _clearMatching(store, email);
        if (!mounted) return;
      }

      final terminal =
          failure is ApiFailureRegistrationAlreadyCompleted ||
          failure is ApiFailureRegistrationRestartRequired ||
          failure is ApiFailureInvalidRegistrationType ||
          failure is ApiFailureValidation;

      setState(() {
        _submitting = false;
        if (terminal) {
          _verifiedBlockedEmail = null;
          _blockedReason = null;
        }
        _failureMessage = _recoveryStartMessageFor(failure);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _failureMessage = 'Something went wrong starting recovery. Try again.';
      });
    }
  }

  Future<StoredRegistrationContinuation?> _readStored(
    RegistrationContinuationStore store,
  ) async {
    // A platform read failure means this device cannot recover a continuation.
    // It must not make registration itself unusable.
    try {
      return await store.read();
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearStored(
    RegistrationContinuationStore store,
    String token,
  ) async {
    try {
      await store.clearIfToken(token);
    } catch (_) {
      // Best effort: the token is dead either way, and a storage failure must
      // not block the replacement flow.
    }
  }

  Future<void> _clearMatching(
    RegistrationContinuationStore store,
    String email,
  ) async {
    final stored = await _readStored(store);
    if (stored != null && stored.email == normalizeRegistrationEmail(email)) {
      await _clearStored(store, stored.token);
    }
  }

  String _recoveryMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureTransport() =>
        'No connection to the server. We could not check that registration. '
            'Try again.',
      ApiFailureUnreadableResponse() =>
        'We could not read the server\'s reply, so we could not check that '
            'registration. Try again.',
      ApiFailureServerUnavailable() || ApiFailureServerFault() =>
        'We could not check that registration. Try again shortly.',
      _ => registrationMessageFor(failure),
    };
  }

  String _recoveryStartMessageFor(ApiFailure failure) {
    return switch (failure) {
      ApiFailureTransport() =>
        'No connection to the server. We could not start recovery. Try again.',
      ApiFailureUnreadableResponse() =>
        'We could not confirm whether recovery started. Try again.',
      ApiFailureServerUnavailable() =>
        'Recovery is temporarily unavailable. Try again shortly.',
      ApiFailureServerFault() =>
        'We could not start recovery. Try again shortly.',
      ApiFailureValidation() => 'Check your email address, then try again.',
      _ => registrationMessageFor(failure),
    };
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
                  else if (_verifiedBlockedEmail case final email?)
                    _buildVerifiedBlocked(tokens, email)
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
  /// Reached only when no `GoRouter` is present, which is a test configuration;
  /// a routed app navigates to the PIN screen. It states only what the two
  /// successful responses establish — a PIN was sent — and does not say the
  /// account exists.
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
        const SizedBox(height: AppMetrics.space6),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.secondary,
          onPressed: _openSignIn,
        ),
      ],
    );
  }

  /// The recovery state for a verified registration this device cannot finish.
  ///
  /// `noToken` means no matching continuation exists; recovery is the only path.
  /// `savedCodeUnconfirmed` means a matching token exists but its check could
  /// not be completed; the token is kept until the user retries it, explicitly
  /// chooses recovery, or the backend returns a terminal outcome.
  ///
  /// Nothing here calls the recovery endpoint. Only a tap does.
  Widget _buildVerifiedBlocked(AppTokens tokens, String email) {
    final savedCodeUnconfirmed =
        _blockedReason == _BlockedReason.savedCodeUnconfirmed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Verification already complete',
          style: AppTypography.screenHeading.copyWith(
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: AppMetrics.space1),
        Text(
          savedCodeUnconfirmed
              ? 'We could not check the code saved on this device for $email. '
                    'Try again, or recover the registration with a new PIN. '
                    'Recovering replaces this device\'s saved code.'
              : 'This email has already been verified, but this device does not '
                    'have the code needed to finish it. Recover it with a new '
                    'PIN sent to $email.',
          style: AppTypography.body.copyWith(color: tokens.textSecondary),
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
        if (savedCodeUnconfirmed) ...[
          AppButton(
            label: 'Try again',
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _retrySavedCode,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: 'Recover this registration',
            variant: AppButtonVariant.secondary,
            onPressed: _submitting ? null : _recoverRegistration,
          ),
        ] else ...[
          AppButton(
            label: 'Recover this registration',
            variant: AppButtonVariant.primary,
            busy: _submitting,
            onPressed: _submitting ? null : _recoverRegistration,
          ),
          const SizedBox(height: AppMetrics.space3),
          AppButton(
            label: 'Use a different email',
            variant: AppButtonVariant.secondary,
            onPressed: _submitting ? null : _useDifferentEmail,
          ),
        ],
        const SizedBox(height: AppMetrics.space3),
        AppButton(
          label: 'Back to sign in',
          variant: AppButtonVariant.quiet,
          onPressed: _submitting ? null : _openSignIn,
        ),
      ],
    );
  }

  /// Returns to the email form, keeping the address so it can be edited rather
  /// than retyped, and clears every recovery message.
  void _useDifferentEmail() {
    setState(() {
      _verifiedBlockedEmail = null;
      _blockedReason = null;
      _failureMessage = null;
    });
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

    // The recovery route's refusal for a still-pending normal verification.
    // The recovery action handles it by falling back to the normal flow; this
    // copy only covers an unexpected surfacing.
    ApiFailureRegistrationAlreadyPending() =>
      'This registration is already waiting for a PIN. Continue with that step.',

    // Another request won the unique-constraint race. Nothing about the address
    // is wrong, so the copy asks for the same call again rather than an edit.
    ApiFailureRegistrationRetryable() =>
      'Another sign-up attempt was already in progress. Try again.',

    // A social registration for this address is live under another Google
    // identity. The current attempt cannot take it over while it is pending.
    ApiFailureRegistrationIdentityMismatch() =>
      'A sign-up for this email is already in progress with a different '
          'Google account. Try again after it expires.',

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

    // A stored continuation can be refused terminally during recovery. The
    // registration that owned it cannot be completed, so the correction is a new
    // flow rather than another try at the same token.
    ApiFailureRegistrationContinuationExpired() ||
    ApiFailureRegistrationContinuationRequired() ||
    ApiFailureInvalidRegistrationType() =>
      'That registration can no longer continue. Start a new one.',

    // Finalization is the only consumer of a continuation, so a consumed token
    // means the account was created. Do not offer a restart that would be refused
    // as an already-completed registration.
    ApiFailureRegistrationContinuationConsumed() =>
      'This registration was already completed. Sign in instead.',

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
    ApiFailureSessionEnded() ||
    ApiFailureRefreshUncertain() ||
    ApiFailureCredentialStorage() ||
    ApiFailurePasswordReset() ||
    ApiFailureGoogleAuth() =>
      'We could not start your registration. Try again.',
  };
}
