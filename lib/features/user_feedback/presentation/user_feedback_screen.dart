import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/user_feedback/application/user_feedback_controller.dart';
import 'package:stash_it_app/features/user_feedback/application/user_feedback_submission_state.dart';
import 'package:stash_it_app/features/user_feedback/domain/user_feedback_type.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/app_confirm_dialog.dart';
import 'package:stash_it_app/shared/widgets/app_field.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';

/// The user feedback form.
///
/// A full-screen route because the message is multiline and the draft must
/// survive keyboard and rate-limit states. The form never calls the API
/// directly; [UserFeedbackController] owns the request and the success notice.
class UserFeedbackScreen extends ConsumerStatefulWidget {
  const UserFeedbackScreen({super.key});

  @override
  ConsumerState<UserFeedbackScreen> createState() => _UserFeedbackScreenState();
}

class _UserFeedbackScreenState extends ConsumerState<UserFeedbackScreen> {
  static const int _maxMessageRunes = 5000;

  final _messageController = TextEditingController();
  UserFeedbackType? _type;
  String? _typeError;
  String? _messageError;
  ApiFailure? _failure;
  DateTime? _retryAt;
  Timer? _retryTimer;

  bool get _hasDraft => _messageController.text.isNotEmpty || _type != null;

  @override
  void dispose() {
    _retryTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _onMessageChanged(String value) {
    setState(() {
      _messageError = null;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final type = _type;
    final message = _messageController.text;
    final runeCount = message.runes.length;

    final typeError = type == null ? l10n.userFeedbackTypeRequired : null;
    String? messageError;
    if (message.trim().isEmpty) {
      messageError = l10n.userFeedbackMessageRequired;
    } else if (runeCount > _maxMessageRunes) {
      messageError = l10n.userFeedbackMessageTooLong;
    }

    if (typeError != null || messageError != null) {
      setState(() {
        _typeError = typeError;
        _messageError = messageError;
      });
      return;
    }
    if (type == null) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _typeError = null;
      _messageError = null;
      _failure = null;
    });

    final result = await ref
        .read(userFeedbackControllerProvider.notifier)
        .submit(type: type, message: message);

    if (!mounted) return;

    switch (result) {
      case UserFeedbackSubmitted():
        _leave();
      case UserFeedbackSubmitFailed(:final failure):
        _showFailure(failure);
      case UserFeedbackSubmitIgnored():
        break;
    }
  }

  void _showFailure(ApiFailure failure) {
    _retryTimer?.cancel();
    _retryTimer = null;

    DateTime? retryAt;
    if (failure case ApiFailureRateLimited(
      :final retryAfter,
    ) when retryAfter != null) {
      retryAt = DateTime.now().add(retryAfter);
      _retryTimer = Timer(retryAfter, () {
        if (!mounted) return;
        setState(() {
          _retryAt = null;
          _failure = null;
        });
      });
    }

    setState(() {
      _failure = failure;
      _retryAt = retryAt;
    });
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showAppConfirmDialog(
      context: context,
      title: l10n.userFeedbackDiscardTitle,
      message: l10n.userFeedbackDiscardMessage,
      cancelLabel: l10n.userFeedbackKeepEditing,
      confirmLabel: l10n.userFeedbackDiscard,
      destructive: true,
    );
    if (!mounted || discard != true) return;
    _leave();
  }

  void _leave() {
    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final sending = ref.watch(userFeedbackControllerProvider);
    final canPop = Navigator.of(context).canPop();
    final runeCount = _messageController.text.runes.length;

    return PopScope(
      canPop: !_hasDraft && !sending,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || sending || !_hasDraft) return;
        unawaited(_confirmDiscard());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.userFeedbackTitle),
          leading: canPop
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => context.go(AppRoutes.settings),
                ),
        ),
        body: DesktopContentFrame(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppMetrics.screenPadding,
              AppMetrics.space4,
              AppMetrics.screenPadding,
              AppMetrics.space6,
            ),
            children: [
              Text(
                l10n.userFeedbackIntro,
                style: AppTypography.body.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppMetrics.space5),
              Text(
                l10n.userFeedbackTypeLabel,
                style: AppTypography.label.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: AppMetrics.space2),
              SegmentedButton<UserFeedbackType>(
                segments: [
                  ButtonSegment(
                    value: UserFeedbackType.bug,
                    label: Text(l10n.userFeedbackTypeBug),
                  ),
                  ButtonSegment(
                    value: UserFeedbackType.idea,
                    label: Text(l10n.userFeedbackTypeIdea),
                  ),
                  ButtonSegment(
                    value: UserFeedbackType.other,
                    label: Text(l10n.userFeedbackTypeOther),
                  ),
                ],
                selected: _type == null ? const <UserFeedbackType>{} : {_type!},
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.isEmpty ? null : selection.first;
                    _typeError = null;
                  });
                },
              ),
              if (_typeError case final typeError?) ...[
                const SizedBox(height: AppMetrics.space1),
                Text(
                  typeError,
                  style: AppTypography.meta.copyWith(color: tokens.danger),
                ),
              ],
              const SizedBox(height: AppMetrics.space5),
              AppField(
                label: l10n.userFeedbackMessageLabel,
                controller: _messageController,
                placeholder: l10n.userFeedbackMessageHint,
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                errorText: _messageError,
                onChanged: _onMessageChanged,
              ),
              const SizedBox(height: AppMetrics.space2),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.userFeedbackCharacterCount(runeCount, _maxMessageRunes),
                  style: AppTypography.meta.copyWith(
                    color: runeCount > _maxMessageRunes
                        ? tokens.danger
                        : tokens.textTertiary,
                  ),
                ),
              ),
              if (_failure case final failure?) ...[
                const SizedBox(height: AppMetrics.space3),
                _FailureBanner(
                  message: _failureCopy(l10n, failure),
                  warning: failure is ApiFailureRateLimited,
                  tokens: tokens,
                ),
              ],
              const SizedBox(height: AppMetrics.space5),
              AppButton(
                label: sending
                    ? l10n.userFeedbackSending
                    : l10n.userFeedbackSubmit,
                variant: AppButtonVariant.primary,
                busy: sending,
                onPressed: sending || _retryAt != null ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _failureCopy(AppLocalizations l10n, ApiFailure failure) {
    return switch (failure) {
      ApiFailureRateLimited(:final retryAfter) =>
        retryAfter == null
            ? l10n.userFeedbackRateLimitedNoWait
            : l10n.userFeedbackRateLimitedWithWait(
                _formatWait(l10n, retryAfter),
              ),
      ApiFailureServerUnavailable() => l10n.userFeedbackUnavailable,
      ApiFailureValidation() ||
      ApiFailureMalformedRequest() => l10n.userFeedbackValidation,
      ApiFailureTransport() ||
      ApiFailureUnreadableResponse() => l10n.userFeedbackUnconfirmed,
      _ => l10n.userFeedbackSubmitFailed,
    };
  }

  String _formatWait(AppLocalizations l10n, Duration wait) {
    final seconds = wait.inSeconds;
    if (seconds <= 1) return l10n.retryAfterSecond;
    if (seconds < 60) return l10n.retryAfterSeconds(seconds);

    final minutes = (seconds / 60).ceil();
    if (minutes < 60) return l10n.retryAfterMinutes(minutes);

    return l10n.retryAfterHours((seconds / 3600).ceil());
  }
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({
    required this.message,
    required this.warning,
    required this.tokens,
  });

  final String message;
  final bool warning;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.space3),
      decoration: BoxDecoration(
        color: warning ? tokens.accentSoft : tokens.dangerSoft,
        border: Border.all(
          color: warning ? tokens.accentBorder : tokens.dangerBorder,
        ),
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
      ),
      child: Text(
        message,
        style: AppTypography.body.copyWith(
          color: warning ? tokens.accent : tokens.danger,
        ),
      ),
    );
  }
}
