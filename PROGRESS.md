# Stash-it Flutter — Project Progress

> Last updated: 2026-11-10
> Scope: Flutter application (`stash-it-app`).

## Current Status

The app has its core saved-link experience in place, including authentication, collections, search, profile and account settings, Google Sign-In, and Android link sharing for device-local saves.

Recent work includes **manual Inbox note composition** — an optional draft note with a compact preview, a bottom-sheet composer, and an explicit save choice that sends the URL and note in one create request — **Saved Item Detail URL actions, price, and note management** — a compact URL row with Android sharing and desktop copying, string-based price display with a non-interactive caveat, and add/update/delete note flows through the existing feedback system — **Inbox price and note display** — nullable `note`, `price_amount` and `price_currency` fields in the Inbox data flow, compact price formatting, a two-line note preview, and a read-only full-note sheet — and **macOS target support**: a macOS runner and Codemagic build workflow are in place, and the existing Windows browser-based Desktop OAuth implementation is shared by Windows and macOS. Static Flutter verification is complete; macOS build, runtime, Google Sign-In, and Keychain behavior have not been verified on a Mac.

The test suite has also been reduced from roughly 1,600 tests to about 890, focused on security, persistence, data integrity, and critical user flows.

**Current focus:** First Codemagic macOS build, M1 runtime and Google Sign-In verification, macOS secure-storage verification, Windows desktop visual review, manual Inbox enrichment polling verification, localize the remaining theme/language preference warnings, and complete native-speaker/device review.

## Verification

### Saved Item Detail desktop hero width (2026-11-10)

- `dart format lib/features/saved_items/presentation/saved_item_detail_screen.dart` — completed; no formatting changes were needed.
- `flutter analyze` — no issues found.
- `git diff --check` — no whitespace errors.
- No focused non-visual test was directly affected: there is no existing test for the detail hero sizing, and none was added because visual tests are out of scope.
- build_runner and localization generation were not rerun; no annotations or ARB files changed.
- The full test suite was not run. No application launch, emulator, screenshot, golden, widget visual, or manual visual verification was performed.

### Saved Item Detail refinements (2026-11-10)

- `flutter gen-l10n` — completed; the existing 2 Indonesian preference-warning messages still fall back to English.
- `dart format` on the changed Dart files — completed.
- `flutter analyze` — no issues found.
- `flutter test test/features/saved_items/application/note_edit_decision_test.dart test/features/saved_items/application/note_mutation_controller_test.dart test/features/saved_items/presentation/price_label_test.dart` — 26 tests passed.
- `git diff --check` — no whitespace errors.
- No Riverpod, Freezed, Retrofit or JSON annotation changed, so build_runner was not rerun.
- The full test suite was not run. No application launch, emulator, screenshot, golden, widget visual, or manual visual verification was performed.

### Saved Item Detail URL actions, price, and notes (2026-11-09)

- Read the sibling backend's `docs/swagger.yaml` directly for `GET /saved-items/{id}`, `PUT /saved-items/{id}/note`, and `DELETE /saved-items/{id}/note`.
- `flutter pub add share_plus` — added `share_plus: ^13.3.1`; Windows and macOS plugin registrants were regenerated.
- `flutter gen-l10n` — completed; the existing 2 Indonesian preference-warning messages still fall back to English.
- `dart run build_runner build --delete-conflicting-outputs` — the installed build_runner no longer accepts that flag and ignored it; generation completed for the new note DTOs, Retrofit methods, Riverpod controller, and detail response fields. Unrelated provider hash-only changes from the same run were reverted.
- `dart format` on all changed Dart files — completed.
- `flutter analyze` — no issues found.
- `flutter test test/core/error/api_failure_mapper_test.dart test/features/saved_items/data/saved_items_repository_test.dart test/features/saved_items/data/saved_item_detail_mapper_test.dart test/features/saved_items/application/note_edit_decision_test.dart test/features/saved_items/application/note_mutation_controller_test.dart test/features/saved_items/application/saved_item_url_actions_test.dart test/features/saved_items/application/saved_items_controller_test.dart` — 203 tests passed.
- `flutter test test/features/saved_items/application/enrich_saved_item_controller_test.dart test/features/saved_items/application/collection_saved_items_controller_test.dart test/features/saved_items/application/delete_saved_item_controller_test.dart` — 74 tests passed.
- `git diff --check` — no whitespace errors.
- The full test suite was not run. No application launch, emulator, screenshot, golden, widget visual, or manual visual verification was performed; the UI and the native Sharesheet remain for the user to inspect.

