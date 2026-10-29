import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/router/routes.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/save_pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_url_save_summary_copy.dart';
import 'package:stash_it_app/shared/widgets/app_button.dart';

/// The device-local fallback list.
///
/// **Not an authenticated destination.** It reads the local store and is
/// allowed by the router while signed out, so it can be opened from the auth
/// entry screen before a user has ever registered. It never calls the API on
/// open and never requires a session.
///
/// The rows are inspect-only: there is no per-row retry, delete, edit, or
/// collection assignment. The one write is the explicit bulk save action:
/// signed out it points at sign-in, signed in it submits the local list
/// sequentially through the existing `POST /saved-items` path. A confirmed
/// entry is removed; a rejected or unconfirmed entry stays.
class PendingUrlsScreen extends ConsumerWidget {
  const PendingUrlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppTheme.tokensOf(context);
    final pending = ref.watch(pendingUrlsProvider);
    final auth = ref.watch(authStateProvider);
    final saveState = ref.watch(savePendingUrlsProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVED ON THIS DEVICE'),
        leading: canPop
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, size: AppMetrics.iconSize),
                tooltip: auth.isSignedIn ? 'Back to Inbox' : 'Back to sign in',
                onPressed: () => context.go(
                  auth.isSignedIn ? AppRoutes.inbox : AppRoutes.auth,
                ),
              ),
      ),
      body: switch (pending) {
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
                    'Loading links…',
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
    final tokens = AppTheme.tokensOf(context);

    final explanation = isSignedIn
        ? "Links you shared are kept here for seven days when a save didn't "
              'finish. They are stored on this device until you save them to '
              'your account.'
        : "Links you shared are kept here for seven days when a save didn't "
              'finish. They are stored on this device, not in your account.';

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
                    label: 'Save all to my account',
                    variant: AppButtonVariant.primary,
                    busy: true,
                    onPressed: onSave,
                  )
                : isSignedIn
                ? AppButton(
                    label: 'Save all to my account',
                    variant: AppButtonVariant.primary,
                    onPressed: onSave,
                  )
                : AppButton(
                    label: 'Sign in to save these links',
                    variant: AppButtonVariant.primary,
                    onPressed: onSignIn,
                  ),
          if (hasEntries && saveState.isRunning) ...[
            const SizedBox(height: AppMetrics.space2),
            Text(
              _progressLabel(saveState),
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

String _progressLabel(PendingUrlSaveState state) {
  final total = state.total;
  if (total <= 1) return 'Saving…';

  final current = state.processed + 1 < total ? state.processed + 1 : total;
  return 'Saving $current of $total…';
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

class _PendingUrlRow extends StatelessWidget {
  const _PendingUrlRow({required this.entry});

  final PendingUrl entry;

  @override
  Widget build(BuildContext context) {
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
          Wrap(
            spacing: AppMetrics.space2,
            runSpacing: AppMetrics.space1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _keptLabel(entry.addedAt, DateTime.now().toUtc()),
                style: AppTypography.meta.copyWith(color: tokens.textTertiary),
              ),
              if (entry.uncertain)
                Text(
                  'Save not confirmed',
                  style: AppTypography.label.copyWith(color: tokens.warning),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nothing saved on this device',
              textAlign: TextAlign.center,
              style: AppTypography.screenHeading.copyWith(
                fontSize: 15,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: AppMetrics.space2),
            Text(
              "Links that didn't finish saving will appear here for seven "
              'days.',
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
    final tokens = AppTheme.tokensOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We couldn't read the links saved on this device.",
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: AppMetrics.space4),
            AppButton(
              label: 'Retry',
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
/// Kept deliberately simple and English-only, like the rest of the app until
/// the ARB layer lands. The seven-day retention means the largest value is
/// `6 days ago`.
String _keptLabel(DateTime addedAt, DateTime now) {
  final age = now.difference(addedAt);
  if (age.inMinutes < 1) return 'Kept just now';
  if (age.inMinutes < 60) return 'Kept ${age.inMinutes} min ago';
  if (age.inHours < 24) {
    return age.inHours == 1
        ? 'Kept 1 hour ago'
        : 'Kept ${age.inHours} hours ago';
  }
  if (age.inDays == 1) return 'Kept yesterday';
  return 'Kept ${age.inDays} days ago';
}
