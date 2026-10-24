## Profile display name and password (2026-10-25)

### Verified backend contract (stash-it-backend)
- `PATCH /users/me` takes exactly `{display_name}`: 2–100 Unicode code points, stored verbatim (no trim, no case-fold). Success is `200` with the **complete** profile, the same shape `GET /users/me` returns. Errors: `VALIDATION_ERROR` 400, `USER_NOT_FOUND` 404, the three 401s, `INTERNAL_SERVER_ERROR` 500. A `500` can arrive **after** the rename committed, because identities are read after the user update.
- `PUT /users/me/password` takes `{new_password, current_password?}`. `new_password` is 8–128 code points; every composition rule stays server-side. An absent key selects create, a present one selects change, and the server treats an empty string as omitted. Success is `200` with `data: null`. Errors: `CURRENT_PASSWORD_INVALID` 401 (handler, not the bearer guard), `CURRENT_PASSWORD_REQUIRED` 400, `UNEXPECTED_CURRENT_PASSWORD` 400, `PASSWORD_CREDENTIAL_ALREADY_EXISTS` 409, `PASSWORD_ALREADY_CHANGED` 409, `USER_NOT_FOUND` 404, `PASSWORD_WORK_UNAVAILABLE` 503 with `Retry-After`, the three 401s, `INTERNAL_SERVER_ERROR`.
- Change revokes every other session and keeps the caller's; already-issued access tokens stay usable until their own ~15-minute expiry. Create revokes nothing.
- `PASSWORD_CREDENTIAL_NOT_FOUND` is consumed internally to select the create branch and is **not** a reachable HTTP response, so no branch was added for it.