### Inbox price and note display (2026-11-09)

- `flutter gen-l10n` — completed; the existing 2 Indonesian preference-warning messages still fall back to English.
- `dart run build_runner build --delete-conflicting-outputs` — the installed build_runner no longer accepts that flag and ignored it; generation completed. `listed_saved_item.freezed.dart` and `listed_saved_item.g.dart` were regenerated. Unrelated provider hash-only changes from the same run were reverted.
- `dart format` on the changed Dart files — completed.
- `flutter analyze` — no issues found.
- `flutter test test/features/saved_items/data/saved_items_repository_test.dart test/features/saved_items/presentation/price_label_test.dart test/features/saved_items/application/saved_items_controller_test.dart` — 104 tests passed, including the new note/price decoding cases, missing-field handling, price formatting, and the existing Inbox controller behaviour.
- No application launch, emulator, screenshot, golden, widget visual, or manual visual verification was performed. The UI remains for the user to inspect.

### Inbox enrichment synchronization (2026-11-06)

- `dart format` on all changed Dart files — completed.
- `flutter analyze` — no issues found.
- `flutter test test/features/saved_items/application/saved_items_controller_test.dart test/features/saved_items/application/save_url_controller_test.dart test/features/saved_items/application/saved_items_enrichment_poller_test.dart` — 91 tests passed, including overlapping head-refresh ordering, retention of a save-triggered refresh when a newer poll fails, head reconciliation, local-update protection, cursor preservation, polling lifecycle, and the confirmed-save flow.
- `git diff --check` — no whitespace errors.
- The full test suite was not run, and no application, emulator, or visual verification was performed. Polling timing and lifecycle behavior on a device remain a manual check.

### macOS target and desktop OAuth sharing (2026-11-05)

- `flutter pub get` — completed; macOS plugins resolved and `macos/Flutter/GeneratedPluginRegistrant.swift` generated. No dependency-version changes.
- `dart format` on changed Dart files — completed.
- `flutter analyze` — no issues found.
- `flutter test test/features/auth/data/desktop_google_auth_service_test.dart test/shared/widgets/desktop_layout_test.dart` — 27 tests passed, including Windows and macOS selection of the desktop browser flow, Android selection of the plugin service, and desktop-layout selection.
- `codemagic.yaml` parsed with the project's `yaml` package — valid; workflow is macOS-only and targets `mac_mini_m1`.
- macOS `Info.plist` and entitlement XML parsed successfully.
- No macOS build, runtime, secure-storage, or Google Sign-In verification was performed: development is on Windows and no Mac is available. These remain manual M1/Codemagic checks.

### Windows browser-based Google Sign-In (2026-11-04)

- `dart format` on all changed Dart files — completed.
- `flutter analyze` — no issues found.
- `flutter test test/features/auth/data/windows_google_auth_service_test.dart` — 17 tests passed (PKCE, authorization URL, callback validation, cancellation, timeout, cleanup, token exchange, platform selection).
- `flutter test test/features/auth/application/google_auth_state_test.dart test/app/router/google_auth_routes_test.dart` — 21 tests passed; existing Google authentication outcomes remain unchanged.
- `flutter build windows --debug --dart-define=API_BASE_URL=http://localhost:8080 --dart-define=GOOGLE_DESKTOP_CLIENT_ID=test-desktop-client` — succeeded.
- The app was not launched and no real Google authentication request was made. End-to-end Windows sign-in is not verified.

