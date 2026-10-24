import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/collections/domain/collection_summary.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';

part 'delete_collection_controller.g.dart';

/// What one collection-deletion action produced.
sealed class CollectionDeletionOutcome {
  const CollectionDeletionOutcome();
}

/// The delete transaction committed. The screen closes and returns to
/// Collections.
final class CollectionDeletionSucceeded extends CollectionDeletionOutcome {
  const CollectionDeletionSucceeded();
}

/// The selected `move` destination is gone or is not this caller's.
///
/// **Known not deleted, and the source is intact.** The user can choose another
/// destination; no automatic retry was sent.
final class CollectionDeletionTargetNotFound extends CollectionDeletionOutcome {
  const CollectionDeletionTargetNotFound();
}

/// The collection being deleted is no longer available to this caller.
///
/// The loaded listing was reconciled, but no copy may claim this request
/// deleted it. The screen has nothing left to show and returns to Collections.
final class CollectionDeletionSourceNotFound extends CollectionDeletionOutcome {
  const CollectionDeletionSourceNotFound();
}

/// A concurrent insert made the backend roll the whole transaction back.
///
/// The collection and its items are as they were. The contents were asked to
/// refresh so the newly inserted rows become visible; the delete is not retried.
final class CollectionDeletionNotEmpty extends CollectionDeletionOutcome {
  const CollectionDeletionNotEmpty();
}

/// The backend refused because the collection is Unsorted.
final class CollectionDeletionProtected extends CollectionDeletionOutcome {
  const CollectionDeletionProtected();
}

/// No established outcome. The request may have committed. No cache entry is
/// removed and the screen stays where it is.
final class CollectionDeletionUnconfirmed extends CollectionDeletionOutcome {
  const CollectionDeletionUnconfirmed();
}

/// A known not-deleted refusal, or a session outcome the auth layer owns.
final class CollectionDeletionFailed extends CollectionDeletionOutcome {
  const CollectionDeletionFailed();
}

/// A second action arrived while one request was in flight. No request was sent.
final class CollectionDeletionIgnored extends CollectionDeletionOutcome {
  const CollectionDeletionIgnored();
}

/// The destructive collection flow: one request, chosen by the disposition the
/// user confirmed.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// collection deletion is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when the sheet or route rebuilds.
///
/// **The two actions are separate methods rather than one parameterised call.**
/// An empty collection has no destination to name, and a non-empty one must name
/// the destination the user picked. Keeping them apart makes it impossible for a
/// caller to send `delete` with a target or `move` without one.
///
/// **No cache is invalidated.** Loaded listings are edited in place through
/// their own reconciliation methods: the Inbox drops or rewrites the rows it
/// already holds, and the Collections list loses the source collection without
/// resetting its sort. A successful bulk move then refreshes that list so the
/// destination's count is authoritative. Search is deliberately untouched.
@Riverpod(keepAlive: true)
class CollectionDeletion extends _$CollectionDeletion {
  @override
  bool build() => false;

