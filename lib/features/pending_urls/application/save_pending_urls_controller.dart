import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_failure_policy.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';

part 'save_pending_urls_controller.g.dart';

/// The explicit, user-initiated bulk save of the device-local URL list.
///
/// ## One run at a time, one request at a time
///
/// [saveAll] walks the snapshot it was given in order and awaits each
/// `POST /saved-items` before starting the next. It moves to the next URL only
/// after a confirmed create; every refusal — including a validation refusal —
/// stops the run. A second call while a run is in progress returns immediately;
/// the screen also disables its button while [isRunning].
///
/// The controller itself never retries. The `AuthInterceptor` may replay a
/// request once after `ACCESS_TOKEN_EXPIRED`; that replay is the first and only
/// request that can write, and a confirmed `201` from it is a normal success that
/// lets the run continue.
///
/// ## Why a sync [Notifier]
///
/// The outcome is not provider build state. Publishing a failed save as
/// `AsyncError` would let Riverpod retry the build, and a retried POST is a
/// second insert — the backend has no idempotency key. The run reports through
/// its own state instead, exactly as `SaveUrl` does for a single save.
///
/// ## Reuse
///
/// The repository is `SavedItemsRepository.create`, so this path shares the
/// existing `appDio` + `AuthInterceptor`, request/response DTOs, and typed
/// [ApiFailure] mapping. No API client or batch endpoint is introduced.
///
/// ## What is kept
///
/// An entry is removed only after a confirmed create, and only by its exact URL
/// (`PendingUrls.removeConfirmed`). A refused entry stays; an ambiguous outcome
/// stays and is marked uncertain without refreshing its seven-day timestamp. The
/// run stops on the first refusal, so every unprocessed entry also stays.
/// Confirmed entries are never submitted again by a later run because they are
/// gone from the snapshot that run reads.
///
/// ## `keepAlive`
///
/// The run outlives the screen that started it. The user can switch destination
/// while the requests are in flight; the notifier must still reconcile the local
/// list and leave the summary available when the screen is opened again.
@Riverpod(keepAlive: true)
class SavePendingUrls extends _$SavePendingUrls {
  @override
  PendingUrlSaveState build() => const PendingUrlSaveState();

  /// Saves every pending URL in the current snapshot, sequentially.
  ///
  /// The guard and the snapshot are evaluated before the first `await`, so two
  /// taps in the same frame cannot start two runs.
  Future<void> saveAll() async {
    if (state.isRunning) return;
    if (!ref.read(authStateProvider).isSignedIn) return;

    final snapshot = ref.read(pendingUrlsProvider).value;
    if (snapshot == null || snapshot.entries.isEmpty) return;

    final entries = List<PendingUrl>.unmodifiable(snapshot.entries);
    final total = entries.length;

    state = PendingUrlSaveState(isRunning: true, total: total);

    var saved = 0;
    var knownFailed = 0;
    var uncertain = 0;
    var processed = 0;
    var stoppedBy = PendingUrlSaveStop.none;
    Duration? retryAfter;

    for (final entry in entries) {
      if (!ref.mounted) return;

      // The list can change while the run is in flight: an entry can expire,
      // be removed by another engine, or be pruned by a read. Do not submit a
      // URL the screen no longer holds. `.value` keeps the previous data during
      // a loading refresh, so an app-resume invalidation does not abort the run.
      final live = ref.read(pendingUrlsProvider).value;
      if (live == null || !live.entries.any((item) => item.url == entry.url)) {
        processed++;
        _publishProgress(processed, total);
        continue;
      }

      // A session can end between entries. Do not start an authenticated
      // request without one.
      if (!ref.read(authStateProvider).isSignedIn) {
        stoppedBy = PendingUrlSaveStop.authRequired;
        break;
      }

      var stop = false;

      try {
        await ref.read(savedItemsRepositoryProvider).create(url: entry.url);
        saved++;

        try {
          await ref
              .read(pendingUrlsProvider.notifier)
              .removeConfirmed(entry.url);
        } catch (_) {
          // The server confirmed the create. The local copy could not be
          // removed, so it is still on screen; stop rather than accumulate more
          // unremovable copies. The summary must not claim it was removed.
          stoppedBy = PendingUrlSaveStop.localList;
          stop = true;
        }
      } on ApiFailure catch (failure) {
        switch (pendingUrlSaveDisposition(failure)) {
          case PendingUrlSaveDisposition.stop:
            knownFailed++;
            stoppedBy = _stopFor(failure);
            retryAfter = failure is ApiFailureRateLimited
                ? failure.retryAfter
                : null;
            stop = true;

          case PendingUrlSaveDisposition.uncertain:
            uncertain++;
            await _markUncertain(entry.url);
            stoppedBy = PendingUrlSaveStop.unknown;
            stop = true;
        }
      } catch (_) {
        // A non-ApiFailure is unexpected, but the remote outcome is still not
        // established. Keep the entry and do not claim a known failure.
        uncertain++;
        await _markUncertain(entry.url);
        stoppedBy = PendingUrlSaveStop.unknown;
        stop = true;
      }

      processed++;
      _publishProgress(processed, total);
      if (stop) break;
    }

    // The final count comes from the store, not from arithmetic on the snapshot:
    // entries can have been added or pruned while the run was in flight. A read
    // failure leaves the count unknown rather than inventing one.
    int? remaining;
    try {
      remaining =
          (await ref.read(pendingUrlStoreProvider).readAll()).entries.length;
    } catch (_) {
      remaining = null;
    }

    // The same best-effort head refresh the single save and the share intake
    // use. It never throws, and a refresh failure must not turn confirmed saves
    // into a reported failure.
    if (saved > 0) {
      unawaited(ref.read(savedItemsProvider.notifier).refreshHead());
    }

    if (!ref.mounted) return;

    state = PendingUrlSaveState(
      processed: processed,
      total: total,
      lastSummary: PendingUrlSaveSummary(
        total: total,
        saved: saved,
        knownFailed: knownFailed,
        uncertain: uncertain,
        notAttempted: total - processed,
        remaining: remaining,
        stoppedBy: stoppedBy,
        retryAfter: retryAfter,
      ),
    );
  }

  void _publishProgress(int processed, int total) {
    if (!ref.mounted) return;
    state = state.copyWith(processed: processed, total: total);
  }

  Future<void> _markUncertain(String url) async {
    try {
      await ref.read(pendingUrlsProvider.notifier).markSaveUncertain(url);
    } catch (_) {
      // The summary still reports the uncertainty. A local write failure must
      // not turn an unestablished remote outcome into a known one.
    }
  }

  PendingUrlSaveStop _stopFor(ApiFailure failure) => switch (failure) {
    ApiFailureRateLimited() => PendingUrlSaveStop.rateLimited,
    ApiFailureAuthRequired() ||
    ApiFailureSessionEnded() ||
    ApiFailureRefreshUncertain() ||
    ApiFailureCredentialStorage() => PendingUrlSaveStop.authRequired,
    ApiFailureServerUnavailable() ||
    ApiFailureServerFault() => PendingUrlSaveStop.server,
    ApiFailureMalformedRequest() => PendingUrlSaveStop.malformed,
    _ => PendingUrlSaveStop.unknown,
  };
}