### Windows desktop adaptation (2026-11-03)

- `flutter analyze` — no issues found.
- Focused bootstrap, saved-items refresh, and collections refresh tests — 66 tests passed in the combined run; bootstrap was re-run after the final `kIsWeb` guard and 18 tests passed.
- `flutter build windows --debug --dart-define=API_BASE_URL=http://localhost:8080` — succeeded.
- Launch smoke test — window title `Stash-it`, 900×700, no resize frame or maximize box, minimize/system menu present, process responding. Visual layout was not verified.
- `git diff --check` — no whitespace errors.
- The full test suite and an Android build were not run for this task.

### Localization Phase 8

- `flutter gen-l10n` — completed; 2 Indonesian preference-warning messages still fall back to English.
- `dart format` on changed Dart files — completed.
- Targeted Pending URLs and share-intake tests — 118 tests passed.
- App-shell regression — 6 tests passed.
- `flutter analyze` — no issues found.
- Android resource processing — `:app:processDebugResources` succeeded.
- Android Kotlin compilation — `:app:compileDebugKotlin` succeeded.
- `git diff --check` — no whitespace errors.
- The full test suite was not rerun for Phase 8; broader regression testing remains with the project owner.

### Test suite reduction (2026-11-03)

- Removed 57 presentation, trivial model, and duplicate test/support files.
- Approximately 720 test cases removed; about 890 retained.
- Targeted critical suites run in batches — 887 tests passed across authentication/security, saved items, search, collections, profile, settings, pending URLs, app routing/shell, and localization/feedback.
- `dart format --output=none --set-exit-if-changed test` — clean.
- `flutter analyze` — no issues found.
- `git diff --check` — no whitespace errors.
- No single full-suite run was performed; broader regression remains with the project owner.

## Implemented

### Saved links

- Save links to an account, view their details, and open the original links.
- View link metadata and enrichment status, and refresh metadata.
- Move and delete saved links.
- Preview saved-link images, including pending and unavailable states.

### Saved Item Detail price, URL actions, and notes

- The shared Saved Item Detail response now carries nullable `note`, `price_amount` and `price_currency` values through the existing DTO, mapper, repository and presentation provider. The amount remains a string end to end.
- The URL below the title is limited to two lines with ellipsis; the stored URL itself is unchanged. Copy always uses the complete original value.
- Android exposes Share and Copy on the URL row. Windows, macOS and other non-Android targets expose Copy only. Android uses the native system Sharesheet; dismissing it is ordinary cancellation with no notice or automatic copy.
- A share that cannot be opened falls back to copying the same URL. Copy, share-fallback success and copy failure use the app-wide feedback host with localized copy.
- A valid price appears below the URL actions and before the collection/enrichment metadata, reusing `price_label.dart`. Missing, malformed or unsupported pairs hide the section entirely.
- A valid price is followed only by the short, non-interactive localized caveat (“Price may have changed.” / “Harga mungkin sudah berubah.”). The separate Open Original Page action remains in the Actions section.
- The note section shows a two-line preview with a note icon, or a compact “Add a personal note” affordance when none exists. Both open one shared editor bottom sheet with the full existing note prepopulated.
- The editor accepts up to 5,000 characters with a localized counter and one Save action. Save chooses between no request, `PUT /saved-items/{id}/note`, and a confirmed `DELETE /saved-items/{id}/note` when an existing note is cleared.
- A persisted note also exposes a compact destructive Delete icon in the editor header. It uses the same confirmation and mutation as clear-all-and-Save; it is absent when opening a new, empty note. Cancelling the clear-all-and-Save confirmation restores the persisted note into the open editor immediately, including line breaks, and updates the counter without a request or refetch.
- The enrichment-status line wraps in Saved Item Detail without the listing's one-line ellipsis. Detail uses a wrapping metadata row so the collection chip and status can occupy separate lines when needed; the Inbox listing keeps its existing single-line treatment.
- The Detail hero image uses a responsive 16:9 frame. Android keeps the full available content width. Windows and macOS share the existing `usesDesktopLayout` condition, cap the hero at 640 logical pixels (360 high at 16:9), and center it horizontally when the content area is wider. Loading, pending and unavailable placeholders are unchanged, and the listing thumbnail is untouched.
- Note writes submit the entered text unchanged (emptiness is checked with `trim`). Confirmed mutations patch the loaded detail, Inbox and collection rows in place without a follow-up read, and publish success or failure through the existing feedback system. Duplicate submissions are blocked while a request is in flight.

