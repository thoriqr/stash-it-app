import 'package:stash_it_app/app/feedback/app_feedback.dart';

/// Stable feedback instances for outcomes whose copy does not depend on a
/// server-provided name. Reusing them preserves identity-based notification
/// replacement for repeated identical outcomes.
final AppFeedback savedItemUnavailableFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.itemUnavailable,
);

final AppFeedback savedItemDeletedFeedback = AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.itemDeleted,
);

final AppFeedback deleteItemUnconfirmedFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: (l10n) => l10n.deleteItemUnconfirmed,
);

final AppFeedback deleteItemAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.deleteItemAuthRequired,
);

final AppFeedback deleteItemRefreshUncertainFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.deleteItemRefreshUncertain,
);

final AppFeedback deleteItemCredentialStorageFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.deleteItemCredentialStorage,
);

final AppFeedback deleteItemFailedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.itemNotDeleted,
);

final AppFeedback deleteItemRateLimitedFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.deleteItemRateLimited,
);

final AppFeedback collectionDeleteFailedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.collectionDeleteFailed,
);

final AppFeedback collectionDeleteAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.collectionDeleteAuthRequired,
);

final AppFeedback moveServerErrorFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.moveServerError,
);

final AppFeedback moveUnconfirmedFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: (l10n) => l10n.moveUnconfirmed,
);

final AppFeedback moveAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.moveAuthRequired,
);

final AppFeedback moveRefreshUncertainFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.moveRefreshUncertain,
);

final AppFeedback moveCredentialStorageFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.moveCredentialStorage,
);

final AppFeedback moveMalformedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.moveMalformed,
);

AppFeedback pageReReadFeedback() => AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.pageReRead,
);

AppFeedback pageReReadNoDetailsFeedback() => AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.pageReReadNoDetails,
);

final AppFeedback pageReadFailedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.pageReadFailed,
);

final AppFeedback enrichUnconfirmedFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: (l10n) => l10n.enrichUnconfirmed,
);

final AppFeedback enrichUnavailableFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.enrichUnavailable,
);

final AppFeedback enrichAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.enrichAuthRequired,
);

final AppFeedback enrichRefreshUncertainFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.enrichRefreshUncertain,
);

final AppFeedback enrichCredentialStorageFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.enrichCredentialStorage,
);

final AppFeedback enrichFailedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.enrichFailed,
);

final AppFeedback enrichServerFaultFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.enrichServerFault,
);

final AppFeedback linkCannotOpenFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.linkCannotOpen,
);

final AppFeedback linkLaunchFailedFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.linkLaunchFailed,
);

AppFeedback refreshFailedFeedback() => AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: (l10n) => l10n.refreshFailed,
);

AppFeedback itemDeletedAndCollectionDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.success,
      message: (l10n) => l10n.itemDeletedAndCollectionDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionUnavailableAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionUnavailableAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionNotEmptyAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionNotEmptyAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionProtectedAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionProtectedAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteUnconfirmedAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.uncertain,
      message: (l10n) => l10n.collectionDeleteUnconfirmedAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteAuthRequiredAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionDeleteAuthRequiredAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteSessionEndedAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionDeleteSessionEndedAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteRefreshUncertainAfterItemDeletedFeedback(
  String name,
) => AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.collectionDeleteRefreshUncertainAfterItemDeleted(
    _collectionNameOrFallback(name, l10n.savedItemTheCollection),
  ),
);

AppFeedback collectionDeleteCredentialStorageAfterItemDeletedFeedback(
  String name,
) => AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.collectionDeleteCredentialStorageAfterItemDeleted(
    _collectionNameOrFallback(name, l10n.savedItemTheCollection),
  ),
);

AppFeedback collectionDeleteRateLimitedAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionDeleteRateLimitedAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteFailedAfterItemDeletedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.danger,
      message: (l10n) => l10n.collectionDeleteFailedAfterItemDeleted(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeletedFeedback(String name) => AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.collectionDeleted(
    _collectionNameOrFallback(name, l10n.savedItemTheCollection),
  ),
);

