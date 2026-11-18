import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/save_pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_url_save_summary_copy.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';
import 'package:stash_it_app/shared/widgets/desktop_layout.dart';
import 'package:stash_it_app/shared/widgets/note_composer_sheet.dart';

final AppFeedback _noteSaveError = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.pendingUrlsNoteSaveError,
);

/// The device-local fallback list.
///
/// **Not an authenticated destination.** It reads the local store and is
/// allowed by the router while signed out, so it can be opened from the auth
/// entry screen before a user has ever registered. It never calls the API on
/// open and never requires a session.
///
/// Rows are inspect-only except for the device-local note, which can be added
/// or edited without a request. There is no per-row retry, delete, or
/// collection assignment. The one account write is the explicit bulk save
/// action:
/// signed out it points at sign-in, signed in it submits the local list
/// sequentially through the existing `POST /saved-items` path. A confirmed
/// entry is removed; a rejected or unconfirmed entry stays.
class PendingUrlsScreen extends ConsumerWidget {
  const PendingUrlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final pending = ref.watch(pendingUrlsProvider);
    final auth = ref.watch(authStateProvider);
    final saveState = ref.watch(savePendingUrlsProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingUrlsTitle),
        leading: canPop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: auth.isSignedIn
                    ? l10n.pendingUrlsBackToInbox
                    : l10n.pendingUrlsBackToSignIn,
                onPressed: () => context.go(
                  auth.isSignedIn ? AppRoutes.inbox : AppRoutes.auth,
                ),
              ),
      ),
      body: DesktopContentFrame(
        child: switch (pending) {
          AsyncData(:final value) => _LoadedBody(
            entries: value.entries,
            isSignedIn: auth.isSignedIn,
            saveState: saveState,
            onSave: () {
              ref.read(savePendingUrlsProvider.notifier).saveAll();
            },
            onSignIn: () => context.go(AppRoutes.signIn),
          ),
          AsyncError(isLoading: false) => _ErrorState(
            onRetry: () => ref.invalidate(pendingUrlsProvider),
          ),
          _ => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppMetrics.space6),
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
                      l10n.pendingUrlsLoading,
                      style: AppTypography.body.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({
    required this.entries,
    required this.isSignedIn,
    required this.saveState,
    required this.onSave,
    required this.onSignIn,
  });

  final List<PendingUrl> entries;
  final bool isSignedIn;
  final PendingUrlSaveState saveState;
  final VoidCallback onSave;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entries.isNotEmpty) _Intro(isSignedIn: isSignedIn),
        if (entries.isNotEmpty || saveState.lastSummary != null)
          _SavePanel(
            hasEntries: entries.isNotEmpty,
            isSignedIn: isSignedIn,
            saveState: saveState,
            onSave: onSave,
            onSignIn: onSignIn,
          ),
        Expanded(
          child: entries.isEmpty
              ? const _EmptyState()
              : _PendingUrlList(entries: entries),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.isSignedIn});

  final bool isSignedIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    final explanation = isSignedIn
        ? l10n.pendingUrlsSignedInIntro
        : l10n.pendingUrlsSignedOutIntro;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space4,
        AppMetrics.space4,
        AppMetrics.space4,
        0,
      ),
      child: Text(
        explanation,
        style: AppTypography.body.copyWith(color: tokens.textSecondary),
      ),
    );
  }
}

/// The one primary action and the one outcome band.
///
/// The button is present only when there is something to save or when a
/// previous summary needs a place to live. A run in flight shows the busy
/// button and a progress line; a completed run shows one persistent summary.
class _SavePanel extends StatelessWidget {
  const _SavePanel({
    required this.hasEntries,
    required this.isSignedIn,
    required this.saveState,
    required this.onSave,
    required this.onSignIn,
  });