### Inbox price and note display

- The Inbox listing response and presentation model carry nullable `note`, `price_amount` and `price_currency` values. The amount remains a string end to end so decimal precision is preserved.
- A price appears directly below the title and source line only when both fields are present and form a valid, supported pair. IDR amounts render with `Rp` and dot grouping (for example `Rp24.500.000`); USD amounts render with `US$` and comma grouping (for example `US$129.99`). Missing, empty, malformed amounts and unsupported currency codes hide the price section entirely.
- Price formatting is string-based and never converts the amount to `double`.
- A non-empty note renders below the collection/enrichment metadata as a compact two-line preview with a note icon and the localized “Your note” label. The preview uses an ellipsis beyond two lines.
- Tapping the note preview opens a read-only bottom sheet with the complete note, preserving line breaks and scrolling long content. It uses the note already loaded in the Inbox: no request, refresh, detail-screen navigation, or edit/delete control is involved.
- The note preview has its own tap target, so tapping it does not also open the saved-item detail screen.
- The “Your note” label is localized in English and Indonesian. Collection listings, Search and the saved-item detail screen do not populate or display these fields.

### Manual Inbox note composition

- The manual Save URL form offers a compact optional note entry below the URL field. Without a draft it shows “Add a personal note”; with one it shows a two-line “Your note” preview with ellipsis.
- The note opens in a bottom-sheet composer with multiline text, preserved line breaks, a character counter and the documented maximum length. Done applies the local draft without contacting the server; applying empty or whitespace-only text returns the intake to the add affordance.
- A meaningful draft adds an explicit Save URL confirmation with Save with note, Save without note, and Cancel. Saving with the note sends the URL and note together in the single create request; saving without it sends only the URL. Cancel sends nothing and keeps both inputs.
- The draft stays local to the retained Inbox intake and survives switching destinations. A confirmed save clears it so the next save starts without a note; cancellation, refusal and unconfirmed outcomes keep it for correction. It is never persisted or shared with other features.
- Android Quick Share and device-local Pending URL saves are unchanged and never include a note.

### Inbox enrichment synchronization

- While the Inbox is visible and the app is in the foreground, a single coordinated polling loop keeps `pending` items synchronized with the server.
- Only `pending` items created within approximately 60 seconds are eligible; the window is evaluated per item from the server's `created_at` value.
- Polling waits 1.5, 3, 5, 8, and then 10 seconds between requests, capped at 10 seconds, and never starts a request while the previous one is still running.
- A newly appearing pending item restarts the interval progression so the first poll after a save is prompt.
- Leaving the Inbox, switching destinations, opening a covering screen, or backgrounding the app stops the timer. Returning performs one head synchronisation, re-evaluates eligibility, and resumes only when an eligible pending item remains.
- A head refresh now updates existing rows in place, so an item that moves from `pending` to `completed` or `failed`, or whose metadata changes, is reflected without discarding loaded pages or the pagination cursor.
- Newly discovered items are inserted at the head, existing items keep their positions, items absent from the head remain loaded, and tombstones and collection relocation still filter stale replies.
- A confirmed local update made while a head request is in flight is not overwritten by that older reply.
- Overlapping head refreshes are ordered by when they started: once a newer reply has been adopted, a later reply from an earlier request is dropped instead of regressing statuses or moving the cursor backwards. If the newer request fails, the earlier save-triggered reply can still be adopted.
- Polling reads are best effort: a failure keeps the displayed rows, publishes no feedback, and continues on the bounded schedule while eligible items remain.
- The existing Save URL flow is unchanged: a confirmed save still triggers the head refresh without becoming a save failure if the refresh fails.

