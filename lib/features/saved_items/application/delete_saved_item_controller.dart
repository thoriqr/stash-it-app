import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/data/collections_providers.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_delete_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'delete_saved_item_controller.g.dart';

/// What one saved-item delete produced.
sealed class DeleteSavedItemOutcome {
  const DeleteSavedItemOutcome();
}

/// The item was deleted and the response makes the optional collection delete
/// eligible. The screen must show the second dialog before leaving.
final class DeleteSavedItemCollectionOffered extends DeleteSavedItemOutcome {
  const DeleteSavedItemCollectionOffered(this.result);

  final SavedItemDeleted result;
}

/// The item was deleted, but there is no collection follow-up. The success
/// notice has already been published.
final class DeleteSavedItemSucceeded extends DeleteSavedItemOutcome {
  const DeleteSavedItemSucceeded();
}

/// The item is not available to this caller. The item was removed from loaded
/// listings, but no copy may claim this request deleted it.
final class DeleteSavedItemNotFound extends DeleteSavedItemOutcome {
  const DeleteSavedItemNotFound();
}

/// No established outcome. The request may have committed. No cache row is
/// removed and the copy says the outcome is unconfirmed.
final class DeleteSavedItemUnconfirmed extends DeleteSavedItemOutcome {
  const DeleteSavedItemUnconfirmed();
}

/// A known refusal, or a session outcome the auth layer already owns.
final class DeleteSavedItemFailed extends DeleteSavedItemOutcome {
  const DeleteSavedItemFailed();
}

/// A second action arrived while one request was in flight. No request was sent.
final class DeleteSavedItemIgnored extends DeleteSavedItemOutcome {
  const DeleteSavedItemIgnored();
}

/// What one optional collection delete produced.
sealed class DeleteCollectionOutcome {
  const DeleteCollectionOutcome();
}

/// The collection delete transaction committed.
final class DeleteCollectionSucceeded extends DeleteCollectionOutcome {
  const DeleteCollectionSucceeded();
}

/// The collection is not available to this caller. The loaded listing was
/// reconciled, but the item deletion is still the only thing this flow claims.
final class DeleteCollectionNotFound extends DeleteCollectionOutcome {
  const DeleteCollectionNotFound();
}

/// A concurrent insert made the backend roll the transaction back. The
/// collection and its contents are as they were.
final class DeleteCollectionNotEmpty extends DeleteCollectionOutcome {
  const DeleteCollectionNotEmpty();
}

/// The backend refused because the collection is Unsorted.
final class DeleteCollectionProtected extends DeleteCollectionOutcome {
  const DeleteCollectionProtected();
}

/// No established collection-delete outcome. The collection row is left in the
/// listing because the client cannot tell whether the delete landed.
final class DeleteCollectionUnconfirmed extends DeleteCollectionOutcome {
  const DeleteCollectionUnconfirmed();
}

/// A known not-deleted refusal.
final class DeleteCollectionFailed extends DeleteCollectionOutcome {
  const DeleteCollectionFailed();
}

/// A second action arrived while the collection delete was in flight.
final class DeleteCollectionIgnored extends DeleteCollectionOutcome {
  const DeleteCollectionIgnored();
}

/// The destructive saved-item flow: one item delete, then at most one optional
/// collection delete.
///
/// **One request per explicit user action.** The state is a plain `bool` — "a
/// destructive request is in flight" — set synchronously before the first
/// `await`, so a double tap cannot issue two requests. It is keep-alive so a
/// request already sent is not abandoned when a route rebuilds.
///
/// **The item delete is never retried as part of a collection-delete failure.**
/// The two operations have separate outcomes. Once the item delete succeeds, the
/// collection step can fail for any reason without revisiting the item.
///
/// **No cache is invalidated to remove one row.** Loaded listings are edited in
/// place through their own tombstone-aware methods, preserving their pages,
/// cursors and sort. A collection delete that establishes the collection is gone
/// (success or not-found) invalidates that collection's contents provider by
/// default, because a mounted collection screen must stop showing a collection
/// that no longer exists. The caller may opt out when it is about to pop that
/// screen.
@Riverpod(keepAlive: true)
class DeleteSavedItem extends _$DeleteSavedItem {
  @override
  bool build() => false;

