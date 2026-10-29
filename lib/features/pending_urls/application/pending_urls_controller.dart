import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/features/pending_urls/data/pending_url_store.dart';
import 'package:stash_it_app/features/pending_urls/domain/pending_url.dart';

part 'pending_urls_controller.g.dart';

/// The device-local fallback list.
///
/// **Not user-scoped.** This provider deliberately depends on no session or
/// account provider and is not cleared by `SessionBoundary`: the entries belong
/// to the installation, not to a signed-in user.
@Riverpod(keepAlive: true)
class PendingUrls extends _$PendingUrls {
  @override
  Future<PendingUrlSnapshot> build() async {
    final store = ref.watch(pendingUrlStoreProvider);
    final snapshot = await store.readAll();

    // The flag covers a prune that happened during an earlier write, when no
    // screen was reading. Consuming it here makes the notice appear once.
    final expired = await store.consumeExpiryNotice();
    if (expired) {
      // Deferred rather than written during this build: the notice belongs to
      // the app-wide feedback provider, and this provider is being initialized.
      unawaited(
        Future<void>.microtask(() {
          if (!ref.mounted) return;
          ref
              .read(feedbackProvider.notifier)
              .show(
                const AppFeedback(
                  tone: FeedbackTone.warning,
                  copy:
                      'Some links saved on this device expired after seven '
                      'days.',
                ),
              );
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