### Collections

- Browse collections and view their saved links.
- Search collections and saved links.
- Move saved links between collections.
- Delete collections using the supported server options.

### Windows desktop

- Runs in a fixed 900×700 window titled `Stash-it`, with minimize and close available and resize/maximize disabled.
- Inbox and Collections expose a Windows-only manual refresh action with an in-progress spinner and duplicate-request guard; Android pull-to-refresh is unchanged.
- Main content is centered at a compact maximum width, Collections uses an adaptive card grid, bottom sheets are width-constrained, and feedback banners no longer span the full window.
- Bottom navigation remains at the bottom; there is no desktop sidebar.
- Windows reports `Windows PC` as its device name in client metadata.
- Google Sign-In on Windows uses the system default browser with OAuth 2.0 Authorization Code and PKCE (`S256`); Android keeps the existing `google_sign_in` implementation.
- Windows binds a temporary callback server to `127.0.0.1` on an available port, validates the OAuth state, and exchanges the authorization code with the original verifier.
- The Windows flow returns a Google ID token into the existing Google authentication call, so direct sign-in, account linking, and social registration keep their existing handling.
- Windows startup requires `GOOGLE_DESKTOP_CLIENT_ID`; it does not require `GOOGLE_SERVER_CLIENT_ID`. Other supported platforms retain the existing server client validation.
- The Windows target is additive; desktop-only layout and authentication behavior is selected only on native desktop platforms and is not applied on Android.

### macOS desktop

- Adds a macOS Flutter target with application name `Stash-it`, bundle identifier `id.my.thoriqr.stashit`, and a 900×700 initial window.
- The shared desktop browser OAuth implementation is selected on macOS and Windows; Android keeps the existing `google_sign_in` implementation.
- macOS uses the same PKCE, state validation, loopback callback, token exchange, cancellation, timeout, cleanup, and diagnostic behavior as Windows.
- macOS uses `GOOGLE_DESKTOP_CLIENT_ID` and `GOOGLE_DESKTOP_CLIENT_SECRET` (the latter supplied only through build configuration).
- macOS uses the legacy Keychain (`usesDataProtectionKeychain: false`) so the unsigned testing build does not need a Keychain Sharing entitlement or provisioning profile.
- macOS entitlements allow outbound network access and the local OAuth callback server. ATS allows local networking only, without globally disabling transport security.
- The desktop layout, manual refresh actions, constrained sheets, and adaptive collection grid apply to macOS.
- Client metadata reports platform `macos` and device name `macOS`.
- A macOS-only Codemagic workflow builds an unsigned M1 application using `mac_mini_m1` and accepts `API_BASE_URL`, `GOOGLE_DESKTOP_CLIENT_ID`, and `GOOGLE_DESKTOP_CLIENT_SECRET` from a Codemagic environment group.

### Authentication and account

- Email registration, PIN verification, and registration recovery.
- Google Sign-In, account linking, and social registration.
- Password reset and recovery.
- Profile display-name updates and password management.
- Persistent theme and language preferences.

### Save links on this device

- Share links to the app on Android without signing in.
- Keep shared links on the device for seven days.
- Consolidate exact duplicate links.
- Explicitly submit locally saved links to an account.
- Distinguish confirmed saves from outcomes that could not be confirmed.

### Localization