### Flutter implementation
- Added the six verified codes to `ApiErrorCode` with typed `ApiFailure` variants and mapper arms. `ApiFailureUserNotFound` is deliberately separate from `ApiFailureNotFound`: it names the authenticated account, not the resource on screen. Every exhaustive switch in profile, saved-items and auth gained the new arms.
- Added `UpdateDisplayNameRequest`, `SetPasswordRequest` (`includeIfNull: false`, so create sends **no** `current_password` key), `SetPasswordResponse` and `UpdateUserResponse`; Retrofit `PATCH /users/me` and `PUT /users/me/password`; repository methods mapping `DioException` / `TypeError` / `FormatException` the same way as every other write.
- `Profile` gained narrow `applyUpdatedProfile`, `markPasswordCredentialSet` and `reconcile`, plus `UserProfile.withPasswordCredential` — no general `copyWith`. A rename replaces the loaded profile only when one exists and the returned id matches; otherwise the provider is invalidated and refetched. Confirmed password success sets the flag; nothing is optimistic.
- Display name is a modal bottom sheet: title `Edit display name`, one prefilled `AppField` carrying the **raw untrimmed** stored value, `Save` / `Cancel`, 2–100 `runes.length` locally, keyboard insets and `PopScope(canPop: !busy)`. `VALIDATION_ERROR` shows against the field. A known refusal keeps the sheet and the typed name in a tone-coded notice band. A `500`, transport failure or unreadable body is treated as **ambiguous**: the sheet closes, the profile is refetched, and the copy says the outcome could not be confirmed.
- Password is a dedicated top-level route `/profile/password`, outside the shell. The screen captures create/change once from the loaded profile and never re-derives it; a loading or failed profile shows a loading state or Retry and never defaults to create. Create shows `New password` / `Confirm new password`; change adds `Current password`. Current is required and non-empty only; new is 8–128 runes; confirmation is client-only and exact. No trimming, no composition rules. `AutofillHints.password` only on current and `newPassword` only on new; visibility toggles carry accessible tooltips.
- `CURRENT_PASSWORD_INVALID` is inline on the current field and leaves the credential flag alone; it is a 401 from the handler, so the auth interceptor does not refresh (covered by a regression test). `PASSWORD_ALREADY_CHANGED` keeps the form open and clears the stale current password. `PASSWORD_CREDENTIAL_ALREADY_EXISTS`, `CURRENT_PASSWORD_REQUIRED` and `UNEXPECTED_CURRENT_PASSWORD` close the screen, refetch and explain what changed. Password rate limits and `PASSWORD_WORK_UNAVAILABLE` use capacity-neutral copy with only the server's `Retry-After`; failures are never described as excessive attempts. No automatic retries and no automatic sign-out after success.
- Change mode states that other sessions are revoked but already-issued access tokens may remain usable for about 15 minutes; create mode omits that note entirely.
- Profile rows are now interactive with 48 px minimum targets, `InkWell` and a chevron; the password TODO placeholder is gone. The rename row pre-fills the raw stored value, not the trimmed display form.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` completed (the flag is reported as removed and ignored).
- `dart format` on every changed Dart file; `flutter analyze` — no issues found.
- Focused suites passed: profile application/data/domain/presentation, `api_failure_mapper_test.dart` and `auth_interceptor_test.dart` — 138 tests.
- `flutter test` — 1045 passed.
- No app, device, or emulator run. Nothing staged or committed.

### Remaining limitations
- All new copy is hardcoded English; the app still has no l10n layer.
- **Pre-existing, unchanged:** `profileProvider` is keep-alive and `signOut` does not invalidate it, so a later sign-in can briefly read the previous account's profile from cache. This now matters more because the password screen's mode comes from that profile. Fixing it is a separate change to the sign-out path.
- A successful rename applies the profile the `PATCH` returned, including its linked-identity snapshots, and never rewrites those snapshots locally. If the backend leaves a snapshot stale, the client shows it as returned rather than assuming a rename propagated into another provider.
- The password screen does not offer a password-reset link; the backend has no reset route, so none was invented.

## Open a saved item's original URL (2026-10-24)

### Not a backend contract
- Opening the original page is a **platform action, not an API call** (`ux-discovery.md` C.3). There is no endpoint, no server-side validation and no `HEAD`/`GET` availability probe. The stored `url` is handed to the OS as it was saved — never `image_url`, never a metadata-derived value, never resolved against a base.

### Flutter implementation
- Added `url_launcher: ^6.3.2` (resolved 6.3.3, plus its seven platform packages). It is the only dependency change; no existing package version moved.
- `lib/features/saved_items/application/open_saved_item_url.dart`: `SavedItemUrlLauncher` is a concrete class with one `launch(Uri)`, overridable through `savedItemUrlLauncherProvider` — the same seam the repository fakes use, so no test opens a browser or touches a platform channel.
- `LaunchMode.externalApplication`, **not** `platformDefault`: on Android the package's default opens `http(s)` in-app through a Custom Tab, which is not a handoff to the user's browser. No WebView.
- `launchableSavedItemUrl` reuses `isSubmittableUrl` from `domain/saved_item_url.dart` rather than restating the rules, so the launch gate and the intake gate cannot drift. No `canLaunchUrl`: it needs a `<queries>` entry on Android 11+ and is a preliminary check.
- Three outcomes, two notices, **no success message**. A value the client refuses → `This link can't be opened.` (danger). A launch the platform refuses → `We couldn't open this link. Try again.` (danger). An accepted handoff → nothing, because the OS taking a link does not establish that a page loaded.
- Refusals arrive in two shapes and both are handled: iOS returns `false`, Android turns its own `false` into a thrown `PlatformException('ACTIVITY_NOT_FOUND')`. `open` catches `on Exception`, so a missing plugin is handled the same way.
- Detail screen: `Open the original page` sits between `Move to a collection` and `Delete this item` (wireframe C1 order) as an `AppButton.secondary`. It is wired only in the loaded state, so the skeleton, read-error and not-found screens cannot reach it. It stays enabled while a re-read or delete is in flight, because it reads and writes nothing.
- A tap changes nothing: no enrichment status, metadata, Inbox row, collection contents, count or pagination is written, refreshed or invalidated. No retry and no connectivity check.

### Verification
- `dart format` on the five changed Dart files; `flutter analyze` — no issues found.
- Focused suites passed: `open_saved_item_url_test.dart` (25) and `saved_item_detail_screen_test.dart` (33) — 58 tests.
- `flutter test` — 981 passed.
- No app, device, or emulator run. Nothing staged or committed.

### Remaining limitations
- The action is only on the saved-item detail. Rows carry no open affordance.
- Copy is hardcoded English; the app still has no l10n layer. `AGENTS.md` §4 still lists "opening the source URL" as a missing capability; the line is now stale, but that file is edited only when asked.
- Nothing observes the outcome after the handoff: whether the page loads, redirects, demands a sign-in or is gone is unknowable from the client, and no notice pretends otherwise.
- A stored URL that passed intake will always pass the launch gate; the refusal path exists for values that reached the client some other way (an older row, a server that accepted something this client would not).

## Re-read page / re-enrich a saved item (2026-10-24)

### Verified backend contract (stash-it-backend)
- `POST /saved-items/{id}/enrich` is **synchronous**. A `200` carries `{data: {saved_item: <12 fields>}, message}` — no `meta` and no collection, nested or sibling. The item is the same Go struct the detail route returns, so the envelope reuses `SavedItemDetailResponse`.
- **The body, not the status, reports the outcome.** `completed` may still carry a null title, description and image; `failed` preserves the metadata already stored and leaves `last_enriched_at` alone. No response sets `pending`. A page that could not be read is a recorded `failed` outcome in a `200`.
- A successful attempt overwrites `title`, `platform`, `description` and `image_url` from the extractor, including writing NULL to clear an old value. `url`, `domain` and `collection_id` never change.
- Mounted `Auth` → per-user rate limit → handler. `429 USER_RATE_LIMIT_EXCEEDED` (with `Retry-After`) and `503 USER_RATE_LIMIT_UNAVAILABLE` (without one) run before the handler: no fetch and no write. `404 SAVED_ITEM_NOT_FOUND` also covers the item being deleted while the attempt runs. A `500` can only come from the handler's own write — one `UPDATE ... RETURNING` that leaves the row as it was if it fails.

### Flutter implementation
- Added `SavedItemsApi.enrich` (one `POST`, no body, no query) and `SavedItemsRepository.enrich` with the same `DioException` / `TypeError` / `FormatException` mapping as every other write. Added `EnrichSavedItemResponse` / `EnrichSavedItemDataResponse`; the item DTO is reused, not duplicated.
- Added `SavedItemEnrichmentResult` (the id plus the four fields a re-read can change) and `savedItemEnrichmentFrom`, which reuses `enrichmentStatusFrom` so this route words the three states exactly as the Inbox, Search and Detail mappers do.
- Added `SavedItemSummary.copyWithEnrichment`: every parameter is required and nullable, so an explicit null **clears** the old value instead of retaining it. Identity, URL, collection id/name and saved-time label are carried from the read that produced the row.
- `SavedItems.applyEnrichment` and `CollectionSavedItems.applyEnrichment` patch one loaded row in place. Order, cursor, `hasMore`, `isLoadingMore`, `loadMoreFailed` and tombstones are preserved; no row is inserted, resurrected or re-sorted. `collectionsProvider` is not invalidated, because membership and counts cannot change.
- `savedItemDetailProvider` is now an auto-dispose notifier family with the same provider name and family key, the same initial GET and `_neverRetry`. `applyEnrichment` patches only a loaded detail for the same id and issues **no** follow-up GET: the POST's `200` is authoritative, and a failed reconciliation read must not replace a successful re-read.
- Added keep-alive `EnrichSavedItem` with plain `bool` state, a synchronous pre-`await` duplicate guard, exhaustive `ApiFailure` handling and a `ref.mounted`-guarded `finally`. One tap is one POST; nothing polls, retries or reconciles.
- Detail screen: `Re-read page` is enabled for all three enrichment states. The disabled control and "Not available in this version." are gone. While a re-read runs the button is busy and captioned `Reading the page…`, the item stays visible, the enrichment status is **not** changed optimistically, and Move/Delete are disabled.
- One notice per attempt: `Page re-read.` / `Page re-read. This page shows no details.` / `Couldn't read this page.`. A `429` uses only the server's real `Retry-After`; a `503` invents no interval; `404` invalidates the detail so its existing unavailable state takes over; transport and an unreadable `200` stay **uncertain** and claim nothing. Every failure leaves all metadata caches untouched.
- A `500` is treated as a **known** failure rather than an ambiguous one: the route's write is a single statement that either commits with a representation or fails, and a failed request carries no representation to apply.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` — 31 outputs written (the flag itself is reported as removed and ignored).
- `dart format` on the changed Dart files; `flutter analyze` — no issues found.
- Focused suites passed: enrich envelope decoding, enrichment mapper, repository incl. the new `enrich` group, detail provider incl. `applyEnrichment`, the new controller, the detail screen and `SavedItemSummary` — 165 tests across the seven files.
- `flutter test` — 950 passed.
- No app, device, or emulator run. Nothing staged or committed.

