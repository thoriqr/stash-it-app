// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsBackToInbox => 'Back to Inbox';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsLanguage => 'LANGUAGE';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsContact => 'Contact';

  @override
  String get settingsCloseAction => 'Close';

  @override
  String get settingsGithub => 'GitHub';

  @override
  String get settingsInstagram => 'Instagram';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navCollections => 'Collections';

  @override
  String get navSearch => 'Search';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get clearTooltip => 'Clear';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get dismissAction => 'Dismiss';

  @override
  String get sessionEnded =>
      'Your session has ended. Sign in again to continue.';

  @override
  String get genericReadRateLimited => 'Too many attempts. Try again shortly.';

  @override
  String get genericReadServerFault =>
      'We could not reach the server. Try again shortly.';

  @override
  String get genericReadUnreadable =>
      'We couldn\'t read the server\'s reply. Try again.';

  @override
  String get retryAfterSecond => 'a second';

  @override
  String retryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String retryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String retryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get themePreferenceNotSaved =>
      'Theme changed, but the preference could not be saved.';

  @override
  String get languagePreferenceNotSaved =>
      'Language changed, but the preference could not be saved.';

  @override
  String get savedTimeJustNow => 'Saved just now';

  @override
  String savedTimeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count min ago',
      one: 'Saved 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String savedTimeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count hours ago',
      one: 'Saved 1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get savedTimeYesterday => 'Saved yesterday';

  @override
  String savedTimeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count days ago',
      one: 'Saved 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get profileIdentityEmailPassword => 'Email & password';

  @override
  String get profileIdentityUnknown => 'Unknown';

  @override
  String get pendingUrlsExpired =>
      'Some links saved on this device expired after seven days.';

  @override
  String pendingSummaryLocalList(int saved) {
    String _temp0 = intl.Intl.pluralLogic(
      saved,
      locale: localeName,
      other: '$saved links',
      one: '1 link',
    );
    return 'Saved $_temp0, but this device couldn\'t update the list. Check the list before trying again.';
  }

  @override
  String get pendingSummaryUncertainSingle =>
      'We couldn\'t confirm the save. The link is still on this device. Check your Inbox before trying again.';

  @override
  String pendingSummaryUncertainNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'We couldn\'t confirm saving these links.$_temp0 Check your Inbox before trying again.';
  }

  @override
  String pendingSummaryUncertainPartial(
    int saved,
    int total,
    int uncertain,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      uncertain,
      locale: localeName,
      other: '$uncertain links',
      one: '1 link',
    );
    String _temp1 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'Saved $saved of $total links. We couldn\'t confirm $_temp0.$_temp1 Check your Inbox before trying again.';
  }

  @override
  String pendingSummaryRateLimitedSingleNoneSavedNoWait(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'The link wasn\'t saved. You\'re saving too quickly. Try again shortly.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedSingleNoneSavedWithWait(
    String wait,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'The link wasn\'t saved. You\'re saving too quickly. Try again in $wait.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedNoneSavedNoWait(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'No links were saved. You\'re saving too quickly. Try again shortly.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedNoneSavedWithWait(
    String wait,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'No links were saved. You\'re saving too quickly. Try again in $wait.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedPartialNoWait(
    int saved,
    int total,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'Saved $saved of $total links. You\'re saving too quickly. Try again shortly.$_temp0';
  }

  @override
  String pendingSummaryRateLimitedPartialWithWait(
    int saved,
    int total,
    String wait,
    int remaining,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'Saved $saved of $total links. You\'re saving too quickly. Try again in $wait.$_temp0';
  }

  @override
  String pendingSummaryAuthSingleNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'The link wasn\'t saved. Sign in again to save the rest.$_temp0';
  }

  @override
  String pendingSummaryAuthNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'No links were saved. Sign in again to save the rest.$_temp0';
  }

  @override
  String pendingSummaryAuthPartial(int saved, int total, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'Saved $saved of $total links. Sign in again to save the rest.$_temp0';
  }

  @override
  String pendingSummaryRetrySingleNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'The link wasn\'t saved. Try again.$_temp0';
  }

  @override
  String pendingSummaryRetryNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'No links were saved. Try again.$_temp0';
  }

  @override
  String pendingSummaryRetryPartial(int saved, int total, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'Saved $saved of $total links. Try again.$_temp0';
  }

  @override
  String get pendingSummaryAllSavedSingle => 'Saved the link to your account.';

  @override
  String pendingSummaryAllSaved(int total) {
    return 'Saved all $total links to your account.';
  }

  @override
  String pendingSummaryNoneSaved(int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'No links were saved.$_temp0';
  }

  @override
  String pendingSummaryPartial(int saved, int total, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: ' $remaining links are still on this device.',
      one: ' 1 link is still on this device.',
      zero: '',
    );
    return 'Saved $saved of $total links.$_temp0';
  }

  @override
  String get saved => 'Saved.';

  @override
  String get invalidUrlFull =>
      'That doesn\'t look like a valid link. Enter a full http:// or https:// address.';

  @override
  String get saveValidation =>
      'That doesn\'t look like a valid link. Check the URL and try again.';

  @override
  String get saveMalformed =>
      'Something went wrong sending that link. Try again.';

  @override
  String get saveRateLimitedNoWait =>
      'You\'re saving too quickly. Try again shortly.';

  @override
  String saveRateLimitedWithWait(String wait) {
    return 'You\'re saving too quickly. Try again in $wait.';
  }

  @override
  String get saveServerUnavailable =>
      'We couldn\'t save this link just now. Try again shortly.';

  @override
  String get saveUnreadable =>
      'We couldn\'t read the server\'s reply, so we can\'t confirm the save. Check your Inbox before trying again.';

  @override
  String get saveTransport =>
      'We couldn\'t confirm this save. It may or may not have gone through — check your Inbox before trying again.';

  @override
  String get saveRefreshUncertain =>
      'We couldn\'t renew your session, so that link wasn\'t saved. Try again.';

  @override
  String get saveCredentialStorage =>
      'This device couldn\'t refresh your session, so that link wasn\'t saved. Try again.';

  @override
  String get saveAuthRequired => 'Sign in again to save this link.';

  @override
  String get pageReRead => 'Page re-read.';

  @override
  String get pageReReadNoDetails => 'Page re-read. This page shows no details.';

  @override
  String get pageReadFailed => 'Couldn\'t read this page.';

  @override
  String get enrichUnconfirmed =>
      'We couldn\'t confirm the re-read. Try again.';

  @override
  String get enrichRateLimitedNoWait =>
      'You\'ve re-read too many pages. Try again shortly.';

  @override
  String enrichRateLimitedWithWait(String wait) {
    return 'You\'ve re-read too many pages. Try again in $wait.';
  }

  @override
  String get enrichUnavailable =>
      'Re-reading is temporarily unavailable. Try again shortly.';

  @override
  String get itemUnavailable => 'This item is no longer available.';

  @override
  String get enrichAuthRequired => 'Sign in again to re-read this page.';

  @override
  String get enrichRefreshUncertain =>
      'We couldn\'t renew your session, so the page wasn\'t re-read. Try again.';

  @override
  String get enrichCredentialStorage =>
      'This device couldn\'t refresh your session, so the page wasn\'t re-read. Try again.';

  @override
  String get enrichFailed => 'We couldn\'t re-read this page. Try again.';

  @override
  String get enrichServerFault =>
      'Something went wrong re-reading this page. Try again.';

  @override
  String get moveServerError =>
      'Something went wrong moving this item. Try again.';

  @override
  String get moveUnconfirmed =>
      'We couldn\'t confirm the move. Check the item\'s collection.';

  @override
  String get moveAuthRequired => 'Sign in again to move this item.';

  @override
  String get moveRefreshUncertain =>
      'We couldn\'t renew your session, so the item wasn\'t moved. Try again.';

  @override
  String get moveCredentialStorage =>
      'This device couldn\'t refresh your session, so the item wasn\'t moved. Try again.';

  @override
  String get moveMalformed =>
      'Something went wrong sending that name. Try again.';

  @override
  String get moveRateLimitedNoWait =>
      'You\'re moving too quickly. Try again shortly.';

  @override
  String moveRateLimitedWithWait(String wait) {
    return 'You\'re moving too quickly. Try again in $wait.';
  }

  @override
  String alreadyInCollection(String name) {
    return 'Already in $name.';
  }

  @override
  String createdCollectionAndMoved(String name) {
    return 'Created $name and moved the item.';
  }

  @override
  String movedToCollection(String name) {
    return 'Moved to $name.';
  }

  @override
  String get itemDeleted => 'Item deleted.';

  @override
  String itemDeletedAndCollectionDeleted(String name) {
    return 'Item deleted, and $name was deleted.';
  }

  @override
  String get deleteItemUnconfirmed =>
      'We couldn\'t confirm whether the item was deleted. Check the Inbox before trying again.';

  @override
  String get deleteItemAuthRequired => 'Sign in again to delete this item.';

  @override
  String get deleteItemRefreshUncertain =>
      'We couldn\'t renew your session, so the item wasn\'t deleted. Try again.';

  @override
  String get deleteItemCredentialStorage =>
      'This device couldn\'t refresh your session, so the item wasn\'t deleted. Try again.';

  @override
  String get itemNotDeleted => 'The item wasn\'t deleted. Try again.';

  @override
  String get deleteItemRateLimited =>
      'You\'re going too quickly. The item wasn\'t deleted. Try again shortly.';

  @override
  String collectionUnavailableAfterItemDeleted(String name) {
    return 'Item deleted. $name is no longer available.';
  }

  @override
  String collectionNotEmptyAfterItemDeleted(String name) {
    return 'Item deleted. $name now has items, so it was not deleted.';
  }

  @override
  String collectionProtectedAfterItemDeleted(String name) {
    return 'Item deleted. $name cannot be deleted.';
  }

  @override
  String collectionDeleteUnconfirmedAfterItemDeleted(String name) {
    return 'Item deleted, but we couldn\'t confirm whether $name was deleted. Check Collections.';
  }

  @override
  String collectionDeleteAuthRequiredAfterItemDeleted(String name) {
    return 'Item deleted. Sign in again to delete $name.';
  }

  @override
  String collectionDeleteSessionEndedAfterItemDeleted(String name) {
    return 'Item deleted. Your session ended before $name could be deleted.';
  }

  @override
  String collectionDeleteRefreshUncertainAfterItemDeleted(String name) {
    return 'Item deleted. We couldn\'t renew your session, so $name was not deleted. Try again.';
  }

  @override
  String collectionDeleteCredentialStorageAfterItemDeleted(String name) {
    return 'Item deleted. This device couldn\'t refresh your session, so $name was not deleted. Try again.';
  }

  @override
  String collectionDeleteRateLimitedAfterItemDeleted(String name) {
    return 'Item deleted. You\'re going too quickly, so $name was not deleted. Try again shortly.';
  }

  @override
  String collectionDeleteFailedAfterItemDeleted(String name) {
    return 'Item deleted, but $name could not be deleted. Try again from Collections.';
  }

  @override
  String collectionDeleted(String name) {
    return '$name was deleted.';
  }

  @override
  String collectionDeletedItemsMoved(String name, String target) {
    return '$name was deleted, and its items were moved to $target.';
  }

  @override
  String get collectionDeleteFailed =>
      'The collection wasn\'t deleted. Try again.';

  @override
  String collectionDeleteTargetUnavailable(String name) {
    return '$name is no longer available. Nothing was changed. Choose another destination.';
  }

  @override
  String collectionUnavailable(String name) {
    return '$name is no longer available.';
  }

  @override
  String collectionNotEmpty(String name) {
    return '$name now has items, so nothing was changed. Its current contents are being refreshed.';
  }

  @override
  String collectionProtected(String name) {
    return '$name cannot be deleted.';
  }

  @override
  String collectionDeleteUnconfirmed(String name) {
    return 'We couldn\'t confirm whether $name was deleted. Check Collections before trying again.';
  }

  @override
  String get collectionDeleteAuthRequired =>
      'Sign in again to delete this collection.';

  @override
  String collectionDeleteRefreshUncertain(String name) {
    return 'We couldn\'t renew your session, so $name wasn\'t deleted. Try again.';
  }

  @override
  String collectionDeleteCredentialStorage(String name) {
    return 'This device couldn\'t refresh your session, so $name wasn\'t deleted. Try again.';
  }

  @override
  String get collectionDeleteRateLimitedNoWait =>
      'You\'re going too quickly. The collection wasn\'t deleted. Try again shortly.';

  @override
  String collectionDeleteRateLimitedWithWait(String wait) {
    return 'You\'re going too quickly. The collection wasn\'t deleted. Try again in $wait.';
  }

  @override
  String get linkCannotOpen => 'This link can\'t be opened.';

  @override
  String get linkLaunchFailed => 'We couldn\'t open this link. Try again.';

  @override
  String get urlCopied => 'URL copied';

  @override
  String get urlCopyFailed => 'Couldn\'t copy the URL. Try again.';

  @override
  String get refreshFailed => 'Couldn\'t refresh. Check your connection.';

  @override
  String get displayNameUpdated => 'Display name updated.';

  @override
  String get displayNameRateLimitedNoWait =>
      'Too many attempts. Try again shortly.';

  @override
  String displayNameRateLimitedWithWait(String wait) {
    return 'Too many attempts. Try again in $wait.';
  }

  @override
  String get displayNameUnavailable =>
      'Display name changes are temporarily unavailable. Try again shortly.';

  @override
  String get displayNameUnconfirmed =>
      'We couldn\'t confirm whether your display name was updated. Check your profile before trying again.';

  @override
  String get accountUnavailable => 'This account is no longer available.';

  @override
  String get displayNameAuthRequired =>
      'Sign in again to change your display name.';

  @override
  String get displayNameRefreshUncertain =>
      'We couldn\'t renew your session, so your display name wasn\'t changed. Try again.';

  @override
  String get displayNameCredentialStorage =>
      'This device couldn\'t refresh your session, so your display name wasn\'t changed. Try again.';

  @override
  String get displayNameChangeFailed =>
      'We couldn\'t change your display name. Try again.';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get passwordCreated => 'Password created.';

  @override
  String get passwordModeConflictExists =>
      'A password was already created for this account. Open this screen again to change it.';

  @override
  String get passwordModeConflictRequired =>
      'Your account already has a password. Open this screen again to change it.';

  @override
  String get passwordModeConflictUnexpected =>
      'Your account has no password yet. Open this screen again to create one.';

  @override
  String get passwordRateLimitedNoWait =>
      'We can\'t set a password right now. Try again shortly.';

  @override
  String passwordRateLimitedWithWait(String wait) {
    return 'We can\'t set a password right now. Try again in $wait.';
  }

  @override
  String get passwordUnavailable =>
      'We can\'t set a password right now. Try again shortly.';

  @override
  String get passwordUnconfirmed =>
      'We couldn\'t confirm whether your password was set. Open this screen again before trying again.';

  @override
  String get passwordAuthRequired => 'Sign in again to set your password.';

  @override
  String get passwordRefreshUncertainChanged =>
      'We couldn\'t renew your session, so your password wasn\'t changed. Try again.';

  @override
  String get passwordRefreshUncertainSet =>
      'We couldn\'t renew your session, so your password wasn\'t set. Try again.';

  @override
  String get passwordCredentialStorageChanged =>
      'This device couldn\'t refresh your session, so your password wasn\'t changed. Try again.';

  @override
  String get passwordCredentialStorageSet =>
      'This device couldn\'t refresh your session, so your password wasn\'t set. Try again.';

  @override
  String get passwordSetFailed => 'We couldn\'t set your password. Try again.';

  @override
  String get newPinSent => 'A new PIN has been sent.';

  @override
  String get pinVerifiedProgressNotSaved =>
      'PIN verified, but this device could not save your progress. Finish before closing the app.';

  @override
  String get shareSaved => 'Saved to your account.';

  @override
  String get shareStoredAfterFailure =>
      'Couldn\'t save it. Kept on this device.';

  @override
  String get shareStoredAfterUncertain =>
      'Save not confirmed. Kept on this device.';

  @override
  String get shareInvalid => 'That\'s not a link, so nothing was saved.';

  @override
  String get shareNotStored => 'Couldn\'t save or keep this link.';

  @override
  String get inboxTitle => 'INBOX';

  @override
  String get inboxRecentlySaved => 'RECENTLY SAVED';

  @override
  String get inboxLoadingMore => 'Loading more…';

  @override
  String get inboxEmptyTitle => 'Nothing saved yet';

  @override
  String get inboxEmptyBody =>
      'Save a link and it will appear here, in the collection it belongs to.';

  @override
  String get inboxRetry => 'Retry';

  @override
  String get inboxSessionEnded =>
      'Your session has ended. Sign in again to see your saved items.';

  @override
  String get inboxSignInRequired => 'Sign in again to see your saved items.';

  @override
  String get inboxUnavailable =>
      'Your saved items are temporarily unavailable. Try again shortly.';

  @override
  String get inboxLoadTransport =>
      'No connection to the server. We could not load your saved items.';

  @override
  String get inboxLoadGeneric =>
      'We could not load your saved items. Try again.';

  @override
  String get inboxSaveUrlSection => 'SAVE A URL';

  @override
  String get inboxSaving => 'Saving…';

  @override
  String get inboxIntakeReady => 'Check or edit the link before saving.';

  @override
  String get inboxIntakeHint => 'Paste fills the field. Save URL sends it.';

  @override
  String get inboxPaste => 'Paste';

  @override
  String get inboxSaveAction => 'Save URL';

  @override
  String get inboxYourNote => 'Your note';

  @override
  String get inboxNoteDoneAction => 'Done';

  @override
  String get inboxSaveWithNoteTitle => 'Save URL with this note?';

  @override
  String get inboxSaveWithNoteAction => 'Save with note';

  @override
  String get inboxSaveWithoutNoteAction => 'Save without note';

  @override
  String get pendingUrlsTitle => 'SAVED ON THIS DEVICE';

  @override
  String get pendingUrlsBackToInbox => 'Back to Inbox';

  @override
  String get pendingUrlsBackToSignIn => 'Back to sign in';

  @override
  String get pendingUrlsLoading => 'Loading links…';

  @override
  String get pendingUrlsSignedInIntro =>
      'Links you shared are kept here for seven days when a save didn\'t finish. They are stored on this device until you save them to your account.';

  @override
  String get pendingUrlsSignedOutIntro =>
      'Links you shared are kept here for seven days when a save didn\'t finish. They are stored on this device, not in your account.';

  @override
  String get pendingUrlsSaveAllAction => 'Save all to my account';

  @override
  String get pendingUrlsSignInAction => 'Sign in to save these links';

  @override
  String get pendingUrlsSaving => 'Saving…';

  @override
  String pendingUrlsSavingProgress(int current, int total) {
    return 'Saving $current of $total…';
  }

  @override
  String get pendingUrlsSaveNotConfirmed => 'Save not confirmed';

  @override
  String get pendingUrlsEmptyTitle => 'Nothing saved on this device';

  @override
  String get pendingUrlsEmptyBody =>
      'Links that didn\'t finish saving will appear here for seven days.';

  @override
  String get pendingUrlsReadError =>
      'We couldn\'t read the links saved on this device.';

  @override
  String get pendingUrlsRetry => 'Retry';

  @override
  String get pendingUrlsKeptJustNow => 'Kept just now';

  @override
  String pendingUrlsKeptMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kept $count min ago',
      one: 'Kept 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String pendingUrlsKeptHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kept $count hours ago',
      one: 'Kept 1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get pendingUrlsKeptYesterday => 'Kept yesterday';

  @override
  String pendingUrlsKeptDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kept $count days ago',
      one: 'Kept 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get pendingUrlsEntryTitle => 'Saved on this device';

  @override
  String get pendingUrlsEntryActiveBody =>
      'Kept on this device. Open to review them.';

  @override
  String get pendingUrlsEntryEmptyBody =>
      'Links that couldn\'t be saved will appear here.';

  @override
  String pendingUrlsEntrySemanticsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count links',
      one: '1 link',
    );
    return 'Saved on this device, $_temp0';
  }

  @override
  String get pendingUrlsEntrySemanticsOverflow =>
      'Saved on this device, more than 99 links';

  @override
  String get savedItemDetailTitle => 'ITEM';

  @override
  String get savedItemCollectionDetailTitle => 'COLLECTION';

  @override
  String get savedItemBackToInbox => 'Back to Inbox';

  @override
  String get savedItemActionsSection => 'ACTIONS';

  @override
  String get savedItemMoveAction => 'Move to a collection';

  @override
  String get savedItemOpenAction => 'Open the original page';

  @override
  String get savedItemCopyUrl => 'Copy URL';

  @override
  String get savedItemShareUrl => 'Share URL';

  @override
  String get savedItemPriceMayHaveChanged => 'Price may have changed.';

  @override
  String get savedItemAddNote => 'Add a personal note';

  @override
  String get savedItemNoteSaveAction => 'Save';

  @override
  String get savedItemNotePlaceholder => 'Write your note…';

  @override
  String savedItemNoteCharacterCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get savedItemNoteDeleteTitle => 'Delete this note?';

  @override
  String get savedItemNoteDeleteMessage =>
      'This removes your note. The saved item stays.';

  @override
  String get savedItemNoteKeepAction => 'Keep note';

  @override
  String get savedItemNoteDeleteConfirmAction => 'Delete note';

  @override
  String get savedItemNoteSaved => 'Note saved.';

  @override
  String get savedItemNoteDeleted => 'Note deleted.';

  @override
  String get savedItemNoteSaveUnconfirmed =>
      'We couldn\'t confirm whether your note was saved. Check the note before trying again.';

  @override
  String get savedItemNoteDeleteUnconfirmed =>
      'We couldn\'t confirm whether your note was deleted. Check the note before trying again.';

  @override
  String get savedItemNoteAuthRequired => 'Sign in again to change this note.';

  @override
  String get savedItemNoteRefreshUncertain =>
      'We couldn\'t renew your session, so the note wasn\'t changed. Try again.';

  @override
  String get savedItemNoteCredentialStorage =>
      'This device couldn\'t refresh your session, so the note wasn\'t changed. Try again.';

  @override
  String get savedItemNoteRateLimitedNoWait =>
      'You\'re changing notes too quickly. Try again shortly.';

  @override
  String savedItemNoteRateLimitedWithWait(String wait) {
    return 'You\'re changing notes too quickly. Try again in $wait.';
  }

  @override
  String get savedItemNoteUnavailable =>
      'Note changes are temporarily unavailable. Try again shortly.';

  @override
  String get savedItemNoteInvalid =>
      'That note can\'t be saved. Check the text and try again.';

  @override
  String get savedItemNoteSaveFailed =>
      'We couldn\'t save your note. Try again.';

  @override
  String get savedItemNoteDeleteFailed =>
      'We couldn\'t delete your note. Try again.';

  @override
  String get savedItemDeleteAction => 'Delete this item';

  @override
  String get savedItemEnrichmentSection => 'ENRICHMENT';

  @override
  String get savedItemReReadAction => 'Re-read page';

  @override
  String get savedItemReadingPage => 'Reading the page…';

  @override
  String get savedItemDeleteDialogTitle => 'Delete this item?';

  @override
  String get savedItemDeleteDialogMessage =>
      'This removes the saved item. It cannot be undone.';

  @override
  String get savedItemKeepAction => 'Keep';

  @override
  String get savedItemDeleteConfirmAction => 'Delete';

  @override
  String savedItemCollectionEmptyTitle(String name) {
    return '$name is now empty';
  }

  @override
  String savedItemCollectionEmptyMessage(String name) {
    return 'This was the last item in $name. You can keep this empty collection or delete it.';
  }

  @override
  String get savedItemKeepCollectionAction => 'Keep it';

  @override
  String get savedItemDeleteCollectionAction => 'Delete collection';

  @override
  String get savedItemCancelAction => 'Cancel';

  @override
  String get savedItemKeepCollectionDismissAction => 'Keep collection';

  @override
  String get savedItemCloseAction => 'Close';

  @override
  String get savedItemNotFoundTitle => 'This item is no longer available';

  @override
  String get savedItemNotFoundBody =>
      'It may have been deleted, or it may belong to another account.';

  @override
  String get savedItemLoadErrorTitle => 'We could not load this item';

  @override
  String get savedItemRetry => 'Retry';

  @override
  String get savedItemSessionEnded =>
      'Your session has ended. Sign in again to see this item.';

  @override
  String get savedItemSignInRequired => 'Sign in again to see this item.';

  @override
  String get savedItemUnavailable =>
      'This item is temporarily unavailable. Try again shortly.';

  @override
  String get savedItemLoadTransport =>
      'No connection to the server. We couldn\'t load this item.';

  @override
  String get savedItemLoadGeneric => 'We couldn\'t load this item. Try again.';

  @override
  String get savedItemEnrichmentReading => 'Reading page…';

  @override
  String get savedItemEnrichmentNoDetails => 'No details on this page';

  @override
  String get savedItemEnrichmentFailed => 'Couldn\'t read this page';

  @override
  String get savedItemBackToCollections => 'Back to Collections';

  @override
  String get savedItemCollectionActionsTooltip => 'Collection actions';

  @override
  String get savedItemLoadingMore => 'Loading more…';

  @override
  String get savedItemLoadMoreFailed => 'Couldn\'t load more items.';

  @override
  String get savedItemEmptyCollectionTitle => 'Nothing saved here yet';

  @override
  String get savedItemEmptyCollectionBody =>
      'Items saved to this collection will appear here.';

  @override
  String get savedItemCollectionUnavailableTitle =>
      'This collection is no longer available';

  @override
  String get savedItemCollectionUnavailableBody =>
      'It may have been deleted, or it may belong to another account.';

  @override
  String get savedItemCollectionLoadErrorTitle =>
      'We could not load this collection';

  @override
  String get savedItemCollectionSessionEnded =>
      'Your session has ended. Sign in again to see this collection.';

  @override
  String get savedItemCollectionSignInRequired =>
      'Sign in again to see this collection.';

  @override
  String get savedItemCollectionUnavailable =>
      'This collection is temporarily unavailable. Try again shortly.';

  @override
  String get savedItemCollectionLoadTransport =>
      'No connection to the server. We could not load this collection.';

  @override
  String get savedItemCollectionLoadGeneric =>
      'We could not load this collection. Try again.';

  @override
  String get savedItemEmptyCollectionDeleteTitle => 'Delete this collection?';

  @override
  String savedItemDeleteCollectionNamedTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get savedItemEmptyCollectionDeleteMessage =>
      'This collection is empty. There are no items to keep or discard. This cannot be undone.';

  @override
  String savedItemCurrentlyIn(String name) {
    return 'Currently in $name';
  }

  @override
  String get savedItemYourCollections => 'YOUR COLLECTIONS';

  @override
  String get savedItemBrowseAllCollections => 'Browse all collections';

  @override
  String get savedItemNewCollection => 'New collection';

  @override
  String get savedItemNewCollectionPlaceholder => 'e.g. Reading list';

  @override
  String get savedItemLoadingCollections => 'Loading collections…';

  @override
  String get savedItemLoadCollectionsFailed =>
      'We couldn\'t load your collections.';

  @override
  String get savedItemBrowseAllHint =>
      'Browse all collections to find a destination.';

  @override
  String get savedItemNoOtherCollectionsCreate =>
      'No other collections yet. Create one below.';

  @override
  String savedItemAlreadyIn(String name) {
    return 'Already in $name';
  }

  @override
  String savedItemMoveTo(String name) {
    return 'Move to $name';
  }

  @override
  String savedItemCreate(String name) {
    return 'Create $name';
  }

  @override
  String get savedItemMoveHelperError =>
      'You can still create a collection by name, or browse all collections.';

  @override
  String get savedItemMoveHelper =>
      'Choose an existing collection, or enter a name to create a new one.';

  @override
  String get savedItemCollectionNameTaken =>
      'That collection name is already taken. Choose a different name.';

  @override
  String get savedItemCollectionNameRequired => 'Enter a collection name.';

  @override
  String get savedItemCollectionNameTooLong => 'Use 100 characters or fewer.';

  @override
  String get savedItemCollectionNameRange =>
      'Enter a collection name between 1 and 100 characters.';

  @override
  String get savedItemAllCollections => 'All collections';

  @override
  String get savedItemPickerDescription =>
      'Choose a collection to move this item into.';

  @override
  String get savedItemNoOtherCollections => 'No other collections yet.';

  @override
  String get savedItemLoadMoreCollectionsFailed =>
      'We couldn\'t load more collections.';

  @override
  String get savedItemThisCollection => 'This collection';

  @override
  String get savedItemTheCollection => 'the collection';

  @override
  String get savedItemDeleteCollectionCannotUndo =>
      'Deleting the collection cannot be undone, and items you choose to delete cannot be recovered.';

  @override
  String get savedItemMoveItemsAction => 'Move items to another collection';

  @override
  String get savedItemDeleteItemsAction => 'Delete collection and items';

  @override
  String get savedItemCollectionHasItemsUnknown =>
      'This collection has saved items. Choose what happens to them.';

  @override
  String savedItemCollectionHasItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved items. Choose what happens to them.',
      one: '1 saved item. Choose what happens to it.',
    );
    return 'This collection has $_temp0';
  }

  @override
  String savedItemBulkMoveThisItem(String name) {
    return 'Choose where this item should go. $name will be deleted.';
  }

  @override
  String savedItemBulkMoveTheseItems(String name) {
    return 'Choose where these items should go. $name will be deleted.';
  }

  @override
  String get collectionsTitle => 'COLLECTIONS';

  @override
  String get collectionsSortNewest => 'Newest';

  @override
  String get collectionsSortOldest => 'Oldest';

  @override
  String get collectionsSortName => 'Name';

  @override
  String get collectionsEmptyTitle => 'No collections yet';

  @override
  String get collectionsEmptyBody =>
      'Collections appear when you save links or organize them.';

  @override
  String get collectionsRetry => 'Retry';

  @override
  String get collectionsSessionEnded =>
      'Your session has ended. Sign in again to see your collections.';

  @override
  String get collectionsSignInRequired =>
      'Sign in again to see your collections.';

  @override
  String get collectionsUnavailable =>
      'Your collections are temporarily unavailable. Try again shortly.';

  @override
  String get collectionsLoadTransport =>
      'No connection to the server. We could not load your collections.';

  @override
  String get collectionsLoadGeneric =>
      'We could not load your collections. Try again.';

  @override
  String get collectionsSystemBadge => 'system';

  @override
  String collectionsSavedItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved items',
      one: '1 saved item',
    );
    return '$_temp0';
  }

  @override
  String get collectionsSavedItemsCountOverflow => 'More than 99 saved items';

  @override
  String get searchTitle => 'SEARCH';

  @override
  String get searchPlaceholder => 'Search saved items and collections';

  @override
  String get searchInitialTitle => 'Find something you saved';

  @override
  String get searchInitialBody =>
      'Search matches item titles, domains, URLs and collection names.';

  @override
  String searchNoMatchesTitle(String query) {
    return 'No matches for ‘$query’';
  }

  @override
  String get searchNoMatchesBody =>
      'An item may still match by title, domain, URL or collection name. Try a different word, or browse Collections.';

  @override
  String get searchQueryRequired => 'Enter something to search for.';

  @override
  String searchQueryTooShort(int min) {
    return 'Search needs at least $min characters.';
  }

  @override
  String searchQueryTooLong(int max) {
    return 'Search is limited to $max characters. Shorten it and try again.';
  }

  @override
  String get searchSearchingSemantics => 'Searching';

  @override
  String get searchFailureTitle => 'Search did not run';

  @override
  String searchValidationFailure(int min, int max) {
    return 'Search needs between $min and $max characters. Check your search and try again.';
  }

  @override
  String get searchSessionEnded =>
      'Your session has ended. Sign in again to search.';

  @override
  String get searchSignInRequired => 'Sign in again to search.';

  @override
  String get searchRateLimitedNoWait => 'Too many searches. Try again shortly.';

  @override
  String searchRateLimitedWithWait(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Too many searches. Try again in $seconds seconds.',
      one: 'Too many searches. Try again in 1 second.',
    );
    return '$_temp0';
  }

  @override
  String get searchUnavailable =>
      'Search is temporarily unavailable. Try again shortly.';

  @override
  String get searchTransport =>
      'No connection to the server. We could not run your search.';

  @override
  String get searchFailureGeneric => 'We could not run your search. Try again.';

  @override
  String get searchRetry => 'Retry';

  @override
  String get searchCollectionsHeading => 'COLLECTIONS';

  @override
  String get searchSavedItemsHeading => 'SAVED ITEMS';

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileLoading => 'Loading profile…';

  @override
  String get profileRetry => 'Retry';

  @override
  String get profileSessionEnded => 'Your session has ended. Sign in again.';

  @override
  String get profileSignInRequired => 'Sign in again to view your profile.';

  @override
  String get profileUnavailable =>
      'Profile is temporarily unavailable. Try again shortly.';

  @override
  String get profileTransport =>
      'No connection. We could not load your profile.';

  @override
  String get profileLoadGeneric => 'We could not load your profile. Try again.';

  @override
  String get profileAccountSection => 'ACCOUNT';

  @override
  String get profileLinkedIdentitiesSection => 'LINKED IDENTITIES';

  @override
  String get profileDisplayNameLabel => 'Display name';

  @override
  String get profileChangePasswordAction => 'Change password';

  @override
  String get profileCreatePasswordAction => 'Create password';

  @override
  String get profileNoAccountsConnected => 'No accounts connected yet.';

  @override
  String profileJoinedDate(String date) {
    return 'joined $date';
  }

  @override
  String profileLinkedDate(String date) {
    return 'linked $date';
  }

  @override
  String get profilePasswordTitle => 'PASSWORD';

  @override
  String get profileChangePasswordTitle => 'CHANGE PASSWORD';

  @override
  String get profileCreatePasswordTitle => 'CREATE PASSWORD';

  @override
  String get profileBackToProfile => 'Back to Profile';

  @override
  String get profileChangePasswordDescription =>
      'Choose a new password for your account.';

  @override
  String get profileCreatePasswordDescription =>
      'Add a password so you can sign in with your email address.';

  @override
  String get profileCurrentPasswordLabel => 'Current password';

  @override
  String get profileNewPasswordLabel => 'New password';

  @override
  String get profileConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get profileShowCurrentPassword => 'Show current password';

  @override
  String get profileHideCurrentPassword => 'Hide current password';

  @override
  String get profileShowNewPassword => 'Show new password';

  @override
  String get profileHideNewPassword => 'Hide new password';

  @override
  String get profileShowConfirmationPassword => 'Show confirmation password';

  @override
  String get profileHideConfirmationPassword => 'Hide confirmation password';

  @override
  String get profileCurrentPasswordRequired => 'Enter your current password.';

  @override
  String get profilePasswordLength => 'Use between 8 and 128 characters.';

  @override
  String get profilePasswordsDoNotMatch => 'The passwords do not match.';

  @override
  String get profileCurrentPasswordIncorrect =>
      'That current password is incorrect.';

  @override
  String get profilePasswordChangedElsewhere =>
      'Your password was changed somewhere else. Enter the current password again.';

  @override
  String get profileEditDisplayNameTitle => 'Edit display name';

  @override
  String get profileDisplayNameValidation =>
      'Use between 2 and 100 characters.';

  @override
  String get profileCancelAction => 'Cancel';

  @override
  String get profileSaveAction => 'Save';

  @override
  String get authBackToWelcome => 'Back to welcome';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPinLabel => 'PIN';

  @override
  String get authDisplayNameLabel => 'Display name';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInTitle => 'Sign in to your account';

  @override
  String get authSignInDescription =>
      'Enter your email and password to continue.';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get authCreateAnAccount => 'Create an account';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSignUpTitle => 'Create your account';

  @override
  String get authSignUpDescription =>
      'Enter your email address. We will send you a PIN to confirm it.';

  @override
  String get authSendPin => 'Send PIN';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authRetry => 'Retry';

  @override
  String get authTryAgain => 'Try again';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authStartOver => 'Start over';

  @override
  String get authStartNewRegistration => 'Start a new registration';

  @override
  String get authStartNewReset => 'Start a new reset';

  @override
  String get authUseDifferentEmail => 'Use a different email';

  @override
  String get authContinue => 'Continue';

  @override
  String get authCancel => 'Cancel';

  @override
  String get authLinkAccount => 'Link account';

  @override
  String get authVerifyPin => 'Verify PIN';

  @override
  String get authResendPin => 'Resend PIN';

  @override
  String authResendPinIn(int seconds) {
    return 'Resend PIN in $seconds s';
  }

  @override
  String get authSending => 'Sending…';

  @override
  String get authSendResetPin => 'Send reset PIN';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authBackToPasswordReset => 'Back to password reset';

  @override
  String get authReplaceSavedResetTitle => 'Replace saved password reset?';

  @override
  String get authKeepSavedReset => 'Keep saved reset';

  @override
  String get authReplaceAndVerify => 'Replace and verify';

  @override
  String get authRecoverRegistration => 'Recover this registration';

  @override
  String get authEntryHeadline =>
      'A place for things you find on the internet.';

  @override
  String get authEntryDescription =>
      'Save a link from any browser, then find it again here.';

  @override
  String get authCheckYourEmail => 'Check your email';

  @override
  String get authEnterYourPin => 'Enter your PIN';

  @override
  String get authCompleteYourAccount => 'Complete your account';

  @override
  String get authRegistrationUnavailable => 'Registration unavailable';

  @override
  String get authResetUnavailable => 'Reset unavailable';

  @override
  String get authResetPasswordTitle => 'Reset your password';

  @override
  String get authChooseNewPassword => 'Choose a new password';

  @override
  String get authLinkYourGoogleAccount => 'Link your Google account';

  @override
  String get authEnterEmail => 'Enter your email address.';

  @override
  String get authInvalidEmail => 'Enter a valid email address.';

  @override
  String get authEmailTooLong => 'That email address is too long.';

  @override
  String get authEnterPassword => 'Enter your password.';

  @override
  String get authPasswordMin8 => 'Your password is at least 8 characters.';

  @override
  String get authPasswordTooLong => 'That password is too long.';

  @override
  String get authEnterNewPassword => 'Enter a new password.';

  @override
  String get authPasswordRange => 'Use between 8 and 128 characters.';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get authEnterDisplayName => 'Enter a display name.';

  @override
  String get authDisplayNameMin2 => 'Display name is at least 2 characters.';

  @override
  String get authDisplayNameTooLong => 'Display name is too long.';

  @override
  String get authEnterSixDigitPin => 'Enter a 6-digit PIN.';

  @override
  String get authCheckEmailThenTryAgain =>
      'Check your email address, then try again.';

  @override
  String get authCheckDetailsThenTryAgain =>
      'Check your details, then try again.';

  @override
  String get authCheckDisplayNameThenTryAgain =>
      'Check your display name, then try again.';

  @override
  String get authRegistrationSuccessSignIn =>
      'Registration successful. Please sign in with your new account.';

  @override
  String get authRegistrationUncertainSignIn =>
      'We could not confirm whether registration completed. Try signing in; if it fails, start again.';

  @override
  String get authPasswordResetSuccessSignIn =>
      'Your password has been reset. Please sign in with your new password.';

  @override
  String get authPasswordResetUncertainSignIn =>
      'We could not confirm whether the password reset completed. Try signing in with your new password.';

  @override
  String get authSignInGenericFailure =>
      'Something went wrong signing in. Try again.';

  @override
  String get authSignInInvalidCredentials =>
      'That doesn\'t look like a valid email or password.';

  @override
  String get authSignInValidation =>
      'Check your email address and password, then try again.';

  @override
  String get authSignInUnavailable =>
      'Sign in is temporarily unavailable. Try again shortly.';

  @override
  String get authSignInUnconfirmed =>
      'No connection to the server. We could not confirm this sign-in.';

  @override
  String get authSessionUnconfirmed =>
      'We could not confirm your session. Try again.';

  @override
  String get authSignInStorageFailed =>
      'Your sign-in could not be saved securely. Try again.';

  @override
  String authTooManyAttemptsWithWait(int seconds) {
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  @override
  String get authSignUpGenericFailure =>
      'Something went wrong starting your registration. Try again.';

  @override
  String get authRegistrationMismatch =>
      'We could not match that registration to this email. Try again with the same address.';

  @override
  String get authRegistrationAlreadyCompletedSignIn =>
      'This registration was already completed. Sign in instead.';

  @override
  String get authRecoveryCouldNotStart =>
      'Recovery could not be started. Try again.';

  @override
  String get authRecoveryGenericFailure =>
      'Something went wrong starting recovery. Try again.';

  @override
  String get authRegistrationCheckTransport =>
      'No connection to the server. We could not check that registration. Try again.';

  @override
  String get authRegistrationCheckUnreadable =>
      'We could not read the server\'s reply, so we could not check that registration. Try again.';

  @override
  String get authRegistrationCheckUnavailable =>
      'We could not check that registration. Try again shortly.';

  @override
  String get authRegistrationCheckGeneric =>
      'We could not check this registration. Try again.';

  @override
  String get authRecoveryTransport =>
      'No connection to the server. We could not start recovery. Try again.';

  @override
  String get authRecoveryUnreadable =>
      'We could not confirm whether recovery started. Try again.';

  @override
  String get authRecoveryUnavailable =>
      'Recovery is temporarily unavailable. Try again shortly.';

  @override
  String get authRecoveryServerFault =>
      'We could not start recovery. Try again shortly.';

  @override
  String authPinSentToEmail(String email) {
    return 'We sent a PIN to $email. You will need it to finish creating your account.';
  }

  @override
  String get authVerificationComplete => 'Verification already complete';

  @override
  String authVerifiedSavedCodeUnconfirmed(String email) {
    return 'We could not check the code saved on this device for $email. Try again, or recover the registration with a new PIN. Recovering replaces this device\'s saved code.';
  }

  @override
  String authVerifiedNoToken(String email) {
    return 'This email has already been verified, but this device does not have the code needed to finish it. Recover it with a new PIN sent to $email.';
  }

  @override
  String get authRegistrationAlreadyCompleted =>
      'An account already exists for this email. Sign in instead.';

  @override
  String get authRegistrationAlreadyPending =>
      'This registration is already waiting for a PIN. Continue with that step.';

  @override
  String get authRegistrationRetryable =>
      'Another sign-up attempt was already in progress. Try again.';

  @override
  String get authRegistrationIdentityMismatch =>
      'A sign-up for this email is already in progress with a different Google account. Try again after it expires.';

  @override
  String get authRegistrationRestartRequired =>
      'That registration can no longer continue. Start a new one.';

  @override
  String get authPinRecentlySent =>
      'A PIN was sent to this email recently. Try again shortly.';

  @override
  String get authPinEmailUnconfirmed =>
      'We could not confirm the PIN email was sent. Check your inbox before trying again.';

  @override
  String get authPinEmailUnconfirmedShort =>
      'We could not confirm the PIN email was sent. Check your inbox.';

  @override
  String get authRegistrationUnavailableShort =>
      'Registration is temporarily unavailable. Try again shortly.';

  @override
  String get authRegistrationServerFault =>
      'The server could not start your registration. Try again shortly.';

  @override
  String get authRegistrationStartUnconfirmed =>
      'No connection to the server. We could not confirm whether your registration started.';

  @override
  String get authRegistrationStartUnreadable =>
      'We could not read the server\'s reply, so we cannot confirm whether your registration started or a PIN was sent. Check your inbox before trying again.';

  @override
  String get authRegistrationStartGeneric =>
      'We could not start your registration. Try again.';

  @override
  String get authRegistrationAlreadyCompletedTitle =>
      'Registration already completed';

  @override
  String get authRegistrationAlreadyCompletedBody =>
      'This registration was already completed. Sign in to continue.';

  @override
  String get authRegistrationCannotBeCompletedBody =>
      'This registration can no longer be completed. Start a new registration.';

  @override
  String authAccountForEmail(String email) {
    return 'Account for $email';
  }

  @override
  String get authRegistrationStepClosed =>
      'This registration step is no longer open. Start over with the same email to continue.';

  @override
  String get authRegistrationNotFound =>
      'We could not find that registration. Start a new one.';

  @override
  String get authRegistrationUnreadable =>
      'We could not read that registration. Start a new one.';

  @override
  String get authPinInvalid => 'That PIN is not correct. Try again.';

  @override
  String get authPinAttemptsExceededRegistration =>
      'Too many incorrect PINs. Start a new registration.';

  @override
  String get authPinAttemptsExceededReset =>
      'Too many incorrect PINs. Request a new reset.';

  @override
  String get authVerificationUnavailable =>
      'Verification is temporarily unavailable. Try again shortly.';

  @override
  String get authPinVerifyServerFault =>
      'We could not verify your PIN. Try again shortly.';

  @override
  String get authPinVerifyTransport =>
      'No connection to the server. We could not confirm your PIN.';

  @override
  String get authPinVerifyGeneric => 'We could not verify your PIN. Try again.';

  @override
  String get authRegistrationCompleteGeneric =>
      'We could not complete your registration. Try again.';

  @override
  String get authPinInstructions =>
      'We sent a PIN to your email address. Enter it below to continue.';

  @override
  String authSocialVerifiedDescription(String email) {
    return 'Your Google account is verified. Choose the name to show in Stash-it for $email.';
  }

  @override
  String get authAccountAlreadyCreated => 'Account already created';

  @override
  String get authSocialAlreadyCompletedBody =>
      'This social registration was already completed. Continue with Google or sign in to use the account.';

  @override
  String get authSocialInactiveBody =>
      'This social registration can no longer be completed. Start again with Google to create the account.';

  @override
  String get authAccountCreatedSignInNotSaved =>
      'Account created, sign-in not saved';

  @override
  String get authSocialStorageFailureBody =>
      'Your account is ready, but this device could not save the sign-in. Continue with Google or sign in to use it.';

  @override
  String get authSocialSubmitUnconfirmed =>
      'We could not confirm whether registration completed. Continue with Google or sign in; if the account was not created, try again.';

  @override
  String get authLinkInvalidTitle => 'Link unavailable';

  @override
  String get authLinkInvalidBody =>
      'This account-link request is no longer active. It may have expired or already been used. Start again with Google to sign in.';

  @override
  String get authLinkDifferentAccountTitle => 'Different Google account';

  @override
  String get authLinkDifferentAccountBody =>
      'The Google account used here does not match the one this link was started with. Start again and choose the account you originally used.';

  @override
  String get authGoogleSignInExpiredTitle => 'Google sign-in expired';

  @override
  String get authGoogleSignInExpiredBody =>
      'Google no longer accepts the sign-in used for this link. Start again with Google to continue.';

  @override
  String get authAccountsLinkedTitle => 'Accounts linked';

  @override
  String get authAccountsLinkedBody =>
      'Your Google account is now linked, but signing in did not finish. Continue with Google again to sign in.';

  @override
  String get authGoogleAlreadyLinkedTitle => 'Google account already linked';

  @override
  String get authGoogleAlreadyLinkedBody =>
      'This Google account is already linked to a Stash-it account. Continue with Google to sign in.';

  @override
  String get authLinkExistingAccount =>
      'Stash-it found an existing account for this email. Link the Google account you just verified to it?';

  @override
  String authLinkExistingAccountForEmail(String email) {
    return 'Stash-it found an existing account for $email. Link the Google account you just verified to it?';
  }

  @override
  String authGoogleProfile(String name) {
    return 'Google profile: $name';
  }

  @override
  String get authLinkUnavailableShort =>
      'Account linking is temporarily unavailable. Try again shortly.';

  @override
  String get authLinkCheckTransport =>
      'No connection to the server. We could not check this link.';

  @override
  String get authLinkCheckGeneric => 'We could not check this link. Try again.';

  @override
  String get authLinkOutcomeUnconfirmed =>
      'We could not confirm whether the link completed. Continue with Google to sign in; if it was not linked, start again.';

  @override
  String get authLinkFailed => 'We could not link this account. Try again.';

  @override
  String get authGoogleNotConfigured =>
      'Google sign-in is not configured for this build.';

  @override
  String get authGoogleCouldNotStart =>
      'Google sign-in could not start. Try again.';

  @override
  String get authGoogleMissingToken =>
      'Google did not return a sign-in token. Try again.';

  @override
  String get authGoogleBrowserFailed =>
      'Could not open your browser for Google sign-in. Try again.';

  @override
  String get authGoogleSignInTimeout => 'Google sign-in timed out. Try again.';

  @override
  String get authGoogleStateMismatch =>
      'Google sign-in could not be verified. Try again.';

  @override
  String get authGoogleCallbackError =>
      'Google sign-in was not completed. Try again.';

  @override
  String get authCancelGoogleSignIn => 'Cancel Google sign-in';

  @override
  String get authGoogleSignInCancelled => 'Google sign-in was cancelled.';

  @override
  String get authGoogleTokenExchangeFailed =>
      'Google sign-in could not be completed after the browser returned. Try again.';

  @override
  String get authGoogleInvalidToken =>
      'Google could not verify that sign-in. Try again.';

  @override
  String get authGoogleRegistrationIdentityMismatch =>
      'A registration for this email is already in progress under a different account. Try again after it expires.';

  @override
  String get authGoogleLinkSessionFailed =>
      'Your accounts were linked, but sign-in did not finish. Continue with Google again.';

  @override
  String get authGoogleLinkIdentityMismatch =>
      'That Google account does not match the account being linked.';

  @override
  String get authGoogleLinkConfirmationInactive =>
      'This account-link request is no longer active. Start again.';

  @override
  String get authGoogleAccountExists =>
      'This account already exists. Continue with Google or sign in.';

  @override
  String get authGoogleUnavailable =>
      'Google sign-in is temporarily unavailable. Try again shortly.';

  @override
  String get authGoogleServerFault =>
      'We could not start Google sign-in. Try again shortly.';

  @override
  String get authGoogleTransport =>
      'No connection to the server. We could not start Google sign-in.';

  @override
  String get authGoogleUnreadable =>
      'We could not read the server\'s reply, so we could not start Google sign-in. Try again.';

  @override
  String get authGoogleGenericFailure =>
      'Google sign-in could not be completed. Try again.';

  @override
  String get authResetRequestDescription =>
      'Enter your email address. If an account exists, we will send a PIN to confirm it.';

  @override
  String get authResetSavedCheckFailure =>
      'We could not check for a saved password reset. You can request a new one.';

  @override
  String get authResetAlreadyCompletedNotice =>
      'This password reset was already completed. Sign in with your new password, or request a new reset.';

  @override
  String get authResetPreviousInactive =>
      'Your previous password reset is no longer active. Request a new one.';

  @override
  String get authResetSavedCheckGeneric =>
      'We could not check your saved password reset. Try again.';

  @override
  String authResetSavedContinueMessage(String email) {
    return 'A saved password reset for $email is available on this device. Continue it, or use a different email.';
  }

  @override
  String get authResetAlreadyInProgress =>
      'A password reset is already in progress. Try again shortly.';

  @override
  String get authResetStartGeneric =>
      'We could not start the password reset. Try again.';

  @override
  String get authResetStartTransport =>
      'No connection to the server. We could not start the password reset.';

  @override
  String get authResetStartUnreadable =>
      'We could not read the server\'s reply, so we could not start the password reset. Try again.';

  @override
  String get authResetStartServerFault =>
      'We could not start the password reset. Try again shortly.';

  @override
  String get authResetUnavailableShort =>
      'Password reset is temporarily unavailable. Try again shortly.';

  @override
  String get authResetSavedCheckTransport =>
      'No connection to the server. We could not check your saved password reset. Try again.';

  @override
  String get authResetSavedCheckUnreadable =>
      'We could not confirm whether your saved password reset is still active. Try again.';

  @override
  String get authResetSavedCheckServerFault =>
      'We could not check your saved password reset. Try again shortly.';

  @override
  String get authResetContinueTitle => 'Continue password reset';

  @override
  String authResetInProgressFor(String email) {
    return 'A password reset is in progress for $email.';
  }

  @override
  String get authResetAlreadyVerifiedTitle => 'Reset already verified';

  @override
  String get authResetAlreadyVerifiedWaitingBody =>
      'This password reset was already verified, but this device does not have a usable saved reset for this email. Requesting another PIN is not possible. The reset expires within 15 minutes; after that you can request a new one.';

  @override
  String get authResetNeutralBody =>
      'If an account exists for that address, we have sent a password reset PIN.';

  @override
  String authResetPinSentBody(String email) {
    return 'We sent a password reset PIN to $email.';
  }

  @override
  String get authResetAlreadyVerifiedBody =>
      'This reset\'s PIN step is already complete. If this device has the saved reset, continue from the password reset screen. Otherwise wait up to 15 minutes for it to expire and request a new one.';

  @override
  String get authResetNoLongerActiveTitle => 'Reset no longer active';

  @override
  String get authResetNoLongerActiveBody =>
      'This password reset is no longer active. Request a new one to continue.';

  @override
  String get authResetNotAvailableTitle => 'Reset not available';

  @override
  String get authResetNotAvailableBody =>
      'We could not find that password reset. Check the address or start again.';

  @override
  String get authResetVerifiedNotSavedTitle => 'Reset verified, but not saved';

  @override
  String get authResetVerifiedNotSavedBody =>
      'Your PIN was verified, but this device could not save the reset securely. The reset cannot continue here. Request a new one after this reset expires, which takes up to 15 minutes.';

  @override
  String get authResetSavedCheckLocalFailure =>
      'We could not check the saved reset on this device. Try again.';

  @override
  String authResetReplacementUnknownIncoming(String savedEmail) {
    return 'A saved password reset for $savedEmail is on this device. If this PIN verifies, it may replace it; the saved reset for $savedEmail may no longer be available on this device. This does not cancel it on the server.';
  }

  @override
  String authResetReplacementKnownIncoming(String incoming, String savedEmail) {
    return 'A saved password reset for $savedEmail is on this device. If this PIN verifies for $incoming, it will replace it; the saved reset for $savedEmail will no longer be available on this device. This does not cancel it on the server.';
  }

  @override
  String authResetPinSentToEmail(String email) {
    return 'We sent a PIN to $email. Enter it below to choose a new password.';
  }

  @override
  String authResetPinSentToEmailIssued(String email) {
    return 'We sent a PIN to $email. If you already have one, enter it below to choose a new password.';
  }

  @override
  String get authResetPinSentGeneric =>
      'We sent a PIN to your email address. Enter it below to choose a new password.';

  @override
  String get authResetPinSentGenericIssued =>
      'We sent a PIN to your email address. If you already have one, enter it below to choose a new password.';

  @override
  String get authResetResendUnavailable =>
      'PIN delivery is temporarily unavailable. Try again shortly.';

  @override
  String get authResetResendTransport =>
      'No connection to the server. We could not request a new PIN.';

  @override
  String get authResetResendGeneric =>
      'We could not request a new PIN. Try again.';

  @override
  String get authResetLoadTransport =>
      'No connection to the server. We could not check this reset. Try again.';

  @override
  String get authResetLoadServerFault =>
      'We could not check this reset. Try again shortly.';

  @override
  String get authResetLoadGeneric =>
      'We could not check this reset. Try again.';

  @override
  String get authResetStorageReadFailure =>
      'We could not read the saved password reset from this device. Try again.';

  @override
  String get authResetCompletedTitle => 'Password reset completed';

  @override
  String get authResetCompletedBody =>
      'This password reset was already completed. Sign in with your new password.';

  @override
  String get authNoResetInProgressTitle => 'No reset in progress';

  @override
  String get authNoResetInProgressBody =>
      'Start a password reset from sign-in to choose a new password.';

  @override
  String authChooseNewPasswordForEmail(String email) {
    return 'Choose a new password for $email.';
  }

  @override
  String authSetPasswordForEmail(String email) {
    return 'Set a password for $email.';
  }

  @override
  String authResetSubmitRateLimitedWithWait(int seconds) {
    return 'We can\'t reset your password right now. Try again in $seconds seconds.';
  }

  @override
  String get authResetSubmitRateLimitedNoWait =>
      'We can\'t reset your password right now. Try again shortly.';

  @override
  String get authResetOutcomeUnconfirmed =>
      'We could not confirm whether the password reset completed. Try signing in with your new password.';

  @override
  String get authResetSubmitGeneric =>
      'We could not reset your password. Try again.';
}
