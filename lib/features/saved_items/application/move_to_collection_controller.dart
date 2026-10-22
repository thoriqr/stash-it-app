import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/collections/application/collections_controller.dart';
import 'package:stash_it_app/features/collections/domain/collection_name.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_intent.dart';
import 'package:stash_it_app/features/saved_items/domain/move_to_collection_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'move_to_collection_controller.g.dart';

/// What one explicit move action produced.
///
/// The sheet needs only enough to decide what to do with itself: close for a
/// finished action, keep the name for a correctable one, and keep the input for
/// both name failures. Everything the user reads is published by the notifier
/// through the app-wide feedback channel, except the two inline name errors,
/// which stay in the field.
sealed class MoveToCollectionOutcome {
  const MoveToCollectionOutcome();
}

/// The server confirmed where the item is. [result] carries the stored name and
/// whether this call created the collection or found it already there.
final class MoveToCollectionSucceeded extends MoveToCollectionOutcome {
  const MoveToCollectionSucceeded(this.result);

  final MoveToCollectionResult result;
}

/// The submitted name fails the backend's shape rule and never became a request.
final class MoveToCollectionNameInvalid extends MoveToCollectionOutcome {
  const MoveToCollectionNameInvalid(this.problem);

  /// The local reason, or null when the server rejected a name this client
  /// considered well formed. The sheet still keeps the input either way.
  final CollectionNameProblem? problem;
}

/// The name is already held by one of the user's collections, and the request
/// asked to create it. Nothing was created or moved; the sheet keeps the input
/// so the user can choose another name.
final class MoveToCollectionNameAlreadyExists extends MoveToCollectionOutcome {
  const MoveToCollectionNameAlreadyExists();
}

/// `SAVED_ITEM_NOT_FOUND`. The item is gone or belongs to another user; the
/// detail provider has been invalidated so its screen moves to C3.
final class MoveToCollectionItemNotFound extends MoveToCollectionOutcome {
  const MoveToCollectionItemNotFound();
}

/// No established outcome. The write may have landed; the detail has been asked
/// to refetch so the user can check where the item actually is.
final class MoveToCollectionUnconfirmed extends MoveToCollectionOutcome {
  const MoveToCollectionUnconfirmed();
}

/// A known not-moved refusal, or a session outcome the auth layer already owns.
final class MoveToCollectionFailed extends MoveToCollectionOutcome {
  const MoveToCollectionFailed();
}

/// A second tap arrived while the first request was in flight. No request was
/// sent for it.
final class MoveToCollectionIgnored extends MoveToCollectionOutcome {
  const MoveToCollectionIgnored();
}

/// The Move to collection mutation: **one `PUT` per explicit user action**.
///
/// The state is a plain `bool` — "a move is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried PUT is a
/// second write. Publishing outcomes through the app-wide feedback channel keeps
/// the mutation out of the provider's error path. `keepAlive` makes the notifier
/// outlive the sheet, so a request already sent is not abandoned when the modal
/// closes, and the duplicate guard survives a rebuild of the sheet.
///
/// **The in-flight flag is set synchronously before the first await.** Two taps
/// in the same frame therefore produce one request, not two.
@Riverpod(keepAlive: true)
class MoveToCollection extends _$MoveToCollection {
  @override
  bool build() => false;