### Remaining limitations
- Search results are not patched: a re-read from the detail leaves a stale Search row until the user searches again. Search results are transient and unrelated to the current item's caches, so no invalidation was invented.
- All re-read copy is hardcoded English; the app still has no l10n layer.
- The re-read is only reachable from the saved-item detail, because that is the only surface with a detail action. Rows have no re-read affordance.
- A `completed` re-read that clears metadata is applied as such; there is no "restore what was there" action.

## Saved item image rendering (2026-10-24)

### Flutter implementation
- `SavedItemSummary` carries `imageUrl` exactly as the response reported it, including `null`, an empty string and whitespace. `hasPreviewImage` is now a getter derived from that value and answers only "did enrichment report an image?" — never "did it load?". `copyWithCollection` carries the URL across a move, so a collection move can no longer erase a preview. `hasNoMetadata` keeps its semantics: a reported image still counts as metadata, and a failed image load changes no model field.
- All four mappers pass `image_url` through untouched: Inbox listing, collection contents, Search and saved-item detail. No DTO or generated file changed.
- `SavedItemPreview` owns the entire matrix in one place. `pending` draws the existing 45° hatch with the hollow accent pip and starts no request, even if an anomalous URL is present. A non-pending item with a null, blank, malformed, relative or non-`http(s)` URL draws the existing neutral dashed well, with no resolution against `Uri.base`. A valid URL renders the network image; a load or decode failure falls back to the same dashed well. No spinner, shimmer, polling, broken-image icon or new token was added.
- `Image.network` keeps the hatch through `frameBuilder` until the first frame and handles failures through `errorBuilder`. The well keeps its reserved size, hairline border, radius and clipping in every state, so no state shifts the row. Decode size is bounded on one axis only — `cacheWidth` for a finite width, otherwise `cacheHeight` — so thumbnails do not decode a full-size source and the aspect ratio is not distorted.
- `SavedItemRow` and the saved-item detail band pass `imageUrl` and `enrichmentStatus`. The row and detail skeletons carry no URL, so a skeleton cannot issue an image request; their reserved dimensions and `Skeleton.keep` treatment are unchanged.
- `SavedItemPreview.pendingPlaceholderKey` and `SavedItemPreview.unavailablePlaceholderKey` identify the placeholder subtrees for tests. No test asserts on a painter type.

