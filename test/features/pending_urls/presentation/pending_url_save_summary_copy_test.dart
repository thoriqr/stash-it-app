import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/features/pending_urls/presentation/pending_url_save_summary_copy.dart';

void main() {
  test('all saved is a success', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 3, remaining: 0),
    );

    expect(feedback.tone, FeedbackTone.success);
    expect(feedback.copy, 'Saved all 3 links to your account.');
  });

  test('one saved link is singular', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 1, saved: 1, remaining: 0),
    );

    expect(feedback.tone, FeedbackTone.success);
    expect(feedback.copy, 'Saved the link to your account.');
  });

  test('a partial run is a warning with the remaining count', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 2, remaining: 1),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, contains('Saved 2 of 3 links.'));
    expect(feedback.copy, contains('1 link is still on this device.'));
  });

  test('nothing saved is a known failure', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 0, remaining: 3),
    );

    expect(feedback.tone, FeedbackTone.danger);
    expect(feedback.copy, contains('No links were saved.'));
    expect(feedback.copy, contains('3 links are still on this device.'));
  });

  test(
    'an uncertain outcome uses the uncertain tone and never says unsaved',
    () {
      final feedback = pendingUrlSaveSummaryFeedback(
        const PendingUrlSaveSummary(
          total: 2,
          saved: 1,
          uncertain: 1,
          remaining: 1,
        ),
      );

      expect(feedback.tone, FeedbackTone.uncertain);
      expect(feedback.copy, contains("couldn't confirm 1 link"));
      expect(feedback.copy, contains('1 link is still on this device.'));
      expect(feedback.copy, contains('Check your Inbox before trying again.'));
      expect(feedback.copy, isNot(contains('wasn\u2019t saved')));
      expect(feedback.copy, isNot(contains("wasn't saved")));
    },
  );

  test('a single uncertain link is described without a count', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 1, uncertain: 1, remaining: 1),
    );

    expect(feedback.tone, FeedbackTone.uncertain);
    expect(
      feedback.copy,
      "We couldn't confirm the save. The link is still on this device. "
      'Check your Inbox before trying again.',
    );
  });

  test('a rate-limit stop reports the server wait', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 1,
        stoppedBy: PendingUrlSaveStop.rateLimited,
        retryAfter: Duration(seconds: 42),
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, contains('Try again in 42 seconds.'));
  });

  test('a rate-limit stop without a server wait invents none', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        stoppedBy: PendingUrlSaveStop.rateLimited,
        remaining: 2,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, contains('Try again shortly.'));
    expect(feedback.copy, isNot(contains('seconds')));
  });

  test('an auth stop points at signing in again', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 1,
        stoppedBy: PendingUrlSaveStop.authRequired,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, contains('Sign in again to save the rest.'));
  });

  test('a server stop points at a retry', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 1,
        stoppedBy: PendingUrlSaveStop.server,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, contains('Try again.'));
  });

  test('a local-list failure does not claim the entry was removed', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(
        total: 2,
        saved: 1,
        remaining: 2,
        stoppedBy: PendingUrlSaveStop.localList,
      ),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, contains("couldn't update the list"));
    expect(feedback.copy, isNot(contains('Saved all')));
  });

  test('an unknown remaining count is omitted, not invented', () {
    final feedback = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 2),
    );

    expect(feedback.tone, FeedbackTone.warning);
    expect(feedback.copy, 'Saved 2 of 3 links.');
    expect(feedback.copy, isNot(contains('still on this device')));
  });

  test('a zero remaining count does not claim the rest are still here', () {
    final partial = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 3, saved: 2, remaining: 0),
    );
    expect(partial.copy, 'Saved 2 of 3 links.');
    expect(partial.copy, isNot(contains('still on this device')));

    final none = pendingUrlSaveSummaryFeedback(
      const PendingUrlSaveSummary(total: 2, knownFailed: 2, remaining: 0),
    );
    expect(none.tone, FeedbackTone.danger);
    expect(none.copy, 'No links were saved.');
    expect(none.copy, isNot(contains('still on this device')));
  });
}