  /// Moves [savedItemId] into [collectionName], or creates that collection.
  ///
  /// [intent] states which operation the name means:
  /// [MoveToCollectionIntent.existing] selects a destination, while
  /// [MoveToCollectionIntent.create] asks for a new collection and refuses a
  /// name that is already taken. The name alone cannot answer this, so it is
  /// required rather than inferred.
  ///
  /// The submitted name is trimmed once and sent with its casing intact. Name
  /// shape is checked here so an impossible value never becomes a request;
  /// uniqueness is **not** checked, because only the backend can answer it.
  Future<MoveToCollectionOutcome> submit({
    required String savedItemId,
    required String collectionName,
    required MoveToCollectionIntent intent,
  }) async {
    if (state) return const MoveToCollectionIgnored();

    final problem = collectionNameProblem(collectionName);
    if (problem != null) return MoveToCollectionNameInvalid(problem);

    final name = normalizedCollectionName(collectionName);
    state = true;

    try {
      final result = await ref
          .read(savedItemsRepositoryProvider)
          .moveToCollection(
            savedItemId: savedItemId,
            collectionName: name,
            intent: intent,
          );

      // The notifier is app-level, so this only guards a torn-down container.
      if (!ref.mounted) return MoveToCollectionSucceeded(result);

      _publish(_successFeedback(result));

      if (!result.alreadyInCollection) {
        // The confirmation is already true; the extra read only brings the
        // detail screen and Inbox row in step with it. It must not delay or
        // reverse the confirmed outcome.
        unawaited(_synchronizeConfirmedMove(savedItemId, result));
      }

      return MoveToCollectionSucceeded(result);
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const MoveToCollectionUnconfirmed();
      return _handleFailure(savedItemId, failure);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Refetches the detail after a confirmed move, applies the collection to the
  /// loaded Inbox row, and refreshes the collections listing.
  ///
  /// The PUT response carries an authoritative collection id and stored name, so
  /// it is used if the follow-up detail read fails. That keeps the Inbox from
  /// showing a stale chip even when the read is unavailable; the detail screen
  /// owns its own read error state.
  Future<void> _synchronizeConfirmedMove(
    String savedItemId,
    MoveToCollectionResult result,
  ) async {
    final fresh = await _reloadDetail(savedItemId);
    if (!ref.mounted) return;

    if (fresh != null) {
      _applyInboxCollection(
        savedItemId: savedItemId,
        collectionId: fresh.collectionId,
        collectionName: fresh.collectionName,
      );
    } else {
      _applyInboxCollection(
        savedItemId: savedItemId,
        collectionId: result.collectionId,
        collectionName: result.collectionName,
      );
    }

    // Counts and the collection list changed. The picker never touched this
    // provider; invalidating it here is the confirmed-write refresh, not a side
    // effect of opening the sheet.
    ref.invalidate(collectionsProvider);
  }

  /// Refetches the detail after an unestablished write and applies the truth it
  /// reports to the Inbox if the read succeeds. No feedback is published here:
  /// the neutral notice was already sent, and this read cannot upgrade the
  /// outcome.
  Future<void> _reconcileUnconfirmedMove(String savedItemId) async {
    final fresh = await _reloadDetail(savedItemId);
    if (!ref.mounted || fresh == null) return;

    _applyInboxCollection(
      savedItemId: savedItemId,
      collectionId: fresh.collectionId,
      collectionName: fresh.collectionName,
    );
  }

  /// Invalidates and re-reads the one detail. Any read failure is swallowed:
  /// the caller is reconciling a write, and a failed read neither confirms nor
  /// denies it.
  Future<SavedItemSummary?> _reloadDetail(String savedItemId) async {
    ref.invalidate(savedItemDetailProvider(savedItemId));
    try {
      return await ref.read(savedItemDetailProvider(savedItemId).future);
    } catch (_) {
      return null;
    }
  }

  /// Applies the move to the loaded Inbox row, if that row exists.
  ///
  /// Reading `savedItemsProvider` unconditionally would start an Inbox fetch as a
  /// side effect of a detail-screen action. `exists` keeps this an in-place
  /// update for a listing that is already loaded and deliberately does nothing
  /// otherwise; a later first load will read the server's current state.
  void _applyInboxCollection({
    required String savedItemId,
    required String collectionId,
    required String collectionName,
  }) {
    if (!ref.exists(savedItemsProvider)) return;
    ref
        .read(savedItemsProvider.notifier)
        .applyCollection(
          savedItemId: savedItemId,
          collectionId: collectionId,
          collectionName: collectionName,
        );
  }

  MoveToCollectionOutcome _handleFailure(
    String savedItemId,
    ApiFailure failure,
  ) {
    switch (failure) {
      case ApiFailureValidation():
        return const MoveToCollectionNameInvalid(null);

      case ApiFailureCollectionNameAlreadyExists():
        return const MoveToCollectionNameAlreadyExists();

      case ApiFailureNotFound():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'This item is no longer available.',
          ),
        );
        ref.invalidate(savedItemDetailProvider(savedItemId));
        return const MoveToCollectionItemNotFound();

      // The write may or may not have landed. A malformed `200` is included on
      // purpose: the status passed validation, so only the representation is
      // known to be unreadable, not the outcome.
      case ApiFailureTransport() ||
          ApiFailureUnreadableResponse() ||
          ApiFailureServerFault() ||
          ApiFailureServerUnavailable():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.uncertain,
            copy: "We couldn't confirm the move. Check the item's collection.",
          ),
        );
        unawaited(_reconcileUnconfirmedMove(savedItemId));
        return const MoveToCollectionUnconfirmed();

