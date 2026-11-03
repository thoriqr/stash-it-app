import 'package:stash_it_app/app/feedback/app_feedback.dart';

/// Stable feedback instances for outcomes whose copy does not depend on a
/// runtime value. Reusing them preserves identity-based replacement.
final AppFeedback displayNameUpdatedFeedback = AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => l10n.displayNameUpdated,
);

final AppFeedback displayNameUnconfirmedFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: (l10n) => l10n.displayNameUnconfirmed,
);

final AppFeedback accountUnavailableFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.accountUnavailable,
);

final AppFeedback displayNameAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.displayNameAuthRequired,
);

final AppFeedback passwordModeConflictExistsFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.passwordModeConflictExists,
);

final AppFeedback passwordModeConflictRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.warning,
  message: (l10n) => l10n.passwordModeConflictRequired,
);

final AppFeedback passwordModeConflictUnexpectedFeedback =
    AppFeedback.localized(
      tone: FeedbackTone.warning,
      message: (l10n) => l10n.passwordModeConflictUnexpected,
    );

final AppFeedback passwordUnconfirmedFeedback = AppFeedback.localized(
  tone: FeedbackTone.uncertain,
  message: (l10n) => l10n.passwordUnconfirmed,
);

final AppFeedback passwordAuthRequiredFeedback = AppFeedback.localized(
  tone: FeedbackTone.danger,
  message: (l10n) => l10n.passwordAuthRequired,
);

AppFeedback passwordSucceededFeedback(bool change) => AppFeedback.localized(
  tone: FeedbackTone.success,
  message: (l10n) => change ? l10n.passwordChanged : l10n.passwordCreated,
);

FeedbackMessage displayNameRateLimitedMessage(Duration? retryAfter) =>
    (l10n) => retryAfter == null
    ? l10n.displayNameRateLimitedNoWait
    : l10n.displayNameRateLimitedWithWait(
        l10n.retryAfterSeconds(retryAfter.inSeconds),
      );

FeedbackMessage displayNameUnavailableMessage() =>
    (l10n) => l10n.displayNameUnavailable;

FeedbackMessage displayNameRefreshUncertainMessage() =>
    (l10n) => l10n.displayNameRefreshUncertain;

FeedbackMessage displayNameCredentialStorageMessage() =>
    (l10n) => l10n.displayNameCredentialStorage;

FeedbackMessage displayNameChangeFailedMessage() =>
    (l10n) => l10n.displayNameChangeFailed;

FeedbackMessage passwordRateLimitedMessage(Duration? retryAfter) =>
    (l10n) => retryAfter == null
    ? l10n.passwordRateLimitedNoWait
    : l10n.passwordRateLimitedWithWait(
        l10n.retryAfterSeconds(retryAfter.inSeconds),
      );

FeedbackMessage passwordUnavailableMessage() =>
    (l10n) => l10n.passwordUnavailable;

FeedbackMessage passwordRefreshUncertainMessage(bool change) =>
    (l10n) => change
    ? l10n.passwordRefreshUncertainChanged
    : l10n.passwordRefreshUncertainSet;

FeedbackMessage passwordCredentialStorageMessage(bool change) =>
    (l10n) => change
    ? l10n.passwordCredentialStorageChanged
    : l10n.passwordCredentialStorageSet;

FeedbackMessage passwordSetFailedMessage() =>
    (l10n) => l10n.passwordSetFailed;