### Verification
- `dart format` on the changed Dart files; `flutter analyze` — no issues found.
- Focused suites passed: `saved_item_preview_test.dart` (22, including a real 1×1 PNG served through a fake `HttpOverrides` transport and both light and dark themes), `saved_item_summary_test.dart` (11), `saved_item_row_test.dart` (13), `saved_item_detail_screen_test.dart` (21), and the four mapper/move-preservation suites (57).
- `flutter test` — 867 passed.
- No app, device, or emulator run. Nothing staged or committed.

### Remaining limitations
- A `pending` item's preview changes only when its data is fetched again — pull-to-refresh on a listing, or reopening the detail. There is no polling, timer, background refresh or lifecycle-resume check, so the placeholder correctly stays put until then.
- The preview has no retry action of its own. A failed image remains the neutral well until the screen is rebuilt from a fresh read.
- A source that blocks hotlinks is indistinguishable from a page that never had an image; both use the same placeholder by design.


### Verified backend contract (stash-it-backend)
- `DELETE /collections/{id}` is unchanged in shape but both dispositions are now used: `{saved_items_action: "delete"|"move", target_collection_id}`. `delete` requires a null or omitted target; `move` requires a target that is not the source. `UNSORTED_COLLECTION_PROTECTED` is decided by `system_key`, so Unsorted is a valid destination and never a valid source. The write is one transaction: either the items are moved and the collection removed, or nothing changes.
- A move preserves each item's `created_at`, so the destination's contents interleave by original save time and the Inbox order does not change.
- Errors: `BAD_REQUEST` 400, `INVALID_COLLECTION_DELETE_ACTION` 400, `INVALID_COLLECTION_DELETE_TARGET` 400, `COLLECTION_NOT_FOUND` 404, `COLLECTION_DELETE_TARGET_NOT_FOUND` 404, `UNSORTED_COLLECTION_PROTECTED` 409, `COLLECTION_NOT_EMPTY` 409, `INTERNAL_SERVER_ERROR` 500. `COLLECTION_NOT_EMPTY` is the final foreign-key guard and applies to both actions; it and a missing target roll back entirely, so both are known not-deleted.
- Success is `200` with an unused `data: null` body; the status is the receipt.

