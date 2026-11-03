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
        return result.hasNoMetadata
            ? pageReReadNoDetailsFeedback()
            : pageReReadFeedback();

      case EnrichmentStatus.failed:
        return pageReadFailedFeedback;

      // Defensive fallback: the endpoint should not return a pending result.
      // Neither success nor failure can be claimed if it does.
      case EnrichmentStatus.pending:
        return enrichUnconfirmedFeedback;
    }
  }

  void _handleFailure(String savedItemId, ApiFailure failure) {
    switch (failure) {
      // The request was refused before the re-read started. Use the server's
      // Retry-After value when available rather than calculating a wait time.
      case ApiFailureRateLimited(:final retryAfter):
        _publish(enrichRateLimitedFeedback(retryAfter));

      // Re-reading is temporarily unavailable. No retry interval is provided.
      case ApiFailureServerUnavailable():
        _publish(enrichUnavailableFeedback);

      // The item is unavailable, including when it is deleted during the
      // attempt. Invalidate its detail so the unavailable state can take over.
      // The message does not disclose which situation occurred.
      case ApiFailureNotFound():
        _publish(savedItemUnavailableFeedback);
        ref.invalidate(savedItemDetailProvider(savedItemId));

      // The user must sign in again. Avoid duplicate feedback if the session
      // state has already changed and the router is handling the redirect.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(enrichAuthRequiredFeedback);
        }

      // The session has ended; session handling is responsible for the redirect.
      case ApiFailureSessionEnded():
        break;

      // The session could not be renewed, but the re-read request was not
      // replayed. The page is known not to have been re-read.
      case ApiFailureRefreshUncertain():
        _publish(enrichRefreshUncertainFeedback);

      // The device could not access the stored credentials, so the request
      // was not replayed and the page was not re-read.
      case ApiFailureCredentialStorage():
        _publish(enrichCredentialStorageFeedback);

      // The request was rejected as invalid. The user cannot correct these
      // request details from this screen.
      case ApiFailureValidation() || ApiFailureMalformedRequest():
        _publish(enrichFailedFeedback);

      // The response was not received or could not be read. The attempt may
      // have been recorded, so its outcome is uncertain. No follow-up request
      // is made automatically.
      case ApiFailureTransport() || ApiFailureUnreadableResponse():
        _publish(enrichUnconfirmedFeedback);

      // The server reported a failure while processing the re-read. No result
      // is available to apply to the cached item.
      case ApiFailureServerFault():
        _publish(enrichServerFaultFeedback);

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
        _publish(enrichFailedFeedback);
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}