AppFeedback collectionDeletedItemsMovedFeedback(String name, String target) =>
    AppFeedback.localized(
      tone: FeedbackTone.success,
      message: (l10n) => l10n.collectionDeletedItemsMoved(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
        target,
      ),
    );

AppFeedback collectionDeleteTargetUnavailableFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionDeleteTargetUnavailable(name),
    );

AppFeedback collectionUnavailableFeedback(String name) => AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.collectionUnavailable(
    _collectionNameOrFallback(name, l10n.savedItemTheCollection),
  ),
);

AppFeedback collectionNotEmptyFeedback(String name) => AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.collectionNotEmpty(
    _collectionNameOrFallback(name, l10n.savedItemTheCollection),
  ),
);

AppFeedback collectionProtectedFeedback(String name) => AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.collectionProtected(
    _collectionNameOrFallback(name, l10n.savedItemTheCollection),
  ),
);

AppFeedback collectionDeleteUnconfirmedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.uncertain,
      message: (l10n) => l10n.collectionDeleteUnconfirmed(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteRefreshUncertainFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionDeleteRefreshUncertain(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteCredentialStorageFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.collectionDeleteCredentialStorage(
        _collectionNameOrFallback(name, l10n.savedItemTheCollection),
      ),
    );

AppFeedback collectionDeleteRateLimitedFeedback(Duration? retryAfter) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) {
        if (retryAfter == null) {
          return l10n.collectionDeleteRateLimitedNoWait;
        }
        return l10n.collectionDeleteRateLimitedWithWait(
          _waitPhrase(
            retryAfter,
            second: l10n.retryAfterSecond,
            seconds: l10n.retryAfterSeconds,
            minutes: l10n.retryAfterMinutes,
            hours: l10n.retryAfterHours,
          ),
        );
      },
    );

AppFeedback moveRateLimitedFeedback(Duration? retryAfter) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) {
        if (retryAfter == null) return l10n.moveRateLimitedNoWait;
        return l10n.moveRateLimitedWithWait(
          _waitPhrase(
            retryAfter,
            second: l10n.retryAfterSecond,
            seconds: l10n.retryAfterSeconds,
            minutes: l10n.retryAfterMinutes,
            hours: l10n.retryAfterHours,
          ),
        );
      },
    );

AppFeedback enrichRateLimitedFeedback(Duration? retryAfter) =>
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) {
        if (retryAfter == null) return l10n.enrichRateLimitedNoWait;
        return l10n.enrichRateLimitedWithWait(
          _waitPhrase(
            retryAfter,
            second: l10n.retryAfterSecond,
            seconds: l10n.retryAfterSeconds,
            minutes: l10n.retryAfterMinutes,
            hours: l10n.retryAfterHours,
          ),
        );
      },
    );

AppFeedback alreadyInCollectionFeedback(String name) => AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.alreadyInCollection(name),
);

AppFeedback createdCollectionAndMovedFeedback(String name) =>
    AppFeedback.localized(
      tone: FeedbackTone.success,
      message: (l10n) => l10n.createdCollectionAndMoved(name),
    );

AppFeedback movedToCollectionFeedback(String name) => AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.movedToCollection(name),
);

String _collectionNameOrFallback(String name, String fallback) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

/// Formats the server-provided wait duration using the coarsest unit that does
/// not understate the remaining time.
String _waitPhrase(
  Duration wait, {
  required String second,
  required String Function(int count) seconds,
  required String Function(int count) minutes,
  required String Function(int count) hours,
}) {
  final totalSeconds = wait.inSeconds;
  if (totalSeconds <= 1) return second;
  if (totalSeconds < 60) return seconds(totalSeconds);

  final totalMinutes = (totalSeconds / 60).ceil();
  if (totalMinutes < 60) return minutes(totalMinutes);

  return hours((totalMinutes / 60).ceil());
}
