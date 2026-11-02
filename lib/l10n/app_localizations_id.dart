// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsBackToInbox => 'Kembali ke Inbox';

  @override
  String get settingsAppearance => 'TAMPILAN';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get settingsLanguage => 'BAHASA';

  @override
  String get languageSystemDefault => 'Bawaan sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get navInbox => 'Inbox';

  @override
  String get navCollections => 'Koleksi';

  @override
  String get navSearch => 'Cari';

  @override
  String get navProfile => 'Profil';

  @override
  String get settingsTooltip => 'Pengaturan';

  @override
  String get clearTooltip => 'Kosongkan';

  @override
  String get dismissAction => 'Dismiss';

  @override
  String get sessionEnded =>
      'Your session has ended. Sign in again to continue.';

  @override
  String get genericReadRateLimited =>
      'Terlalu banyak percobaan. Coba lagi sebentar lagi.';

  @override
  String get genericReadServerFault =>
      'Kami tidak dapat menghubungi server. Coba lagi sebentar lagi.';

  @override
  String get genericReadUnreadable =>
      'Kami tidak dapat membaca balasan server. Coba lagi.';

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
  String get savedJustNow => 'Saved just now';

  @override
  String savedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count min ago',
      one: 'Saved 1 min ago',
    );
    return '$_temp0';
  }

  @override
  String savedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count hours ago',
      one: 'Saved 1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get savedYesterday => 'Saved yesterday';

  @override
  String savedDaysAgo(int count) {
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
}
