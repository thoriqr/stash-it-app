import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';

/// The one sentence a bulk save leaves behind.
///
/// Selected from the typed [PendingUrlSaveSummary], never from a backend
/// message. The certainty rule is the same one the rest of the app uses:
/// [FeedbackTone.uncertain] is the only treatment that may say an outcome was
/// not established, and it must not call the link unsaved.
///
/// The copy is client-owned and English-only until the ARB layer exists, like
/// every other string in the app.
AppFeedback pendingUrlSaveSummaryFeedback(PendingUrlSaveSummary summary) {
  final total = summary.total;
  final saved = summary.saved;
  final remaining = summary.remaining;

  if (summary.stoppedBy == PendingUrlSaveStop.localList) {
    return AppFeedback(
      tone: FeedbackTone.warning,
      copy:
          "Saved ${_links(saved)}, but this device couldn't update the list. "
          'Check the list before trying again.',
    );
  }

  if (summary.uncertain > 0) {
    if (total == 1) {
      return const AppFeedback(
        tone: FeedbackTone.uncertain,
        copy:
            "We couldn't confirm the save. The link is still on this device. "
            'Check your Inbox before trying again.',
      );
    }

    final lead = saved == 0
        ? "We couldn't confirm saving these links."
        : "Saved $saved of $total links. We couldn't confirm "
              '${_links(summary.uncertain)}.';
    return AppFeedback(
      tone: FeedbackTone.uncertain,
      copy:
          '$lead${_remainingClause(remaining)} Check your Inbox before trying '
          'again.',
    );
  }

  if (summary.stoppedBy == PendingUrlSaveStop.rateLimited) {
    final wait = summary.retryAfter;
    final advice = wait == null
        ? "You're saving too quickly. Try again shortly."
        : "You're saving too quickly. Try again in ${_waitPhrase(wait)}.";
    return AppFeedback(
      tone: FeedbackTone.warning,
      copy: '${_lead(saved, total)} $advice${_remainingClause(remaining)}',
    );
  }

  if (summary.stoppedBy == PendingUrlSaveStop.authRequired) {
    return AppFeedback(
      tone: FeedbackTone.warning,
      copy:
          '${_lead(saved, total)} Sign in again to save the rest.'
          '${_remainingClause(remaining)}',
    );
  }

  if (summary.stoppedBy == PendingUrlSaveStop.server ||
      summary.stoppedBy == PendingUrlSaveStop.malformed ||
      summary.stoppedBy == PendingUrlSaveStop.unknown) {
    return AppFeedback(
      tone: saved == 0 ? FeedbackTone.danger : FeedbackTone.warning,
      copy: '${_lead(saved, total)} Try again.${_remainingClause(remaining)}',
    );
  }

  if (total > 0 && saved == total && (remaining == null || remaining == 0)) {
    return AppFeedback(
      tone: FeedbackTone.success,
      copy: total == 1
          ? 'Saved the link to your account.'
          : 'Saved all $total links to your account.',
    );
  }

  if (saved == 0) {
    return AppFeedback(
      tone: FeedbackTone.danger,
      copy: 'No links were saved.${_remainingClause(remaining)}',
    );
  }

  return AppFeedback(
    tone: FeedbackTone.warning,
    copy: 'Saved $saved of $total links.${_remainingClause(remaining)}',
  );
}

String _lead(int saved, int total) {
  if (saved == 0) {
    return total == 1 ? "The link wasn't saved." : 'No links were saved.';
  }
  return 'Saved $saved of $total links.';
}

String _remainingClause(int? remaining) {
  // Null means the final store read failed; zero means the entries were
  // pruned. Neither is evidence that anything is still on the device, so
  // neither may carry the sentence that says so.
  if (remaining == null || remaining <= 0) return '';
  return ' ${_links(remaining)} ${remaining == 1 ? 'is' : 'are'} still on this '
      'device.';
}

String _links(int count) => count == 1 ? '1 link' : '$count links';

/// The server's stated wait, in the coarsest unit that does not understate it.
///
/// Mirrors the existing single-save helper: a missing `Retry-After` produces no
/// countdown at all, and the value is never invented.
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