### Flutter implementation
- The collection contents screen's app bar gained an overflow action. It is shown only for a settled listing and a **known** identity: the row for this id from the already-loaded `collectionsProvider`. `ref.exists` keeps this from issuing `GET /collections`; when that list has never loaded the action stays hidden rather than guessing from the header name (**D2**). Unsorted hides it outright, and `UNSORTED_COLLECTION_PROTECTED` remains a defensive outcome.
- Empty collection (`items.isEmpty && hasMore == false`): one `AppConfirmDialog`, no Move option. Non-empty: one sheet with Move / Delete / Keep, stating irreversibility; no second confirmation and no barrier or drag dismissal (`PopScope(canPop: !busy)` plus `Keep collection`).
- The sheet states a number only when the loaded pages cover the collection. `itemCount` is `null` when `hasMore` is true, so a partial page cannot be presented as a total.
- Move opens the existing cursor-paginated picker with an optional `description`; single-item move copy is unchanged, the source is excluded by id, Unsorted is offered, and dismissal sends nothing. The returned destination is sent as one bulk request — no per-item moves.
- Added `CollectionsRepository.moveItemsAndDelete` beside the existing `delete`, sharing one private `_submit`. The disposition and destination therefore cannot be sent inconsistently.
- Added keep-alive `CollectionDeletion` with a synchronous pre-`await` guard, `deleteDiscardingItems` (both destructive paths send `delete` with a null target) and `moveItemsAndDelete`. Success, known refusal and ambiguous outcome stay distinct: an ambiguous outcome changes no cache entry, pops nothing, and keeps the sheet open with `Close` in place of `Keep collection`.
- `COLLECTION_DELETE_TARGET_NOT_FOUND` is a new error code, failure variant and mapper arm; existing mappings and every exhaustive switch were extended, not replaced. It keeps the source and the sheet intact so another destination can be chosen. `COLLECTION_NOT_EMPTY` explains the change, refreshes the contents once and retries nothing. `COLLECTION_NOT_FOUND` reconciles the removal and leaves.
- Cache reconciliation is in place, not by invalidation: the source is removed from `collectionsProvider` (sort preserved); a confirmed move rewrites the loaded Inbox rows to the destination and the controller then refreshes the collections list for authoritative counts without count arithmetic and without invalidating Search. `SavedItems` also covers rows it never loaded, and a page requested before the change cannot resurrect or mis-assign rows.
- After success the decision surface closes and the route pops back to Collections; the source contents are not refreshed for a route that is being removed.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` — 38 outputs written (the flag itself is reported as removed and ignored).
- `dart format` on the changed Dart files; `flutter analyze` — no issues found.
- Focused suites passed: controller, reconciliation, repository delete/move and failure-mapper tests (58), collection contents screen (20), routed delete navigation (2).
- `flutter test` — 830 passed.
- No app, device, or emulator run. Nothing staged or committed.

### Remaining limitations
- Delete copy and feedback remain hardcoded English; the app still has no l10n layer.
- A direct deep entry into a collection route hides the action until the Collections list has been loaded once, because identity is read from that list rather than fetched for the decision.
- A collection with more than one loaded page reports no item count; the endpoint has no total, so the sheet says it has saved items without a number.
- Moving does not re-read the destination's contents; the destination screen reads its own pages when opened.

## Delete saved item (2026-10-23)

### Verified backend contract (stash-it-backend)
- `DELETE /saved-items/{id}` answers `200` with `{data: {collection_id, collection_empty, collection_deletable}, message}` and no `meta`. A `200` proves the row is gone. The flags are advisory: they describe the collection the item left and do not delete it. A `200` with an unreadable body is still a completed item delete, reported without collection flags; a non-2xx unreadable body remains unestablished.
- `DELETE /collections/{id}` requires `{saved_items_action: "delete", target_collection_id: null}`. Success is the status and needs no response payload. `COLLECTION_NOT_FOUND`, `COLLECTION_NOT_EMPTY` and `UNSORTED_COLLECTION_PROTECTED` are known outcomes; no item delete is repeated after a collection-delete failure.

### Flutter implementation
- Added `Delete this item` below `Move to a collection` on the saved-item detail. It opens the shared `AppConfirmDialog` with the fixed copy and `Keep` / `Delete` actions. Only a confirmed choice sends one `DELETE /saved-items/{id}`. No Undo and no automatic collection deletion were added.
- A second dialog is offered only after a successful item delete and only when every eligibility condition holds: both server flags are true, the response `collection_id` is non-empty, it exactly matches the item's last-known `collectionId`, and the trimmed collection name is non-empty. `Keep it`, barrier tap and Back all publish the item-deleted success and send no collection request.
- `DeleteSavedItem` is a keep-alive controller with a synchronous in-flight guard and separate item/collection outcomes. Confirmed deletes remove rows from loaded Inbox and collection-contents listings in place; both listings keep tombstones so an in-flight page cannot resurrect a deleted row. `Collections` removes the collection in place, preserving its chosen sort, cursor and loaded pages.
- The optional collection delete sends the one verified request body and updates the loaded collections list. When the delete establishes that the collection is gone (success or `COLLECTION_NOT_FOUND`), a mounted collection-contents provider is invalidated by default so its existing not-found state can take over; the leaving path described below opts out because that route is being removed.
- Item-delete failures remain distinguishable: a known not-found removes the stale row without claiming this request deleted it; an ambiguous failure stays on the detail with uncertain copy; a confirmed delete with unreadable collection flags reports only the item deletion. Backend `message` is never displayed.

### Navigation after collection deletion
- A saved-item detail opened from collection contents now receives `SavedItemDetailOrigin.collection(collectionId)` through `GoRouterState.extra`. The location still names only the item.
- When that origin collection is deleted successfully, or is already unavailable (`COLLECTION_NOT_FOUND`), the detail pops twice: the item detail and the collection detail. The existing shell stack then reveals whichever destination held the collection — Collections or Search — with no new route or invented destination. The same path passes `invalidateContents: false`, so it does not issue a `GET /collections/{id}/saved-items` for the route being removed.
- Other origins keep the single pop (Inbox, Search, direct entry). If the item was moved to another collection before deletion, the origin collection still exists, so only the item detail is popped. `COLLECTION_NOT_FOUND` remains expected and tolerable for requests that still target a collection deleted elsewhere; it is not broadly suppressed.

### Verification
- `dart format` applied to the changed Dart files; `flutter analyze` — no issues found.
- Focused suites passed: 5 dialog tests (including barrier and system Back), 13 routed-navigation tests, 34 collection-contents/collections tests, plus the delete-controller and saved-items-controller suites. The in-flight tombstone test passed individually.
- `flutter test` — 796 passed.
- No app, device, or emulator run. Nothing staged or committed.

### Remaining limitations
- Delete copy and feedback remain hardcoded English; the app still has no l10n layer.
- `COLLECTION_NOT_FOUND` can still occur when a collection is deleted outside this flow, or on an unconfirmed collection delete. Avoiding it broadly would require suppressing a valid backend answer.
- The collection-delete follow-up is only offered from the saved-item detail, as decided; no Inbox card or batch flow exists.

## Collection detail screen (2026-10-23)

This section supersedes the "Collection detail screen and mutations not
implemented" note in the Collections list integration entry below.

### Verified backend contract (stash-it-backend)
- `GET /collections/{id}/saved-items`, `middleware.Auth` only, **no rate limiter**.
- Envelope `{data: {collection: {id, name}, saved_items: [...]}, message, meta: {cursor: {has_more, next_cursor}}}`. **The collection is a sibling of the rows**, so the items carry no nested `collection` — unlike `GET /saved-items`.
- Optional `limit` (default 20, max 50) and `cursor` (max 512 bytes); no `sort`. Ordering `created_at DESC, id DESC`. No total count. An empty collection is a `200` with `[]`.
- Errors: `BAD_REQUEST`, `INVALID_CURSOR`, `VALIDATION_ERROR`, the three 401s, `COLLECTION_NOT_FOUND` (404, shared by a missing and a foreign collection), `INTERNAL_SERVER_ERROR`.

### Flutter implementation
- New screen at `lib/features/saved_items/presentation/collection_saved_items_screen.dart`, owned by `saved_items`; `collections` only navigates to it. Reached by `context.push(AppRoutes.collectionDetail(id))` from a collection tile.
- Route `/collections/:id` is a **top-level route outside the `StatefulShellRoute`**, on the same pattern as the saved-item detail: plain `COLLECTION` app bar with no Settings action, no bottom navigation, and a pop that returns to the Collections branch with its sort choice and scroll position. A direct entry with nothing beneath it falls back to `/collections`. The two-segment path cannot shadow the `/collections` branch.
- The header is `data.collection.name` from this response, never the tile's name. While page one loads it is a skeleton placeholder inside `ExcludeSemantics`; a settled failure shows no name at all.
- Rows reuse `SavedItemRow` with `showCollectionChip: false` — a new parameter defaulting to `true`, so the Inbox is unchanged — and no `onRetry`. Every row pushes the existing saved-item detail route with its id; there is no second detail route. Loading reuses `SavedItemSkeletonList` (same `showCollectionChip` pass-through), so the placeholder is the real row. No new skeleton system and no centred spinner.
- `CollectionSavedItems` is an auto-dispose family notifier keyed by collection id with `refresh`, `retry`, `loadMore` and `retryLoadMore`. First page, refresh and retry replace the list; pages append in server order and are de-duplicated by id. Automatic paging fires within 320 logical px of the maximum scroll extent.
- Load-more failure is an explicit `loadMoreFailed` flag rather than an error state: loaded rows stay, a footer says so and offers Retry, and scrolling cannot resume the failed cursor. Retry sends the same cursor, refuses a concurrent request, and automatic paging resumes on success. A consumed-cursor set and a `has_more`-without-cursor guard stop a malformed response from looping.
- Pull-to-refresh resets pages and cursor. A failed refresh keeps the rows and publishes one `FeedbackTone.uncertain` notice; a failed refresh with nothing loaded becomes an error state. A page in flight when the list is replaced is dropped by a list-version guard.
- Empty success is `Nothing saved here yet`: neutral, no Retry, still refreshable. `COLLECTION_NOT_FOUND` maps to `ApiFailureNotFound` and renders `This collection is no longer available` with a way back to Collections and no Retry. Every other failure offers Retry. No backend `message` is rendered anywhere.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` — wrote 35 outputs (the flag itself is reported as removed and ignored).
- `dart format` on the changed Dart files; `flutter analyze` — no issues found.
- 71 focused tests passed: `collection_saved_items_response_test.dart`, `api_failure_mapper_test.dart`, the new controller suite (23), the new screen suite (8) and the new navigation suite (2).
- 64 regression tests passed: saved-item row, Inbox screen, router and saved-item detail navigation.
- No app or emulator run. Nothing staged or committed.