  /// Deletes [item], and returns whether the collection follow-up may be shown.
  ///
  /// On a confirmed item deletion, the row is removed from every loaded listing
  /// before this returns. For an eligible follow-up the success notice is
  /// deliberately **not** published: the screen shows the second dialog first, so
  /// a four-second banner cannot appear over it. The screen must call
  /// [keepCollection] when that dialog is resolved by keeping the collection.
  Future<DeleteSavedItemOutcome> deleteItem(SavedItemSummary item) async {
    if (state) return const DeleteSavedItemIgnored();
    state = true;

    try {
      final result = await ref
          .read(savedItemsRepositoryProvider)
          .delete(item.id);

      if (!ref.mounted) return const DeleteSavedItemSucceeded();

      _removeFromLoadedListings(item);

      if (result is SavedItemDeleted &&
          result.mayOfferCollectionDeletionFor(item)) {
        return DeleteSavedItemCollectionOffered(result);
      }

      _publish(
        const AppFeedback(tone: FeedbackTone.success, copy: 'Item deleted.'),
      );
      return const DeleteSavedItemSucceeded();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const DeleteSavedItemUnconfirmed();
      return _handleItemFailure(item, failure);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Publishes the item-deletion success after the second dialog was dismissed.
  ///
  /// This is the "Keep it" path, including a barrier tap or Back. It sends no
  /// request and does not touch any cache: the item was already removed when the
  /// delete succeeded.
  void keepCollection() {
    _publish(
      const AppFeedback(tone: FeedbackTone.success, copy: 'Item deleted.'),
    );
  }

  /// Deletes the collection the item delete left empty.
  ///
  /// Called only after the user confirms the second dialog. The item delete is
  /// already complete and is never repeated here.
  ///
  /// [invalidateContents] defaults to true so a mounted collection screen learns
  /// that its collection is gone. A caller that is about to pop that screen passes
  /// false: refreshing it would issue a request whose answer cannot be shown, and
  /// the route is being removed anyway.
  Future<DeleteCollectionOutcome> deleteCollection({
    required String collectionId,
    required String collectionName,
    bool invalidateContents = true,
  }) async {
    if (state) return const DeleteCollectionIgnored();
    state = true;

    final name = _collectionLabel(collectionName);

    try {
      await ref
          .read(collectionsRepositoryProvider)
          .delete(collectionId: collectionId);

      if (!ref.mounted) return const DeleteCollectionSucceeded();

      _removeCollection(collectionId);
      if (invalidateContents) _invalidateCollectionContents(collectionId);
      _publish(
        AppFeedback(
          tone: FeedbackTone.success,
          copy: 'Item deleted, and $name was deleted.',
        ),
      );
      return const DeleteCollectionSucceeded();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const DeleteCollectionUnconfirmed();
      return _handleCollectionFailure(
        collectionId,
        name,
        failure,
        invalidateContents: invalidateContents,
      );
    } finally {
      if (ref.mounted) state = false;
    }
  }

  DeleteSavedItemOutcome _handleItemFailure(
    SavedItemSummary item,
    ApiFailure failure,
  ) {
    switch (failure) {
      case ApiFailureNotFound():
        // The item is unavailable to this caller. Removing the loaded row keeps
        // the listing from offering an item the server will not return, but the
        // copy never says this request deleted it: another account or an earlier
        // delete is indistinguishable here.
        _removeFromLoadedListings(item);
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'This item is no longer available.',
          ),
        );
        return const DeleteSavedItemNotFound();

      // The delete's three statements are not a transaction, and a 500 can be
      // answered after the row was removed. A 503 or transport failure may also
      // have reached the handler. Nothing here proves the item still exists.
      case ApiFailureTransport() ||
          ApiFailureUnreadableResponse() ||
          ApiFailureServerFault() ||
          ApiFailureServerUnavailable():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.uncertain,
            copy:
                "We couldn't confirm whether the item was deleted. "
                'Check the Inbox before trying again.',
          ),
        );
        return const DeleteSavedItemUnconfirmed();