  /// Deletes [collectionId] and every item in it.
  ///
  /// The request states a disposition (`delete` with a null target), because the
  /// backend never defaults it. Two user decisions reach this method and both
  /// mean the same thing: an empty collection, where there is nothing to move,
  /// and a non-empty one where the user explicitly chose to discard its items.
  /// The copy that led here differs; the request does not.
  Future<CollectionDeletionOutcome> deleteDiscardingItems({
    required String collectionId,
    required String collectionName,
  }) async {
    if (state) return const CollectionDeletionIgnored();
    state = true;

    final name = _collectionLabel(collectionName);

    try {
      await ref
          .read(collectionsRepositoryProvider)
          .delete(collectionId: collectionId);

      if (!ref.mounted) return const CollectionDeletionSucceeded();

      _removeCollection(collectionId);
      _removeInboxRows(collectionId);
      _publish(
        AppFeedback(tone: FeedbackTone.success, copy: '$name was deleted.'),
      );
      return const CollectionDeletionSucceeded();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const CollectionDeletionUnconfirmed();
      return _handleFailure(
        collectionId: collectionId,
        name: name,
        failure: failure,
        movingTo: null,
      );
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Deletes [collectionId] after moving its items into [target].
  ///
  /// The destination travels in the same body as the action, so the backend
  /// moves the items and deletes the collection in one transaction. There is no
  /// per-item move and no second request.
  Future<CollectionDeletionOutcome> moveItemsAndDelete({
    required String collectionId,
    required String collectionName,
    required CollectionSummary target,
  }) async {
    if (state) return const CollectionDeletionIgnored();
    state = true;

    final name = _collectionLabel(collectionName);

    try {
      await ref
          .read(collectionsRepositoryProvider)
          .moveItemsAndDelete(
            collectionId: collectionId,
            targetCollectionId: target.id,
          );

      if (!ref.mounted) return const CollectionDeletionSucceeded();

      _applyInboxMove(collectionId: collectionId, target: target);
      _removeCollection(collectionId);
      _refreshCollections();
      _publish(
        AppFeedback(
          tone: FeedbackTone.success,
          copy:
              '$name was deleted, and its items were moved to ${target.name}.',
        ),
      );
      return const CollectionDeletionSucceeded();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const CollectionDeletionUnconfirmed();
      return _handleFailure(
        collectionId: collectionId,
        name: name,
        failure: failure,
        movingTo: target,
      );
    } finally {
      if (ref.mounted) state = false;
    }
  }

  CollectionDeletionOutcome _handleFailure({
    required String collectionId,
    required String name,
    required ApiFailure failure,
    required CollectionSummary? movingTo,
  }) {
    switch (failure) {
      case ApiFailureCollectionDeleteTargetNotFound():
        // Only a move names a target, and this client never sends one with
        // `delete`. Treat an impossible target on that path as a known refusal
        // rather than inventing a destination the user can change.
        if (movingTo == null) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: "The collection wasn't deleted. Try again.",
            ),
          );
          return const CollectionDeletionFailed();
        }

        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                '${movingTo.name} is no longer available. Nothing was changed. '
                'Choose another destination.',
          ),
        );
        return const CollectionDeletionTargetNotFound();

      case ApiFailureNotFound():
        // The collection is unavailable to this caller. Reconcile the loaded
        // listings; the copy never says this request deleted it, because another
        // account or an earlier delete is indistinguishable here.
        _removeCollection(collectionId);
        _removeInboxRows(collectionId);
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: '$name is no longer available.',
          ),
        );
        return const CollectionDeletionSourceNotFound();

      // A concurrent insert caused the backend to roll the whole transaction
      // back. The collection and its items are exactly as they were; refreshing
      // shows the rows that arrived rather than retrying the delete.
      case ApiFailureCollectionNotEmpty():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                '$name now has items, so nothing was changed. '
                'Its current contents are being refreshed.',
          ),
        );
        _refreshContents(collectionId);
        return const CollectionDeletionNotEmpty();

      case ApiFailureUnsortedCollectionProtected():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: '$name cannot be deleted.',
          ),
        );
        return const CollectionDeletionProtected();

      // The collection delete is a transaction, but the client still has no
      // receipt. The row stays in the listing so the user can check Collections.
      case ApiFailureTransport() ||
          ApiFailureUnreadableResponse() ||
          ApiFailureServerFault() ||
          ApiFailureServerUnavailable():
        _publish(
          AppFeedback(
            tone: FeedbackTone.uncertain,
            copy:
                "We couldn't confirm whether $name was deleted. "
                'Check Collections before trying again.',
          ),
        );
        return const CollectionDeletionUnconfirmed();

      // The guard refused before the handler ran, so nothing was deleted. If the
      // session layer has already taken over, the router and sign-in screen
      // explain the expiry once.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to delete this collection.',
            ),
          );
        }
        return const CollectionDeletionFailed();

      // Only the refresh endpoint emits terminal codes, and the interceptor
      // converts a terminal renewal into the original 401.
      case ApiFailureSessionEnded():
        return const CollectionDeletionFailed();

      // A renewal that failed ambiguously never replayed the DELETE: the 401
      // came from the guard. The collection is known not deleted; the session is
      // the uncertain part.
      case ApiFailureRefreshUncertain():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "We couldn't renew your session, so $name wasn't deleted. "
                'Try again.',
          ),
        );
        return const CollectionDeletionFailed();

      case ApiFailureCredentialStorage():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "This device couldn't refresh your session, so $name wasn't "
                'deleted. Try again.',
          ),
        );
        return const CollectionDeletionFailed();

      // A well-formed client never produces these, and none belongs to a
      // collection delete. Known not deleted, and nothing the user can correct
      // from this screen.
      case ApiFailureValidation() ||
          ApiFailureMalformedRequest() ||
          ApiFailureUserNotFound() ||
          ApiFailureCurrentPasswordInvalid() ||
          ApiFailureCurrentPasswordRequired() ||
          ApiFailureUnexpectedCurrentPassword() ||
          ApiFailurePasswordCredentialAlreadyExists() ||
          ApiFailurePasswordAlreadyChanged() ||
          ApiFailureCollectionNameAlreadyExists():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "The collection wasn't deleted. Try again.",
          ),
        );
        return const CollectionDeletionFailed();

      // The route has no limiter, but a proxy or a renewal can still spend a
      // budget before the handler. Refused before any write, so the collection
      // is known not deleted. No countdown is fabricated when none arrived.
      case ApiFailureRateLimited(:final retryAfter):
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: retryAfter == null
                ? "You're going too quickly. The collection wasn't deleted. "
                      'Try again shortly.'
                : "You're going too quickly. The collection wasn't deleted. "
                      'Try again in ${_waitPhrase(retryAfter)}.',
          ),
        );
        return const CollectionDeletionFailed();
    }
  }

  /// Drops the rows belonging to the deleted collection from a loaded Inbox.
  ///
  /// Reading `savedItemsProvider` unconditionally would start a fetch as a side
  /// effect of a collection action. `exists` keeps this an in-place update for a
  /// listing that is already loaded; a later first load reads the server's
  /// current state.
  void _removeInboxRows(String collectionId) {
    if (!ref.exists(savedItemsProvider)) return;
    ref.read(savedItemsProvider.notifier).removeItemsInCollection(collectionId);
  }

  /// Rewrites a loaded Inbox's rows from the deleted collection to the
  /// destination of a confirmed bulk move.
  void _applyInboxMove({
    required String collectionId,
    required CollectionSummary target,
  }) {
    if (!ref.exists(savedItemsProvider)) return;
    ref
        .read(savedItemsProvider.notifier)
        .applyCollectionToItems(
          sourceCollectionId: collectionId,
          targetCollectionId: target.id,
          targetCollectionName: target.name,
        );
  }

  void _removeCollection(String collectionId) {
    if (!ref.exists(collectionsProvider)) return;
    ref.read(collectionsProvider.notifier).removeCollection(collectionId);
  }

  /// Refreshes the Collections list after a confirmed move, keeping its sort.
  ///
  /// The source is already removed in place. The refresh brings the
  /// destination's count and the list's paging back from the server; it is
  /// deliberately not an `invalidate`, which would reset the chosen sort.
  void _refreshCollections() {
    if (!ref.exists(collectionsProvider)) return;
    unawaited(ref.read(collectionsProvider.notifier).refresh());
  }

  void _refreshContents(String collectionId) {
    final contents = collectionSavedItemsProvider(collectionId);
    if (!ref.exists(contents)) return;
    unawaited(ref.read(contents.notifier).refresh());
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}

/// A non-empty name for copy, or a neutral fallback the screen never needs.
String _collectionLabel(String collectionName) {
  final trimmed = collectionName.trim();
  return trimmed.isEmpty ? 'The collection' : trimmed;
}

/// How long the server said to wait, in the coarsest unit that does not
/// understate it.
///
/// Mirrors the helper in `save_url_controller.dart` rather than sharing it: it
/// is two branches of English pluralisation, not a policy module, and
/// `flutter_localizations` is not a dependency yet (**D20**).
String _waitPhrase(Duration wait) {
  final seconds = wait.inSeconds;
  if (seconds <= 1) return 'a second';
  if (seconds < 60) return '$seconds seconds';

  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return minutes == 1 ? '1 minute' : '$minutes minutes';

  final hours = (minutes / 60).ceil();
  return hours == 1 ? '1 hour' : '$hours hours';
}