      // The guard refused before the handler ran, so the item did not move. If
      // the session layer has already taken over, the router and sign-in screen
      // explain the expiry once; a second notice would be noise.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to move this item.',
            ),
          );
        }
        return const MoveToCollectionFailed();

      // Only the refresh endpoint emits terminal codes, and the interceptor
      // converts a terminal renewal into the original 401. Handled explicitly
      // so a future path cannot announce an expiry that belongs to the session
      // layer.
      case ApiFailureSessionEnded():
        return const MoveToCollectionFailed();

      // A renewal that failed ambiguously never replayed the PUT: the 401 came
      // from the guard, before the handler. The move is known not to have
      // happened; the session is the uncertain part, and the copy must not say
      // it ended.
      case ApiFailureRefreshUncertain():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "We couldn't renew your session, so the item wasn't moved. "
                'Try again.',
          ),
        );
        return const MoveToCollectionFailed();

      // The local credential layer could not produce a session, so the request
      // was never replayed. Known not moved; the session did not end.
      case ApiFailureCredentialStorage():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "This device couldn't refresh your session, so the item wasn't "
                'moved. Try again.',
          ),
        );
        return const MoveToCollectionFailed();

      // A well-formed client never sends an unparseable body. Known not moved,
      // and nothing the user can correct in the name field.
      case ApiFailureMalformedRequest():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'Something went wrong sending that name. Try again.',
          ),
        );
        return const MoveToCollectionFailed();

      // The route has no limiter of its own, but a proxy or a renewal can still
      // spend a budget before the handler. Refused before any write, so the item
      // did not move. No countdown is fabricated when no Retry-After arrived.
      case ApiFailureRateLimited(:final retryAfter):
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: retryAfter == null
                ? "You're moving too quickly. Try again shortly."
                : "You're moving too quickly. Try again in "
                      '${_waitPhrase(retryAfter)}.',
          ),
        );
        return const MoveToCollectionFailed();
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}

/// Confirmation copy, always using the server's stored name.
///
/// Mutually exclusive flags: a created collection was not already there, and an
/// already-in request wrote nothing. The already case is checked first so a
/// contradictory pair can never claim a create.
AppFeedback _successFeedback(MoveToCollectionResult result) {
  if (result.alreadyInCollection) {
    return AppFeedback(
      tone: FeedbackTone.success,
      copy: 'Already in ${result.collectionName}.',
    );
  }

  if (result.collectionCreated) {
    return AppFeedback(
      tone: FeedbackTone.success,
      copy: 'Created ${result.collectionName} and moved the item.',
    );
  }

  return AppFeedback(
    tone: FeedbackTone.success,
    copy: 'Moved to ${result.collectionName}.',
  );
}

/// How long the server said to wait, in the coarsest unit that does not
/// understate it.
///
/// This mirrors the helper in `save_url_controller.dart` rather than sharing it:
/// it is two branches of English pluralisation, not a policy module, and
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
