import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/auth/application/session_controller.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Manual sign-in, following `docs/design-explorations/auth.html`.
///
/// Reached only through the router redirect, so this screen does not check
/// whether a session exists — doing so in both places is how the two drift
/// apart.
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
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

/// Copy for a session that ended while the user was elsewhere.
///
/// One string, two callers: the message shown when the screen mounts onto an
/// ended session, and [messageFor]'s `ApiFailureSessionEnded` case. Keeping them
/// the same constant is what stops the two explanations of one event from
/// drifting apart.
///
/// **Neutral and factual.** It says the session ended and what to do next, and
/// makes no claim about why — the backend's reason is not shown to users
/// ([D22]), and an expiry the user did not cause is not presented as a mistake
/// they made.
const String sessionEndedMessage =
    'Your session has ended. Sign in again to continue.';

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
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
  _MessageTone _messageTone = _MessageTone.danger;

  @override
  void initState() {
    super.initState();

    // A session can end while the user is somewhere else entirely: a renewal the
    // backend refuses terminally clears the credentials, the router sends them
    // here, and nothing else would say why. The reason is *consumed* rather than
    // stored, so it appears once and never repeats on a rebuild or a later visit
    // — see `SessionController.consumeSessionEnded`.
    //
    // A deliberate sign-out does not set it: `AuthState.signOut` discards the
    // session directly rather than ending it, so asking to be signed out is never
    // reported back as an expiry. An ambiguous renewal failure does not set it
    // either, because nothing ended the session — only `_endSession` does.
    if (ref.read(sessionControllerProvider.notifier).consumeSessionEnded()) {
      _message = sessionEndedMessage;

      // Warning, not danger: `design-system.md` §6.5 files expiry under Warning.
      // Nothing the user did failed here — a session simply lapsed — and a danger
      // band would read as a mistake of theirs.
      _messageTone = _MessageTone.warning;
    }
  }

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
        _messageTone = _MessageTone.danger;
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
        _messageTone = _MessageTone.danger;
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
                    const _BrandRow(),
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
                      _SignInMessage(
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
}

/// The wordmark and its mark, the one place the brand is set.
class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Row(
      children: [
        Container(
          width: AppMetrics.brandMarkSize,
          height: AppMetrics.brandMarkSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: tokens.accent,
              width: AppMetrics.borderWidthEmphasis,
            ),
            borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.accent,
                borderRadius: BorderRadius.circular(1),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const SizedBox(width: AppMetrics.space2),
        // Written uppercase at the call site: Flutter has no text-transform.
        Text(
          'STASH-IT',
          style: AppTypography.wordmark.copyWith(
            fontSize: 12,
            color: tokens.textPrimary,
          ),
        ),
      ],
    );
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

    // `ApiFailureNotFound` is unreachable on these routes: none of them answers
    // `RESOURCE_NOT_FOUND`. `ApiFailureCollectionNameAlreadyExists` is likewise
    // a move-route conflict. Both are grouped with the unreadable replies rather
    // than given sign-in copy for an outcome sign-in cannot produce, and the
    // closed taxonomy stays exhaustive.
    ApiFailureNotFound() ||
    ApiFailureCollectionNameAlreadyExists() ||
    ApiFailureMalformedRequest() ||
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

/// How a message band presents itself.
///
/// `design-system.md` §6.5 gives five feedback treatments. Only two of them can
/// appear here, and the distinction is the point rather than decoration:
///
/// | Situation | Treatment | Mark |
/// | --- | --- | --- |
/// | **Warning** (budget spent, **expiry**) | `warning-soft` + `warning-border` | filled |
/// | **Failure** (known) | `danger-soft` + `danger-border` | filled |
///
/// An expiry is filed under Warning by the specification, so it must not wear the
/// Failure colours: the user did not do anything wrong, and a danger band reads
/// as a mistake they made. The fifth row — **Uncertain**, the same warning colours
/// with a *hollow* mark — is deliberately not modelled here. Nothing on this
/// screen reports an outcome the client cannot determine, so adding a third tone
/// now would be a case with no caller.
enum _MessageTone {
  /// A confirmed failure of something the user attempted.
  danger,

  /// Something lapsed without the user attempting it.
  warning,
}

/// A message the user can dismiss.
///
/// The tone decides the fill, border and mark; the layout is identical either
/// way, so a change of treatment never changes the band's height or its
/// wrapping.
///
/// The message and Dismiss share one row. They were stacked, and because
/// Material gives a `TextButton` a 48 px minimum target the dismiss row alone
/// was taller than the sentence above it, so a one-line failure occupied roughly
/// a hundred pixels with an empty gap under the text. Inline, the band is as
/// tall as the message it has to show — and a longer message still wraps, because
/// the text is the flexible child and Dismiss is not.
class _SignInMessage extends StatelessWidget {
  const _SignInMessage({
    required this.message,
    required this.onDismiss,
    this.tone = _MessageTone.danger,
  });

  final String message;
  final VoidCallback onDismiss;

  /// Defaults to [_MessageTone.danger], so every ordinary sign-in failure keeps
  /// the treatment it has always had without each call site naming it.
  final _MessageTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    final fill = switch (tone) {
      _MessageTone.danger => tokens.dangerSoft,
      _MessageTone.warning => tokens.warningSoft,
    };
    final border = switch (tone) {
      _MessageTone.danger => tokens.dangerBorder,
      _MessageTone.warning => tokens.warningBorder,
    };
    final mark = switch (tone) {
      _MessageTone.danger => tokens.danger,
      _MessageTone.warning => tokens.warning,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.space3),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Row(
        // Centred, so a single-line message and its dismiss action read as one
        // unit rather than as two unrelated rows.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The flexible child: this is what wraps when a message is long.
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  // Sits on the first line's baseline rather than the row's top.
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(width: 5, height: 5, color: mark),
                ),
                const SizedBox(width: AppMetrics.space2),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.meta.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              // 32 px rather than Material's 48: the band is a confirmation of
              // a failure, not the primary action, and its own target still
              // clears WCAG 2.5.8's 24 px minimum by a comfortable margin.
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(
                horizontal: AppMetrics.space2,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
