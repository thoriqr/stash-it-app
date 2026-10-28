import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/profile/application/password_update_controller.dart';
import 'package:stash_it_app/features/profile/application/profile_controller.dart';
import 'package:stash_it_app/features/profile/domain/user_profile.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';

/// Creates the account's first password, or changes the existing one.
///
/// **The mode is captured once per visit from the loaded profile and never
/// re-derived.** Re-reading `has_password_credential` mid-visit could replace the
/// form under the user's hands. The server remains authoritative: if the actual
/// credential state differs, it answers with one of the mode-conflict codes and
/// this screen closes so the next visit renders the right form.
///
/// The route is reachable directly as well as from Profile. If the profile has not
/// loaded, the screen shows its loading or failure state and **never defaults to
/// create**: guessing would show a first-password form to an account that already
/// has one.
class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  /// Null until the loaded profile supplies it. `true` means change, `false`
  /// means create.
  bool? _changeMode;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentServerError;
  String? _newServerError;
  ({String copy, FeedbackTone tone})? _notice;

  @override
  void initState() {
    super.initState();
    // `AsyncData`, not `hasValue`: an `AsyncLoading` can carry the profile of
    // the account that signed out, and its credential state must not choose the
    // form this account sees.
    final profile = ref.read(profileProvider);
    if (profile is AsyncData<UserProfile>) {
      _changeMode = profile.value.hasPasswordCredential;
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(passwordUpdateProvider)) return;
    final change = _changeMode;
    if (change == null) return;

    setState(() {
      _currentServerError = null;
      _newServerError = null;
      _notice = null;
    });

    if (_formKey.currentState?.validate() != true) return;

    final outcome = await ref
        .read(passwordUpdateProvider.notifier)
        .submit(
          change: change,
          newPassword: _newController.text,
          // Create mode omits the key entirely; the repository drops a null.
          currentPassword: change ? _currentController.text : null,
        );

    if (!mounted) return;

    switch (outcome) {
      case PasswordUpdateSucceeded() ||
          PasswordUpdateModeConflict() ||
          PasswordUpdateAccountUnavailable() ||
          PasswordUpdateUncertain() ||
          PasswordUpdateSessionRefused():
        Navigator.of(context).pop();

      case PasswordUpdateCurrentPasswordInvalid():
        setState(
          () => _currentServerError = 'That current password is incorrect.',
        );

      case PasswordUpdateValidation():
        setState(() => _newServerError = 'Use between 8 and 128 characters.');

      // A concurrent change won. The submitted current password is no longer the
      // stored one, so it is cleared rather than left looking usable.
      case PasswordUpdateAlreadyChanged():
        _currentController.clear();
        setState(() {
          _currentServerError =
              'Your password was changed somewhere else. Enter the current '
              'password again.';
        });

      case PasswordUpdateRejected(:final message, :final tone):
        setState(() => _notice = (copy: message, tone: tone));

      case PasswordUpdateIgnored():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);
    final profile = ref.watch(profileProvider);

    // Capture the mode when the profile arrives after this screen was pushed.
    // Once captured, later profile rebuilds leave it alone.
    ref.listen(profileProvider, (previous, next) {
      if (_changeMode == null && next is AsyncData<UserProfile>) {
        setState(() => _changeMode = next.value.hasPasswordCredential);
      }
    });

    final change = _changeMode;
    final busy = ref.watch(passwordUpdateProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          change == null
              ? 'PASSWORD'
              : change
              ? 'CHANGE PASSWORD'
              : 'CREATE PASSWORD',
        ),
        leading: canPop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: 'Back to Profile',
                onPressed: () => context.go(AppRoutes.profile),
              ),
      ),
      body: change == null
          ? _UnavailableBody(
              profile: profile,
              tokens: tokens,
              onRetry: () => ref.read(profileProvider.notifier).retry(),
            )
          : _buildForm(context, tokens, change: change, busy: busy),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppTokens tokens, {
    required bool change,
    required bool busy,
  }) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppMetrics.screenPadding,
            AppMetrics.space5,
            AppMetrics.screenPadding,
            AppMetrics.space6 + viewInsets.bottom,
          ),
          children: [
            Text(
              change
                  ? 'Choose a new password for your account.'
                  : 'Add a password so you can sign in with your email '
                        'address.',
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: AppMetrics.space5),
            if (change) ...[
              AppField(
                label: 'Current password',
                controller: _currentController,
                enabled: !busy,
                obscureText: _obscureCurrent,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.next,
                errorText: _currentServerError,
                onChanged: (_) {
                  if (_currentServerError == null) return;
                  setState(() => _currentServerError = null);
                },
                suffixIcon: _visibilityToggle(
                  tokens: tokens,
                  obscured: _obscureCurrent,
                  showLabel: 'Show current password',
                  hideLabel: 'Hide current password',
                  enabled: !busy,
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'Enter your current password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppMetrics.space4),
            ],
            AppField(
              label: 'New password',
              controller: _newController,
              enabled: !busy,
              obscureText: _obscureNew,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              errorText: _newServerError,
              onChanged: (_) {
                if (_newServerError == null) return;
                setState(() => _newServerError = null);
              },
              suffixIcon: _visibilityToggle(
                tokens: tokens,
                obscured: _obscureNew,
                showLabel: 'Show new password',
                hideLabel: 'Hide new password',
                enabled: !busy,
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
              validator: (value) {
                final length = (value ?? '').runes.length;
                if (length < 8 || length > 128) {
                  return 'Use between 8 and 128 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppMetrics.space4),
            AppField(
              label: 'Confirm new password',
              controller: _confirmController,
              enabled: !busy,
              obscureText: _obscureConfirm,
              // No autofill hint here: the requirement is one password-manager
              // suggestion, on the new-password field. A second `newPassword`
              // hint would offer to fill a confirmation the server never sees.
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              suffixIcon: _visibilityToggle(
                tokens: tokens,
                obscured: _obscureConfirm,
                showLabel: 'Show confirmation password',
                hideLabel: 'Hide confirmation password',
                enabled: !busy,
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (value) {
                if ((value ?? '') != _newController.text) {
                  return 'The passwords do not match.';
                }
                return null;
              },
            ),
            if (_notice case final notice?) ...[
              const SizedBox(height: AppMetrics.space4),
              _PasswordNotice(notice: notice, tokens: tokens),
            ],
            const SizedBox(height: AppMetrics.space6),
            AppButton(
              label: change ? 'Change password' : 'Create password',
              variant: AppButtonVariant.primary,
              busy: busy,
              onPressed: busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityToggle({
    required AppTokens tokens,
    required bool obscured,
    required String showLabel,
    required String hideLabel,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      tooltip: obscured ? showLabel : hideLabel,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      iconSize: AppMetrics.iconSize,
      color: tokens.textTertiary,
      padding: EdgeInsets.zero,
    );
  }
}

/// The profile has not supplied the mode yet.
///
/// Loading is not a reason to default to create: a first-password form shown to an
/// account that already has a password is a form whose submission the server will
/// refuse. The failure state offers a retry and nothing else.
class _UnavailableBody extends StatelessWidget {
  const _UnavailableBody({
    required this.profile,
    required this.tokens,
    required this.onRetry,
  });

  final AsyncValue<UserProfile> profile;
  final AppTokens tokens;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (profile.hasError) {
      return ListView(
        padding: const EdgeInsets.all(AppMetrics.screenPadding),
        children: [
          Text(
            _modeFailureCopy(profile.error!),
            style: AppTypography.body.copyWith(color: tokens.textPrimary),
          ),
          const SizedBox(height: AppMetrics.space3),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Retry',
              variant: AppButtonVariant.secondary,
              block: false,
              onPressed: onRetry,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: tokens.accent,
            ),
          ),
          const SizedBox(width: AppMetrics.space2),
          Flexible(
            child: Text(
              'Loading profile…',
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

String _modeFailureCopy(Object error) => switch (error) {
  ApiFailureSessionEnded() => 'Your session has ended. Sign in again.',
  ApiFailureAuthRequired() => 'Sign in again to set your password.',
  ApiFailureUserNotFound() => 'This account is no longer available.',
  ApiFailureServerUnavailable() =>
    'Profile is temporarily unavailable. Try again shortly.',
  ApiFailureTransport() => 'No connection. We could not load your profile.',
  _ => 'We could not load your profile. Try again.',
};

/// A known not-set refusal that is not tied to one field.
class _PasswordNotice extends StatelessWidget {
  const _PasswordNotice({required this.notice, required this.tokens});

  final ({String copy, FeedbackTone tone}) notice;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    final (fill, border, mark) = switch (notice.tone) {
      FeedbackTone.warning => (
        tokens.warningSoft,
        tokens.warningBorder,
        tokens.warning,
      ),
      _ => (tokens.dangerSoft, tokens.dangerBorder, tokens.danger),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(width: 5, height: 5, color: mark),
          ),
          const SizedBox(width: AppMetrics.space2),
          Expanded(
            child: Text(
              notice.copy,
              style: AppTypography.meta.copyWith(color: tokens.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