  final bool hasEntries;
  final bool isSignedIn;
  final PendingUrlSaveState saveState;
  final VoidCallback onSave;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final summary = saveState.lastSummary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space4,
        AppMetrics.space3,
        AppMetrics.space4,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasEntries)
            saveState.isRunning
                ? AppButton(
                    label: l10n.pendingUrlsSaveAllAction,
                    variant: AppButtonVariant.primary,
                    busy: true,
                    onPressed: onSave,
                  )
                : isSignedIn
                ? AppButton(
                    label: l10n.pendingUrlsSaveAllAction,
                    variant: AppButtonVariant.primary,
                    onPressed: onSave,
                  )
                : AppButton(
                    label: l10n.pendingUrlsSignInAction,
                    variant: AppButtonVariant.primary,
                    onPressed: onSignIn,
                  ),
          if (hasEntries && saveState.isRunning) ...[
            const SizedBox(height: AppMetrics.space2),
            Text(
              _progressLabel(saveState, l10n),
              textAlign: TextAlign.center,
              style: AppTypography.meta.copyWith(color: tokens.textSecondary),
            ),
          ],
          if (!saveState.isRunning && summary != null) ...[
            const SizedBox(height: AppMetrics.space3),
            Semantics(
              liveRegion: true,
              container: true,
              child: FeedbackNotice(
                feedback: pendingUrlSaveSummaryFeedback(summary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _progressLabel(
  PendingUrlSaveState state,
  AppLocalizations localizations,
) {
  final total = state.total;
  if (total <= 1) return localizations.pendingUrlsSaving;

  final current = state.processed + 1 < total ? state.processed + 1 : total;
  return localizations.pendingUrlsSavingProgress(current, total);
}

class _PendingUrlList extends StatelessWidget {
  const _PendingUrlList({required this.entries});

  final List<PendingUrl> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppMetrics.space3,
        AppMetrics.space3,
        AppMetrics.space3,
        AppMetrics.space4,
      ),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, index) => _PendingUrlRow(entry: entries[index]),
    );
  }
}

class _PendingUrlRow extends ConsumerWidget {
  const _PendingUrlRow({required this.entry});

  final PendingUrl entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppMetrics.space3),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.border),
        borderRadius: const BorderRadius.all(AppMetrics.slotRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.url,
            style: AppTypography.mono.copyWith(color: tokens.textPrimary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppMetrics.space2),
          _PendingNote(note: entry.note, onTap: () => _editNote(context, ref)),
          const SizedBox(height: AppMetrics.space2),
          Wrap(
            spacing: AppMetrics.space2,
            runSpacing: AppMetrics.space1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _keptLabel(entry.addedAt, DateTime.now().toUtc(), l10n),
                style: AppTypography.meta.copyWith(color: tokens.textTertiary),
              ),
              if (entry.uncertain)
                Text(
                  l10n.pendingUrlsSaveNotConfirmed,
                  style: AppTypography.label.copyWith(color: tokens.warning),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Edits the note locally. No request is made and no session is required.
  Future<void> _editNote(BuildContext context, WidgetRef ref) async {
    final result = await showNoteComposerSheet(
      context,
      initialNote: entry.note ?? '',
    );
    if (result == null) return;

    try {
      await ref
          .read(pendingUrlsProvider.notifier)
          .updateNote(entry.url, result);
    } catch (_) {
      if (!context.mounted) return;
      ref.read(feedbackProvider.notifier).show(_noteSaveError);
    }
  }
}

/// The local note on one kept URL: a two-line preview, or an add affordance.
///
/// The whole surface opens the local editor. It never calls the API; the note
/// is sent later only if the user saves this entry to an account.
class _PendingNote extends StatelessWidget {
  const _PendingNote({required this.note, required this.onTap});

  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);
    final hasNote = note?.trim().isNotEmpty ?? false;

    return Semantics(
      button: true,
      container: true,
      label: hasNote ? l10n.inboxYourNote : l10n.savedItemAddNote,
      child: Material(
        color: tokens.surfaceInset,
        borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
        child: InkWell(
          borderRadius: const BorderRadius.all(AppMetrics.controlRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMetrics.space2,
              vertical: 7,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    hasNote
                        ? Icons.sticky_note_2_outlined
                        : Icons.note_add_outlined,
                    size: 14,
                    color: tokens.textTertiary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: hasNote
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.inboxYourNote,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.meta.copyWith(
                                color: tokens.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              note!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body.copyWith(
                                fontSize: 12.5,
                                height: 1.4,
                                color: tokens.textSecondary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          l10n.savedItemAddNote,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.meta.copyWith(
                            color: tokens.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: tokens.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pendingUrlsEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              l10n.pendingUrlsEmptyBody,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pendingUrlsReadError,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: AppMetrics.space4),
            AppButton(
              label: l10n.pendingUrlsRetry,
              variant: AppButtonVariant.secondary,
              block: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// The relative age shown under a locally kept URL.
///
/// The seven-day retention means the largest value is `6 days ago`.
String _keptLabel(
  DateTime addedAt,
  DateTime now,
  AppLocalizations localizations,
) {
  final age = now.difference(addedAt);
  if (age.inMinutes < 1) return localizations.pendingUrlsKeptJustNow;
  if (age.inMinutes < 60) {
    return localizations.pendingUrlsKeptMinutesAgo(age.inMinutes);
  }
  if (age.inHours < 24) {
    return localizations.pendingUrlsKeptHoursAgo(age.inHours);
  }
  if (age.inDays == 1) return localizations.pendingUrlsKeptYesterday;
  return localizations.pendingUrlsKeptDaysAgo(age.inDays);
}
