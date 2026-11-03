import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_url_save_state.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// The one sentence a bulk save leaves behind.
///
/// Selected from the typed [PendingUrlSaveSummary], never from a backend
/// message. The certainty rule is the same one the rest of the app uses:
/// [FeedbackTone.uncertain] is the only treatment that may say an outcome was
/// not established, and it must not call the link unsaved.
AppFeedback pendingUrlSaveSummaryFeedback(PendingUrlSaveSummary summary) {
  final total = summary.total;
  final saved = summary.saved;
  final uncertain = summary.uncertain;
  final remaining = summary.remaining ?? 0;
  final stoppedBy = summary.stoppedBy;

  return AppFeedback.localized(
    tone: _toneFor(summary),
    message: (localizations) {
      if (stoppedBy == PendingUrlSaveStop.localList) {
        return localizations.pendingSummaryLocalList(saved);
      }

      if (uncertain > 0) {
        if (total == 1) {
          return localizations.pendingSummaryUncertainSingle;
        }
        if (saved == 0) {
          return localizations.pendingSummaryUncertainNoneSaved(remaining);
        }
        return localizations.pendingSummaryUncertainPartial(
          saved,
          total,
          uncertain,
          remaining,
        );
      }

      if (stoppedBy == PendingUrlSaveStop.rateLimited) {
        final wait = summary.retryAfter;
        if (saved == 0) {
          if (total == 1) {
            return wait == null
                ? localizations.pendingSummaryRateLimitedSingleNoneSavedNoWait(
                    remaining,
                  )
                : localizations
                      .pendingSummaryRateLimitedSingleNoneSavedWithWait(
                        _waitPhrase(localizations, wait),
                        remaining,
                      );
          }
          return wait == null
              ? localizations.pendingSummaryRateLimitedNoneSavedNoWait(
                  remaining,
                )
              : localizations.pendingSummaryRateLimitedNoneSavedWithWait(
                  _waitPhrase(localizations, wait),
                  remaining,
                );
        }
        return wait == null
            ? localizations.pendingSummaryRateLimitedPartialNoWait(
                saved,
                total,
                remaining,
              )
            : localizations.pendingSummaryRateLimitedPartialWithWait(
                saved,
                total,
                _waitPhrase(localizations, wait),
                remaining,
              );
      }

      if (stoppedBy == PendingUrlSaveStop.authRequired) {
        if (saved == 0) {
          return total == 1
              ? localizations.pendingSummaryAuthSingleNoneSaved(remaining)
              : localizations.pendingSummaryAuthNoneSaved(remaining);
        }
        return localizations.pendingSummaryAuthPartial(saved, total, remaining);
      }

      if (stoppedBy == PendingUrlSaveStop.server ||
          stoppedBy == PendingUrlSaveStop.malformed ||
          stoppedBy == PendingUrlSaveStop.unknown) {
        if (saved == 0) {
          return total == 1
              ? localizations.pendingSummaryRetrySingleNoneSaved(remaining)
              : localizations.pendingSummaryRetryNoneSaved(remaining);
        }
        return localizations.pendingSummaryRetryPartial(
          saved,
          total,
          remaining,
        );
      }

      if (total > 0 &&
          saved == total &&
          (summary.remaining == null || remaining == 0)) {
        return total == 1
            ? localizations.pendingSummaryAllSavedSingle
            : localizations.pendingSummaryAllSaved(total);
      }

      if (saved == 0) {
        return localizations.pendingSummaryNoneSaved(remaining);
      }

      return localizations.pendingSummaryPartial(saved, total, remaining);
    },
  );
}

FeedbackTone _toneFor(PendingUrlSaveSummary summary) {
  final total = summary.total;
  final saved = summary.saved;

  if (summary.stoppedBy == PendingUrlSaveStop.localList) {
    return FeedbackTone.warning;
  }

  if (summary.uncertain > 0) return FeedbackTone.uncertain;

  if (summary.stoppedBy == PendingUrlSaveStop.rateLimited ||
      summary.stoppedBy == PendingUrlSaveStop.authRequired) {
    return FeedbackTone.warning;
  }

  if (summary.stoppedBy == PendingUrlSaveStop.server ||
      summary.stoppedBy == PendingUrlSaveStop.malformed ||
      summary.stoppedBy == PendingUrlSaveStop.unknown) {
    return saved == 0 ? FeedbackTone.danger : FeedbackTone.warning;
  }

  if (total > 0 &&
      saved == total &&
      (summary.remaining == null || summary.remaining == 0)) {
    return FeedbackTone.success;
  }

  return saved == 0 ? FeedbackTone.danger : FeedbackTone.warning;
}

/// The server's stated wait, in the coarsest unit that does not understate it.
String _waitPhrase(AppLocalizations localizations, Duration wait) {
  final seconds = wait.inSeconds;
  if (seconds <= 1) return localizations.retryAfterSecond;
  if (seconds < 60) return localizations.retryAfterSeconds(seconds);

  final minutes = (seconds / 60).ceil();
  if (minutes < 60) return localizations.retryAfterMinutes(minutes);

  return localizations.retryAfterHours((minutes / 60).ceil());
}
