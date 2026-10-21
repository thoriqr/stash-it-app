## Move to collection (2026-10-22)

### Flutter implementation
- Added the detail screen's `ACTIONS` section between the detail divider and `ENRICHMENT`: one secondary `AppButton` labelled `Move to a collection`, shown only for loaded detail data. Loading, generic read errors and C3 omit the section; `pending` and `failed` keep it.
- Added the picker as a modal bottom sheet (`showModalBottomSheet`, `isScrollControlled`, safe area): `Currently in <name>` context, the current collection excluded by id and never selectable, every collection returned by `GET /collections` (including system collections; nothing filtered by type, name, or `isUnsorted`), a new-collection field, and one primary action. The primary reads `Move to <stored name>` for a trimmed case-insensitive match against the loaded list, `Already in <name>` (disabled) for the current name, and `Create <trimmed name>` otherwise. `INVALID_COLLECTION_NAME` and `COLLECTION_NAME_RESERVED` stay inline with the sheet and input open; the reserved copy is `That collection name is reserved. Choose a different name.` and names no system collection. While a request is in flight, rows, field, Retry, close/dismiss and the primary are disabled and one compact indicator shows.
- Added `MoveDestinations` as a separate auto-dispose provider over `CollectionsRepository` with `sort=name`; it follows every page, dedupes by id preserving order, keeps every returned collection including system collections, and treats `has_more == true` with a null cursor as unreadable. Opening the sheet never touches `collectionsProvider`, and reopening fetches a fresh snapshot. A failed destinations load still allows create-by-name while disclosing that existing collections could not load and the server decides conflicts.
- Added `PUT /saved-items/{id}/collection` end to end: a name-only Freezed request (never a collection id), Freezed response DTOs for the no-`meta` envelope (`data.collection`, `data.saved_item`, `data.collection_created`, `data.already_in_collection`, `message`) and a mapper to `MoveToCollectionResult`; the response is never decoded as the full detail shape. `SavedItemsRepository.moveToCollection` maps the route's failures.
- Extended the error taxonomy with `ApiFailureNotFound` (verified `RESOURCE_NOT_FOUND` and `SAVED_ITEM_NOT_FOUND`), `ApiFailureValidation` (existing `VALIDATION_ERROR` and the move route's `INVALID_COLLECTION_NAME`) and `ApiFailureCollectionNameReserved` (`COLLECTION_NAME_RESERVED`). No existing mapping changed.
- Added the keep-alive `moveToCollectionProvider` notifier with synchronous duplicate-submission guarding and one PUT per explicit action. Confirmed moves refetch detail, update the Inbox row in place (`SavedItemSummary.copyWithCollection` / `SavedItems.applyCollection`, never `refreshHead`) and fall back to the PUT collection when that read fails; `already_in_collection` is a no-op that publishes `Already in <name>.`, and only a confirmed non-already move invalidates `collectionsProvider`. Transport, `5xx`, unavailable and unreadable-200 outcomes are unconfirmed: they refetch detail, publish `We couldn't confirm the move. Check the item's collection.`, and are never replayed. `SAVED_ITEM_NOT_FOUND` invalidates detail to C3 and publishes `This item is no longer available.` Feedback copy uses the stored name: `Moved to ...` / `Created ... and moved the item.`
- Added the name-shape rule in `features/collections/domain/collection_name.dart`: trimming, blank rejection, 100-rune maximum and case-insensitive comparison for the label. Uniqueness stays backend-owned; no new dependency, API client, repository or endpoint was added, and `collections` does not import `saved_items`.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` completed for the new Freezed, Retrofit and Riverpod sources.
- `dart format` applied to the changed Dart files.
- `flutter analyze`: no issues found.
- Focused move destinations, picker sheet, detail screen and mutation controller tests: 54 passed.
- `flutter test`: 686 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- The sheet's copy (`Move to a collection`, `Currently in ...`, helper text, inline errors) is hardcoded English; the app still has no l10n layer.
- An unconfirmed move is reconciled once by reading the item; there is no automatic replay, consistent with D23/D24.
- Collection counts refresh only after the post-move detail read settles, because the confirmed-move reconciliation runs unawaited behind the sheet's immediate close.
- No on-device keyboard, drag, or back-gesture check of the sheet was performed.

## Saved item detail (2026-10-22)

### Flutter implementation
- Added `GET /saved-items/{id}` end to end: Freezed `GetSavedItemResponse` with the item and its collection as **siblings** (no `meta`), `savedItemDetailFrom` reusing `SavedItemSummary` and the existing enrichment/time-label helpers, and `SavedItemsRepository.getById`. The twelve documented fields are decoded; the six nullable ones stay null.
- Added `/saved-items/:id` as a top-level route outside `StatefulShellRoute`. It is not a fifth destination: Inbox rows `context.push` it, returning pops to the Inbox with its scroll position and pages intact, and a direct entry gets a `Back to Inbox` fallback. The existing auth redirect protects the route (covered against the production router).
- Added an auto-dispose `savedItemDetailProvider(id)` with `retry: _neverRetry`, so a failed read is not retried automatically. The screen's explicit Retry invalidates the provider and issues exactly one fresh GET.
- Added the detail screen with the wireframe's C1, C2 and C3 states: full metadata; `pending`/`failed` with the item kept visible; and a neutral not-found state with no Retry. A completed item with no metadata says `No details on this page`, not an error. Loading shows the real layout under `Skeletonizer`; every other failure gets feature copy and Retry.
- Added `ApiErrorCode.resourceNotFound` and `ApiFailureNotFound`, mapped initially from the verified `RESOURCE_NOT_FOUND`; the move endpoint's `SAVED_ITEM_NOT_FOUND` now also maps to it (see the section above). An unreadable or uncoded 404 remains `ApiFailureUnreadableResponse`, and the two screens are distinct.
- The one enrichment control is deliberately inert: `onPressed: null`, label `Re-read page`, caption `Not available in this version.` Opening the detail never enriches, extracts, polls, refreshes in the background, moves, deletes, or loads a remote image.
- Extracted `SavedItemPreview`, `SavedItemCollectionChip` and `SavedItemEnrichmentState` from `SavedItemRow` so the row and detail share one preview, chip and status treatment; the row's rendering and behaviour are unchanged. Search rows remain non-interactive.

### Verification
- `dart run build_runner build --delete-conflicting-outputs`: completed; wrote 25 outputs (this build_runner reported the flag as ignored).
- `dart format` applied to the changed Dart files.
- `flutter analyze`: no issues found.
- Focused saved-items data tests: 50 passed. Detail provider: 7 passed. Detail screen and navigation: 24 passed. Auth redirect: 6 passed.
- `flutter test`: 624 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- Detail copy, including `Re-read page` and `Not available in this version.`, is English-only; the app still has no l10n layer.
- Enrichment is intentionally unavailable in this iteration. The control is visual only and issues no request; no enrich endpoint is wired.
- Delete, Open original page, and remote `image_url` loading are deliberately excluded. Move to collection is now implemented; see the section above. `url_launcher` was not added.
- A non-UUID or otherwise rejected id answers `BAD_REQUEST`, which the screen reports as a retryable generic error, not as not-found. The route is normally reached with server-issued UUIDs.
- The not-found copy names both possibilities (deleted or another account) because the backend deliberately returns the same `RESOURCE_NOT_FOUND` for both.
- The detail always reads fresh: there is no warm-start cache or Inbox prefetch, so revisiting an item costs another GET.

## Settings and theme preference (2026-10-22)

### Flutter implementation
- Added `/settings` as a top-level route outside `StatefulShellRoute`. It is not a fifth navigation destination: all four destinations expose one top-right gear action through the shared `DestinationAppBar`, which uses `context.push` so returning restores the same tab and retained branch state. The existing auth redirect protects `/settings`; a direct entry gets a `Back to Inbox` fallback, while a pushed entry keeps the ordinary back affordance.
- Added `lib/features/settings/`: a `SETTINGS` app bar, an `APPEARANCE` group with mutually exclusive Light/Dark/System choices (`RadioGroup<ThemeMode>` plus `RadioListTile`), and a disabled Language row showing `Coming soon` with no chevron, selector or `onTap`. The screen uses existing themes and `AppTokens` only.
- Added `shared_preferences: ^2.5.6` for this non-sensitive preference; the token pair remains in `SecureCredentialStore`. The key is `stash_it.settings.theme_mode`, the stored values are stable words (`light`, `dark`, `system`), and a missing or malformed value falls back to System.
- `bootstrap` reads the preference before `runApp` and supplies the store and restored mode as overrides, so a saved choice is present on the first frame and a fresh install starts on System. `StashItApp` watches the keep-alive controller and updates `MaterialApp.router.themeMode` immediately without recreating the router or resetting navigation.
- Selecting a theme applies it even if persistence fails; that case publishes the warning `Theme changed, but the preference could not be saved.` rather than reporting a saved preference.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` completed; this build_runner version reported the flag as ignored. Generated `theme_mode_controller.g.dart`.
- `dart format` applied to the changed Dart files.
- `flutter analyze`: no issues found.
- `flutter test`: 564 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- Light-mode visual verification on a device is outstanding; the Settings layout and theme switching are covered by widget tests, not by a rendered on-device check. This follows the repository execution policy.
- Theme persistence is covered with `shared_preferences`' in-memory test store; no on-device restart check was performed.
- Settings copy and the Language placeholder are still hardcoded English. Language switching is not implemented or available.

## Sign-in field fixes (2026-10-22)

### Flutter implementation
- `AppField` now clears its own validation message as soon as that field is edited (`FormFieldState.clearError` via an internal `GlobalKey`). Editing Email does not touch Password's message, and validation still runs only on form submission with every existing rule and message unchanged.
- `AppField` gained an optional `suffixIcon` (mutually exclusive with `onClear`). Sign-in uses it for an inline eye/eye-off `IconButton` with `Show password` / `Hide password` tooltips. The password stays obscured by default; the toggle does not submit, validate, or remove focus, and is disabled while the form is submitting.
- **Cause of the green rectangle:** the focused-field halo was a spread `BoxShadow` on a `Container` wrapping the whole `TextFormField`. `InputDecorator` reserves the error message inside that box, so the shadow's fill extended behind the error text; only the focused Email field showed it. The halo now paints from a private focused `InputBorder` (`_AppFieldBorder`), whose rectangle is the input box alone. There is no accent halo on `focusedErrorBorder`; email and password errors share the same 2 px danger border and danger message.

### Verification
- `dart format` applied to the changed Dart files.
- `flutter analyze`: no issues found.
- Focused `flutter test` of `sign_in_screen_test.dart` and `app_field_test.dart`: 27 tests passed.
- `flutter test`: 542 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- `Show password` / `Hide password` are hardcoded English; the app still has no l10n layer.
- The eye/eye-off glyphs are Material icons, matching the existing Material `Icons.search` / `Icons.close` usage.

## Inline clear controls (2026-10-21)

### Flutter implementation
- `AppField` gained an optional `onClear` action. When supplied it renders an 18 px Material `Icons.close` suffix button with a 48 px tap target inside the field; when omitted every existing field is unchanged, including its 48 px height.
- Inbox: the URL field shows the `X` only for non-whitespace text, and hides it while a save is in flight. `_clear` only empties the controller and rebuilds, so it never calls the save controller, sends a POST, or publishes feedback; the hint and Save URL state follow from the existing build.
- Search: the separate `Clear` button is gone. The same inline `X` appears for any non-empty query and calls the existing `_clear`, which resets the submitted query/results and invalidates an in-flight request through `Search.clear()`. No request is sent for an empty query; keyboard submission, 2–128 validation, loading/error states and request-version guards are unchanged.

### Verification
- `dart format` applied to the six changed Dart files.
- `flutter analyze`: no issues found.
- Focused `flutter test` of `app_field_test.dart`, `search_screen_test.dart`, and `inbox_screen_test.dart`: 63 tests passed.
- `flutter test`: 538 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- The clear button's tooltip is the hardcoded English `Clear`; the app still has no localization layer.
- The icon is Material's `Icons.close`, matching the existing Material `Icons.search` prefix; the design system's custom icon family does not define a clear glyph.
- The Search design exploration still shows the former separate `Clear` button; the implementation now follows the requested inline pattern.

## Inbox paste URL (2026-10-21)

### Flutter implementation
- `InboxIntake` Paste now reads `Clipboard.getData(Clipboard.kTextPlain)` from Flutter's built-in `package:flutter/services.dart`. No clipboard package, native code, or `pubspec` change was needed; `AGENTS.md` §4's "clipboard not in pubspec" note is incorrect and was left untouched because that file requires explicit authorization.
- Non-empty clipboard text replaces the field's contents and places the caret at the end. `setState` updates the hint and Save URL's enabled state immediately. Null, empty, whitespace-only, non-text, and failed reads leave the field unchanged and publish no feedback.
- Paste never validates, submits, calls `SaveUrl`, or publishes feedback. Invalid and unrelated text is placed as-is; the existing local gate in `SaveUrl.submit` still rejects it only when Save URL is pressed. Q13 remains open: no paste-time validation and no clipboard-failure/empty-state copy was added.
- Paste is disabled while a save is in flight, matching the design exploration's Saving state.
- `_save` now captures the submitted value and clears the field only if it still holds that value, so text entered while the POST is in flight is preserved.

### Verification
- `dart format` applied to the three changed Dart files.
- `flutter analyze`: no issues found.
- `flutter test test/features/inbox/presentation/inbox_screen_test.dart`: 39 tests passed.
- `flutter test`: 536 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- Paste replaces the field's contents; there is no confirmation or undo for overwriting an existing value.
- Empty-clipboard and clipboard-read-failure behavior is silent by design (Q13 / `ux-discovery.md` §5); no copy exists for those states.
- Clipboard coverage is widget-level through the `SystemChannels.platform` mock; no on-device iOS/Android clipboard check was performed.

## Search integration (2026-10-21)

### Verified backend contract (stash-it-backend)
- Route: `GET /search`, authenticated, behind the per-user limiter (`search-user`, 30/min). The only parameter is `q`; there is no limit, cursor, page or sort.
- Success: `{"data": {"saved_items": [...], "collections": [...]}, "message": "..."}`; no `meta`. Both arrays are always present, and an empty result is a successful `200`.
- Saved item: `id`, nullable `title`, `url`, nullable `domain`, nullable `image_url`, `enrichment_status`, nested `collection {id, name}`, `created_at`. No description, platform, image dimensions, counts or score.
- Collection: `id` and `name` only. The service returns at most 20 saved items (default) and 5 collections; there is no truncation flag, so the client cannot state that more results exist.
- Errors: `INVALID_SEARCH_QUERY` (400), the three 401s, `USER_RATE_LIMIT_EXCEEDED` (429 with `Retry-After`), `USER_RATE_LIMIT_UNAVAILABLE` (503), `INTERNAL_SERVER_ERROR`.

### Flutter implementation
- Added `lib/features/search/`: data (`SearchApi` over `appDio`, Freezed `SearchResponse` DTOs, `search_mapper.dart`, `SearchRepository`, providers), domain (`SearchCollection`, `SearchResults`, `search_query.dart`), application (`SearchState` Freezed union, `Search` notifier), presentation (`SearchScreen`, `SearchCollectionRow`).
- Search has its own minimal DTOs. It neither reuses `ListedSavedItemResponse`/`CollectionSummary` nor declares a field the endpoint does not return; collection results carry only `id` and `name`, and nullable saved-item metadata stays explicit.
- `Search` performs no request in `build`. Only the keyboard Search action submits; typing never does. The query is trimmed and checked against 2-128 Unicode runes locally before the request, and the controller repeats the guard.
- `Clear` appears whenever the input is non-empty. It resets the screen, clears the field and advances the request version, so a late answer cannot repopulate a cleared screen. A request version also discards superseded answers when a newer submission wins.
- Results render Collections first, then Saved Items, each in the server's order. An empty group is omitted; both empty shows the query-specific zero state. Initial, loading, results, zero and failure are distinct. Loading is a compact `CircularProgressIndicator`, not Skeletonizer.
- Reused `SavedItemRow` with `onTap` and `onRetry` null: results have no per-item action, chevron, mutation or navigation. Search maps only fields the response actually carries; description stays null, while the item id and the nested collection id are preserved.
- Added `INVALID_SEARCH_QUERY` to `ApiErrorCode` and mapped it to `ApiFailureValidation`; Search gives it query-specific validation copy. Backend `message` is never displayed. Automatic Riverpod retries are disabled for Search, and a failed request is retried only by the explicit Retry action, which resubmits the failed query once.
- Shared additions: optional `prefixIcon` and `errorText` on `AppField` (existing fields unchanged); `enrichmentStatusFrom` and `savedTimeLabelFrom` extracted to `saved_item_display_mapper.dart`, with the Inbox mapper delegating to them unchanged; `SavedItemSummary` now carries the nested `collectionId`, set by both mappers and never rendered.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` completed (the flag is ignored by this build_runner version).
- `dart format` applied to all changed Dart files.
- `flutter analyze`: no issues found.
- Focused Search, saved-items, Inbox and error-mapper tests: 289 passed.
- `flutter test`: 529 tests passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- Search copy is English-only; the app still has no l10n layer.
- Results are capped at 20 saved items and 5 collections by the backend, and the response carries no truncation metadata. The client therefore shows no cap note rather than asserting that more results exist.
- Search rows and collection rows are non-interactive because no collection-contents or saved-item detail destination routes exist yet.
- The per-user Search budget is 30 requests per minute; the screen does not pre-empt the limit, and a 429 is shown as a rate-limit failure with the server's `Retry-After`.

## Profile refinement (2026-10-21)

### Flutter implementation
- Rebuilt `lib/features/profile/presentation/profile_screen.dart` against `docs/design-explorations/profile.html`: a full-bleed identity band (name, mono email, joined-date chip), ruled section labels, hairline account and identity rows, a compact empty-identities state, and a full-width secondary Sign out.
- Display name gets a right-aligned row. The password row labels itself `Change password` or `Create password` from `has_password_credential` and carries the reference chevron. No password route, API, or flow exists: the row is a non-interactive visual placeholder with a TODO.
- Sign out still calls `authStateProvider.notifier.signOut()`; no auth, session, or credential-cleanup behaviour changed.
- Loading is a compact header spinner plus `Loading profile…` (not Skeletonizer); failure shows one safe message with Retry wired to `Profile.retry()`. Sign out stays available in both states, and the account/identity sections are hidden rather than filled with fabricated data.

### Dates
- Added `intl: ^0.20.3` via `flutter pub add intl` (promoted from a transitive dependency).
- `lib/features/profile/presentation/profile_date.dart` converts both profile timestamps to the device's local timezone and formats them with `DateFormat('dd MMM yyyy')` (for example `07 Oct 2026`).
- `UserProfile.createdAt` and `UserIdentity.linkedAt` are nullable. `profile_mapper.dart` uses `DateTime.tryParse` with no `DateTime.now()` fallback, so an unparseable timestamp is omitted instead of fabricated.
- Identity rows show `linked dd MMM yyyy`; when no valid date exists, a snapshot email or name is shown only when it differs from the account value.

### Verification
- `dart format` applied to all changed Dart files.
- `flutter analyze`: no issues found.
- `flutter test test/features/profile`: 16 tests passed (mapper, date helper, Profile screen).
- `flutter test`: 461 tests passed.
- No device or emulator run was performed.

### Remaining limitations
- Password creation/change remains unimplemented by design; the row is a placeholder.
- The new Profile copy is not localized. The app still has no l10n layer (existing gap, not introduced here).

## Collections list integration (2026-10-21)

### Verified backend contract (stash-it-backend)
- Route: CollectionRoutes registers GET / on /collections group (mounted at /collections) -> handler.ListCollections (internal/api/collection/routes.go, handler.go). Auth required per route.
- Response envelope: {"data": {"collections": [...]}, "message": "...", "meta": {"cursor": {"next_cursor": null|string, "has_more": bool}}} with meta.cursor always present; next_cursor explicitly null on final/empty page.
- ListedCollection fields (response.go ListedCollectionResponse): id, name, type, system_key (*string) for Unsorted identification by system_key=="unsorted" (D2, never by display name); saved_items_count (int64, never null) - whole collection count identical on every page (0-99 exact; 99 with overflow true means "99 or more"); saved_items_count_overflow (bool); created_at, updated_at.
- Ordering: server-provided order; Unsorted pinned first under every sort (sort defaults "newest", supports "newest"/"oldest"/"name"). Cursor pagination (opaque). limit defaults 20, capped 50. No total count. INVALID_CURSOR if token invalid/wrong sort/version.
- Errors: INVALID_COLLECTION_SORT, INVALID_CURSOR, VALIDATION_ERROR (limit), INVALID_AUTHORIZATION_HEADER, INVALID_ACCESS_TOKEN, ACCESS_TOKEN_EXPIRED, INTERNAL_SERVER_ERROR.

### Flutter implementation
- Feature structure under lib/features/collections/ mirroring SavedItems: data (datasources/collections_api.dart @RestApi over appDio, models/listed_collection.dart Freezed DTOs, collections_mapper.dart, collections_repository.dart, collections_providers.dart), domain (collection_summary.dart with displayCount returning "99+" if overflow else number, collection_page.dart), application (collections_state.dart Freezed with sort, collections_controller.dart @Riverpod keepAlive retry:_neverRetry with sort state, cursor pagination/load-more/dedup), presentation (collections_screen.dart replacing placeholder with dropdown sort selector, grid list with refresh, empty, error-with-retry, pagination), widgets (collection_tile.dart with count badge, Unsorted marked by system_key with accent border and "system" tag, collection_skeleton.dart).
- Sorting: Added dropdown in Collections screen (Newest/Oldest/Name) sending exact API values (newest/oldest/name), default newest. Changing sort calls controller.setSort() which increments list version, sets loading state, refetches first page with new sort (no cursor reuse), and guards against stale responses. loadMore/refresh use current sort. Cursor reset on sort change.
- Counts: displayed per entry from backend whole-collection count; overflow true -> "99+". No local counting.
- Ordering/Unsorted: server order preserved; identified by system_key only, no hardcoded ID.
- States: loading skeleton, populated grid, empty, error-with-retry (typed ApiFailure), pagination indicator.
- Tests/generation: dart run build_runner build completed. dart format applied. flutter analyze clean. flutter test all passed (436 tests). SavedItems tests still pass.

### Notes
- Product decisions had older note against showing counts; implemented per task instruction to display counts with overflow as 99+. Discrepancy noted here without editing decision history.

### Remaining limitations
- Collection detail screen and mutations not implemented.
- Sort UI added; no additional sort controls.
