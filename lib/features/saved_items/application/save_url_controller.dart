import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/auth_state.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/saved_items/data/saved_items_providers.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';

part 'save_url_controller.g.dart';

/// What a confirmed save says. **Only that the item was created.**
///
/// **[D26]** A save confirmation must not imply that enrichment finished, that
/// metadata exists, that organization ran, or that the item will move — the
/// backend has queued enrichment by the time this is shown, and nothing about
/// that work has been observed yet.
const String _savedCopy = 'Saved.';

/// What a value this client can see is **not a URL** says.
///
/// **Nothing was sent, and the copy must not suggest otherwise.** It names the
/// format and what to do about it rather than claiming a rejection, so the one
/// case that never reached the server cannot read like a server answer. The
/// server's own refusals keep their own sentence (`saveFeedbackFor`), and the
/// user's next action is the same in both: edit the field and send it again.
///
/// A `const` instance, like the table's rows: `Feedback.show` treats republishing
/// the same instance as a no-op, and that is right here — a second refusal of the
/// same shape while the notice is still up is the same unchanged situation.
const AppFeedback _invalidUrlFeedback = AppFeedback(
  tone: FeedbackTone.danger,
  copy:
      "That doesn't look like a valid link. Enter a full http:// or https:// "
      'address.',
);

/// The Save URL mutation: one `POST /saved-items` per explicit user action.
///
/// ## State is "a save is in flight", and that is all
///
/// The *outcome* of a save is deliberately not provider state. A failure
/// published as `AsyncError` would be retried by Riverpod (a failed build is
/// retried up to ten times with backoff unless the provider opts out), and a
/// retried POST is a second insert: the backend has no idempotency key and
/// duplicates are allowed (**D16**), so the duplicate would be silent and real.
/// Publishing the outcome through the app-wide feedback channel avoids the whole
/// question, keeps a failed save out of the widget's build, and matches how the
/// rest of the app reports transient outcomes.
///
/// `bool` is therefore the entire state, and value equality is built in.
///
/// ## `keepAlive`
///
/// A save outlives the screen that started it. The user may switch destination
/// while the POST is in flight; the notifier must still publish the outcome and
/// refresh the listing afterwards, and an auto-disposed notifier could do neither
/// (its `ref` is dead, so the state write would throw).
///
/// ## No retry, at any layer
///
/// The POST is issued **once per tap**. [submit] has no retry, no timer and no
/// "try again" path, and nothing here resubmits after an uncertain outcome
/// (**D15**, **D16**). The `AuthInterceptor`'s one replay is not a retry of this
/// mutation: it happens after a `401` that the bearer guard raised *before* the
/// handler ran, so the first attempt wrote nothing and the replayed request is
/// still the first one that can write.
///
/// A second call while one is in flight is declined rather than queued — see
/// [submit].
///
/// ## No `retry:` override
///
/// [build] is `=> false`: it performs no I/O and cannot fail, so there is no
/// failure for Riverpod's retry policy to see. `SavedItems` needs the override
/// because its *build* reads the network; this one has nothing to guard.
@Riverpod(keepAlive: true)
class SaveUrl extends _$SaveUrl {
  @override
  bool build() => false;