- English and Bahasa Indonesia are supported.
- The initial language follows the device language when supported; otherwise, English is used.
- Users can choose System default, English, or Bahasa Indonesia in Settings.
- An explicit language choice is retained on the device and takes precedence over the device language.
- The selected language is restored before the app is shown.
- An explicit language choice is applied even when it differs from the device locale; System default follows the ordered device locales and falls back to English.
- Shared navigation labels, Settings and Clear tooltips, and generic read-error copy use the active localization.
- Feedback accepts locale-aware messages and resolves them using the active locale when the notice is presented.
- Authentication screens, form validation, typed API-error copy, Google Sign-In outcomes, account linking, social registration, PIN states, and password reset are localized in English and Indonesian.
- Authentication feedback resolves its copy from the active locale while preserving its tone, identity, dismissal, and timer behavior.
- Inbox headings, empty and loading states, retry copy, URL intake actions, saving state, typed load failures, save feedback, and manual-refresh feedback are localized in English and Indonesian.
- Saved Item detail headings, actions, enrichment states, empty and error states, deletion confirmations, collection move and delete sheets, and Saved Items feedback are localized in English and Indonesian.
- Saved-time labels are represented by typed time buckets and converted to localized copy in presentation, with English singular/plural forms and natural Indonesian equivalents.
- Collections headings, localized sort labels, empty and error states, retry copy, system badges, and saved-item count accessibility labels are localized in English and Indonesian; technical sort values remain unchanged.
- Search title, placeholder, initial and zero-result states, validation messages, loading semantics, result-group headings, typed failure copy, and retry are localized in English and Indonesian; queries and server-provided result content remain unchanged.
- Profile headings, account fields, localized identity labels, joined and linked dates, display-name editing, password forms, validation, typed failures, and update feedback are localized in English and Indonesian. Dates use the active locale explicitly, while provider identifiers remain unchanged.
- Pending URLs titles, introductions, empty/loading/error states, kept-time labels, progress, expiry feedback, bulk-save summaries, entry semantics, and share-intake outcomes are localized in English and Indonesian. The headless share path resolves the restored language preference without a widget tree; the native fallback uses Android string resources.

### Test suite

- Tests focus on authentication and session security, saved-item and collection behavior, search request handling, profile updates, pending-URL persistence and share intake, localization mechanisms, preference persistence, routing, and app-shell flows.
- Presentation-only copy and static rendering tests, trivial DTO model tests, and redundant mapper/provider tests were removed.
- Critical error mapping, malformed-data handling, pagination, account isolation, and typed failure behavior remain covered.

## In Progress and Next Steps

- [ ] Trigger the first Codemagic macOS workflow and retrieve the unsigned `Stash-it.app` artifact.
- [ ] Verify macOS startup, desktop layout, backend connectivity over the LAN, Google Sign-In, account linking, and social registration on the M1 Mac.
- [ ] Verify macOS credential persistence and restoration with the legacy Keychain configuration.
- [ ] Verify Windows Google Sign-In end to end against a configured Desktop OAuth client.
- [ ] Confirm the backend accepts the Desktop OAuth client ID as a valid Google ID-token audience.
- [ ] Review the Windows desktop layout and interactions manually.
- [ ] Localize the remaining theme/language preference warnings.
- [ ] Review Indonesian translations with a native speaker, including native share fallback wording.
- [ ] Verify the app on a physical Android device.
- [ ] Run the full test suite once after the test-suite reduction.

## Known Limitations