      // The guard refused before the handler ran, so the item was not deleted.
      // If the session layer has already taken over, the router and sign-in
      // screen explain the expiry once.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to delete this item.',
            ),
          );
        }
        return const DeleteSavedItemFailed();

      // Only the refresh endpoint emits terminal codes, and the interceptor
      // converts a terminal renewal into the original 401.
      case ApiFailureSessionEnded():
        return const DeleteSavedItemFailed();

      // A renewal that failed ambiguously never replayed the DELETE: the 401
      // came from the guard. The item is known not deleted; the session is the
      // uncertain part.
      case ApiFailureRefreshUncertain():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "We couldn't renew your session, so the item wasn't deleted. "
                'Try again.',
          ),
        );
        return const DeleteSavedItemFailed();

      case ApiFailureCredentialStorage():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "This device couldn't refresh your session, so the item wasn't "
                'deleted. Try again.',
          ),
        );
        return const DeleteSavedItemFailed();

      // A well-formed client never produces these. Known not deleted, and
      // nothing the user can correct from this screen.
      case ApiFailureValidation() || ApiFailureMalformedRequest():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "The item wasn't deleted. Try again.",
          ),
        );
        return const DeleteSavedItemFailed();

      // The route has no limiter, but a proxy can still refuse before the
      // handler. Known not deleted.
      case ApiFailureRateLimited():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "You're going too quickly. The item wasn't deleted. "
                'Try again shortly.',
          ),
        );
        return const DeleteSavedItemFailed();

      // Unreachable on this route: the collection-write codes belong to
      // `PUT /saved-items/{id}/collection` and `DELETE /collections/{id}`, and
      // the account and password codes belong to the profile routes.
      case ApiFailureUserNotFound() ||
          ApiFailureCurrentPasswordInvalid() ||
          ApiFailureCurrentPasswordRequired() ||
          ApiFailureUnexpectedCurrentPassword() ||
          ApiFailurePasswordCredentialAlreadyExists() ||
          ApiFailurePasswordAlreadyChanged() ||
          ApiFailureCollectionNameAlreadyExists() ||
          ApiFailureCollectionNotEmpty() ||
          ApiFailureUnsortedCollectionProtected() ||
          ApiFailurePinEmailDeliveryFailed() ||
          ApiFailureRegistration() ||
          ApiFailurePasswordReset() ||
          ApiFailureCollectionDeleteTargetNotFound():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "The item wasn't deleted. Try again.",
          ),
        );
        return const DeleteSavedItemFailed();
    }
  }

  DeleteCollectionOutcome _handleCollectionFailure(
    String collectionId,
    String name,
    ApiFailure failure, {
    required bool invalidateContents,
  }) {
    switch (failure) {
      case ApiFailureNotFound():
        // The collection is unavailable to this caller. Reconcile the loaded
        // listing and, if its screen is mounted beneath this route, let its
        // existing not-found state take over.
        _removeCollection(collectionId);
        if (invalidateContents) _invalidateCollectionContents(collectionId);
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: 'Item deleted. $name is no longer available.',
          ),
        );
        return const DeleteCollectionNotFound();

      // A concurrent insert caused the backend to roll the whole transaction
      // back. The collection and its items are exactly as they were.
      case ApiFailureCollectionNotEmpty():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: 'Item deleted. $name now has items, so it was not deleted.',
          ),
        );
        return const DeleteCollectionNotEmpty();

      case ApiFailureUnsortedCollectionProtected():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: 'Item deleted. $name cannot be deleted.',
          ),
        );
        return const DeleteCollectionProtected();

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
                "Item deleted, but we couldn't confirm whether $name was "
                'deleted. Check Collections.',
          ),
        );
        return const DeleteCollectionUnconfirmed();

      // The item deletion already stands. These copy lines report it while
      // explaining why the collection was not deleted.
      case ApiFailureAuthRequired():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: 'Item deleted. Sign in again to delete $name.',
          ),
        );
        return const DeleteCollectionFailed();

      case ApiFailureSessionEnded():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                'Item deleted. Your session ended before $name could be deleted.',
          ),
        );
        return const DeleteCollectionFailed();

      case ApiFailureRefreshUncertain():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "Item deleted. We couldn't renew your session, so $name was not "
                'deleted. Try again.',
          ),
        );
        return const DeleteCollectionFailed();

      case ApiFailureCredentialStorage():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "Item deleted. This device couldn't refresh your session, so "
                '$name was not deleted. Try again.',
          ),
        );
        return const DeleteCollectionFailed();

      case ApiFailureRateLimited():
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "Item deleted. You're going too quickly, so $name was not "
                'deleted. Try again shortly.',
          ),
        );
        return const DeleteCollectionFailed();

      // A well-formed client sends `delete` with a null target, so either shape
      // code means this client sent an incoherent request. The item delete is
      // still complete.
      case ApiFailureValidation() || ApiFailureMalformedRequest():
        _publish(
          AppFeedback(
            tone: FeedbackTone.danger,
            copy:
                'Item deleted, but $name could not be deleted. '
                'Try again from Collections.',
          ),
        );
        return const DeleteCollectionFailed();

      // Unreachable on a collection delete: only the move endpoint emits the
      // duplicate-name code, and this flow sends the `delete` action, which has
      // no target to be missing. The account and password codes belong to the
      // profile routes.
      case ApiFailureUserNotFound() ||
          ApiFailureCurrentPasswordInvalid() ||
          ApiFailureCurrentPasswordRequired() ||
          ApiFailureUnexpectedCurrentPassword() ||
          ApiFailurePasswordCredentialAlreadyExists() ||
          ApiFailurePasswordAlreadyChanged() ||
          ApiFailureCollectionNameAlreadyExists() ||
          ApiFailurePinEmailDeliveryFailed() ||
          ApiFailureRegistration() ||
          ApiFailurePasswordReset() ||
          ApiFailureCollectionDeleteTargetNotFound():
        _publish(
          AppFeedback(
            tone: FeedbackTone.danger,
            copy:
                'Item deleted, but $name could not be deleted. '
                'Try again from Collections.',
          ),
        );
        return const DeleteCollectionFailed();
    }
  }

  void _removeFromLoadedListings(SavedItemSummary item) {
    if (ref.exists(savedItemsProvider)) {
      ref.read(savedItemsProvider.notifier).removeItem(item.id);
    }

    if (item.collectionId.trim().isEmpty) return;
    final contents = collectionSavedItemsProvider(item.collectionId);
    if (ref.exists(contents)) {
      ref.read(contents.notifier).removeItem(item.id);
    }
  }

  void _removeCollection(String collectionId) {
    if (!ref.exists(collectionsProvider)) return;
    ref.read(collectionsProvider.notifier).removeCollection(collectionId);
  }

  void _invalidateCollectionContents(String collectionId) {
    final contents = collectionSavedItemsProvider(collectionId);
    if (ref.exists(contents)) ref.invalidate(contents);
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}

/// A non-empty name for copy, or a neutral fallback the screen never needs.
String _collectionLabel(String collectionName) {
  final trimmed = collectionName.trim();
  return trimmed.isEmpty ? 'the collection' : trimmed;
}