  /// Saves [rawUrl], and returns whether the server **confirmed the create**.
  ///
  /// That boolean is the only thing a caller may act on: `true` means the field
  /// can be cleared, `false` means it must be kept so the value can be corrected
  /// and sent again (**D25**). This method does not throw for a refusal — the
  /// refusal has already been reported through the feedback channel.
  ///
  /// **A second submission while one is in flight is declined, not queued.** The
  /// button is disabled while this is true; this guard is what holds when two
  /// taps still arrive in the same frame. Declining rather than queueing is the
  /// only safe choice: the backend allows duplicate URLs, so a queued second tap
  /// would create a second item that no one asked for.
  ///
  /// **The URL is trimmed, then checked for a shape that cannot be a URL**
  /// ([isSubmittableUrl]). §2.9 recommends mirroring the server's `url` rule so
  /// the common mistake never round-trips; what is checked here is the part of
  /// that rule this client can decide alone, and everything it cannot — whether
  /// the host resolves, the 2048-byte cap, domain rules — is still the server's
  /// to refuse, with the server's own copy. A refused value never reaches the
  /// repository, and the field keeps it (**D25**).
  Future<bool> submit(String rawUrl) async {
    if (state) return false;

    final url = rawUrl.trim();
    if (url.isEmpty) return false;

    // Before the flag and before the repository, so a value that cannot be a URL
    // never becomes a request — not even a declined one.
    if (!isSubmittableUrl(url)) {
      _publish(_invalidUrlFeedback);
      return false;
    }

    state = true;

    try {
      await ref.read(savedItemsRepositoryProvider).create(url: url);

      // The notifier is app-level and outlives the screen, so this is a guard
      // against a torn-down container rather than a state the app reaches.
      if (!ref.mounted) return true;

      _publish(const AppFeedback(tone: FeedbackTone.success, copy: _savedCopy));

      // Deliberately **not** awaited. The save is confirmed, so the caller's
      // field clears now; whether the listing has caught up is a separate read.
      // `refreshHead` never throws, and a refresh that fails must not turn a
      // confirmed save into a reported failure — the list simply stays stale
      // until the user's own retry.
      unawaited(ref.read(savedItemsProvider.notifier).refreshHead());

      return true;
    } on ApiFailure catch (failure) {
      if (!ref.mounted) return false;

      final feedback = saveFeedbackFor(
        failure,
        sessionEnded: ref.read(authStateProvider).isSignedOut,
      );
      if (feedback != null) _publish(feedback);

      return false;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  void _publish(AppFeedback feedback) =>
      ref.read(feedbackProvider.notifier).show(feedback);
}

/// What a failed save says, and in which tone — or `null` for "say nothing".
///
/// The mapping is a pure function of the typed [ApiFailure], so every outcome can
/// be checked without a container, a request or a widget. **No branch reads
/// `error.code` or `error.message`**: the variant is the decision (**D15**,
/// **D22**), and the copy below is this client's, per outcome.
///
/// The certainty of each variant decides both the tone and the words:
///
/// | Variant | Outcome | Tone |
/// | --- | --- | --- |
/// | validation, malformed, rate limit, 5xx | known not saved | danger / warning |
/// | transport | **uncertain** | uncertain |
/// | unreadable reply | **unestablished** | uncertain |
/// | auth required, session ended | known not saved | danger, or silent |
/// | renewal failed | known not saved; session unknown | warning |
///
/// [sessionEnded] is the caller's answer to "has the session layer already taken
/// over this failure?". When it has, the router has moved the user to the auth
/// entry screen and `AuthEntryScreen` is showing its own one-time
/// `sessionEndedMessage`; a second notice about the same expiry would be two
/// announcements of one event.
AppFeedback? saveFeedbackFor(ApiFailure failure, {required bool sessionEnded}) {
  return switch (failure) {
    // A URL the server refuses to use. Actionable, and the field still holds the
    // value, so the action is "fix it here". **D15 group D.**
    ApiFailureValidation() => const AppFeedback(
      tone: FeedbackTone.danger,
      copy: "That doesn't look like a valid link. Check the URL and try again.",
    ),

    // The body itself was unparseable, which a well-formed client never sends.
    // Known not saved, and nothing the user can correct, so it does not pretend
    // the URL was the problem. **D15 group E.**
    ApiFailureMalformedRequest() => const AppFeedback(
      tone: FeedbackTone.danger,
      copy: 'Something went wrong sending that link. Try again.',
    ),

    // A spent budget. The wait comes from `Retry-After` when the server sent one
    // and is never invented when it did not — a 429 with no header, or a
    // malformed one, gets no countdown at all. **D15 group B**, §6.5 copy rules.
    //
    // The wording does not name the save budget, because this variant is also
    // what a `429` from a *renewal* looks like (`POST /auth/refresh` is IP
    // rate-limited), and both are "too many requests, come back later".
    ApiFailureRateLimited(:final retryAfter) => AppFeedback(
      tone: FeedbackTone.warning,
      copy: retryAfter == null
          ? "You're saving too quickly. Try again shortly."
          : "You're saving too quickly. Try again in ${_waitPhrase(retryAfter)}.",
    ),

    // A `503` from a limiter that failed closed, or a `500` from the insert. Both
    // are known not saved: the limiter refuses before the handler runs, and a
    // `500` is a commit that did not happen. No countdown — no recovery time is
    // known. **D15 group C**, which covers both codes.
    //
    // `ApiFailureNotFound` is unreachable on `POST /saved-items` (the handler
    // answers `201`, `400`, `401`, `429`, `500` or `503`), and so are the
    // collection-write variants. If a proxy ever produced any of them, the
    // existing known-not-saved copy is the honest reading; they are grouped here
    // rather than given a misleading create-specific message.
    ApiFailureServerUnavailable() ||
    ApiFailureServerFault() ||
    ApiFailureNotFound() ||
    ApiFailureUserNotFound() ||
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
    ApiFailureCollectionDeleteTargetNotFound() => const AppFeedback(
      tone: FeedbackTone.danger,
      copy: "We couldn't save this link just now. Try again shortly.",
    ),

    // A reply arrived and this client could not use it. **Not reported as a
    // known failure**, because the variant also covers a `201` whose body failed
    // to decode — a save that committed. The client cannot tell the two apart, so
    // the notice claims neither, and the treatment that may not claim "not
    // saved" is the only honest one (**D16**). The advice is the one D15 gives
    // for an outcome that is not known: look at the Inbox before trying again.
    ApiFailureUnreadableResponse() => const AppFeedback(
      tone: FeedbackTone.uncertain,
      copy:
          "We couldn't read the server's reply, so we can't confirm the save. "
          'Check your Inbox before trying again.',
    ),

    // Nothing arrived. **Uncertain, the only case that may say so** (D15 groups
    // G and H, D16), and it may not state that the item is unsaved. The advice is
    // manual: check the Inbox, then decide. No countdown, and no automatic
    // resubmission anywhere in this code.
    ApiFailureTransport() => const AppFeedback(
      tone: FeedbackTone.uncertain,
      copy:
          "We couldn't confirm this save. It may or may not have gone through "
          '— check your Inbox before trying again.',
    ),

    // The renewal itself failed ambiguously, so the original POST was never
    // replayed: the `401` came from the guard, before the handler ran, and the
    // replay only happens after a successful renewal. The *save* is therefore
    // known not saved — what is unknown is the session, which is why the copy
    // says nothing about it having ended and the credentials are kept.
    ApiFailureRefreshUncertain() => const AppFeedback(
      tone: FeedbackTone.warning,
      copy:
          "We couldn't renew your session, so that link wasn't saved. "
          'Try again.',
    ),

    // The local credential layer could not produce a usable session, so again the
    // POST was never replayed. Known not saved; the session did **not** end, and
    // the copy must not imply that it did.
    ApiFailureCredentialStorage() => const AppFeedback(
      tone: FeedbackTone.warning,
      copy:
          "This device couldn't refresh your session, so that link wasn't "
          'saved. Try again.',
    ),

    // The guard refused the request after the interceptor had already done
    // everything it can: either renew-and-replay succeeded and the replay was
    // refused again, or a terminal renewal surfaced the original `401`. A known,
    // actionable refusal — **unless** the session has ended, in which case the
    // router is already taking the user to the auth entry screen, which explains
    // it once. **D15 group A.**
    ApiFailureAuthRequired() =>
      sessionEnded
          ? null
          : const AppFeedback(
              tone: FeedbackTone.danger,
              copy: 'Sign in again to save this link.',
            ),

    // Unreachable on this route: only `POST /auth/refresh` emits the terminal
    // codes, and the interceptor turns a terminal renewal into the original
    // `401` (which arrives as `ApiFailureAuthRequired`, above). Handled
    // explicitly rather than defaulted so a future path cannot announce an
    // expiry that belongs to the session layer.
    ApiFailureSessionEnded() => null,
  };
}

/// How long the server said to wait, in the coarsest unit that does not
/// **understate** it.
///
/// `Retry-After` is the limiter's remaining TTL rounded **up** to whole seconds,
/// so rounding up again keeps the promise "not before this" rather than inviting
/// a retry that is still refused. Only formats a duration the server sent — a
/// missing header yields no countdown at all.
///
/// Two branches of English pluralisation, not a localisation layer: `intl`'s
/// plural rules arrive with `flutter_localizations` (**D20**), which is not a
/// dependency yet, and this is the only counted string in the app.
String _waitPhrase(Duration wait) {
  final seconds = wait.inSeconds;
  if (seconds <= 1) return 'a second';
  if (seconds < 60) return '$seconds seconds';

  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return _count(minutes, 'minute');

  return _count((minutes / 60).ceil(), 'hour');
}

String _count(int value, String unit) =>
    value == 1 ? '1 $unit' : '$value ${unit}s';