- macOS support has not been built or run on a Mac. Codemagic build results, runtime behavior, Google Sign-In, and secure storage remain unverified.
- The Codemagic macOS artifact is intentionally unsigned and ad-hoc distribution is not configured. Without an Apple Developer Program membership there is no Developer ID signing, notarization, App Store distribution, or auto-update. macOS may require right-click Open or quarantine removal before first launch.
- macOS uses the legacy Keychain instead of the data-protection Keychain to remain compatible with an unsigned testing build. Enabling Keychain Sharing or the data-protection Keychain would require provisioning.
- macOS backend connectivity requires the Windows PC to be reachable on the LAN and port 8080 to be allowed through the Windows firewall. The app accepts the LAN URL only through `API_BASE_URL`.
- Google Desktop OAuth requires the Desktop client secret for the token exchange. The macOS build receives it through `--dart-define`; it is not committed to the repository.
- Windows and macOS Google Sign-In require a Google OAuth client of type **Desktop app**, supplied as `GOOGLE_DESKTOP_CLIENT_ID`, and have not been verified against Google's live endpoints.
- The resulting Google ID token on Windows and macOS is issued for the Desktop OAuth client. The backend must accept that client ID as an ID-token audience; no backend or API changes were made.
- The Windows desktop UI has not yet been reviewed visually by the project owner.
- Inbox polling only refreshes the newest page. An eligible pending item loaded further down the history keeps polling active but is only updated when it appears in the head response; polling never requests individual pages.
- Polling eligibility compares the server's `created_at` with the device clock. A large clock offset can end the window early or, beyond the 60-second window, mark a newly saved item ineligible; this bound avoids polling indefinitely.
- Enrichment polling runs only while the Inbox is visible and the app is in the foreground. There is no background synchronization while the app is closed or another destination is active.
- Search results are limited by the server.
- Price display in Inbox and Saved Item Detail supports IDR and USD. Other currency codes are hidden rather than shown without a supported format.
- Inbox price and note display was implemented first; Saved Item Detail now shows both and note management. Collection listings and Search still do not display price or note.
- The native Android Sharesheet, its dismissal result, and the clipboard fallback have not been verified on a device. Desktop and other non-Android targets expose Copy only.
- The note editor's 5,000-character limit and counter are enforced in the client; the server rejection path is mapped but has not been exercised against the live backend.
- The dedicated note Delete shortcut and the Keep-note restoration are covered by the pure decision and mutation-controller tests, not by widget tests. Their exact in-sheet behavior remains a manual check.
- The manual Inbox note composer, its two-line preview and the save confirmation have not been visually verified; manual inspection remains with the project owner.
- The refined Windows 16:9 hero image, including the 640 px desktop cap and centering, and the wrapping enrichment status have not been visually verified. macOS shares the same desktop sizing path but has not been run or visually verified either. Manual inspection remains with the project owner.
- Physical-device verification has not yet been completed.
- Android link sharing still needs verification in cases such as the app being closed, the user being signed out, or the device being offline.
- If a local-link submission is interrupted, its outcome may be uncertain. Retrying an operation with an uncertain outcome can create a duplicate.
- A link rejected by the server may remain in the device-local list until it expires or the list is otherwise cleared.
- Some operations started under a previous account may finish after the account changes. User-specific data must remain isolated across account changes.
- Theme and language preference warnings still use fixed English copy.
- 2 Indonesian preference-warning messages still fall back to English.
- The native Android share fallback uses Android device-locale resource resolution. It cannot read the app's persisted language preference without a preference bridge, which was not introduced.
- Skeleton placeholder text is layout-only and excluded from accessibility; it is not localized copy.
- Presentation copy, layout, and localization rendering no longer have dedicated automated tests; UI changes require manual or visual review.
- Authentication screen flows are covered indirectly through application, data, routing, and redirect tests rather than screen-level widget tests.
- DTO-level parsing tests were removed; repository and mapper tests retain the main conversion and malformed-data coverage.

## Project Constraints

- Preserve the existing project structure and separation of responsibilities.
- Keep user-facing messages under app control; do not display raw server error messages.
- Do not report an operation as successful unless its result is confirmed.
- Keep uncertain outcomes distinct from operations known to have been rejected.
- Do not introduce automatic retries or background synchronization unless explicitly planned.
- Preserve pagination behaviour and account-data isolation.
- Device-local saved links must remain available when the user signs out.
- Keep credentials and authentication continuations in secure storage. Ordinary preferences and the local link list do not require secure storage.
- Do not expand an app-only task into backend changes unless explicitly requested.
- Do not modify `AGENTS.md`, decision records, or agent configuration unless explicitly authorized.

## Updating This Document

Keep this file focused on the project's current state, completed work, known limitations, and next steps.

- Describe completed capabilities and user-visible outcomes, not implementation steps.
- Update verification status when new checks are completed; do not imply that older results cover later changes.
- Mark work complete only after implementation and relevant verification are finished.
- Do not resolve open product decisions by assumption.
