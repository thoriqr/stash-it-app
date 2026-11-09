import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_feedback.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'note_mutation_controller.g.dart';

/// What one note save or delete produced.
sealed class NoteMutationOutcome {
  const NoteMutationOutcome();

  /// Whether the editor has nothing left to do and may close.
  ///
  /// Known rejections and unconfirmed outcomes keep the editor open so the
  /// entered text is not lost. A missing item closes it because the detail
  /// screen itself takes over the unavailable state.
  bool get closesEditor;
}

/// The note was saved. [note] is the value the client applied.
final class NoteSaved extends NoteMutationOutcome {
  const NoteSaved(this.note);

  final String? note;

  @override
  bool get closesEditor => true;
}

/// The note was cleared.
final class NoteDeleted extends NoteMutationOutcome {
  const NoteDeleted();

  @override
  bool get closesEditor => true;
}

/// The item is no longer available to this caller.
final class NoteNotFound extends NoteMutationOutcome {
  const NoteNotFound();

  @override
  bool get closesEditor => true;
}

/// The request was refused or could not be sent. Nothing was changed.
final class NoteRejected extends NoteMutationOutcome {
  const NoteRejected();

  @override
  bool get closesEditor => false;
}

/// No established outcome. The note may or may not have changed.
final class NoteUnconfirmed extends NoteMutationOutcome {
  const NoteUnconfirmed();

  @override
  bool get closesEditor => false;
}

/// A second action arrived while one request was in flight.
final class NoteIgnored extends NoteMutationOutcome {
  const NoteIgnored();

  @override
  bool get closesEditor => false;
}

/// One note save or delete at a time.
///
/// The state is a plain `bool` set synchronously before the first `await`, so a
/// double tap cannot issue two writes. It is keep-alive so a request already
/// sent is not abandoned when the editor route closes.
///
/// Feedback is published only by this controller, through the app-wide notice
/// system. On a confirmed mutation, the loaded detail and any loaded listings
/// are patched in place rather than refetched.
@Riverpod(keepAlive: true)
class NoteMutation extends _$NoteMutation {
  @override
  bool build() => false;

  /// Saves [note] for [item] and applies the stored result.
  ///
  /// The text is submitted exactly as entered. The response's stored note wins;
  /// if a successful response omits it, the submitted text is used because the
  /// request was accepted.
  Future<NoteMutationOutcome> save(SavedItemSummary item, String note) async {
    if (state) return const NoteIgnored();
    state = true;

    try {
      final stored = await ref
          .read(savedItemsRepositoryProvider)
          .updateNote(savedItemId: item.id, note: note);

      if (!ref.mounted) return NoteSaved(stored ?? note);

      final applied = stored ?? note;
      _apply(item, applied);
      _publish(noteSavedFeedback);
      return NoteSaved(applied);
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const NoteUnconfirmed();
      return _handleFailure(item, failure, deleting: false);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Clears [item]'s note and applies the confirmed result.
  Future<NoteMutationOutcome> delete(SavedItemSummary item) async {
    if (state) return const NoteIgnored();
    state = true;

    try {
      await ref.read(savedItemsRepositoryProvider).deleteNote(item.id);

      if (!ref.mounted) return const NoteDeleted();

      _apply(item, null);
      _publish(noteDeletedFeedback);
      return const NoteDeleted();
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return const NoteUnconfirmed();
      return _handleFailure(item, failure, deleting: true);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Patches the detail and any already-loaded listing that contains [item].
  ///
  /// Providers are checked first, so no read is started as a side effect of a
  /// mutation. A page already in flight can still overwrite the row later, but
  /// the head refresh path already reconciles the newest server representation.
  void _apply(SavedItemSummary item, String? note) {
    final detail = savedItemDetailProvider(item.id);
    if (ref.exists(detail)) {
      ref.read(detail.notifier).applyNote(note);
    }

    if (ref.exists(savedItemsProvider)) {
      ref.read(savedItemsProvider.notifier).applyNote(item.id, note);
    }

    final collectionId = item.collectionId.trim();
    if (collectionId.isEmpty) return;

    final contents = collectionSavedItemsProvider(collectionId);
    if (ref.exists(contents)) {
      ref.read(contents.notifier).applyNote(item.id, note);
    }
  }

  NoteMutationOutcome _handleFailure(
    SavedItemSummary item,
    ApiFailure failure, {
    required bool deleting,
  }) {
    switch (failure) {
      // The request was refused before the write ran.
      case ApiFailureRateLimited(:final retryAfter):
        _publish(noteRateLimitedFeedback(retryAfter));
        return const NoteRejected();

      // The limiter refused before the note was written.
      case ApiFailureServerUnavailable():
        _publish(noteUnavailableFeedback);
        return const NoteRejected();

      // The item is unavailable to this caller. Invalidate the detail so its
      // not-found state can take over; the message does not disclose whether it
      // was deleted or belongs to someone else.
      case ApiFailureNotFound():
        _publish(savedItemUnavailableFeedback);
        ref.invalidate(savedItemDetailProvider(item.id));
        return const NoteNotFound();

      // The user must sign in again. Avoid duplicate feedback if the session
      // state has already changed and the router is redirecting.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(noteAuthRequiredFeedback);
        }
        return const NoteRejected();

      // The session ended; the session layer owns the redirect and its copy.
      case ApiFailureSessionEnded():
        return const NoteRejected();

      // A renewal failed ambiguously and the write was never replayed.
      case ApiFailureRefreshUncertain():
        _publish(noteRefreshUncertainFeedback);
        return const NoteRejected();

      case ApiFailureCredentialStorage():
        _publish(noteCredentialStorageFeedback);
        return const NoteRejected();

      // The note itself was rejected, or the request shape was malformed.
      // Nothing was written.
      case ApiFailureValidation() || ApiFailureMalformedRequest():
        _publish(deleting ? noteDeleteFailedFeedback : noteInvalidFeedback);
        return const NoteRejected();

      // No response or an unreadable one: the write may have committed.
      case ApiFailureTransport() || ApiFailureUnreadableResponse():
        _publish(
          deleting
              ? noteDeleteUnconfirmedFeedback
              : noteSaveUnconfirmedFeedback,
        );
        return const NoteUnconfirmed();

      // A server fault can occur after the write committed. Do not claim that
      // the note is unchanged.
      case ApiFailureServerFault():
        _publish(
          deleting
              ? noteDeleteUnconfirmedFeedback
              : noteSaveUnconfirmedFeedback,
        );
        return const NoteUnconfirmed();

      // These belong to other features and are not expected here. Handle them
      // explicitly so a new failure type cannot be overlooked.
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
          ApiFailureGoogleAuth() ||
          ApiFailurePasswordReset() ||
          ApiFailureCollectionDeleteTargetNotFound():
        _publish(deleting ? noteDeleteFailedFeedback : noteSaveFailedFeedback);
        return const NoteRejected();
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}
