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
