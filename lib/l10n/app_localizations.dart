import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// Tooltip for the back-to-Inbox button when Settings is entered directly.
  ///
  /// In en, this message translates to:
  /// **'Back to Inbox'**
  String get settingsBackToInbox;

  /// Appearance section heading in Settings.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsAppearance;

  /// Light theme option label.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option label.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System theme option label.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Language section heading in Settings.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguage;

  /// System default language option. Endonym — same in every locale.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// English language option. Endonym — same in every locale (D21).
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Indonesian language option. Endonym — same in every locale (D21).
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// Inbox destination label in the shell navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get navInbox;

  /// Collections destination label in the shell navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navCollections;

  /// Search destination label in the shell navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Profile destination label in the shell navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Tooltip for the Settings action on every destination app bar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// Tooltip for the clear action inside a text field.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTooltip;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// Dismiss action on an inline message band.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAction;

  /// Neutral explanation shown when a session ends while the user is elsewhere.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to continue.'**
  String get sessionEnded;

  /// Shared copy for a rate-limited read.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again shortly.'**
  String get genericReadRateLimited;

  /// Shared copy for a read that could not reach the server.
  ///
  /// In en, this message translates to:
  /// **'We could not reach the server. Try again shortly.'**
  String get genericReadServerFault;

  /// Shared copy for an unreadable or malformed read reply.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the server\'s reply. Try again.'**
  String get genericReadUnreadable;

  /// A wait of one second or less, used after 'in'.
  ///
  /// In en, this message translates to:
  /// **'a second'**
  String get retryAfterSecond;

  /// A wait in seconds, used after 'in'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String retryAfterSeconds(int count);

  /// A wait in minutes, used after 'in'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String retryAfterMinutes(int count);

  /// A wait in hours, used after 'in'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String retryAfterHours(int count);

  /// Warning shown when the theme changed but could not be persisted.
  ///
  /// In en, this message translates to:
  /// **'Theme changed, but the preference could not be saved.'**
  String get themePreferenceNotSaved;

  /// Warning shown when the language changed but could not be persisted.
  ///
  /// In en, this message translates to:
  /// **'Language changed, but the preference could not be saved.'**
  String get languagePreferenceNotSaved;

  /// Saved-time label for an item saved less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Saved just now'**
  String get savedTimeJustNow;

  /// Saved-time label for an item saved less than an hour ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 min ago} other{Saved {count} min ago}}'**
  String savedTimeMinutesAgo(int count);

  /// Saved-time label for an item saved less than a day ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 hour ago} other{Saved {count} hours ago}}'**
  String savedTimeHoursAgo(int count);

  /// Saved-time label for an item saved between 24 and 48 hours ago.
  ///
  /// In en, this message translates to:
  /// **'Saved yesterday'**
  String get savedTimeYesterday;

  /// Saved-time label for an item saved two or more days ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 day ago} other{Saved {count} days ago}}'**
  String savedTimeDaysAgo(int count);

  /// Label for an email and password identity.
  ///
  /// In en, this message translates to:
  /// **'Email & password'**
  String get profileIdentityEmailPassword;

  /// Label for an identity whose provider is empty.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get profileIdentityUnknown;

  /// One-shot warning that local pending URLs expired after seven days.
  ///
  /// In en, this message translates to:
  /// **'Some links saved on this device expired after seven days.'**
  String get pendingUrlsExpired;

  /// Bulk-save summary when the local list could not be updated after some saves.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved, plural, =1{1 link} other{{saved} links}}, but this device couldn\'t update the list. Check the list before trying again.'**
  String pendingSummaryLocalList(int saved);

  /// Bulk-save summary for one link whose save could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the save. The link is still on this device. Check your Inbox before trying again.'**
  String get pendingSummaryUncertainSingle;

  /// Bulk-save summary when no link was confirmed and the outcome is uncertain.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm saving these links.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}} Check your Inbox before trying again.'**
  String pendingSummaryUncertainNoneSaved(int remaining);

  /// Bulk-save summary when some links were confirmed and others are uncertain.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total} links. We couldn\'t confirm {uncertain, plural, =1{1 link} other{{uncertain} links}}.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}} Check your Inbox before trying again.'**
  String pendingSummaryUncertainPartial(
    int saved,
    int total,
    int uncertain,
    int remaining,
  );

  /// Bulk-save summary for one link stopped by a rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'The link wasn\'t saved. You\'re saving too quickly. Try again shortly.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRateLimitedSingleNoneSavedNoWait(int remaining);

  /// Bulk-save summary for one link stopped by a rate limit with a wait.
  ///
  /// In en, this message translates to:
  /// **'The link wasn\'t saved. You\'re saving too quickly. Try again in {wait}.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRateLimitedSingleNoneSavedWithWait(
    String wait,
    int remaining,
  );

  /// Bulk-save summary when no link was saved and a rate limit stopped the run.
  ///
  /// In en, this message translates to:
  /// **'No links were saved. You\'re saving too quickly. Try again shortly.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRateLimitedNoneSavedNoWait(int remaining);

  /// Bulk-save summary when no link was saved and a rate limit supplied a wait.
  ///
  /// In en, this message translates to:
  /// **'No links were saved. You\'re saving too quickly. Try again in {wait}.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRateLimitedNoneSavedWithWait(String wait, int remaining);

  /// Bulk-save summary when some links were saved and a rate limit stopped the run.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total} links. You\'re saving too quickly. Try again shortly.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRateLimitedPartialNoWait(
    int saved,
    int total,
    int remaining,
  );

  /// Bulk-save summary when some links were saved and a rate limit supplied a wait.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total} links. You\'re saving too quickly. Try again in {wait}.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRateLimitedPartialWithWait(
    int saved,
    int total,
    String wait,
    int remaining,
  );

  /// Bulk-save summary for one link stopped because the session ended.
  ///
  /// In en, this message translates to:
  /// **'The link wasn\'t saved. Sign in again to save the rest.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryAuthSingleNoneSaved(int remaining);

  /// Bulk-save summary when no link was saved because the session ended.
  ///
  /// In en, this message translates to:
  /// **'No links were saved. Sign in again to save the rest.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryAuthNoneSaved(int remaining);

  /// Bulk-save summary when some links were saved before the session ended.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total} links. Sign in again to save the rest.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryAuthPartial(int saved, int total, int remaining);

  /// Bulk-save summary for one link stopped by a server or malformed failure.
  ///
  /// In en, this message translates to:
  /// **'The link wasn\'t saved. Try again.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRetrySingleNoneSaved(int remaining);

  /// Bulk-save summary when no link was saved and the run stopped on a server failure.
  ///
  /// In en, this message translates to:
  /// **'No links were saved. Try again.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRetryNoneSaved(int remaining);

  /// Bulk-save summary when some links were saved before a server failure.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total} links. Try again.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryRetryPartial(int saved, int total, int remaining);

  /// Bulk-save summary for one confirmed link.
  ///
  /// In en, this message translates to:
  /// **'Saved the link to your account.'**
  String get pendingSummaryAllSavedSingle;

  /// Bulk-save summary for every link confirmed.
  ///
  /// In en, this message translates to:
  /// **'Saved all {total} links to your account.'**
  String pendingSummaryAllSaved(int total);

  /// Bulk-save summary when no link was saved.
  ///
  /// In en, this message translates to:
  /// **'No links were saved.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryNoneSaved(int remaining);

  /// Bulk-save summary when some but not all links were saved.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total} links.{remaining, plural, =0{} =1{ 1 link is still on this device.} other{ {remaining} links are still on this device.}}'**
  String pendingSummaryPartial(int saved, int total, int remaining);

  /// Confirmed save. Only says the item was created (D26).
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saved;

  /// Local refusal for a value that cannot be an absolute http(s) URL.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid link. Enter a full http:// or https:// address.'**
  String get invalidUrlFull;

  /// Server validation refusal for a save.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid link. Check the URL and try again.'**
  String get saveValidation;

  /// Known not-saved refusal for a malformed save request.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong sending that link. Try again.'**
  String get saveMalformed;

  /// Save rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'You\'re saving too quickly. Try again shortly.'**
  String get saveRateLimitedNoWait;

  /// Save rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'You\'re saving too quickly. Try again in {wait}.'**
  String saveRateLimitedWithWait(String wait);

  /// Known not-saved server refusal for a save.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save this link just now. Try again shortly.'**
  String get saveServerUnavailable;

  /// Uncertain save outcome when the reply could not be read.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the server\'s reply, so we can\'t confirm the save. Check your Inbox before trying again.'**
  String get saveUnreadable;

  /// Uncertain save outcome when no reply arrived.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm this save. It may or may not have gone through — check your Inbox before trying again.'**
  String get saveTransport;

  /// Known not-saved outcome after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so that link wasn\'t saved. Try again.'**
  String get saveRefreshUncertain;

  /// Known not-saved outcome when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so that link wasn\'t saved. Try again.'**
  String get saveCredentialStorage;

  /// Known not-saved outcome when the session refuses a save.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to save this link.'**
  String get saveAuthRequired;

  /// A re-read completed and metadata was found.
  ///
  /// In en, this message translates to:
  /// **'Page re-read.'**
  String get pageReRead;

  /// A re-read completed with no metadata.
  ///
  /// In en, this message translates to:
  /// **'Page re-read. This page shows no details.'**
  String get pageReReadNoDetails;

  /// The re-read request succeeded but extraction failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this page.'**
  String get pageReadFailed;

  /// The re-read outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the re-read. Try again.'**
  String get enrichUnconfirmed;

  /// Re-read rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'You\'ve re-read too many pages. Try again shortly.'**
  String get enrichRateLimitedNoWait;

  /// Re-read rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'You\'ve re-read too many pages. Try again in {wait}.'**
  String enrichRateLimitedWithWait(String wait);

  /// Re-reading is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Re-reading is temporarily unavailable. Try again shortly.'**
  String get enrichUnavailable;

  /// The saved item is no longer available.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available.'**
  String get itemUnavailable;

  /// The session refuses a re-read.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to re-read this page.'**
  String get enrichAuthRequired;

  /// Known not-re-read outcome after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so the page wasn\'t re-read. Try again.'**
  String get enrichRefreshUncertain;

  /// Known not-re-read outcome when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so the page wasn\'t re-read. Try again.'**
  String get enrichCredentialStorage;

  /// Known not-re-read outcome.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t re-read this page. Try again.'**
  String get enrichFailed;

  /// A server fault during a re-read.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong re-reading this page. Try again.'**
  String get enrichServerFault;

  /// Known not-moved outcome for an unexpected failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong moving this item. Try again.'**
  String get moveServerError;

  /// The move outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm the move. Check the item\'s collection.'**
  String get moveUnconfirmed;

  /// The session refuses a move.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to move this item.'**
  String get moveAuthRequired;

  /// Known not-moved outcome after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so the item wasn\'t moved. Try again.'**
  String get moveRefreshUncertain;

  /// Known not-moved outcome when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so the item wasn\'t moved. Try again.'**
  String get moveCredentialStorage;

  /// Known not-moved outcome for a malformed request.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong sending that name. Try again.'**
  String get moveMalformed;

  /// Move rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'You\'re moving too quickly. Try again shortly.'**
  String get moveRateLimitedNoWait;

  /// Move rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'You\'re moving too quickly. Try again in {wait}.'**
  String moveRateLimitedWithWait(String wait);

  /// The item was already in the named collection.
  ///
  /// In en, this message translates to:
  /// **'Already in {name}.'**
  String alreadyInCollection(String name);

  /// A collection was created and the item moved into it.
  ///
  /// In en, this message translates to:
  /// **'Created {name} and moved the item.'**
  String createdCollectionAndMoved(String name);

  /// The item was moved into the named collection.
  ///
  /// In en, this message translates to:
  /// **'Moved to {name}.'**
  String movedToCollection(String name);

  /// A saved item was deleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted.'**
  String get itemDeleted;

  /// A saved item and its now-empty collection were deleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted, and {name} was deleted.'**
  String itemDeletedAndCollectionDeleted(String name);

  /// The saved-item delete outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether the item was deleted. Check the Inbox before trying again.'**
  String get deleteItemUnconfirmed;

  /// The session refuses a saved-item delete.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to delete this item.'**
  String get deleteItemAuthRequired;

  /// Known not-deleted outcome after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so the item wasn\'t deleted. Try again.'**
  String get deleteItemRefreshUncertain;

  /// Known not-deleted outcome when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so the item wasn\'t deleted. Try again.'**
  String get deleteItemCredentialStorage;

  /// Known not-deleted outcome for a saved item.
  ///
  /// In en, this message translates to:
  /// **'The item wasn\'t deleted. Try again.'**
  String get itemNotDeleted;

  /// A rate limit stopped a saved-item delete.
  ///
  /// In en, this message translates to:
  /// **'You\'re going too quickly. The item wasn\'t deleted. Try again shortly.'**
  String get deleteItemRateLimited;

  /// The item was deleted and its collection is no longer available.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. {name} is no longer available.'**
  String collectionUnavailableAfterItemDeleted(String name);

  /// The item was deleted but its collection received new items.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. {name} now has items, so it was not deleted.'**
  String collectionNotEmptyAfterItemDeleted(String name);

  /// The item was deleted but its collection cannot be deleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. {name} cannot be deleted.'**
  String collectionProtectedAfterItemDeleted(String name);

  /// The item was deleted but the collection delete could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'Item deleted, but we couldn\'t confirm whether {name} was deleted. Check Collections.'**
  String collectionDeleteUnconfirmedAfterItemDeleted(String name);

  /// The item was deleted but the session refuses the collection delete.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. Sign in again to delete {name}.'**
  String collectionDeleteAuthRequiredAfterItemDeleted(String name);

  /// The item was deleted but the session ended before the collection delete.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. Your session ended before {name} could be deleted.'**
  String collectionDeleteSessionEndedAfterItemDeleted(String name);

  /// The item was deleted but an ambiguous refresh stopped the collection delete.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. We couldn\'t renew your session, so {name} was not deleted. Try again.'**
  String collectionDeleteRefreshUncertainAfterItemDeleted(String name);

  /// The item was deleted but local credential storage stopped the collection delete.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. This device couldn\'t refresh your session, so {name} was not deleted. Try again.'**
  String collectionDeleteCredentialStorageAfterItemDeleted(String name);

  /// The item was deleted but a rate limit stopped the collection delete.
  ///
  /// In en, this message translates to:
  /// **'Item deleted. You\'re going too quickly, so {name} was not deleted. Try again shortly.'**
  String collectionDeleteRateLimitedAfterItemDeleted(String name);

  /// The item was deleted but the collection delete failed.
  ///
  /// In en, this message translates to:
  /// **'Item deleted, but {name} could not be deleted. Try again from Collections.'**
  String collectionDeleteFailedAfterItemDeleted(String name);

  /// A collection was deleted.
  ///
  /// In en, this message translates to:
  /// **'{name} was deleted.'**
  String collectionDeleted(String name);

  /// A collection was deleted after its items were moved.
  ///
  /// In en, this message translates to:
  /// **'{name} was deleted, and its items were moved to {target}.'**
  String collectionDeletedItemsMoved(String name, String target);

  /// Known not-deleted outcome for a collection.
  ///
  /// In en, this message translates to:
  /// **'The collection wasn\'t deleted. Try again.'**
  String get collectionDeleteFailed;

  /// The destination collection for a move-and-delete is unavailable.
  ///
  /// In en, this message translates to:
  /// **'{name} is no longer available. Nothing was changed. Choose another destination.'**
  String collectionDeleteTargetUnavailable(String name);

  /// The collection is no longer available.
  ///
  /// In en, this message translates to:
  /// **'{name} is no longer available.'**
  String collectionUnavailable(String name);

  /// The collection received items so nothing was changed.
  ///
  /// In en, this message translates to:
  /// **'{name} now has items, so nothing was changed. Its current contents are being refreshed.'**
  String collectionNotEmpty(String name);

  /// The collection cannot be deleted.
  ///
  /// In en, this message translates to:
  /// **'{name} cannot be deleted.'**
  String collectionProtected(String name);

  /// The collection delete outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether {name} was deleted. Check Collections before trying again.'**
  String collectionDeleteUnconfirmed(String name);

  /// The session refuses a collection delete.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to delete this collection.'**
  String get collectionDeleteAuthRequired;

  /// Known not-deleted collection outcome after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so {name} wasn\'t deleted. Try again.'**
  String collectionDeleteRefreshUncertain(String name);

  /// Known not-deleted collection outcome when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so {name} wasn\'t deleted. Try again.'**
  String collectionDeleteCredentialStorage(String name);

  /// Collection delete rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'You\'re going too quickly. The collection wasn\'t deleted. Try again shortly.'**
  String get collectionDeleteRateLimitedNoWait;

  /// Collection delete rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'You\'re going too quickly. The collection wasn\'t deleted. Try again in {wait}.'**
  String collectionDeleteRateLimitedWithWait(String wait);

  /// The stored link cannot be handed to the platform.
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be opened.'**
  String get linkCannotOpen;

  /// The platform refused to open the link.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open this link. Try again.'**
  String get linkLaunchFailed;

  /// Feedback after the saved URL was copied.
  ///
  /// In en, this message translates to:
  /// **'URL copied'**
  String get urlCopied;

  /// Feedback when the saved URL could not be copied.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy the URL. Try again.'**
  String get urlCopyFailed;

  /// A manual refresh failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh. Check your connection.'**
  String get refreshFailed;

  /// The display name was updated.
  ///
  /// In en, this message translates to:
  /// **'Display name updated.'**
  String get displayNameUpdated;

  /// Display-name rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again shortly.'**
  String get displayNameRateLimitedNoWait;

  /// Display-name rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {wait}.'**
  String displayNameRateLimitedWithWait(String wait);

  /// Display-name changes are temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Display name changes are temporarily unavailable. Try again shortly.'**
  String get displayNameUnavailable;

  /// The display-name update outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether your display name was updated. Check your profile before trying again.'**
  String get displayNameUnconfirmed;

  /// The account behind the token is no longer available.
  ///
  /// In en, this message translates to:
  /// **'This account is no longer available.'**
  String get accountUnavailable;

  /// The session refuses a display-name update.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to change your display name.'**
  String get displayNameAuthRequired;

  /// Known not-changed display name after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so your display name wasn\'t changed. Try again.'**
  String get displayNameRefreshUncertain;

  /// Known not-changed display name when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so your display name wasn\'t changed. Try again.'**
  String get displayNameCredentialStorage;

  /// Known not-changed display name.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t change your display name. Try again.'**
  String get displayNameChangeFailed;

  /// The password was changed.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordChanged;

  /// A password was created.
  ///
  /// In en, this message translates to:
  /// **'Password created.'**
  String get passwordCreated;

  /// The account already has a password; the form was in create mode.
  ///
  /// In en, this message translates to:
  /// **'A password was already created for this account. Open this screen again to change it.'**
  String get passwordModeConflictExists;

  /// The account requires a current password; the form was in create mode.
  ///
  /// In en, this message translates to:
  /// **'Your account already has a password. Open this screen again to change it.'**
  String get passwordModeConflictRequired;

  /// The account has no password; the form was in change mode.
  ///
  /// In en, this message translates to:
  /// **'Your account has no password yet. Open this screen again to create one.'**
  String get passwordModeConflictUnexpected;

  /// Password rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'We can\'t set a password right now. Try again shortly.'**
  String get passwordRateLimitedNoWait;

  /// Password rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'We can\'t set a password right now. Try again in {wait}.'**
  String passwordRateLimitedWithWait(String wait);

  /// Password changes are temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'We can\'t set a password right now. Try again shortly.'**
  String get passwordUnavailable;

  /// The password update outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether your password was set. Open this screen again before trying again.'**
  String get passwordUnconfirmed;

  /// The session refuses a password update.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to set your password.'**
  String get passwordAuthRequired;

  /// Known not-changed password after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so your password wasn\'t changed. Try again.'**
  String get passwordRefreshUncertainChanged;

  /// Known not-set password after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so your password wasn\'t set. Try again.'**
  String get passwordRefreshUncertainSet;

  /// Known not-changed password when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so your password wasn\'t changed. Try again.'**
  String get passwordCredentialStorageChanged;

  /// Known not-set password when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so your password wasn\'t set. Try again.'**
  String get passwordCredentialStorageSet;

  /// Known not-set password.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t set your password. Try again.'**
  String get passwordSetFailed;

  /// A new verification PIN was sent.
  ///
  /// In en, this message translates to:
  /// **'A new PIN has been sent.'**
  String get newPinSent;

  /// The PIN verified but the registration continuation could not be saved locally.
  ///
  /// In en, this message translates to:
  /// **'PIN verified, but this device could not save your progress. Finish before closing the app.'**
  String get pinVerifiedProgressNotSaved;

  /// Share intake confirmed the save.
  ///
  /// In en, this message translates to:
  /// **'Saved to your account.'**
  String get shareSaved;

  /// Share intake could not save remotely and kept the URL locally.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save it. Kept on this device.'**
  String get shareStoredAfterFailure;

  /// Share intake could not confirm the save and kept the URL locally as uncertain.
  ///
  /// In en, this message translates to:
  /// **'Save not confirmed. Kept on this device.'**
  String get shareStoredAfterUncertain;

  /// Share intake found no submittable URL.
  ///
  /// In en, this message translates to:
  /// **'That\'s not a link, so nothing was saved.'**
  String get shareInvalid;

  /// Share intake could neither save remotely nor keep the URL locally.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save or keep this link.'**
  String get shareNotStored;

  /// Title of the Inbox destination.
  ///
  /// In en, this message translates to:
  /// **'INBOX'**
  String get inboxTitle;

  /// Section label above the recently saved items list.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY SAVED'**
  String get inboxRecentlySaved;

  /// Label shown while the next page of saved items loads.
  ///
  /// In en, this message translates to:
  /// **'Loading more…'**
  String get inboxLoadingMore;

  /// Heading shown when the Inbox has no saved items.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get inboxEmptyTitle;

  /// Explanation shown when the Inbox has no saved items.
  ///
  /// In en, this message translates to:
  /// **'Save a link and it will appear here, in the collection it belongs to.'**
  String get inboxEmptyBody;

  /// Retry action for a failed Inbox listing request.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get inboxRetry;

  /// Inbox listing message when the session has ended.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to see your saved items.'**
  String get inboxSessionEnded;

  /// Inbox listing message when authentication is required.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to see your saved items.'**
  String get inboxSignInRequired;

  /// Inbox listing message when saved items are temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Your saved items are temporarily unavailable. Try again shortly.'**
  String get inboxUnavailable;

  /// Unconfirmed Inbox load because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not load your saved items.'**
  String get inboxLoadTransport;

  /// Fallback copy for a failed Inbox listing request.
  ///
  /// In en, this message translates to:
  /// **'We could not load your saved items. Try again.'**
  String get inboxLoadGeneric;

  /// Section label above the URL intake.
  ///
  /// In en, this message translates to:
  /// **'SAVE A URL'**
  String get inboxSaveUrlSection;

  /// Status label while a Save URL request is in progress.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get inboxSaving;

  /// Status label when the URL field has content.
  ///
  /// In en, this message translates to:
  /// **'Check or edit the link before saving.'**
  String get inboxIntakeReady;

  /// Status hint when the URL field is empty.
  ///
  /// In en, this message translates to:
  /// **'Paste fills the field. Save URL sends it.'**
  String get inboxIntakeHint;

  /// Action that fills the URL field from the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get inboxPaste;

  /// Action that submits the URL field.
  ///
  /// In en, this message translates to:
  /// **'Save URL'**
  String get inboxSaveAction;

  /// Label for the saved item's note preview and the full-note sheet.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get inboxYourNote;

  /// App bar title for the device-local Pending URLs screen.
  ///
  /// In en, this message translates to:
  /// **'SAVED ON THIS DEVICE'**
  String get pendingUrlsTitle;

  /// Back tooltip for a signed-in direct entry to Pending URLs.
  ///
  /// In en, this message translates to:
  /// **'Back to Inbox'**
  String get pendingUrlsBackToInbox;

  /// Back tooltip for a signed-out direct entry to Pending URLs.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get pendingUrlsBackToSignIn;

  /// Loading label while the device-local URL list is read.
  ///
  /// In en, this message translates to:
  /// **'Loading links…'**
  String get pendingUrlsLoading;

  /// Explanation of device-local retention for signed-in users.
  ///
  /// In en, this message translates to:
  /// **'Links you shared are kept here for seven days when a save didn\'t finish. They are stored on this device until you save them to your account.'**
  String get pendingUrlsSignedInIntro;

  /// Explanation of device-local retention for signed-out users.
  ///
  /// In en, this message translates to:
  /// **'Links you shared are kept here for seven days when a save didn\'t finish. They are stored on this device, not in your account.'**
  String get pendingUrlsSignedOutIntro;

  /// Action that saves every device-local URL to the account.
  ///
  /// In en, this message translates to:
  /// **'Save all to my account'**
  String get pendingUrlsSaveAllAction;

  /// Signed-out action that opens sign-in before saving local URLs.
  ///
  /// In en, this message translates to:
  /// **'Sign in to save these links'**
  String get pendingUrlsSignInAction;

  /// Progress label when a single local URL is being saved.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get pendingUrlsSaving;

  /// Progress label with the current and total local URLs.
  ///
  /// In en, this message translates to:
  /// **'Saving {current} of {total}…'**
  String pendingUrlsSavingProgress(int current, int total);

  /// Row label for a local URL whose save outcome is unconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Save not confirmed'**
  String get pendingUrlsSaveNotConfirmed;

  /// Empty state title for the device-local URL list.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved on this device'**
  String get pendingUrlsEmptyTitle;

  /// Empty state explanation for the device-local URL list.
  ///
  /// In en, this message translates to:
  /// **'Links that didn\'t finish saving will appear here for seven days.'**
  String get pendingUrlsEmptyBody;

  /// Error copy when the device-local URL store cannot be read.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the links saved on this device.'**
  String get pendingUrlsReadError;

  /// Retry action for a failed device-local URL read.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get pendingUrlsRetry;

  /// Kept-time label for a URL kept less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Kept just now'**
  String get pendingUrlsKeptJustNow;

  /// Kept-time label for a URL kept less than an hour ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Kept 1 min ago} other{Kept {count} min ago}}'**
  String pendingUrlsKeptMinutesAgo(int count);

  /// Kept-time label for a URL kept less than a day ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Kept 1 hour ago} other{Kept {count} hours ago}}'**
  String pendingUrlsKeptHoursAgo(int count);

  /// Kept-time label for a URL kept between one and two days ago.
  ///
  /// In en, this message translates to:
  /// **'Kept yesterday'**
  String get pendingUrlsKeptYesterday;

  /// Kept-time label for a URL kept two or more days ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Kept 1 day ago} other{Kept {count} days ago}}'**
  String pendingUrlsKeptDaysAgo(int count);

  /// Title of the Pending URLs entry card.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get pendingUrlsEntryTitle;

  /// Entry card subtitle when device-local URLs exist.
  ///
  /// In en, this message translates to:
  /// **'Kept on this device. Open to review them.'**
  String get pendingUrlsEntryActiveBody;

  /// Entry card subtitle when no device-local URLs exist.
  ///
  /// In en, this message translates to:
  /// **'Links that couldn\'t be saved will appear here.'**
  String get pendingUrlsEntryEmptyBody;

  /// Accessibility label for the entry card with a count.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device, {count, plural, =1{1 link} other{{count} links}}'**
  String pendingUrlsEntrySemanticsCount(int count);

  /// Accessibility label when the entry card count is shown as 99+.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device, more than 99 links'**
  String get pendingUrlsEntrySemanticsOverflow;

  /// Title of the saved-item detail app bar.
  ///
  /// In en, this message translates to:
  /// **'ITEM'**
  String get savedItemDetailTitle;

  /// Title of the saved-items collection app bar.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION'**
  String get savedItemCollectionDetailTitle;

  /// Back action or tooltip returning to the Inbox.
  ///
  /// In en, this message translates to:
  /// **'Back to Inbox'**
  String get savedItemBackToInbox;

  /// Section label for item actions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get savedItemActionsSection;

  /// Action opening collection selection for the item.
  ///
  /// In en, this message translates to:
  /// **'Move to a collection'**
  String get savedItemMoveAction;

  /// Action opening the original saved URL.
  ///
  /// In en, this message translates to:
  /// **'Open the original page'**
  String get savedItemOpenAction;

  /// Icon action that copies the complete saved URL.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get savedItemCopyUrl;

  /// Icon action that opens the Android system share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share URL'**
  String get savedItemShareUrl;

  /// Informational caveat below a displayed price.
  ///
  /// In en, this message translates to:
  /// **'Price may have changed.'**
  String get savedItemPriceMayHaveChanged;

  /// Compact affordance shown when the saved item has no note.
  ///
  /// In en, this message translates to:
  /// **'Add a personal note'**
  String get savedItemAddNote;

  /// Primary action in the note editor.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savedItemNoteSaveAction;

  /// Placeholder in the empty note editor.
  ///
  /// In en, this message translates to:
  /// **'Write your note…'**
  String get savedItemNotePlaceholder;

  /// Note editor character counter.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String savedItemNoteCharacterCount(int count, int max);

  /// Confirmation title shown when an existing note is cleared.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get savedItemNoteDeleteTitle;

  /// Confirmation body for clearing a note; the item itself is kept.
  ///
  /// In en, this message translates to:
  /// **'This removes your note. The saved item stays.'**
  String get savedItemNoteDeleteMessage;

  /// Safe action in the note deletion confirmation.
  ///
  /// In en, this message translates to:
  /// **'Keep note'**
  String get savedItemNoteKeepAction;

  /// Destructive action that clears the note.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get savedItemNoteDeleteConfirmAction;

  /// Feedback after a confirmed note save.
  ///
  /// In en, this message translates to:
  /// **'Note saved.'**
  String get savedItemNoteSaved;

  /// Feedback after a confirmed note clear.
  ///
  /// In en, this message translates to:
  /// **'Note deleted.'**
  String get savedItemNoteDeleted;

  /// Feedback when a note save outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether your note was saved. Check the note before trying again.'**
  String get savedItemNoteSaveUnconfirmed;

  /// Feedback when a note clear outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t confirm whether your note was deleted. Check the note before trying again.'**
  String get savedItemNoteDeleteUnconfirmed;

  /// Feedback when the session refuses a note change.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to change this note.'**
  String get savedItemNoteAuthRequired;

  /// Known not-changed note outcome after an ambiguous session refresh.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t renew your session, so the note wasn\'t changed. Try again.'**
  String get savedItemNoteRefreshUncertain;

  /// Known not-changed note outcome when local credential storage failed.
  ///
  /// In en, this message translates to:
  /// **'This device couldn\'t refresh your session, so the note wasn\'t changed. Try again.'**
  String get savedItemNoteCredentialStorage;

  /// Note mutation rate limit with no Retry-After.
  ///
  /// In en, this message translates to:
  /// **'You\'re changing notes too quickly. Try again shortly.'**
  String get savedItemNoteRateLimitedNoWait;

  /// Note mutation rate limit with a Retry-After wait.
  ///
  /// In en, this message translates to:
  /// **'You\'re changing notes too quickly. Try again in {wait}.'**
  String savedItemNoteRateLimitedWithWait(String wait);

  /// Note changes are temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Note changes are temporarily unavailable. Try again shortly.'**
  String get savedItemNoteUnavailable;

  /// The submitted note was rejected as invalid.
  ///
  /// In en, this message translates to:
  /// **'That note can\'t be saved. Check the text and try again.'**
  String get savedItemNoteInvalid;

  /// Known not-saved note outcome.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your note. Try again.'**
  String get savedItemNoteSaveFailed;

  /// Known not-cleared note outcome.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete your note. Try again.'**
  String get savedItemNoteDeleteFailed;

  /// Action starting saved-item deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete this item'**
  String get savedItemDeleteAction;

  /// Section label for enrichment actions.
  ///
  /// In en, this message translates to:
  /// **'ENRICHMENT'**
  String get savedItemEnrichmentSection;

  /// Action requesting a fresh read of the saved page.
  ///
  /// In en, this message translates to:
  /// **'Re-read page'**
  String get savedItemReReadAction;

  /// Caption shown while a re-read is in progress.
  ///
  /// In en, this message translates to:
  /// **'Reading the page…'**
  String get savedItemReadingPage;

  /// Title of the saved-item deletion confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get savedItemDeleteDialogTitle;

  /// Body of the saved-item deletion confirmation.
  ///
  /// In en, this message translates to:
  /// **'This removes the saved item. It cannot be undone.'**
  String get savedItemDeleteDialogMessage;

  /// Safe action in the saved-item deletion confirmation.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get savedItemKeepAction;

  /// Destructive confirmation action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get savedItemDeleteConfirmAction;

  /// Confirmation title when deleting the last item empties a collection.
  ///
  /// In en, this message translates to:
  /// **'{name} is now empty'**
  String savedItemCollectionEmptyTitle(String name);

  /// Offers to keep or delete a collection emptied by item deletion.
  ///
  /// In en, this message translates to:
  /// **'This was the last item in {name}. You can keep this empty collection or delete it.'**
  String savedItemCollectionEmptyMessage(String name);

  /// Action keeping an emptied collection.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get savedItemKeepCollectionAction;

  /// Action deleting a collection.
  ///
  /// In en, this message translates to:
  /// **'Delete collection'**
  String get savedItemDeleteCollectionAction;

  /// Cancel action in saved-item dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get savedItemCancelAction;

  /// Dismissal label that explicitly keeps the collection.
  ///
  /// In en, this message translates to:
  /// **'Keep collection'**
  String get savedItemKeepCollectionDismissAction;

  /// Dismissal label when an outcome is uncertain.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get savedItemCloseAction;

  /// Title when a saved item no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available'**
  String get savedItemNotFoundTitle;

  /// Body when a saved item no longer exists.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted, or it may belong to another account.'**
  String get savedItemNotFoundBody;

  /// Title for a retryable saved-item read failure.
  ///
  /// In en, this message translates to:
  /// **'We could not load this item'**
  String get savedItemLoadErrorTitle;

  /// Retry action for saved-item reads and enrichment.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get savedItemRetry;

  /// Saved-item read message when the session ended.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to see this item.'**
  String get savedItemSessionEnded;

  /// Saved-item read message when authentication is required.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to see this item.'**
  String get savedItemSignInRequired;

  /// Saved item is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'This item is temporarily unavailable. Try again shortly.'**
  String get savedItemUnavailable;

  /// Saved-item read failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We couldn\'t load this item.'**
  String get savedItemLoadTransport;

  /// Fallback copy for a failed saved-item read.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this item. Try again.'**
  String get savedItemLoadGeneric;

  /// Enrichment status while the page is being read.
  ///
  /// In en, this message translates to:
  /// **'Reading page…'**
  String get savedItemEnrichmentReading;

  /// Completed enrichment with no usable metadata.
  ///
  /// In en, this message translates to:
  /// **'No details on this page'**
  String get savedItemEnrichmentNoDetails;

  /// Enrichment could not read the page.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this page'**
  String get savedItemEnrichmentFailed;

  /// Back action or tooltip returning to Collections.
  ///
  /// In en, this message translates to:
  /// **'Back to Collections'**
  String get savedItemBackToCollections;

  /// Tooltip for the collection actions menu.
  ///
  /// In en, this message translates to:
  /// **'Collection actions'**
  String get savedItemCollectionActionsTooltip;

  /// Footer label while another page loads.
  ///
  /// In en, this message translates to:
  /// **'Loading more…'**
  String get savedItemLoadingMore;

  /// Footer copy when loading another page failed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load more items.'**
  String get savedItemLoadMoreFailed;

  /// Empty state title for a saved-items collection.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved here yet'**
  String get savedItemEmptyCollectionTitle;

  /// Empty state body for a saved-items collection.
  ///
  /// In en, this message translates to:
  /// **'Items saved to this collection will appear here.'**
  String get savedItemEmptyCollectionBody;

  /// Title when a collection is no longer available.
  ///
  /// In en, this message translates to:
  /// **'This collection is no longer available'**
  String get savedItemCollectionUnavailableTitle;

  /// Body when a collection is no longer available.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted, or it may belong to another account.'**
  String get savedItemCollectionUnavailableBody;

  /// Title for a retryable collection read failure.
  ///
  /// In en, this message translates to:
  /// **'We could not load this collection'**
  String get savedItemCollectionLoadErrorTitle;

  /// Collection read message when the session ended.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to see this collection.'**
  String get savedItemCollectionSessionEnded;

  /// Collection read message when authentication is required.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to see this collection.'**
  String get savedItemCollectionSignInRequired;

  /// Collection is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'This collection is temporarily unavailable. Try again shortly.'**
  String get savedItemCollectionUnavailable;

  /// Collection read failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not load this collection.'**
  String get savedItemCollectionLoadTransport;

  /// Fallback copy for a failed collection read.
  ///
  /// In en, this message translates to:
  /// **'We could not load this collection. Try again.'**
  String get savedItemCollectionLoadGeneric;

  /// Deletion title for an empty collection.
  ///
  /// In en, this message translates to:
  /// **'Delete this collection?'**
  String get savedItemEmptyCollectionDeleteTitle;

  /// Deletion title naming a collection.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String savedItemDeleteCollectionNamedTitle(String name);

  /// Deletion confirmation for an empty collection.
  ///
  /// In en, this message translates to:
  /// **'This collection is empty. There are no items to keep or discard. This cannot be undone.'**
  String get savedItemEmptyCollectionDeleteMessage;

  /// Shows the item's current collection in the move sheet.
  ///
  /// In en, this message translates to:
  /// **'Currently in {name}'**
  String savedItemCurrentlyIn(String name);

  /// Heading above loaded collection destinations.
  ///
  /// In en, this message translates to:
  /// **'YOUR COLLECTIONS'**
  String get savedItemYourCollections;

  /// Action opening the full collection picker.
  ///
  /// In en, this message translates to:
  /// **'Browse all collections'**
  String get savedItemBrowseAllCollections;

  /// Label for the new-collection name field.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get savedItemNewCollection;

  /// Placeholder example for a new collection name.
  ///
  /// In en, this message translates to:
  /// **'e.g. Reading list'**
  String get savedItemNewCollectionPlaceholder;

  /// Loading label for collection destinations.
  ///
  /// In en, this message translates to:
  /// **'Loading collections…'**
  String get savedItemLoadingCollections;

  /// Copy when collection destinations fail to load.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your collections.'**
  String get savedItemLoadCollectionsFailed;

  /// Hint to browse all collections when the preview is empty.
  ///
  /// In en, this message translates to:
  /// **'Browse all collections to find a destination.'**
  String get savedItemBrowseAllHint;

  /// Hint when no other collections exist.
  ///
  /// In en, this message translates to:
  /// **'No other collections yet. Create one below.'**
  String get savedItemNoOtherCollectionsCreate;

  /// Primary action label when the typed name is the current collection.
  ///
  /// In en, this message translates to:
  /// **'Already in {name}'**
  String savedItemAlreadyIn(String name);

  /// Primary action label for moving to a loaded collection.
  ///
  /// In en, this message translates to:
  /// **'Move to {name}'**
  String savedItemMoveTo(String name);

  /// Primary action label for creating a collection by name.
  ///
  /// In en, this message translates to:
  /// **'Create {name}'**
  String savedItemCreate(String name);

  /// Helper copy when destinations failed to load.
  ///
  /// In en, this message translates to:
  /// **'You can still create a collection by name, or browse all collections.'**
  String get savedItemMoveHelperError;

  /// Default helper copy for collection selection.
  ///
  /// In en, this message translates to:
  /// **'Choose an existing collection, or enter a name to create a new one.'**
  String get savedItemMoveHelper;

  /// Inline error for a duplicate collection name.
  ///
  /// In en, this message translates to:
  /// **'That collection name is already taken. Choose a different name.'**
  String get savedItemCollectionNameTaken;

  /// Inline error for a blank collection name.
  ///
  /// In en, this message translates to:
  /// **'Enter a collection name.'**
  String get savedItemCollectionNameRequired;

  /// Inline error for a collection name over 100 characters.
  ///
  /// In en, this message translates to:
  /// **'Use 100 characters or fewer.'**
  String get savedItemCollectionNameTooLong;

  /// Fallback collection-name length error.
  ///
  /// In en, this message translates to:
  /// **'Enter a collection name between 1 and 100 characters.'**
  String get savedItemCollectionNameRange;

  /// Title of the full collection picker.
  ///
  /// In en, this message translates to:
  /// **'All collections'**
  String get savedItemAllCollections;

  /// Default picker description for a single-item move.
  ///
  /// In en, this message translates to:
  /// **'Choose a collection to move this item into.'**
  String get savedItemPickerDescription;

  /// Empty state in the full collection picker.
  ///
  /// In en, this message translates to:
  /// **'No other collections yet.'**
  String get savedItemNoOtherCollections;

  /// Footer copy when loading more collections failed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load more collections.'**
  String get savedItemLoadMoreCollectionsFailed;

  /// Fallback name for an unnamed current collection.
  ///
  /// In en, this message translates to:
  /// **'This collection'**
  String get savedItemThisCollection;

  /// Neutral fallback name used in feedback copy.
  ///
  /// In en, this message translates to:
  /// **'the collection'**
  String get savedItemTheCollection;

  /// Irreversibility warning in the collection deletion sheet.
  ///
  /// In en, this message translates to:
  /// **'Deleting the collection cannot be undone, and items you choose to delete cannot be recovered.'**
  String get savedItemDeleteCollectionCannotUndo;

  /// Bulk action moving items before deleting their collection.
  ///
  /// In en, this message translates to:
  /// **'Move items to another collection'**
  String get savedItemMoveItemsAction;

  /// Bulk action deleting a collection together with its items.
  ///
  /// In en, this message translates to:
  /// **'Delete collection and items'**
  String get savedItemDeleteItemsAction;

  /// Collection item-count copy when the exact total is unknown.
  ///
  /// In en, this message translates to:
  /// **'This collection has saved items. Choose what happens to them.'**
  String get savedItemCollectionHasItemsUnknown;

  /// Collection item-count copy with an exact plural count.
  ///
  /// In en, this message translates to:
  /// **'This collection has {count, plural, =1{1 saved item. Choose what happens to it.} other{{count} saved items. Choose what happens to them.}}'**
  String savedItemCollectionHasItems(int count);

  /// Destination picker description for one item.
  ///
  /// In en, this message translates to:
  /// **'Choose where this item should go. {name} will be deleted.'**
  String savedItemBulkMoveThisItem(String name);

  /// Destination picker description for multiple items.
  ///
  /// In en, this message translates to:
  /// **'Choose where these items should go. {name} will be deleted.'**
  String savedItemBulkMoveTheseItems(String name);

  /// App bar title and section label for the Collections destination.
  ///
  /// In en, this message translates to:
  /// **'COLLECTIONS'**
  String get collectionsTitle;

  /// Sort option that orders collections by newest first.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get collectionsSortNewest;

  /// Sort option that orders collections by oldest first.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get collectionsSortOldest;

  /// Sort option that orders collections by name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get collectionsSortName;

  /// Empty state title when there are no collections.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get collectionsEmptyTitle;

  /// Empty state explanation for the Collections destination.
  ///
  /// In en, this message translates to:
  /// **'Collections appear when you save links or organize them.'**
  String get collectionsEmptyBody;

  /// Retry action for a failed Collections read.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get collectionsRetry;

  /// Collections read message when the session ended.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to see your collections.'**
  String get collectionsSessionEnded;

  /// Collections read message when authentication is required.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to see your collections.'**
  String get collectionsSignInRequired;

  /// Collections are temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Your collections are temporarily unavailable. Try again shortly.'**
  String get collectionsUnavailable;

  /// Collections read failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not load your collections.'**
  String get collectionsLoadTransport;

  /// Fallback copy for a failed Collections read.
  ///
  /// In en, this message translates to:
  /// **'We could not load your collections. Try again.'**
  String get collectionsLoadGeneric;

  /// Badge identifying a locally known system collection.
  ///
  /// In en, this message translates to:
  /// **'system'**
  String get collectionsSystemBadge;

  /// Accessibility label for a collection's saved-item count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 saved item} other{{count} saved items}}'**
  String collectionsSavedItemsCount(int count);

  /// Accessibility label when a collection's count is shown as 99+.
  ///
  /// In en, this message translates to:
  /// **'More than 99 saved items'**
  String get collectionsSavedItemsCountOverflow;

  /// Switching title for the Search destination.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get searchTitle;

  /// Placeholder in the Search input field.
  ///
  /// In en, this message translates to:
  /// **'Search saved items and collections'**
  String get searchPlaceholder;

  /// Initial Search prompt before any query is submitted.
  ///
  /// In en, this message translates to:
  /// **'Find something you saved'**
  String get searchInitialTitle;

  /// Initial Search explanation of what the search matches.
  ///
  /// In en, this message translates to:
  /// **'Search matches item titles, domains, URLs and collection names.'**
  String get searchInitialBody;

  /// Title for a successful search with no results.
  ///
  /// In en, this message translates to:
  /// **'No matches for ‘{query}’'**
  String searchNoMatchesTitle(String query);

  /// Explanation that a different search might still match.
  ///
  /// In en, this message translates to:
  /// **'An item may still match by title, domain, URL or collection name. Try a different word, or browse Collections.'**
  String get searchNoMatchesBody;

  /// Validation message for an empty search query.
  ///
  /// In en, this message translates to:
  /// **'Enter something to search for.'**
  String get searchQueryRequired;

  /// Validation message for a query below the minimum length.
  ///
  /// In en, this message translates to:
  /// **'Search needs at least {min} characters.'**
  String searchQueryTooShort(int min);

  /// Validation message for a query above the maximum length.
  ///
  /// In en, this message translates to:
  /// **'Search is limited to {max} characters. Shorten it and try again.'**
  String searchQueryTooLong(int max);

  /// Accessibility label for the Search loading indicator.
  ///
  /// In en, this message translates to:
  /// **'Searching'**
  String get searchSearchingSemantics;

  /// Title shown when a search request fails.
  ///
  /// In en, this message translates to:
  /// **'Search did not run'**
  String get searchFailureTitle;

  /// Server-side search validation failure copy.
  ///
  /// In en, this message translates to:
  /// **'Search needs between {min} and {max} characters. Check your search and try again.'**
  String searchValidationFailure(int min, int max);

  /// Search failure copy when the session ended.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again to search.'**
  String get searchSessionEnded;

  /// Search failure copy when authentication is required.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to search.'**
  String get searchSignInRequired;

  /// Search rate-limit copy without a retry interval.
  ///
  /// In en, this message translates to:
  /// **'Too many searches. Try again shortly.'**
  String get searchRateLimitedNoWait;

  /// Search rate-limit copy with a retry interval in seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds, plural, =1{Too many searches. Try again in 1 second.} other{Too many searches. Try again in {seconds} seconds.}}'**
  String searchRateLimitedWithWait(int seconds);

  /// Search is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Search is temporarily unavailable. Try again shortly.'**
  String get searchUnavailable;

  /// Search failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not run your search.'**
  String get searchTransport;

  /// Fallback copy for a failed search request.
  ///
  /// In en, this message translates to:
  /// **'We could not run your search. Try again.'**
  String get searchFailureGeneric;

  /// Retry action for a failed search request.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get searchRetry;

  /// Heading for the Collections result group.
  ///
  /// In en, this message translates to:
  /// **'COLLECTIONS'**
  String get searchCollectionsHeading;

  /// Heading for the Saved Items result group.
  ///
  /// In en, this message translates to:
  /// **'SAVED ITEMS'**
  String get searchSavedItemsHeading;

  /// App bar title for the Profile destination.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileTitle;

  /// Action that signs the current account out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// Loading label while the profile is being read.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoading;

  /// Retry action for a failed profile read.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileRetry;

  /// Profile read failure when the session ended.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again.'**
  String get profileSessionEnded;

  /// Profile read failure when authentication is required.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to view your profile.'**
  String get profileSignInRequired;

  /// Profile is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile is temporarily unavailable. Try again shortly.'**
  String get profileUnavailable;

  /// Profile read failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection. We could not load your profile.'**
  String get profileTransport;

  /// Fallback copy for a failed profile read.
  ///
  /// In en, this message translates to:
  /// **'We could not load your profile. Try again.'**
  String get profileLoadGeneric;

  /// Heading for editable account fields.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileAccountSection;

  /// Heading for linked sign-in identities.
  ///
  /// In en, this message translates to:
  /// **'LINKED IDENTITIES'**
  String get profileLinkedIdentitiesSection;

  /// Label for the display name account row and edit field.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profileDisplayNameLabel;

  /// Action that opens the change-password form.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePasswordAction;

  /// Action that opens the create-password form.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get profileCreatePasswordAction;

  /// Empty state when the profile has no linked identities.
  ///
  /// In en, this message translates to:
  /// **'No accounts connected yet.'**
  String get profileNoAccountsConnected;

  /// Chip copy combining the joined label with a formatted date.
  ///
  /// In en, this message translates to:
  /// **'joined {date}'**
  String profileJoinedDate(String date);

  /// Identity note combining the linked label with a formatted date.
  ///
  /// In en, this message translates to:
  /// **'linked {date}'**
  String profileLinkedDate(String date);

  /// Password screen title while the profile mode is still loading.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get profilePasswordTitle;

  /// Password screen title when changing a password.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get profileChangePasswordTitle;

  /// Password screen title when creating a password.
  ///
  /// In en, this message translates to:
  /// **'CREATE PASSWORD'**
  String get profileCreatePasswordTitle;

  /// Back action or tooltip returning to Profile.
  ///
  /// In en, this message translates to:
  /// **'Back to Profile'**
  String get profileBackToProfile;

  /// Explanation shown in change-password mode.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get profileChangePasswordDescription;

  /// Explanation shown in create-password mode.
  ///
  /// In en, this message translates to:
  /// **'Add a password so you can sign in with your email address.'**
  String get profileCreatePasswordDescription;

  /// Label for the current-password field.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPasswordLabel;

  /// Label for the new-password field.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPasswordLabel;

  /// Label for the new-password confirmation field.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmNewPasswordLabel;

  /// Tooltip that reveals the current password.
  ///
  /// In en, this message translates to:
  /// **'Show current password'**
  String get profileShowCurrentPassword;

  /// Tooltip that hides the current password.
  ///
  /// In en, this message translates to:
  /// **'Hide current password'**
  String get profileHideCurrentPassword;

  /// Tooltip that reveals the new password.
  ///
  /// In en, this message translates to:
  /// **'Show new password'**
  String get profileShowNewPassword;

  /// Tooltip that hides the new password.
  ///
  /// In en, this message translates to:
  /// **'Hide new password'**
  String get profileHideNewPassword;

  /// Tooltip that reveals the password confirmation.
  ///
  /// In en, this message translates to:
  /// **'Show confirmation password'**
  String get profileShowConfirmationPassword;

  /// Tooltip that hides the password confirmation.
  ///
  /// In en, this message translates to:
  /// **'Hide confirmation password'**
  String get profileHideConfirmationPassword;

  /// Validation message for an empty current password.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get profileCurrentPasswordRequired;

  /// Validation message for a password outside the supported length.
  ///
  /// In en, this message translates to:
  /// **'Use between 8 and 128 characters.'**
  String get profilePasswordLength;

  /// Validation message when the password confirmation differs.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match.'**
  String get profilePasswordsDoNotMatch;

  /// Server error when the current password is incorrect.
  ///
  /// In en, this message translates to:
  /// **'That current password is incorrect.'**
  String get profileCurrentPasswordIncorrect;

  /// Server error when another request changed the password first.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed somewhere else. Enter the current password again.'**
  String get profilePasswordChangedElsewhere;

  /// Title of the edit-display-name sheet.
  ///
  /// In en, this message translates to:
  /// **'Edit display name'**
  String get profileEditDisplayNameTitle;

  /// Validation message for a display name outside the supported length.
  ///
  /// In en, this message translates to:
  /// **'Use between 2 and 100 characters.'**
  String get profileDisplayNameValidation;

  /// Cancel action in the display-name sheet.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancelAction;

  /// Save action in the display-name sheet.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveAction;

  /// Tooltip for returning to the signed-out welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Back to welcome'**
  String get authBackToWelcome;

  /// Label for an email address field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Label for a password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Label for a verification PIN field.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get authPinLabel;

  /// Label for a display name field.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get authDisplayNameLabel;

  /// Label for confirming a password during registration.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// Label for a new password field during reset.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// Label for confirming a new password during reset.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPasswordLabel;

  /// Tooltip that reveals a masked password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Tooltip that masks a visible password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Sign-in action label.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Heading on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Stash It'**
  String get authSignInTitle;

  /// Description below the sign-in heading.
  ///
  /// In en, this message translates to:
  /// **'Use the email and password on your Stash It account.'**
  String get authSignInDescription;

  /// Action opening the password-reset flow.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Prompt before the create-account action on sign-in.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccountPrompt;

  /// Create-account action on the welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAnAccount;

  /// Create-account action on registration forms.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// Heading on the registration start screen.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignUpTitle;

  /// Description below the registration heading.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. We will send you a PIN to confirm it.'**
  String get authSignUpDescription;

  /// Action that starts registration and requests a PIN.
  ///
  /// In en, this message translates to:
  /// **'Send PIN'**
  String get authSendPin;

  /// Prompt before the sign-in action on registration.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// Google authentication action label.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Retry action label on authentication screens.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get authRetry;

  /// Try-again action label on authentication screens.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get authTryAgain;

  /// Action returning to the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// Action restarting a registration from the beginning.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get authStartOver;

  /// Action starting a new registration.
  ///
  /// In en, this message translates to:
  /// **'Start a new registration'**
  String get authStartNewRegistration;

  /// Action starting a new password reset.
  ///
  /// In en, this message translates to:
  /// **'Start a new reset'**
  String get authStartNewReset;

  /// Action returning to the email form.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get authUseDifferentEmail;

  /// Continue action label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// Cancel action label on account linking.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get authCancel;

  /// Action confirming an account link.
  ///
  /// In en, this message translates to:
  /// **'Link account'**
  String get authLinkAccount;

  /// Action verifying an entered PIN.
  ///
  /// In en, this message translates to:
  /// **'Verify PIN'**
  String get authVerifyPin;

  /// Action requesting another PIN.
  ///
  /// In en, this message translates to:
  /// **'Resend PIN'**
  String get authResendPin;

  /// Resend action showing the remaining cooldown in seconds.
  ///
  /// In en, this message translates to:
  /// **'Resend PIN in {seconds} s'**
  String authResendPinIn(int seconds);

  /// Busy label while a PIN resend is in progress.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get authSending;

  /// Action starting a password reset and requesting a PIN.
  ///
  /// In en, this message translates to:
  /// **'Send reset PIN'**
  String get authSendResetPin;

  /// Action submitting a new password.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPassword;

  /// Action returning to the password-reset start.
  ///
  /// In en, this message translates to:
  /// **'Back to password reset'**
  String get authBackToPasswordReset;

  /// Confirmation dialog title for replacing a saved password reset.
  ///
  /// In en, this message translates to:
  /// **'Replace saved password reset?'**
  String get authReplaceSavedResetTitle;

  /// Safe action in the saved-reset replacement dialog.
  ///
  /// In en, this message translates to:
  /// **'Keep saved reset'**
  String get authKeepSavedReset;

  /// Destructive action in the saved-reset replacement dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace and verify'**
  String get authReplaceAndVerify;

  /// Action recovering a verified registration with a new PIN.
  ///
  /// In en, this message translates to:
  /// **'Recover this registration'**
  String get authRecoverRegistration;

  /// Headline on the signed-out welcome screen.
  ///
  /// In en, this message translates to:
  /// **'A place for things you find on the internet.'**
  String get authEntryHeadline;

  /// Description on the signed-out welcome screen.
  ///
  /// In en, this message translates to:
  /// **'Save a link from any browser, then find it again here.'**
  String get authEntryDescription;

  /// Heading shown after a PIN is sent.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authCheckYourEmail;

  /// Heading for the PIN entry step.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get authEnterYourPin;

  /// Heading for registration finalization.
  ///
  /// In en, this message translates to:
  /// **'Complete your account'**
  String get authCompleteYourAccount;

  /// Heading when a registration cannot continue.
  ///
  /// In en, this message translates to:
  /// **'Registration unavailable'**
  String get authRegistrationUnavailable;

  /// Heading when a password reset cannot continue.
  ///
  /// In en, this message translates to:
  /// **'Reset unavailable'**
  String get authResetUnavailable;

  /// Heading on the password-reset request screen.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authResetPasswordTitle;

  /// Heading for choosing a new password.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authChooseNewPassword;

  /// Heading for Google account linking.
  ///
  /// In en, this message translates to:
  /// **'Link your Google account'**
  String get authLinkYourGoogleAccount;

  /// Validation message for an empty email field.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get authEnterEmail;

  /// Validation message for a malformed email address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authInvalidEmail;

  /// Validation message for an overlong email address.
  ///
  /// In en, this message translates to:
  /// **'That email address is too long.'**
  String get authEmailTooLong;

  /// Validation message for an empty password field.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get authEnterPassword;

  /// Validation message for a password shorter than eight characters.
  ///
  /// In en, this message translates to:
  /// **'Your password is at least 8 characters.'**
  String get authPasswordMin8;

  /// Validation message for an overlong password.
  ///
  /// In en, this message translates to:
  /// **'That password is too long.'**
  String get authPasswordTooLong;

  /// Validation message for an empty new-password field.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password.'**
  String get authEnterNewPassword;

  /// Validation message requiring eight to 128 characters.
  ///
  /// In en, this message translates to:
  /// **'Use between 8 and 128 characters.'**
  String get authPasswordRange;

  /// Validation message when password confirmation differs.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordsDoNotMatch;

  /// Validation message for an empty display name.
  ///
  /// In en, this message translates to:
  /// **'Enter a display name.'**
  String get authEnterDisplayName;

  /// Validation message for a display name shorter than two characters.
  ///
  /// In en, this message translates to:
  /// **'Display name is at least 2 characters.'**
  String get authDisplayNameMin2;

  /// Validation message for an overlong display name.
  ///
  /// In en, this message translates to:
  /// **'Display name is too long.'**
  String get authDisplayNameTooLong;

  /// Validation message requiring a six-digit PIN.
  ///
  /// In en, this message translates to:
  /// **'Enter a 6-digit PIN.'**
  String get authEnterSixDigitPin;

  /// Guidance after an email validation refusal.
  ///
  /// In en, this message translates to:
  /// **'Check your email address, then try again.'**
  String get authCheckEmailThenTryAgain;

  /// Guidance after a general validation refusal.
  ///
  /// In en, this message translates to:
  /// **'Check your details, then try again.'**
  String get authCheckDetailsThenTryAgain;

  /// Guidance after a display-name validation refusal.
  ///
  /// In en, this message translates to:
  /// **'Check your display name, then try again.'**
  String get authCheckDisplayNameThenTryAgain;

  /// Message on sign-in after a confirmed registration.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please sign in with your new account.'**
  String get authRegistrationSuccessSignIn;

  /// Message on sign-in when registration completion is unconfirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether registration completed. Try signing in; if it fails, start again.'**
  String get authRegistrationUncertainSignIn;

  /// Message on sign-in after a confirmed password reset.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset. Please sign in with your new password.'**
  String get authPasswordResetSuccessSignIn;

  /// Message on sign-in when password-reset completion is unconfirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether the password reset completed. Try signing in with your new password.'**
  String get authPasswordResetUncertainSignIn;

  /// Fallback copy for an unexpected sign-in failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong signing in. Try again.'**
  String get authSignInGenericFailure;

  /// Sign-in refusal for an unknown email or incorrect password.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid email or password.'**
  String get authSignInInvalidCredentials;

  /// Sign-in refusal for invalid credentials.
  ///
  /// In en, this message translates to:
  /// **'Check your email address and password, then try again.'**
  String get authSignInValidation;

  /// Sign-in is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign in is temporarily unavailable. Try again shortly.'**
  String get authSignInUnavailable;

  /// Unconfirmed sign-in because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not confirm this sign-in.'**
  String get authSignInUnconfirmed;

  /// Session renewal outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm your session. Try again.'**
  String get authSessionUnconfirmed;

  /// The sign-in could not be stored securely on this device.
  ///
  /// In en, this message translates to:
  /// **'Your sign-in could not be saved securely. Try again.'**
  String get authSignInStorageFailed;

  /// Authentication rate limit with the server-provided wait in seconds.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} seconds.'**
  String authTooManyAttemptsWithWait(int seconds);

  /// Fallback copy for an unexpected registration-start failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong starting your registration. Try again.'**
  String get authSignUpGenericFailure;

  /// Saved registration does not match the entered email.
  ///
  /// In en, this message translates to:
  /// **'We could not match that registration to this email. Try again with the same address.'**
  String get authRegistrationMismatch;

  /// The registration is already complete; direct the user to sign in.
  ///
  /// In en, this message translates to:
  /// **'This registration was already completed. Sign in instead.'**
  String get authRegistrationAlreadyCompletedSignIn;

  /// Registration recovery could not be started.
  ///
  /// In en, this message translates to:
  /// **'Recovery could not be started. Try again.'**
  String get authRecoveryCouldNotStart;

  /// Fallback copy for an unexpected recovery-start failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong starting recovery. Try again.'**
  String get authRecoveryGenericFailure;

  /// Unconfirmed registration check because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not check that registration. Try again.'**
  String get authRegistrationCheckTransport;

  /// Registration check failed because the reply was unreadable.
  ///
  /// In en, this message translates to:
  /// **'We could not read the server\'s reply, so we could not check that registration. Try again.'**
  String get authRegistrationCheckUnreadable;

  /// Registration check is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'We could not check that registration. Try again shortly.'**
  String get authRegistrationCheckUnavailable;

  /// Fallback copy for a failed registration check.
  ///
  /// In en, this message translates to:
  /// **'We could not check this registration. Try again.'**
  String get authRegistrationCheckGeneric;

  /// Recovery start failed because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not start recovery. Try again.'**
  String get authRecoveryTransport;

  /// Recovery start outcome could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether recovery started. Try again.'**
  String get authRecoveryUnreadable;

  /// Recovery is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Recovery is temporarily unavailable. Try again shortly.'**
  String get authRecoveryUnavailable;

  /// Recovery could not start because of a server fault.
  ///
  /// In en, this message translates to:
  /// **'We could not start recovery. Try again shortly.'**
  String get authRecoveryServerFault;

  /// Confirms a registration PIN was sent to the given email.
  ///
  /// In en, this message translates to:
  /// **'We sent a PIN to {email}. You will need it to finish creating your account.'**
  String authPinSentToEmail(String email);

  /// Heading for a registration that is already verified.
  ///
  /// In en, this message translates to:
  /// **'Verification already complete'**
  String get authVerificationComplete;

  /// Explains that a saved registration code could not be checked.
  ///
  /// In en, this message translates to:
  /// **'We could not check the code saved on this device for {email}. Try again, or recover the registration with a new PIN. Recovering replaces this device\'s saved code.'**
  String authVerifiedSavedCodeUnconfirmed(String email);

  /// Explains that a verified registration has no saved code on this device.
  ///
  /// In en, this message translates to:
  /// **'This email has already been verified, but this device does not have the code needed to finish it. Recover it with a new PIN sent to {email}.'**
  String authVerifiedNoToken(String email);

  /// The email already belongs to a completed account.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email. Sign in instead.'**
  String get authRegistrationAlreadyCompleted;

  /// The registration is already waiting for PIN verification.
  ///
  /// In en, this message translates to:
  /// **'This registration is already waiting for a PIN. Continue with that step.'**
  String get authRegistrationAlreadyPending;

  /// Another registration attempt was already in progress.
  ///
  /// In en, this message translates to:
  /// **'Another sign-up attempt was already in progress. Try again.'**
  String get authRegistrationRetryable;

  /// Registration is in progress with a different Google account.
  ///
  /// In en, this message translates to:
  /// **'A sign-up for this email is already in progress with a different Google account. Try again after it expires.'**
  String get authRegistrationIdentityMismatch;

  /// The registration can no longer continue.
  ///
  /// In en, this message translates to:
  /// **'That registration can no longer continue. Start a new one.'**
  String get authRegistrationRestartRequired;

  /// A PIN was sent recently; wait before requesting another.
  ///
  /// In en, this message translates to:
  /// **'A PIN was sent to this email recently. Try again shortly.'**
  String get authPinRecentlySent;

  /// PIN email delivery could not be confirmed; ask the user to check their inbox.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm the PIN email was sent. Check your inbox before trying again.'**
  String get authPinEmailUnconfirmed;

  /// Short PIN email delivery uncertainty message.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm the PIN email was sent. Check your inbox.'**
  String get authPinEmailUnconfirmedShort;

  /// Registration is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Registration is temporarily unavailable. Try again shortly.'**
  String get authRegistrationUnavailableShort;

  /// A server fault prevented registration from starting.
  ///
  /// In en, this message translates to:
  /// **'The server could not start your registration. Try again shortly.'**
  String get authRegistrationServerFault;

  /// Registration start could not be confirmed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not confirm whether your registration started.'**
  String get authRegistrationStartUnconfirmed;

  /// Registration start and PIN delivery could not be confirmed from an unreadable reply.
  ///
  /// In en, this message translates to:
  /// **'We could not read the server\'s reply, so we cannot confirm whether your registration started or a PIN was sent. Check your inbox before trying again.'**
  String get authRegistrationStartUnreadable;

  /// Fallback copy for a failed registration start.
  ///
  /// In en, this message translates to:
  /// **'We could not start your registration. Try again.'**
  String get authRegistrationStartGeneric;

  /// Terminal heading when registration was already completed.
  ///
  /// In en, this message translates to:
  /// **'Registration already completed'**
  String get authRegistrationAlreadyCompletedTitle;

  /// Terminal body when registration was already completed.
  ///
  /// In en, this message translates to:
  /// **'This registration was already completed. Sign in to continue.'**
  String get authRegistrationAlreadyCompletedBody;

  /// Terminal body when a registration can no longer be completed.
  ///
  /// In en, this message translates to:
  /// **'This registration can no longer be completed. Start a new registration.'**
  String get authRegistrationCannotBeCompletedBody;

  /// Subheading naming the account email during finalization.
  ///
  /// In en, this message translates to:
  /// **'Account for {email}'**
  String authAccountForEmail(String email);

  /// The current registration step is closed; restart with the same email.
  ///
  /// In en, this message translates to:
  /// **'This registration step is no longer open. Start over with the same email to continue.'**
  String get authRegistrationStepClosed;

  /// The registration could not be found.
  ///
  /// In en, this message translates to:
  /// **'We could not find that registration. Start a new one.'**
  String get authRegistrationNotFound;

  /// The registration response could not be read.
  ///
  /// In en, this message translates to:
  /// **'We could not read that registration. Start a new one.'**
  String get authRegistrationUnreadable;

  /// The entered PIN is incorrect.
  ///
  /// In en, this message translates to:
  /// **'That PIN is not correct. Try again.'**
  String get authPinInvalid;

  /// Too many incorrect PINs during registration.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect PINs. Start a new registration.'**
  String get authPinAttemptsExceededRegistration;

  /// Too many incorrect PINs during password reset.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect PINs. Request a new reset.'**
  String get authPinAttemptsExceededReset;

  /// PIN verification is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Verification is temporarily unavailable. Try again shortly.'**
  String get authVerificationUnavailable;

  /// A server fault prevented PIN verification.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your PIN. Try again shortly.'**
  String get authPinVerifyServerFault;

  /// PIN verification could not be confirmed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not confirm your PIN.'**
  String get authPinVerifyTransport;

  /// Fallback copy for a failed PIN verification.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your PIN. Try again.'**
  String get authPinVerifyGeneric;

  /// Fallback copy for an incomplete registration.
  ///
  /// In en, this message translates to:
  /// **'We could not complete your registration. Try again.'**
  String get authRegistrationCompleteGeneric;

  /// Instructions for entering a registration PIN.
  ///
  /// In en, this message translates to:
  /// **'We sent a PIN to your email address. Enter it below to continue.'**
  String get authPinInstructions;

  /// Explains social registration and prompts for a display name.
  ///
  /// In en, this message translates to:
  /// **'Your Google account is verified. Choose the name to show in Stash-it for {email}.'**
  String authSocialVerifiedDescription(String email);

  /// Heading when a social account was already created.
  ///
  /// In en, this message translates to:
  /// **'Account already created'**
  String get authAccountAlreadyCreated;

  /// Terminal body for a completed social registration.
  ///
  /// In en, this message translates to:
  /// **'This social registration was already completed. Continue with Google or sign in to use the account.'**
  String get authSocialAlreadyCompletedBody;

  /// Terminal body for an inactive social registration.
  ///
  /// In en, this message translates to:
  /// **'This social registration can no longer be completed. Start again with Google to create the account.'**
  String get authSocialInactiveBody;

  /// Heading when the account exists but the sign-in was not saved.
  ///
  /// In en, this message translates to:
  /// **'Account created, sign-in not saved'**
  String get authAccountCreatedSignInNotSaved;

  /// Terminal body when the social sign-in could not be stored.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready, but this device could not save the sign-in. Continue with Google or sign in to use it.'**
  String get authSocialStorageFailureBody;

  /// Social registration completion could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether registration completed. Continue with Google or sign in; if the account was not created, try again.'**
  String get authSocialSubmitUnconfirmed;

  /// Heading for an inactive account-link request.
  ///
  /// In en, this message translates to:
  /// **'Link unavailable'**
  String get authLinkInvalidTitle;

  /// Body for an inactive account-link request.
  ///
  /// In en, this message translates to:
  /// **'This account-link request is no longer active. It may have expired or already been used. Start again with Google to sign in.'**
  String get authLinkInvalidBody;

  /// Heading for a mismatched Google account during linking.
  ///
  /// In en, this message translates to:
  /// **'Different Google account'**
  String get authLinkDifferentAccountTitle;

  /// Body for a mismatched Google account during linking.
  ///
  /// In en, this message translates to:
  /// **'The Google account used here does not match the one this link was started with. Start again and choose the account you originally used.'**
  String get authLinkDifferentAccountBody;

  /// Heading for an expired Google sign-in during linking.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in expired'**
  String get authGoogleSignInExpiredTitle;

  /// Body for an expired Google sign-in during linking.
  ///
  /// In en, this message translates to:
  /// **'Google no longer accepts the sign-in used for this link. Start again with Google to continue.'**
  String get authGoogleSignInExpiredBody;

  /// Heading when accounts were linked but sign-in did not finish.
  ///
  /// In en, this message translates to:
  /// **'Accounts linked'**
  String get authAccountsLinkedTitle;

  /// Body when accounts were linked but sign-in did not finish.
  ///
  /// In en, this message translates to:
  /// **'Your Google account is now linked, but signing in did not finish. Continue with Google again to sign in.'**
  String get authAccountsLinkedBody;

  /// Heading when the Google account is already linked.
  ///
  /// In en, this message translates to:
  /// **'Google account already linked'**
  String get authGoogleAlreadyLinkedTitle;

  /// Body when the Google account is already linked.
  ///
  /// In en, this message translates to:
  /// **'This Google account is already linked to a Stash-it account. Continue with Google to sign in.'**
  String get authGoogleAlreadyLinkedBody;

  /// Prompts to link a Google account to an existing account.
  ///
  /// In en, this message translates to:
  /// **'Stash-it found an existing account for this email. Link the Google account you just verified to it?'**
  String get authLinkExistingAccount;

  /// Prompts to link a Google account to an existing account with a masked email.
  ///
  /// In en, this message translates to:
  /// **'Stash-it found an existing account for {email}. Link the Google account you just verified to it?'**
  String authLinkExistingAccountForEmail(String email);

  /// Shows the Google profile name used for the pending link.
  ///
  /// In en, this message translates to:
  /// **'Google profile: {name}'**
  String authGoogleProfile(String name);

  /// Account linking is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Account linking is temporarily unavailable. Try again shortly.'**
  String get authLinkUnavailableShort;

  /// Account-link check failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not check this link.'**
  String get authLinkCheckTransport;

  /// Fallback copy for a failed account-link check.
  ///
  /// In en, this message translates to:
  /// **'We could not check this link. Try again.'**
  String get authLinkCheckGeneric;

  /// Account-link completion could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether the link completed. Continue with Google to sign in; if it was not linked, start again.'**
  String get authLinkOutcomeUnconfirmed;

  /// Fallback copy for a failed account link.
  ///
  /// In en, this message translates to:
  /// **'We could not link this account. Try again.'**
  String get authLinkFailed;

  /// Google sign-in is not configured for this build.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured for this build.'**
  String get authGoogleNotConfigured;

  /// Google sign-in could not start.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not start. Try again.'**
  String get authGoogleCouldNotStart;

  /// Google did not return an ID token.
  ///
  /// In en, this message translates to:
  /// **'Google did not return a sign-in token. Try again.'**
  String get authGoogleMissingToken;

  /// The system browser could not be opened for Google sign-in.
  ///
  /// In en, this message translates to:
  /// **'Could not open your browser for Google sign-in. Try again.'**
  String get authGoogleBrowserFailed;

  /// The browser-based Google sign-in callback timed out.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in timed out. Try again.'**
  String get authGoogleSignInTimeout;

  /// The OAuth callback state did not match the request.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not be verified. Try again.'**
  String get authGoogleStateMismatch;

  /// Google returned an OAuth error instead of an authorization code.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was not completed. Try again.'**
  String get authGoogleCallbackError;

  /// Action shown while the desktop browser sign-in is waiting for its callback.
  ///
  /// In en, this message translates to:
  /// **'Cancel Google sign-in'**
  String get authCancelGoogleSignIn;

  /// The user explicitly cancelled the desktop browser sign-in.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authGoogleSignInCancelled;

  /// The authorization code could not be exchanged for an ID token.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not be completed after the browser returned. Try again.'**
  String get authGoogleTokenExchangeFailed;

  /// Google could not verify the returned token.
  ///
  /// In en, this message translates to:
  /// **'Google could not verify that sign-in. Try again.'**
  String get authGoogleInvalidToken;

  /// A different account already owns the in-progress registration.
  ///
  /// In en, this message translates to:
  /// **'A registration for this email is already in progress under a different account. Try again after it expires.'**
  String get authGoogleRegistrationIdentityMismatch;

  /// Accounts were linked but Google sign-in did not finish.
  ///
  /// In en, this message translates to:
  /// **'Your accounts were linked, but sign-in did not finish. Continue with Google again.'**
  String get authGoogleLinkSessionFailed;

  /// The Google identity does not match the link request.
  ///
  /// In en, this message translates to:
  /// **'That Google account does not match the account being linked.'**
  String get authGoogleLinkIdentityMismatch;

  /// The account-link confirmation is no longer active.
  ///
  /// In en, this message translates to:
  /// **'This account-link request is no longer active. Start again.'**
  String get authGoogleLinkConfirmationInactive;

  /// The account already exists; continue with Google or sign in.
  ///
  /// In en, this message translates to:
  /// **'This account already exists. Continue with Google or sign in.'**
  String get authGoogleAccountExists;

  /// Google sign-in is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is temporarily unavailable. Try again shortly.'**
  String get authGoogleUnavailable;

  /// A server fault prevented Google sign-in from starting.
  ///
  /// In en, this message translates to:
  /// **'We could not start Google sign-in. Try again shortly.'**
  String get authGoogleServerFault;

  /// Google sign-in could not start because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not start Google sign-in.'**
  String get authGoogleTransport;

  /// Google sign-in could not start because the reply was unreadable.
  ///
  /// In en, this message translates to:
  /// **'We could not read the server\'s reply, so we could not start Google sign-in. Try again.'**
  String get authGoogleUnreadable;

  /// Fallback copy for a failed Google sign-in.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in could not be completed. Try again.'**
  String get authGoogleGenericFailure;

  /// Description below the password-reset heading.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. If an account exists, we will send a PIN to confirm it.'**
  String get authResetRequestDescription;

  /// The saved password reset could not be checked.
  ///
  /// In en, this message translates to:
  /// **'We could not check for a saved password reset. You can request a new one.'**
  String get authResetSavedCheckFailure;

  /// The saved password reset was already completed.
  ///
  /// In en, this message translates to:
  /// **'This password reset was already completed. Sign in with your new password, or request a new reset.'**
  String get authResetAlreadyCompletedNotice;

  /// The previous password reset is no longer active.
  ///
  /// In en, this message translates to:
  /// **'Your previous password reset is no longer active. Request a new one.'**
  String get authResetPreviousInactive;

  /// Fallback copy for a failed saved-reset check.
  ///
  /// In en, this message translates to:
  /// **'We could not check your saved password reset. Try again.'**
  String get authResetSavedCheckGeneric;

  /// Offers to continue a saved password reset for an email.
  ///
  /// In en, this message translates to:
  /// **'A saved password reset for {email} is available on this device. Continue it, or use a different email.'**
  String authResetSavedContinueMessage(String email);

  /// A password reset is already in progress.
  ///
  /// In en, this message translates to:
  /// **'A password reset is already in progress. Try again shortly.'**
  String get authResetAlreadyInProgress;

  /// Fallback copy for a failed password-reset start.
  ///
  /// In en, this message translates to:
  /// **'We could not start the password reset. Try again.'**
  String get authResetStartGeneric;

  /// Password reset could not start because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not start the password reset.'**
  String get authResetStartTransport;

  /// Password reset could not start because the reply was unreadable.
  ///
  /// In en, this message translates to:
  /// **'We could not read the server\'s reply, so we could not start the password reset. Try again.'**
  String get authResetStartUnreadable;

  /// A server fault prevented the password reset from starting.
  ///
  /// In en, this message translates to:
  /// **'We could not start the password reset. Try again shortly.'**
  String get authResetStartServerFault;

  /// Password reset is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset is temporarily unavailable. Try again shortly.'**
  String get authResetUnavailableShort;

  /// Saved-reset check failed because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not check your saved password reset. Try again.'**
  String get authResetSavedCheckTransport;

  /// Saved-reset activity could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether your saved password reset is still active. Try again.'**
  String get authResetSavedCheckUnreadable;

  /// Saved-reset check failed because of a server fault.
  ///
  /// In en, this message translates to:
  /// **'We could not check your saved password reset. Try again shortly.'**
  String get authResetSavedCheckServerFault;

  /// Heading when continuing a saved password reset.
  ///
  /// In en, this message translates to:
  /// **'Continue password reset'**
  String get authResetContinueTitle;

  /// States that a password reset is in progress for an email.
  ///
  /// In en, this message translates to:
  /// **'A password reset is in progress for {email}.'**
  String authResetInProgressFor(String email);

  /// Heading when a password reset is already verified.
  ///
  /// In en, this message translates to:
  /// **'Reset already verified'**
  String get authResetAlreadyVerifiedTitle;

  /// Explains that a verified reset cannot issue another PIN on this device.
  ///
  /// In en, this message translates to:
  /// **'This password reset was already verified, but this device does not have a usable saved reset for this email. Requesting another PIN is not possible. The reset expires within 15 minutes; after that you can request a new one.'**
  String get authResetAlreadyVerifiedWaitingBody;

  /// Non-enumerating confirmation that a reset PIN may have been sent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that address, we have sent a password reset PIN.'**
  String get authResetNeutralBody;

  /// Confirms a password-reset PIN was sent to an email.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset PIN to {email}.'**
  String authResetPinSentBody(String email);

  /// Explains that the PIN step is complete and how to continue.
  ///
  /// In en, this message translates to:
  /// **'This reset\'s PIN step is already complete. If this device has the saved reset, continue from the password reset screen. Otherwise wait up to 15 minutes for it to expire and request a new one.'**
  String get authResetAlreadyVerifiedBody;

  /// Heading when a password reset is no longer active.
  ///
  /// In en, this message translates to:
  /// **'Reset no longer active'**
  String get authResetNoLongerActiveTitle;

  /// Body when a password reset is no longer active.
  ///
  /// In en, this message translates to:
  /// **'This password reset is no longer active. Request a new one to continue.'**
  String get authResetNoLongerActiveBody;

  /// Heading when a password reset cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Reset not available'**
  String get authResetNotAvailableTitle;

  /// Body when a password reset cannot be found.
  ///
  /// In en, this message translates to:
  /// **'We could not find that password reset. Check the address or start again.'**
  String get authResetNotAvailableBody;

  /// Heading when a verified reset could not be stored securely.
  ///
  /// In en, this message translates to:
  /// **'Reset verified, but not saved'**
  String get authResetVerifiedNotSavedTitle;

  /// Body when a verified reset could not be stored securely.
  ///
  /// In en, this message translates to:
  /// **'Your PIN was verified, but this device could not save the reset securely. The reset cannot continue here. Request a new one after this reset expires, which takes up to 15 minutes.'**
  String get authResetVerifiedNotSavedBody;

  /// The saved reset could not be checked on this device.
  ///
  /// In en, this message translates to:
  /// **'We could not check the saved reset on this device. Try again.'**
  String get authResetSavedCheckLocalFailure;

  /// Warns that replacing a saved reset may remove it from this device.
  ///
  /// In en, this message translates to:
  /// **'A saved password reset for {savedEmail} is on this device. If this PIN verifies, it may replace it; the saved reset for {savedEmail} may no longer be available on this device. This does not cancel it on the server.'**
  String authResetReplacementUnknownIncoming(String savedEmail);

  /// Warns that verifying a reset for one email replaces another saved reset.
  ///
  /// In en, this message translates to:
  /// **'A saved password reset for {savedEmail} is on this device. If this PIN verifies for {incoming}, it will replace it; the saved reset for {savedEmail} will no longer be available on this device. This does not cancel it on the server.'**
  String authResetReplacementKnownIncoming(String incoming, String savedEmail);

  /// Explains where the reset PIN was sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a PIN to {email}. Enter it below to choose a new password.'**
  String authResetPinSentToEmail(String email);

  /// Explains where a previously issued reset PIN was sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a PIN to {email}. If you already have one, enter it below to choose a new password.'**
  String authResetPinSentToEmailIssued(String email);

  /// Explains that a reset PIN was sent to the account email.
  ///
  /// In en, this message translates to:
  /// **'We sent a PIN to your email address. Enter it below to choose a new password.'**
  String get authResetPinSentGeneric;

  /// Explains that a previously issued reset PIN was sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a PIN to your email address. If you already have one, enter it below to choose a new password.'**
  String get authResetPinSentGenericIssued;

  /// PIN delivery is temporarily unavailable.
  ///
  /// In en, this message translates to:
  /// **'PIN delivery is temporarily unavailable. Try again shortly.'**
  String get authResetResendUnavailable;

  /// A new PIN could not be requested because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not request a new PIN.'**
  String get authResetResendTransport;

  /// Fallback copy for a failed PIN resend.
  ///
  /// In en, this message translates to:
  /// **'We could not request a new PIN. Try again.'**
  String get authResetResendGeneric;

  /// The reset could not be checked because the server was unreachable.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. We could not check this reset. Try again.'**
  String get authResetLoadTransport;

  /// The reset could not be checked because of a server fault.
  ///
  /// In en, this message translates to:
  /// **'We could not check this reset. Try again shortly.'**
  String get authResetLoadServerFault;

  /// Fallback copy for a failed reset check.
  ///
  /// In en, this message translates to:
  /// **'We could not check this reset. Try again.'**
  String get authResetLoadGeneric;

  /// The saved reset could not be read from this device.
  ///
  /// In en, this message translates to:
  /// **'We could not read the saved password reset from this device. Try again.'**
  String get authResetStorageReadFailure;

  /// Heading when the password reset was already completed.
  ///
  /// In en, this message translates to:
  /// **'Password reset completed'**
  String get authResetCompletedTitle;

  /// Body when the password reset was already completed.
  ///
  /// In en, this message translates to:
  /// **'This password reset was already completed. Sign in with your new password.'**
  String get authResetCompletedBody;

  /// Heading when no password reset is in progress.
  ///
  /// In en, this message translates to:
  /// **'No reset in progress'**
  String get authNoResetInProgressTitle;

  /// Body when no password reset is in progress.
  ///
  /// In en, this message translates to:
  /// **'Start a password reset from sign-in to choose a new password.'**
  String get authNoResetInProgressBody;

  /// Prompts for a new password for an email.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for {email}.'**
  String authChooseNewPasswordForEmail(String email);

  /// Prompts to set a password for an email.
  ///
  /// In en, this message translates to:
  /// **'Set a password for {email}.'**
  String authSetPasswordForEmail(String email);

  /// Password reset is capacity-limited with a server-provided wait.
  ///
  /// In en, this message translates to:
  /// **'We can\'t reset your password right now. Try again in {seconds} seconds.'**
  String authResetSubmitRateLimitedWithWait(int seconds);

  /// Password reset is capacity-limited without a server wait.
  ///
  /// In en, this message translates to:
  /// **'We can\'t reset your password right now. Try again shortly.'**
  String get authResetSubmitRateLimitedNoWait;

  /// Password-reset completion could not be confirmed.
  ///
  /// In en, this message translates to:
  /// **'We could not confirm whether the password reset completed. Try signing in with your new password.'**
  String get authResetOutcomeUnconfirmed;

  /// Fallback copy for a failed password reset.
  ///
  /// In en, this message translates to:
  /// **'We could not reset your password. Try again.'**
  String get authResetSubmitGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
