import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';

part 'pending_urls_controller.g.dart';

const AppFeedback _expiredFeedback = AppFeedback(
  tone: FeedbackTone.warning,
  copy: 'Some links saved on this device expired after seven days.',
);

/// The device-local fallback list.
///
/// **Not user-scoped.** This provider deliberately depends on no session or
/// account provider and is not cleared by `SessionBoundary`: the entries belong
/// to the installation, not to a signed-in user.
///
/// The two mutations below are local reconciliation only. They never call the
/// API, never require a session, and never change the list's ownership.
@Riverpod(keepAlive: true)
class PendingUrls extends _$PendingUrls {
  @override
  Future<PendingUrlSnapshot> build() {
    final store = ref.watch(pendingUrlStoreProvider);
    return _readAndAnnounce(store);
  }

  /// Removes [url] from the device-local list after a confirmed save.
  ///
  /// The store's exact-string removal is the identity rule: a different URL is
  /// never removed, and a refreshed entry with the same URL is redundant now
  /// that the server has it. A store write failure propagates to the caller,
  /// which must stop rather than claim the local copy is gone.
  ///
  /// The re-read keeps the snapshot, the count, and the one-shot expiry notice
  /// in step with the store. It also picks up entries another engine added or
  /// pruned while the save was in flight.
  Future<void> removeConfirmed(String url) async {
    final store = ref.read(pendingUrlStoreProvider);
    await store.removeExact(url);
    final snapshot = await _readAndAnnounce(store);
    if (!ref.mounted) return;
    state = AsyncData(snapshot);
  }

  /// Marks [url] uncertain after a save whose outcome could not be established.
  ///
  /// The store preserves `addedAt`, so this does not extend the seven-day
  /// retention window. A write failure propagates; the caller's summary still
  /// reports the uncertainty but must not claim the flag was persisted.
  Future<void> markSaveUncertain(String url) async {
    final store = ref.read(pendingUrlStoreProvider);
    await store.markUncertain(url);
    final snapshot = await _readAndAnnounce(store);
    if (!ref.mounted) return;
    state = AsyncData(snapshot);
  }

  /// Reads the store and publishes a prune owed a notice, exactly once.
  ///
  /// The flag covers a prune that happened during an earlier write, when no
  /// screen was reading. The same path serves a prune that happens during a
  /// bulk reconciliation. Deferred through a microtask so a notice is never
  /// written to another provider while this one is initializing.
  Future<PendingUrlSnapshot> _readAndAnnounce(PendingUrlStore store) async {
    final snapshot = await store.readAll();

    final expired = await store.consumeExpiryNotice();
    if (expired) {
      unawaited(
        Future<void>.microtask(() {
          if (!ref.mounted) return;
          ref.read(feedbackProvider.notifier).show(_expiredFeedback);
        }),
      );
    }

    return snapshot;
  }
}

/// The count used by the two entry points.
///
/// Zero while the store is loading or has failed: an entry point with nothing
/// to show is better than a spinner on the auth screen. The dedicated screen
/// watches [pendingUrlsProvider] directly and renders its own error state.
final Provider<int> pendingUrlCountProvider = Provider<int>((ref) {
  final snapshot = ref.watch(pendingUrlsProvider).value;
  return snapshot?.entries.length ?? 0;
});