### Remaining limitations
- No item count is shown; the endpoint reports no total, and none is invented.
- A server that repeats a cursor makes the footer Retry unusable, because the same cursor is refused. Recovery is pull-to-refresh. This is deliberate: retrying an unadvanced cursor would loop.
- `_LoadingMoreRow` is a small duplicate of the Inbox's private footer rather than a promotion with a single consumer.

## Collection preview and paginated picker (2026-10-23)

This section supersedes the destination-loading and close-control details in the
move-to-collection sections below. The `collection_intent` and duplicate-name
behaviour is unchanged.

### Flutter implementation
- The main Move to a collection sheet now renders at most five other collections. It reads one `GET /collections?sort=name&limit=6` page: six slots cover five visible rows plus the current collection when the server returns it. It does not follow `next_cursor`. `Browse all collections` appears when the loaded page is longer than five or reports `has_more`, and also when a typed name matches no loaded collection.
- Added an auto-dispose `MoveCollectionPicker` controller over the existing `CollectionsRepository`. It loads `sort=name&limit=20` one cursor page at a time, appends in server order, de-duplicates by id, and exposes initial-load errors, a load-more failure with retry, loading-more state, and the empty state. It never pre-fetches every page. The current collection is excluded by id; system collections are kept.
- `Browse all collections` opens a dedicated modal picker with the same centred grab handle, a `Load more collections` footer while `has_more` is true, and a visible Retry for either page failure. A selected collection is returned to the main sheet and sent through the existing `existing` move path, so row taps, typed matches, and picker selection share one operation. A typed non-match still offers `create`; it is never silently converted into `existing`.
- Removed the top-right X from the main sheet. Both sheets use Flutter's `showDragHandle` and default `enableDrag`/`isDismissible` behaviour; `AppTheme.bottomSheetTheme` paints the handle with `borderStrong`. No custom gesture system was added. `PopScope(canPop: !busy)` still prevents system back while a move is in flight, and modal barrier dismissal continues to work when the sheet is not busy.
- **Lookup limitation:** `GET /collections` exposes only `sort`, `limit`, and the opaque `cursor`. It has no name or search filter. A typed name is therefore matched only against collections already loaded by the sheet, and an efficient global existence check is not possible from this endpoint. The separate `GET /search` route can match collection names, but it is a capped, relevance-ranked mixed result, not an exact or complete collection lookup; it was not used here. The paginated picker is the discovery path. If a name exists outside the loaded preview, `create` remains available and the backend's `409 COLLECTION_NAME_ALREADY_EXISTS` remains the authority; the sheet stays open, preserves the name, and shows the existing duplicate-name copy. No backend endpoint or contract was added.

