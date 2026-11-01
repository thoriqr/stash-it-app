import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/saved_items/application/collection_saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/application/saved_item_detail_provider.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_enrichment_result.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_summary.dart';

part 'enrich_saved_item_controller.g.dart';

/// Handles one re-read request per explicit user action.
///
/// The state is a boolean indicating whether a request is in flight, not its
/// outcome. Keeping failures out of the provider's build path prevents Riverpod
/// from automatically retrying a write. Feedback is published separately.
///
/// The notifier stays alive while a request is running, even if the screen is
/// closed. The in-flight flag also prevents duplicate requests after rebuilds.
///
/// The flag is set synchronously before the first `await`, so multiple taps in
/// the same frame still produce only one request.
///
/// The endpoint returns the complete result of the attempt in its response.
/// No polling or follow-up read is needed.
@Riverpod(keepAlive: true)
class EnrichSavedItem extends _$EnrichSavedItem {
  @override
  bool build() => false;

  /// Re-reads [item]'s source page once.
  ///
  /// [item] provides the saved item ID and collection ID used to update any
  /// already-loaded cache entries. Calls made while another request is in
  /// flight are ignored.
  ///
  /// Cache entries are updated only after a confirmed response. A refused or
  /// ambiguous request does not provide a result that can safely be applied.
  /// No automatic reconciliation request is made; another attempt requires
  /// an explicit user action.
  ///
  /// An enrichment status of `failed` is still a successful request: the
  /// attempt was recorded, but the page could not be extracted. Existing
  /// metadata is preserved, and the returned result is applied as received.
  Future<void> enrich(SavedItemSummary item) async {
    if (state) return;
    state = true;

    try {
      final result = await ref
          .read(savedItemsRepositoryProvider)
          .enrich(item.id);

      if (!ref.mounted) return;

      _apply(item, result);
      _publish(_outcomeFeedback(result));
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return;
      _handleFailure(item.id, failure);
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Applies a confirmed result to cache entries that already contain this item.
  ///
  /// Providers are checked with `exists` before reading them, avoiding fetches
  /// triggered as a side effect of a detail-screen action. No providers are
  /// invalidated because enrichment does not change collection membership,
  /// counts, or sort order. Search results remain unchanged until searched again.
  void _apply(SavedItemSummary item, SavedItemEnrichmentResult result) {
    final detail = savedItemDetailProvider(item.id);
    if (ref.exists(detail)) {
      ref.read(detail.notifier).applyEnrichment(result);
    }

    if (ref.exists(savedItemsProvider)) {
      ref.read(savedItemsProvider.notifier).applyEnrichment(result);
    }

    final collectionId = item.collectionId.trim();
    if (collectionId.isEmpty) return;

    final contents = collectionSavedItemsProvider(collectionId);
    if (ref.exists(contents)) {
      ref.read(contents.notifier).applyEnrichment(result);
    }
  }

  /// Selects feedback based on the returned enrichment result.
  ///
  /// A `completed` item without metadata is still a successful extraction,
  /// so it receives success feedback with an appropriate message. A `failed`
  /// status means extraction failed, not that the saved item is broken.
  AppFeedback _outcomeFeedback(SavedItemEnrichmentResult result) {
    switch (result.enrichmentStatus) {
      case EnrichmentStatus.completed:
        return AppFeedback(
          tone: FeedbackTone.success,
          copy: result.hasNoMetadata
              ? 'Page re-read. This page shows no details.'
              : 'Page re-read.',
        );

      case EnrichmentStatus.failed:
        return const AppFeedback(
          tone: FeedbackTone.danger,
          copy: "Couldn't read this page.",
        );

      // Defensive fallback: the endpoint should not return a pending result.
      // Neither success nor failure can be claimed if it does.
      case EnrichmentStatus.pending:
        return const AppFeedback(
          tone: FeedbackTone.uncertain,
          copy: "We couldn't confirm the re-read. Try again.",
        );
    }
  }

  void _handleFailure(String savedItemId, ApiFailure failure) {
    switch (failure) {
      // The request was refused before the re-read started. Use the server's
      // Retry-After value when available rather than calculating a wait time.
      case ApiFailureRateLimited(:final retryAfter):
        _publish(
          AppFeedback(
            tone: FeedbackTone.warning,
            copy: retryAfter == null
                ? "You've re-read too many pages. Try again shortly."
                : "You've re-read too many pages. Try again in "
                      '${_waitPhrase(retryAfter)}.',
          ),
        );

      // Re-reading is temporarily unavailable. No retry interval is provided.
      case ApiFailureServerUnavailable():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy: 'Re-reading is temporarily unavailable. Try again shortly.',
          ),
        );

      // The item is unavailable, including when it is deleted during the
      // attempt. Invalidate its detail so the unavailable state can take over.
      // The message does not disclose which situation occurred.
      case ApiFailureNotFound():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'This item is no longer available.',
          ),
        );
        ref.invalidate(savedItemDetailProvider(savedItemId));

      // The user must sign in again. Avoid duplicate feedback if the session
      // state has already changed and the router is handling the redirect.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to re-read this page.',
            ),
          );
        }

      // The session has ended; session handling is responsible for the redirect.
      case ApiFailureSessionEnded():
        break;

      // The session could not be renewed, but the re-read request was not
      // replayed. The page is known not to have been re-read.
      case ApiFailureRefreshUncertain():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "We couldn't renew your session, so the page wasn't re-read. "
                'Try again.',
          ),
        );

      // The device could not access the stored credentials, so the request
      // was not replayed and the page was not re-read.
      case ApiFailureCredentialStorage():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "This device couldn't refresh your session, so the page wasn't "
                're-read. Try again.',
          ),
        );

      // The request was rejected as invalid. The user cannot correct these
      // request details from this screen.
      case ApiFailureValidation() || ApiFailureMalformedRequest():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "We couldn't re-read this page. Try again.",
          ),
        );

      // The response was not received or could not be read. The attempt may
      // have been recorded, so its outcome is uncertain. No follow-up request
      // is made automatically.
      case ApiFailureTransport() || ApiFailureUnreadableResponse():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.uncertain,
            copy: "We couldn't confirm the re-read. Try again.",
          ),
        );

      // The server reported a failure while processing the re-read. No result
      // is available to apply to the cached item.
      case ApiFailureServerFault():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "Something went wrong re-reading this page. Try again.",
          ),
        );

      // These failures belong to other features and are not expected here.
      // Handle them explicitly so newly added failure types are not overlooked.
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
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "We couldn't re-read this page. Try again.",
          ),
        );
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}

/// Formats the server-provided wait duration using the coarsest unit that
/// does not understate the remaining time.
String _waitPhrase(Duration wait) {
  final seconds = wait.inSeconds;
  if (seconds <= 1) return 'a second';
  if (seconds < 60) return '$seconds seconds';

  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return minutes == 1 ? '1 minute' : '$minutes minutes';

  final hours = (minutes / 60).ceil();
  return hours == 1 ? '1 hour' : '$hours hours';
}
