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
  String get savedJustNow;

  /// Saved-time label for an item saved less than an hour ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 min ago} other{Saved {count} min ago}}'**
  String savedMinutesAgo(int count);

  /// Saved-time label for an item saved less than a day ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 hour ago} other{Saved {count} hours ago}}'**
  String savedHoursAgo(int count);

  /// Saved-time label for an item saved between 24 and 48 hours ago.
  ///
  /// In en, this message translates to:
  /// **'Saved yesterday'**
  String get savedYesterday;

  /// Saved-time label for an item saved two or more days ago.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 day ago} other{Saved {count} days ago}}'**
  String savedDaysAgo(int count);

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
