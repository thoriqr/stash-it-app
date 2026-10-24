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

/// The re-read mutation: **one synchronous `POST` per explicit user action**.
///
/// The state is a plain `bool` — "a re-read is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried POST is a
/// second page fetch and a second write. Publishing the outcome through the
/// app-wide feedback channel keeps the mutation out of the provider's error path.
/// `keepAlive` makes the notifier outlive the route, so a request already sent is
/// not abandoned when the screen is popped, and the duplicate guard survives a
/// rebuild.
///
/// **The in-flight flag is set synchronously before the first `await`.** Two taps
/// in the same frame therefore produce one request, not two.
///
/// **There is nothing to poll.** The endpoint is synchronous: its `200` is the
/// complete post-attempt item, whether extraction succeeded or failed. This
/// controller applies that answer directly and issues no follow-up read.
@Riverpod(keepAlive: true)
class EnrichSavedItem extends _$EnrichSavedItem {
  @override
  bool build() => false;

  /// Re-reads [item]'s source page once.
  ///
  /// [item] supplies the id to POST and the collection whose already-loaded
  /// contents should be patched. A second call while the first is in flight is
  /// ignored and sends nothing.
  ///
  /// **No cache is touched on failure.** Metadata is only ever replaced by a
  /// `200` from this request, because a refused request wrote nothing and an
  /// ambiguous one established nothing. In particular there is no reconciliation
  /// GET after a transport failure: re-reading would be a second attempt, which
  /// [D23]/[D24] reserve for the user.
  ///
  /// **A `failed` enrichment status is a successful request.** The server recorded
  /// an attempt that could not extract the page; the item keeps the metadata it
  /// already had, and this method applies exactly that.
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

  /// Applies a confirmed result to every cache entry that already holds this item.
  ///
  /// Each provider is checked with `exists` first: reading a listing would start
  /// a fetch as a side effect of a detail-screen action. Nothing is invalidated —
  /// enrichment changes no membership, count, or sort, so `collectionsProvider`
  /// and the Inbox's cursor stay as they are, and Search results are left stale
  /// until the user searches again.
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

  /// Copy for a returned outcome, selected from the item the server reported.
  ///
  /// A `completed` item with no metadata is a normal extraction, not an error
  /// (D17), so it gets success tone and a sentence that says what the page had. A
  /// `failed` item is an extraction failure — not evidence that the saved item is
  /// broken — and keeps whatever metadata the backend preserved.
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

      // Defensive and unreachable: the verified contract never answers a call
      // with `pending`. Claiming either extraction outcome would be a guess.
      case EnrichmentStatus.pending:
        return const AppFeedback(
          tone: FeedbackTone.uncertain,
          copy: "We couldn't confirm the re-read. Try again.",
        );
    }
  }

  void _handleFailure(String savedItemId, ApiFailure failure) {
    switch (failure) {
      // The limiter refused before the handler ran: no page was fetched and no
      // state was written. The countdown is the server's own `Retry-After`, never
      // a number computed from the window.
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

      // The limiter failed closed. Nothing ran, and there is no retry interval to
      // report: a fabricated one would be a guess presented as a fact.
      case ApiFailureServerUnavailable():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy: 'Re-reading is temporarily unavailable. Try again shortly.',
          ),
        );

      // The item is gone or is another account's; also answered when the item is
      // deleted while the attempt runs. The detail provider is invalidated so its
      // existing unavailable state can take over. No copy says which of the
      // possibilities happened.
      case ApiFailureNotFound():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: 'This item is no longer available.',
          ),
        );
        ref.invalidate(savedItemDetailProvider(savedItemId));

      // The guard refused before the handler ran. If the session layer has already
      // taken over, the router and sign-in screen explain the expiry once; a
      // second notice would be noise.
      case ApiFailureAuthRequired():
        if (!ref.read(authStateProvider).isSignedOut) {
          _publish(
            const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to re-read this page.',
            ),
          );
        }

      // Only the refresh endpoint emits terminal codes, and the interceptor
      // converts a terminal renewal into the original 401.
      case ApiFailureSessionEnded():
        break;

      // A renewal that failed ambiguously never replayed the POST: the 401 came
      // from the guard, before the handler. The page is known not re-read; the
      // session is the uncertain part, and the copy must not say it ended.
      case ApiFailureRefreshUncertain():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "We couldn't renew your session, so the page wasn't re-read. "
                'Try again.',
          ),
        );

      // The local credential layer could not produce a session, so the request
      // was never replayed. Known not re-read; the session did not end.
      case ApiFailureCredentialStorage():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.warning,
            copy:
                "This device couldn't refresh your session, so the page wasn't "
                're-read. Try again.',
          ),
        );

      // A well-formed client never sends an unparseable id or body. Known not
      // re-read, and nothing the user can correct from this screen.
      case ApiFailureValidation() || ApiFailureMalformedRequest():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "We couldn't re-read this page. Try again.",
          ),
        );

      // No response, or a response whose body could not be read. The attempt may
      // have been recorded and only its representation be missing, so the copy
      // must not claim the page was not re-read. No reconciliation read is issued:
      // that would be a second attempt the user did not ask for.
      case ApiFailureTransport() || ApiFailureUnreadableResponse():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.uncertain,
            copy: "We couldn't confirm the re-read. Try again.",
          ),
        );

      // A `500` from this route is the handler's own database write: the request
      // produced no representation, so nothing can be applied. It is a known
      // failure rather than an ambiguous one — the write is a single statement,
      // and a failure to commit leaves the item as it was.
      case ApiFailureServerFault():
        _publish(
          const AppFeedback(
            tone: FeedbackTone.danger,
            copy: "Something went wrong re-reading this page. Try again.",
          ),
        );

      // Unreachable on this route: these belong to collection writes and
      // deletes, and to the profile routes. Handled explicitly so a future code
      // cannot be silently ignored.
      case ApiFailureUserNotFound() ||
          ApiFailureCurrentPasswordInvalid() ||
          ApiFailureCurrentPasswordRequired() ||
          ApiFailureUnexpectedCurrentPassword() ||
          ApiFailurePasswordCredentialAlreadyExists() ||
          ApiFailurePasswordAlreadyChanged() ||
          ApiFailureCollectionNameAlreadyExists() ||
          ApiFailureCollectionNotEmpty() ||
          ApiFailureUnsortedCollectionProtected() ||
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

/// How long the server said to wait, in the coarsest unit that does not
/// understate it.
///
/// This mirrors the helpers in `save_url_controller.dart` and
/// `move_to_collection_controller.dart` rather than sharing one: it is two
/// branches of English pluralisation, not a policy module, and
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