### Verification
- `dart run build_runner build --delete-conflicting-outputs`: completed; this build_runner reported the flag as ignored and wrote 7 outputs.
- `dart format` applied to the changed and new Dart sources and tests.
- `flutter analyze`: no issues found.
- Focused preview and picker controller tests: 9 passed.
- Focused move sheet and collection picker widget tests: 21 passed.
- `test/app/theme/app_theme_test.dart`: 15 passed.
- No full test suite, app run, device, or emulator operation was performed.

### Remaining limitations
- Picker copy (`All collections`, `Load more collections`, page errors) and the revised sheet helper remain hardcoded English; the app still has no l10n layer.
- `Load more collections` is an explicit footer action rather than an infinite-scroll trigger. This keeps the next network request user-initiated and the footer reachable by keyboard and screen readers.
- No on-device drag, keyboard, or back-gesture check was performed.

## Collection intent and duplicate names (2026-10-23)

This section supersedes the move-to-collection error and request details in the
2026-10-22 section below. The backend now requires `collection_intent` and no
longer emits `COLLECTION_NAME_RESERVED`.

### Flutter implementation
- `PUT /saved-items/{id}/collection` now sends the required `collection_intent` with `collection_name`. `MoveToCollectionIntent` owns the exact wire values: `existing` when the user taps a destination row or types a name matching a loaded collection, and `create` when the typed name matches nothing. The request still sends no collection id, and response handling for `collection_created` / `already_in_collection` is unchanged.
- Replaced the stale `COLLECTION_NAME_RESERVED` / `ApiFailureCollectionNameReserved` mapping with `COLLECTION_NAME_ALREADY_EXISTS` / `ApiFailureCollectionNameAlreadyExists`. A duplicate create attempt keeps the sheet open, preserves the typed name and shows `That collection name is already taken. Choose a different name.`; the controller returns `MoveToCollectionNameAlreadyExists`, publishes no success, and does not reconcile the item.
- `INVALID_COLLECTION_INTENT` maps to `ApiFailureMalformedRequest` and follows the existing unexpected-request path, `Something went wrong sending that name. Try again.` It is never presented as a duplicate-name error, and no server message is displayed.

### Verification
- `dart run build_runner build --delete-conflicting-outputs` completed; this build_runner reported the flag as ignored and regenerated the request Freezed/JSON output.
- `dart format` applied to the changed Dart files.
- `flutter analyze`: no issues found.
- Focused move, mapper, save-url and sign-in message tests: 143 passed.
- `test/features/auth/presentation/sign_in_screen_test.dart`: 20 passed.
- No app, device, or emulator run was performed.

### Remaining limitations
- The sheet copy remains hardcoded English; the app still has no l10n layer.
- `INVALID_COLLECTION_INTENT` indicates a client defect. It gets the standard malformed-request feedback and closes the sheet; the local intent mapping is covered by tests, so this should be unreachable from the shipped client.

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
