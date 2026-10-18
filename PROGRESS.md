# PROGRESS.md — Stash-it Flutter client

Handoff document for the next coding session. Rules live in [`AGENTS.md`](./AGENTS.md);
product behaviour lives in [`docs/product-discovery/`](./docs/product-discovery/README.md).
Neither is duplicated here.

**Status:** the application shell, the **approved design system v1**, the
**authentication and network foundation**, and the **Saved Items API integration** are
complete. Manual sign-in, secure credential storage, startup restoration, access-token
attachment, single-flight renewal, session invalidation and logout all work and are tested.
The Inbox now reads `GET /saved-items` over that same pipeline — loading, empty,
error-with-retry and rows states, with cursor pagination. The refresh path's failure handling
was hardened this iteration: a renewal that failed with anything other than a
`SessionExpiredException` or a `DioException` used to leave the request's Dio error handler
unresolved and the request hanging, and now fails in a controlled, classified way.
**No other product feature is
implemented**: Collections, Search and Profile data are not fetched, the Inbox intake is
still visual only, and Registration, Google sign-in and password reset are not built.

> **The Saved Items integration is complete for this iteration, not signed off.** It is
> verified by the automated suite recorded below and by nothing else: no request has ever
> left this machine, so the contract has been matched against Swagger and not against a
> live backend, and the feature has not been reviewed on a device. Manual review is
> expected to produce follow-up work.

---

## What exists

### Foundation and four primary destinations

`lib/main.dart` is a thin entry point — `runApp` with a `ProviderScope` around
`StashItApp`. Startup is deliberately **synchronous**: there is no asynchronous
initialization to do yet, so there is no bootstrap step. Add one only when something
genuinely requires it (secure storage is the first candidate, V5).

`lib/app/app.dart` provides `StashItApp`, a `MaterialApp.router`. Its optional `router`
parameter exists so a test can supply a router carrying no navigation history.

The four destinations required by **D1** — **Inbox, Collections, Search, Profile** —
are implemented at `lib/features/<feature>/presentation/<name>_screen.dart`. Three of
them are placeholders that state plainly that they show nothing. The Inbox is the only
destination with content.

### Routing

`lib/app/router/app_router.dart` and `lib/app/router/routes.dart`.

- `StatefulShellRoute.indexedStack` with four branches, so each destination keeps its
  own navigation state.
- A bottom `NavigationBar` in a private shell scaffold switches branches via
  `goBranch`; selection is observable as `NavigationBar.selectedIndex`.
- Paths are centralised in `AppRoutes` (`/inbox`, `/collections`, `/search`,
  `/profile`). The app opens on the Inbox, matching the share → save → Inbox loop.
- `createAppRouter()` sits beside the shared `appRouter` for test isolation.

Not implemented, deliberately: auth redirects, deep links, pending-share intake,
nested feature navigation, and any fifth destination. The pending-URL queue is a section
inside the Inbox (D18, D25), not a route.

### Theme — B · Inventory / B-Dark (**implemented**)

`lib/app/theme/` holds the approved design system v1, specified in
`docs/design-explorations/design-system.md`. The provisional Paper & Ink theme is gone.

| File | Holds |
| --- | --- |
| `app_tokens.dart` | `AppTokens`, a `ThemeExtension` with `AppTokens.light` and `AppTokens.dark` — every semantic colour the M3 `ColorScheme` has no slot for |
| `app_typography.dart` | The specification's type roles, and the `TextTheme` mapping onto the Material slots |
| `app_metrics.dart` | Spacing, radii, borders, icon and control sizing — brightness-independent, so one set |
| `app_theme.dart` | `ThemeData` for each brightness, plus `tokensOf(context)` |

**The accent is Dusty Sage**: `#4C6B5F` light, `#74A88C` dark — one hue at two lightnesses.
Light surfaces are cool white-grey, dark surfaces layered charcoal, and neither uses
cream or pure black.

**Theme selection is the system brightness.** `StashItApp` passes both `theme` and
`darkTheme` and leaves `themeMode` at its default. There is no in-app theme switch
because none is specified.

**Three typefaces are bundled** in `assets/fonts/`, registered in `pubspec.yaml`:
Silkscreen (display only), Inter (all UI and saved-item copy), JetBrains Mono (machine
text only). They ship as **`.ttf`, not the prototypes' `.woff2`** — Flutter's font loader
goes through Skia, which reads TTF/OTF only. The same four files were decompressed once;
the converter is not part of the project. Inter and JetBrains Mono are variable fonts, so
`AppTypography` sets the `wght` axis via `FontVariation`; the weights are also declared in
`pubspec.yaml` so font matching never synthesises a faux bold on top of a real weight.
They are **latin subsets** — Indonesian (D21) is covered, but no Cyrillic, Greek or CJK.

Shared components live in `lib/shared/widgets/`: `AppButton` and `AppField`. Those two are
the only ones promoted, because they are the only ones with a second consumer — sign-in
and the Inbox intake. The chip, the feedback note and the inventory slot each have one
consumer and stay with their owning feature.

> **Input height revised 40 px → 48 px.** Device screenshots showed the sign-in fields
> reading as thin text bars. Measured in a widget test, the cause was two things together:
> `isDense: true`, which collapses Material's vertical content padding to nothing, and a
> `contentPadding` that supplied only a horizontal inset. The 20 px text run therefore sat
> **0 px from the top border with 20 px of dead space beneath it**, inside a 40 px box that
> was also under Material's 48 px touch target. `AppMetrics.fieldHeight` is now 48 and the
> inset is `AppMetrics.fieldContentPadding` (12 px all round), giving 14 px above and 14 px
> below. `isDense` is gone. This changes a number in the approved specification, so
> `design-system.md` §6.2 carries the same revision and the reason.

### Auth failure feedback — grouped, not stacked

The sign-in failure band showed the message and **Dismiss** as two stacked rows, and because
Material gives a `TextButton` a 48 px minimum target the dismiss row alone was taller than
the sentence above it: roughly a hundred pixels for a one-line failure, with an empty gap
under the text. They now share one row — the message is the `Expanded` child and Dismiss is
fixed — so the band is as tall as the message it has to show. A long message still wraps,
because the text is the flexible side; there is no fixed height anywhere.

Dismiss drops to a 32 px target with `shrinkWrap`. That is below Material's 48 px guideline
on purpose: the band is a confirmation of a failure, not the primary action, and 32 px still
clears WCAG 2.5.8's 24 px minimum comfortably.

### Sign-in — approved design, unchanged behaviour

`lib/features/auth/presentation/sign_in_screen.dart` follows `auth.html`: the brand row
replaces the app bar (auth sits outside the four destinations), then a screen heading, a
lede, two labelled fields, and one filled action.

**The behaviour is untouched**: the same validators, the same client-side email and
password rules mirroring `login/request.go`, the same dismissal-not-retry failure message,
and the same `ApiFailure` → copy mapping. Only the presentation changed.

`messageFor` now has direct unit coverage in
`test/features/auth/application/sign_in_message_test.dart`, because **D15**/**D16** make
those strings load-bearing: a 429, a 503 and an offline device must stay three different
things, and an uncertain outcome must never claim the attempt did not happen.

### Saved-item row — the inventory slot

`lib/features/saved_items/presentation/widgets/saved_item_row.dart` is now the inventory
slot from `design-system.md` §6.3: a 1 px bordered card on the canvas, 3 px corner,
56 px thumbnail well, title with the saved time in its top-right corner, the domain in
mono, a two-line description, then collection chip, enrichment state and Retry.

**Thumbnail treatment**: a preview image is a 45° hatch; no image is a dashed empty well.
Both reserve the same space so rows never shift, and neither is coloured as a problem.
The hatch and the dashed square are `CustomPainter`s, so no image asset is needed.

Beside it, `lib/features/saved_items/domain/saved_item_summary.dart` is the **presentation
model** — not a DTO. It holds the `title → URL → domain` fallback chain and the three
`EnrichmentStatus` values from **D8**, and is built by the saved-items mapper.

### Inbox — the listing is integrated

`lib/features/inbox/presentation/inbox_screen.dart` reads `GET /saved-items` and renders
loading, empty, error-with-retry and rows states. The mock data file and the mock-data notice
are **deleted**; nothing in this screen is fabricated any more.

**The intake is still visual only.** `lib/features/inbox/presentation/widgets/inbox_intake.dart`
renders the URL field plus separate **Paste** and **Save URL** actions exactly as
specified — Paste secondary, Save URL the screen's only filled button — but neither is
wired. There is no clipboard package in `pubspec.yaml` and no submission. A visible
control that does nothing is a deliberate gap: it cannot be mistaken for working intake.

**The contract, as implemented.** Read from `../stash-it-backend/docs/swagger.json`:

- Envelope `{ data: { saved_items: [...] }, message, meta: { cursor } }`.
- Item fields: `id`, `url`, `domain`, `platform`, `title`, `description`, `image_url`,
  `collection_id`, `enrichment_status`, `last_enriched_at`, `created_at`,
  `updated_at`, plus a nested `collection: { id, name }`. Nullable metadata is an
  explicit `null`, never omitted.
- Ordering `created_at DESC, id DESC`; **no sort parameter**.
- Cursor pagination: default 20, max 50; `has_more`; `next_cursor` null on the final
  page; empty results are `[]`.
- Read-only; triggers no enrichment and no automatic organization. Nothing is
  filtered, so `pending`, `completed` and `failed` all appear.
- Errors: `BAD_REQUEST`, `VALIDATION_ERROR`, `INVALID_CURSOR`, the three 401s,
  `INTERNAL_SERVER_ERROR`. No rate limiter.
- The Inbox is **not** the Unsorted collection. Unsorted is one collection among the
  ones an item can be in, and keeps its own pinned place in `GET /collections`.

**It is now implemented in this client.** `lib/features/saved_items/` carries the Retrofit
client, the Freezed DTOs, the repository, the mapper, the providers and the listing
controller, plus a page model for the cursor.

- `data/datasources/saved_items_api.dart` — `GET /saved-items` over `appDio`, so the auth
  interceptor owns the bearer token and the renewal-and-replay. **Nothing in this feature
  handles `ACCESS_TOKEN_EXPIRED`.**
- `data/models/listed_saved_item.dart`, `data/models/list_saved_items_response.dart` —
  every documented field, including the nested `collection` and the typed `meta.cursor`.
  Nullable `title`, `description`, `image_url` and `last_enriched_at` stay nullable; a
  `completed` row with a null title is normal, not a fault.
- `data/saved_item_mapper.dart` — wire row to `SavedItemSummary`.
- `data/saved_items_repository.dart` — the only place a `DioException` becomes an
  `ApiFailure` for this feature.
- `application/saved_items_controller.dart` — an `AsyncNotifier` so `retry()` genuinely
  refetches and paging appends without blanking the list. `@Riverpod(keepAlive: true)`:
  the listing is a history, so leaving and returning must not discard it.
- `presentation/widgets/saved_item_skeleton.dart` — a hand-built placeholder in the same
  geometry as the real slot. **`skeletonizer` was not added**: it is not currently a
  dependency, and a placeholder matching *this* card is six boxes in the project's own
  tokens, which is less configuration than adapting a generic package.

**Pagination.** `limit` is deliberately not sent, so the documented server default (20) and
cap (50) apply — restating a cap the client does not own would be a second place for it to
be wrong. The cursor is stored and returned byte for byte and never parsed. Paging stops on
*either* signal: `has_more` false, or `next_cursor` null. Rows are de-duplicated by `id`
across pages, because a cursor explicitly survives an item being re-saved. A failed later
page keeps the rows already on screen.

**Saved-time labels are now derived from `created_at`** by the mapper, using the wording the
approved prototype already established (`Saved just now` / `12 min ago` / `3 hours ago` /
`Saved yesterday` / `N days ago`). This is the one place a real field was mapped onto
existing copy: the product documents specify no relative-time wording, so it is a **flagged
choice**, not a confirmed one. An unparseable or future `created_at` produces no label at
all rather than a fabricated one. It is English-only — `flutter_localizations` is still not
a dependency (D20/D22).

### Two contract observations

- **`INVALID_CURSOR` has no `ApiFailure` variant.** It is documented for this route but is
  not in `ApiErrorCode`, so it falls through the mapper to `ApiFailureUnreadableResponse`
  and gets client-owned copy. Adding a variant would force an edit to the auth feature's
  exhaustive `messageFor` switch, out of scope here. It is only reachable if the client
  sends a cursor the server did not issue.
- **A decode failure now has a typed home.** `mapDecodeFailure` was added to
  `core/error/api_failure_mapper.dart`: Retrofit decodes *after* Dio's transformer returns,
  so a body that does not match the contract surfaced as a raw `TypeError` that bypassed the
  taxonomy entirely. It is now `ApiFailureUnreadableResponse`.

---

## Authentication and network foundation

**Manual sign-in and session handling are implemented.** This milestone added
`lib/core/`, `lib/features/auth/`, `app/config/`, `app/network/` and `app/bootstrap.dart`.
Registration, Google sign-in and password reset are backend features and are
deliberately not built.

### What exists

**`core/error/` — the failure taxonomy and the one mapper.** Every failed HTTP
call becomes an `ApiFailure`, selected on the variant and never on a status code
or a raw code. `api_error_codes.dart` carries only codes verified against the Go
source, each annotated with the file it came from. The mapper distinguishes three
things that are easy to conflate and are load-bearing per D15 and D16: a response
that arrived but could not be decoded (`ApiFailureUnreadableResponse`, *known not
saved*), no response at all (`ApiFailureTransport`, **uncertain**), and a server
that refused (`ApiFailureServerUnavailable`, *known not saved*).

A distinction worth recording: Dio's response transformer throws while decoding an
unparseable body and the resulting exception carries **no** `response`, making it
structurally identical to a dropped connection. The mapper separates them by cause,
because defaulting to "uncertain" would tell a user their write may not have landed
when the server has already answered.

**`core/network/` — the token contract and the interceptor.** `TokenProvider` is
two methods and exists solely to break the dependency cycle: `core/network` never
imports `features/auth`. The interceptor attaches the bearer token per request
(not cached — a cached token is stale on any request issued during a renewal) and
renews **only** on `error.code == ACCESS_TOKEN_EXPIRED`.

That code, not the `401`, is the trigger. All three bearer-guard codes are `401`
(`internal/middleware/auth.go`), and renewing for the other two cannot succeed.
`INVALID_ACCESS_TOKEN` and `INVALID_AUTHORIZATION_HEADER`, an unrecognised code, a
`401` with no readable body, a `429`, and a `500` all pass straight through — each
covered by a test.

Replays use `Dio.fetch` on a copy of the original `RequestOptions`, so method,
headers, query, body, content type and `CancelToken` survive, and a marker in
`extra['auth_retried']` bounds each request to **one** retry with no status-based
recursion.

**Two Dio instances.** `refreshDio` carries no auth interceptor, which makes
recursive renewal **structurally impossible** rather than guarded against — no path
check or flag can be forgotten. `appDio` carries the metadata interceptor and the
auth interceptor. `receiveDataWhenStatusError` is set explicitly because the entire
error taxonomy depends on it.

### The provider dependency cycle that blocked sign-in

Manual sign-in failed on the emulator, reporting a connection error. The cause was
not the network: a `CircularDependencyError` thrown inside the auth interceptor, with
no HTTP response, which the error mapper correctly classified as
`ApiFailureTransport`.

```text
appDio -> sessionController -> authRepository -> authApi -> appDio
```

`appDio` reads `sessionControllerProvider` for the `TokenProvider`; the session
controller read `authRepositoryProvider`; the repository is built from `appDio`.

**Why the lazy lookup made it worse rather than better.** `AuthInterceptor` was given
a callback, `() => ref.read(sessionControllerProvider.notifier)`, so `appDio`'s build
body no longer referenced the session controller directly. That looked like it broke
the cycle. It did not. Riverpod's `_debugAssertCanDependOn`
(`riverpod/src/core/ref.dart:176-187`) walks the *reading* provider's transitive
**dependents** and throws if the target is among them — a static property of the
graph, re-evaluated on **every** `read`/`watch`, not a check on initialisation state.
The callback only moved the throw from construction to the first request, where it
arrived as an unexplained transport failure.

**The fix is the graph, not the timing.** `SessionController` now depends only on
`refreshApiProvider` (hence `refreshDio`), the credential store, and the
bootstrap-supplied tokens. It no longer knows `AuthRepository` exists, and login and
logout moved to `AuthState`, which legitimately depends on `authRepository`. The
resulting graph is acyclic:

```text
credentialStore, restoredTokens, refreshDio      (leaves)
refreshApi        -> refreshDio
sessionController -> refreshApi, credentialStore, restoredTokens
appDio            -> sessionController
authApi           -> appDio
authRepository    -> authApi, refreshApi
authState         -> sessionController, authRepository, credentialStore
```

Two design consequences worth keeping:

- **`AuthState` now *derives* its status** by watching `sessionControllerProvider`
  rather than being told. A renewal that comes back `SESSION_REVOKED` clears the
  session, and the UI follows with no notification path of its own. This is why the
  session controller must not point back at the auth state: the API client depends on
  the session controller, so that edge closes the cycle.
- **`AuthInterceptor` takes a `TokenProvider` instance again**, not a callback. A
  dependency cycle now fails when the interceptor is built rather than as a
  transport error on the first request.

Removing the manual renew-then-retry from logout fell out of this. `logout` is issued
through `appDio`, so an expired access token is already handled by the interceptor —
it sees `ACCESS_TOKEN_EXPIRED`, renews, and replays once. The second code path was
duplicate machinery.

**`features/auth/application/` — single-flight renewal.** The backend rotates the
refresh token on every use and revokes the **whole session** when an
already-rotated token is presented, so concurrent expiries must share one renewal.
`SessionController` holds a single in-flight `Future`, cleared in `whenComplete` on
both success and failure — a cached rejection would make every later renewal fail
with the first error. The refresh token is read from storage at the moment renewal
**begins**, never cached in a field, so a request whose `401` arrives after an
earlier rotation presents the token that rotation produced rather than one already
spent. Three concurrent callers producing exactly one submission is a test.

**Terminal vs. ambiguous renewal.** `REFRESH_TOKEN_INVALID`, `SESSION_REVOKED` and
`SESSION_EXPIRED` clear credentials and sign out: the backend has already committed
the revocation before answering. A `500` or a transport failure does **not** — the
commit outcome is genuinely unknown, so credentials are kept and no automatic retry
is attempted. See the open item below.

**Credential writes are all-or-nothing.** The backend rotates both tokens together,
so a half-written pair is indistinguishable from a real session once persisted and
is unusable. A write that fails partway discards whatever landed; the caller gets
`ApiFailureCredentialStorage` and never a false success. Clearing is key-scoped, not
`deleteAll`, so the pending-URL queue that will share this store is untouched.

**Startup.** `main` is now `async`: `bootstrap()` initialises bindings and reads
storage **before** the first frame, which is what lets the session state resolve
synchronously and lets the router choose between the app and sign-in on its very
first navigation. A stored pair means signed in; a partial pair is not a session.
**No startup network request and no JWT decoding** — the access token is stateless
and only a real request proves it, so decoding `exp` locally would make the client
its own authority on a credential only the backend can judge.

**Routing.** `appRouter` is a keep-alive provider (a top-level `final` has no `Ref`
to read auth state, and one built once could not refresh). `redirectFor` is a pure
function of session and location, tested exhaustively without pumping a router, and
wired through a `GoRouter.refreshListenable` so a session that ends mid-visit
redirects rather than stranding the user. Sign-in sits outside the shell and is not
a fifth destination.

**Logout** clears local credentials in a `finally`, whatever the server said. An
expired access token needs no special handling here: the call goes through `appDio`,
so the interceptor renews on `ACCESS_TOKEN_EXPIRED` and replays once. Without that the
bearer guard would refuse the call and the server session would survive until it lapses
— up to 90 days.

### Five bugs this milestone's own tests found

Recorded because every one was invisible to `flutter analyze` and would have
shipped:

1. **The generated JSON decoders looked for `accessToken` while the backend sends
   `access_token`**, so a successful login threw a null cast instead of decoding.
   Every DTO now names its wire key with `@JsonKey`.
2. **A circular provider dependency** (`appDio` → session controller → repository →
   `appDio`) prevented sign-in outright. The first attempt *hid* it behind a lazy
   `Ref` callback, which only deferred the throw to the first request. Fixed in the
   graph — see the section above.
3. **`bootstrap` read `credentialStoreProvider` from a container with no
   overrides**, hitting the deliberate `UnimplementedError` that provider carries
   by default — so startup would have thrown. It now reads the store directly.
4. **`_endSession` wrote Riverpod state after an `await`**, which throws once the
   provider is disposed. It checks `ref.mounted` first (`AGENTS.md` §4).
5. **The previous `session_controller_test.dart` overrode `authRepositoryProvider`
   with a fake**, which removed the very edge that closed the cycle. The suite was
   green while the app could not sign in. It now runs against the real graph with
   only the two providers `bootstrap` actually overrides.

Bugs 2, 3 and 5 are one failure mode: tests that stub the wiring also stub the bug.
Anything below `main()` is now exercised through the real provider graph.

### Not covered

Only manual sign-in. The `auth-sessions.md` warning that a lost refresh response
costs a session means the ambiguous-renewal policy is a judgement, not a
derivation — see the open items below.

---

## Verification actually performed

Run from the repository root, Flutter 3.47.7 / Dart 3.13.5:

| Command | Result |
| --- | --- |
| `dart format lib test` | 74 files, all formatted, 0 changed |
| `dart run build_runner build` | Built successfully; a repeat run writes 0 changed outputs, so generation is in sync |
| `flutter analyze` | `No issues found!` |
| `flutter test` | `All tests passed!` — **137 tests** (16 pre-existing, 121 new) |

**Device verification has not been performed and is not part of this record.** No
emulator was launched, no app was installed, and `flutter run` was never executed.
The dependency-cycle fix is verified against the real provider graph in tests, but
**whether sign-in now succeeds on the emulator has not been observed** — that
retest is pending.

No test opens a socket. HTTP behaviour is driven through a fake Dio
`HttpClientAdapter` (`test/support/fake_http.dart`) and an in-memory
`FlutterSecureStorage`, so the interceptor, the response transformer and the error
path all run exactly as they do in production with only the transport substituted.

New coverage, beyond the pre-existing shell, row and Inbox tests:

- **Error mapper (24)** — every verified code; `Retry-After` present, absent and
  malformed; the three `401`s; the terminal set pinned to exactly three codes;
  non-JSON, HTML, missing `error` key, unknown code, null body; decode failure vs.
  transport failure.
- **Auth interceptor (20)** — header attachment and per-request re-read; renewal
  triggered by `ACCESS_TOKEN_EXPIRED` and by nothing else; one replay bound by the
  marker; concurrent expiries; replay fidelity for method, path, query, body and
  content type.
- **Session controller (17)** — startup restoration including a partial pair;
  three concurrent callers sharing one renewal; only the current refresh token ever
  submitted; the shared future released after success *and* failure; each terminal
  code clearing credentials *and* the status following without being told; ambiguous,
  rate-limited and unreadable-body failures preserving them; a failed write not
  reporting success. Driven through the real provider graph.
- **Sign-in and sign-out path (11)** — the regression test for the dependency
  cycle: `appDio` resolves with the shipping graph, sign-in completes, credentials
  are persisted and adopted, a refusal stores nothing; sign-out in all four
  outcomes including the interceptor's renew-then-replay for an expired token.
- **Credential store (14)** — a half-present pair is not a session; a failed write
  leaves nothing behind; clearing preserves other keys.
- **Repository (13)** — the exact documented envelopes decode; logout sends no body
  and decodes `data: null`; terminal codes, `429` with `Retry-After`, `503`, `500`.
- **Router (12)** — `redirectFor` over every location and session state, and four
  widget tests driving the real provider-built router in both directions.
- **Bootstrap (10)** — the base-URL check and slash normalization; the credential
  read's handling of a full pair, a partial pair and an empty store; the override
  set wiring a working container in both signed-in and signed-out states; and that
  `refreshDio` carries no auth interceptor while `appDio` does, which is the
  structural guarantee that renewal cannot recurse.

The cycle regression test was validated by reintroducing the offending edge and
confirming it fails with Riverpod's own `CircularDependencyError` chain
(`sessionControllerProvider -> appDioProvider -> Provider<AuthApi> ->
Provider<AuthRepository> -> sessionControllerProvider`), then reverting it.

### Design system v1 milestone

| Command | Result |
| --- | --- |
| `flutter pub get` | `Got dependencies!` — **`pubspec.lock` unchanged**, no dependency added |
| `dart format <19 changed files>` | `Formatted 19 files (15 changed)` |
| `dart run build_runner build` | **Not run — correctly.** No `@riverpod`, `@RestApi`, `@freezed`, `@JsonSerializable` or `@JsonKey` annotation was added or changed, so there is nothing to regenerate. Verified with a diff scan of `lib/`. |
| `flutter analyze` | `No issues found!` (whole project) |
| `flutter test` | `All tests passed!` — **177 tests** (was 137) |
| `build/unit_test_assets/FontManifest.json` | All three families registered with the exact weights the type layer requests: Silkscreen 400/700, Inter 400/500/600, JetBrains Mono 500 |

New and changed coverage:

- **Theme (15)** — system brightness selecting light vs dark; the two themes being
  genuinely distinct; the accent being the approved Dusty Sage in both; the selection
  tokens tracking the accent; the accent clearing AA as a chip label on its own tint and
  as a primary-button label; the pixel face confined to display roles; the mono face
  confined to machine text; variable faces setting their `wght` axis; and the scaffold,
  app bar and navigation bar reading the active tokens.
- **Sign-in widget (13)** — the heading, a labelled field per credential with the label
  above the field, no bottom navigation, obscuring rules, tokens read from the theme in
  force; three client-side validators that must not reach the network; a successful sign-in
  adopting the session and storing both credentials; a refusal storing nothing; client copy
  rather than the server message; dismissal clearing the message **without** retrying; a 429
  showing the countdown only when the server sent one; and the form disabled in flight.
- **Sign-in copy (5)** — `messageFor` over every `ApiFailure`: a wrong password and an
  unknown address reading identically; the countdown being present or absent, never
  invented; a 503 and an offline device not collapsing together; an uncertain outcome never
  claiming nothing happened; and no variant calling the service broken.
- **Inbox (3 new)** — the intake rendering both actions, **Save URL being the only filled
  button**, the URL field using the mono face, and Save URL disabling when the field is
  cleared.
- **Saved-item row (2 rewritten)** — a preview drawing as a hatch and a missing one as a
  dashed well, the two being distinguishable, and the thumbnail space being reserved either
  way so rows never shift.

Two failures during this work were real defects and were fixed, not worked around:
`Size.fromHeight` on a button minimum size forces an **infinite width**, which broke the
Inbox intake's `Paste` button and the Profile screen's outlined button; and `AppField`'s
first draft rendered the validator message twice, once through Flutter's decoration and
once by hand.

### Input and feedback sizing refinement

| Command | Result |
| --- | --- |
| `dart format` (6 changed files) | `Formatted 6 files (3 changed)`; re-run 0 changed |
| `flutter analyze` | `No issues found!` (whole project) |
| `flutter test` | `All tests passed!` — **185 tests** (was 177) |
| Measured, before → after | field height 40 → **48**; text inset 0 above / 20 below → **14 above / 14 below**; failure band ≈ 100 px → **as tall as its message**, with Dismiss no longer adding height |
| Measured at 390 × 844 | Inbox intake 145 px; URL field 48 px; Paste and Save URL share one 34 px row, edges aligned; no overflow |

Eight tests added, and each was confirmed to **fail against the previous code** rather than
passing either way — a test that passes both ways is noise:

- **`test/shared/widgets/app_field_test.dart` (6)** — the field is the shared height and
  clears 48 px; the text run is vertically centred within 1 px; the mono variant has
  identical geometry; the decoration is not dense; a narrow width does not overflow; an
  omitted label leaves no stray gap. Reverting `fieldHeight` to 40 fails two of them, and
  re-introducing `isDense` with a horizontal-only inset fails two more.
- **Failure band (2, added to `sign_in_screen_test.dart`)** — the message and Dismiss share
  a row, and a long message on a 320 px surface wraps without clipping or overflowing.
  Re-stacking them fails seven tests.

### `GET /saved-items` integration milestone

**These are reported results from the implementation session, not checks re-run when this
entry was written.** They were run against the code as it stood at the end of that session.
Nothing has been executed since; re-run them before relying on them.

| Command | Reported result |
| --- | --- |
| `dart run build_runner build --delete-conflicting-outputs` | Built, 5 outputs. **Needed**: new `@RestApi` and `@freezed` types |
| `dart format lib test` | `Formatted 104 files (17 changed)`; re-run `0 changed` |
| `flutter analyze` | `No issues found!` (whole project) |
| `flutter test` | `All tests passed!` — **236 tests** (was 185) |

**No device, emulator or live backend was involved.** Nothing below is evidence about how
the feature behaves against a running server.

New coverage for this milestone:

- **DTO decoding (10)** — the fully-populated row including the nested `collection`, all
  four nullable fields as `null`, pending and failed rows, the empty page as `[]` not
  `null`, a final page's explicit `null` cursor, an opaque cursor preserved byte for byte,
  and server order preserved.
- **Mapper (11)** — null `title`/`description`/`image_url` staying null; empty `image_url`
  treated as no image; the three enrichment values; an unrecognised value resolving to
  `pending`; every saved-time range, plus null for an unparseable or future timestamp.
- **Repository (12)** — envelope decoding, empty result, no cursor on the first request,
  cursor passthrough, `has_more`/`next_cursor` exposure, missing `meta` and null `data` both
  unreadable, four error mappings, and `INVALID_CURSOR` landing in the defensive bucket.
- **Controller (14)** — first page; `retry()` refetching rather than replaying page one and
  recovering from a failed first page; appending; sending the cursor it was given; stopping
  on the final page, on a null cursor, and on `has_more` alone; not stacking in-flight
  requests; and keeping loaded rows when a later page fails.
- **Inbox (13)** — skeleton while in flight and the skeleton occupying the card layout; rows
  in API order with per-row collections; empty state; null-metadata URL fallback; the three
  enrichment states; inline error with a Retry that genuinely refetches; no backend message
  on screen; an expired session reading as a sign-in problem; and the intake's Paste/Save URL
  rules.
- **Protected pipeline (2)** — the request carries the session's bearer token, and an
  `ACCESS_TOKEN_EXPIRED` is renewed and replayed by the interceptor with no involvement from
  this feature. **No auth code was changed.**

Two tests were confirmed to fail against the code they cover: removing the de-duplication
guard fails the duplicate-id test, and removing the `has_more` stop condition fails the
contract-violation test. An empty-page state bug — the skeleton was drawn instead of the
empty state — was found by these tests and fixed in the screen, not in the test.

Two existing tests were also updated for a consequence of this milestone: pumping the app
shell now performs a real request, so `widget_test.dart` and `auth_redirect_widget_test.dart`
script the transport and disable Riverpod's automatic provider retry. Neither changed what
they assert.

### AuthInterceptor exception-handling fix

**Complete for this iteration.** A renewal that failed outside `SessionExpiredException` and
`DioException` escaped `AuthInterceptor._renewAndReplay`'s `unawaited` future. Dio completes
a request from its `ErrorInterceptorHandler`, so a handler that is never completed leaves the
caller's `await` pending forever: the request **hung** rather than failed, with no error and
nothing to report. Three paths reached it — a rotated pair that could not be persisted, a
refresh token that could not be read before any request was attempted, and a cleanup that
failed while clearing credentials on a terminal outcome.

The two `try` blocks gained new arms, and not the same ones. On the **renewal** block:

- **`ApiFailure`** is passed through unchanged. It is already classified by the layer that
  raised it, and re-deriving a decision from a status would discard the reason the renewal
  actually failed.
- **Anything else** becomes `ApiFailureCredentialStorage(cause: …)` — this device could not
  produce a usable session — and the request is rejected, never replayed.

The **replay** block gained only a catch-all, beside the `DioException` arm it already had.
There is deliberately no `ApiFailure` pass-through there: `_replay` returns `dio.fetch`, and
every failure that produces is already a `DioException`. An `ApiFailure` reaching that block
would be wrapped a second time rather than passed through, which is why the arm exists only to
stop an unmodelled throw from leaving the handler unresolved, not because that case is
expected.

The `DioException` arm's construction moved into a `_renewalFailure` helper, field for field
identical, so that arm's behaviour is unchanged. Every arm completes the handler and returns,
which is what makes the exactly-once property hold; Dio also throws `StateError` on a
*second* completion, so "twice" would be a defect too.

**Unchanged, deliberately.** A successful renewal still persists both tokens before the
replay. A terminal code still surfaces the original `401` with credentials cleared. An
ambiguous failure — `500`, transport, `429`, `503` — still reaches the caller as
`ApiFailureRefreshUncertain` with the stored tokens intact and is still not retried
automatically; `mapApiFailure` never reaches a new arm.

**Credential-storage failure is not one case, and none of them replays the request.** A
refresh-token read failure, a failed cleanup and an unexpected exception all reach the
interceptor, become `ApiFailureCredentialStorage`, and clear nothing. A **rotated pair that
could not be persisted** is different, and that difference is pre-existing: `_persist` calls
`_endSession()` before it throws, because an access token the client cannot refresh beside a
refresh token that does not match it is unusable, so that case signs the user out on purpose.
The new arms neither introduce nor remove that.

Seven regression tests across **five scenarios** — the extra two are duplicate coverage, not
missing scenarios. A refresh-token read failure and a persistence failure are each covered
twice: once against a stub `TokenProvider` in `auth_interceptor_test.dart`, which isolates the
interceptor, and once through the real `appDio` graph in `session_controller_test.dart`, which
exercises `SecureCredentialStore` and `SessionController` as they ship. Three of the seven
therefore sit in the former file and four in the latter.

- a refresh token that cannot be read, before any `POST /auth/refresh` is made;
- a rotated pair that cannot be persisted — asserted to fail with a `null` response, so the
  original `401` is not laundered into it, and **not replayed**;
- an unexpected `StateError`, asserted to arrive with its `cause` retained, not discarded;
- a terminal refresh whose cleanup fails, asserted to leave both the stored credentials and
  `AuthStatus` untouched rather than claiming a completed sign-out;
- a failed renewal leaving the interceptor usable on the next request.

Each was confirmed to **fail against the previous code**, and each failed two ways at once.
The request never completed, so every `expectLater` tripped the five-second bound its own test
places on the await — the runner advanced in exact five-second steps. Alongside that, in all
seven cases the exception that had escaped `_renewAndReplay` surfaced first as an unhandled
zone error: `PlatformException` for the read and cleanup failures, `Bad state: boom` for the
unexpected-throw cases, and `Instance of 'ApiFailureCredentialStorage'` for the persistence
cases.

| Command | Result |
| --- | --- |
| `dart format` (5 changed files) | `Formatted 5 files (1 changed)`; re-run `0 changed` |
| `flutter analyze` | `No issues found!` (whole project) |
| `flutter test` (2 focused files) | `All tests passed!` — **41 tests** |
| `flutter test` | `All tests passed!` — **243 tests** (was 236) |

**No device, emulator or live backend was involved.**

**Still open.** This closes the hang; it does not close session lifecycle. A credential
cleanup that fails still leaves local auth state describing a session the backend has already
ended, so the app stays signed in until a later renewal resolves it. That is a separate
decision about ambiguous local credential state, not part of this fix. `_endSession`'s
clear-then-discard ordering is deliberately unchanged: reversing it would race a sign-in
writing a fresh pair against an in-flight clear.

### `savedItemsProvider` automatic-retry fix

**Complete for this iteration.** Riverpod retries a failed provider build by default, and
`savedItemsProvider` was one of the providers it retried. Verified against the **installed**
`riverpod 3.4.3` — the version in `pubspec.lock` and the resolved paths in
`.dart_tool/package_config.json` — rather than inferred from documentation or a neighbouring
version. `ProviderContainer.defaultRetry` allows **ten** rebuilds on a 200 ms doubling backoff
capped at 6.4 s, and its only exclusions are `ProviderException` and `Error`. `ApiFailure` is
a plain sealed class, so it is not among them.

The consequence was specific to this provider. A renewal that fails ambiguously is
deliberately **not** retried — the outcome is genuinely unknown, the stored credentials are
kept, and the user decides (`ApiFailureRefreshUncertain`, and the manual retry **D23** asks
for). But a Riverpod rebuild issues a brand-new `RequestOptions`, so the interceptor's
one-replay bound restarts each time and a second `POST /auth/refresh` presents the **same**
refresh token. The backend reads that as reuse, revokes the session and answers
`SESSION_REVOKED` — so the framework, unprompted, destroyed roughly 200 ms later the exact
session the client had deliberately preserved.

**The change is one annotation argument.** `SavedItems` now passes `retry: _neverRetry`, a
private top-level function returning `null`. `null` is how Riverpod is told not to retry:
`triggerRetry` reads it as "no delay", arms no timer, and publishes `AsyncError` rather than
the `AsyncLoading` it would otherwise publish while a retry is pending.

Two things worth recording, because both are easy to get wrong:

- **`@Riverpod(retry: (_, __) => null)` does not compile.** The annotation is a `const`
  constructor and an inline closure is not a constant expression. Riverpod 3.4.3 ships no
  built-in no-retry constant and `Retry` is `@internal`, so a named top-level function is the
  only route — and a top-level tear-off *is* a constant expression.
- **`invalidateSelf` only schedules a rebuild while the element `isActive`,** and `isActive`
  is `listenerCount > 0`. An unlistened provider is mounted but inert, so the regression tests
  below passed against the *unfixed* code until they were given a listener modelling
  `InboxScreen`'s `ref.watch`.

`saved_items_controller.g.dart` was regenerated with `dart run build_runner build` and now
emits `retry: _neverRetry` where it emitted `retry: null`. **`ProviderScope`, `appDio`,
`AuthInterceptor` and `SessionController` are untouched**: no global retry policy changed, and
the session controller and the router keep Riverpod's default. Because the provider is
`keepAlive`, its Retry button remains the only way the listing is fetched again.

**Five regression tests**, in a file of their own —
`test/features/saved_items/application/saved_items_no_auto_retry_test.dart`. They are separate
because `saved_items_controller_test.dart` passes `retry: (_, _) => null` to its container,
which is right for its request-count assertions and **would mask this defect entirely**.
Every container in the new file is built on Riverpod's **real default policy**; suppressing
retry is the provider's job, and one test asserts the override is attached at all.

- **Four fail against the previous code.** Removing the argument and regenerating makes the
  request count `3` rather than `1` — two extra `GET /saved-items`, at the 200 ms and 600 ms
  retries — and leaves the provider in `AsyncLoading(retrying)` rather than `AsyncError`, which
  is precisely what keeps the Inbox's Retry action unreachable.
- **One is an invariant guard, not proof.** *"an ambiguous renewal failure keeps the stored
  credentials"* passes with **and** without the fix, because the scripted `/auth/refresh`
  always answers `500`, so the renewal stays ambiguous however often it is retried. It pins the
  policy the fix protects; it is not evidence that retries stopped.

| Command | Result |
| --- | --- |
| `dart run build_runner build` | Built, 4 outputs; a re-run writes `0 changed` outputs, so generation is in sync |
| `dart format lib test` | `Formatted 105 files (0 changed)` |
| `flutter analyze` | `No issues found!` (whole project) |
| `flutter test` (`features/saved_items` + `features/inbox`) | `All tests passed!` — **74 tests** |
| `flutter test` | `All tests passed!` — **248 tests** (was 243) |

**No device, emulator or live backend was involved.** Nothing here is evidence about how the
feature behaves against a running server, and the reuse-detection consequence above is read
from the backend's Go source rather than observed.

**Limitation — the regression tests wait on real time.** `fake_async` is present in the pub
cache but is not a declared dependency, and adding one is not a decision this change should
make, so the tests use `Future.delayed(1200ms)` — the project's existing convention, as in
`untilCalled`. That clears both the 200 ms and 600 ms retries with 2× margin and makes the
counts unambiguous (1 versus 3), but it is wall-clock rather than deterministic. Under heavy
CI load it is the one part of this suite that could go flaky. A `testWidgets` using
`tester.pump` would give fake time with no new dependency, at the cost of widget scaffolding
these tests do not otherwise need.

**Not covered.** Only the Inbox listing. Any future `@Riverpod` AsyncNotifier that makes
protected reads inherits the same default unless it opts out, and nothing enforces that
convention yet.

### One-time session-expired feedback

**Complete for this iteration.** A session can end while the user is on another destination: a
renewal the backend refuses terminally clears the credentials, `AuthState` follows, and the
router moves them to `/sign-in`. Nothing said why, so the screen was a bare form and the natural
reading was that they had done something wrong.

**The carrier is a flag on `SessionController`, not a notification system.** `_endSession()`
sets it; `SignInScreen` consumes it once in `initState`. Three properties fall out of choosing
that point rather than another:

- **Terminal only, structurally.** `_endSession()` is the single place the client knowingly ends
  a session, so an ambiguous failure — `500`, transport, `429`, `503` — cannot set the flag
  without needing a conditional. `ApiFailureRefreshUncertain` deliberately keeps the credentials,
  and nothing here changes that.
- **No stale feedback after a logout.** `AuthState.signOut` calls `discard()` directly rather
  than `_endSession()`, so asking to be signed out is never reported back as an expiry. No reset
  logic is needed, because nothing sets the flag in that path.
- **Consumed, not stored.** `consumeSessionEnded()` clears before returning, so a rebuild or a
  later visit gets `false`. It is recorded **after** `clear()` succeeds and **before** `discard()`:
  after, because a cleanup that failed must not claim the session ended; before, because
  discarding is what triggers the redirect, and the screen must not arrive to find nothing.

**The treatment follows `design-system.md` §6.5, which files expiry under Warning** —
`warning-soft` + `warning-border`, a filled `--warning` mark — reserving `danger-soft` +
`danger-border` for a known failure. A lapsed session is not something the user did wrong, and a
danger band reads as their mistake. `_SignInMessage` gained a private `_MessageTone` for this;
danger is the default, so every ordinary sign-in failure keeps the treatment it had without each
call site naming it. The band, its height and its wrapping are identical either way — only the
fill, border and mark change. No new component, no global feedback abstraction, no dependency.

The **Uncertain** row of §6.5 — the same warning colours with a *hollow* mark — is deliberately
not modelled. Nothing on this screen reports an outcome the client cannot determine, so a third
tone would have had no caller.

**Twelve tests in `test/features/auth/presentation/session_expired_feedback_test.dart`**, driving
the real session controller, interceptor and provider-built router against a scripted transport:

- each terminal code redirects to sign-in and shows the message **once**, with the flag consumed;
- a rebuild, and a **fresh mount** of the screen, do not repeat it;
- an ambiguous `500` and a transport failure produce **no** message, leave the session signed in,
  and keep the stored refresh token;
- a deliberate sign-out is not reported as an expiry;
- invalid credentials show their own copy and no session-expired message;
- the expiry band is `warningSoft` / `warningBorder` with a `warning` mark, and the
  invalid-credentials band is `dangerSoft` / `dangerBorder` with a `danger` mark — asserted
  against `AppTokens.light`, because the band is a private widget a test cannot name.

Both halves were confirmed load-bearing by removing each in turn: disabling the screen-side
consumption fails the three terminal tests and the rebuild test, and forcing the expired session
back to the danger tone fails the two treatment tests.

| Command | Result |
| --- | --- |
| `dart format lib test` | `Formatted 106 files (0 changed)` |
| `flutter analyze` | `No issues found!` (whole project) |
| `flutter test` (`features/auth`) | `All tests passed!` — **77 tests** |
| `flutter test` | `All tests passed!` — **260 tests** (was 257) |

**No device, emulator or live backend was involved.** The terminal path is verified against a
scripted transport; the backend's revocation behaviour behind it remains read from its Go source
rather than observed.

**Two limitations worth recording.** First, the app must be pumped as `StashItApp()` with **no
injected router** for the redirect to fire at all: the auth `refreshListenable` only delivers
while `appRouterProvider` is watched, and `StashItApp` is what watches it.
`StashItApp(router: …)` — the seam `auth_redirect_widget_test.dart` uses throughout — skips that
watch, and the redirect then never runs. That test gets away with it because it only asserts states
established before any transition; this milestone's subject *is* the transition. Production is
unaffected, but the seam is a trap. Second, a `testWidgets` body runs in the fake-async zone, so
**awaiting a Dio round-trip inline deadlocks**; the sign-out test uses `unawaited(…)` plus
`pumpAndSettle()`.

The `_endSession` clear-failure inconsistency (open item 6 below) is unchanged and deliberately
untouched — this work records nothing in that case.

## Not implemented

- Collections list, collection contents, deletion.
- Saved-item detail, enrichment retry, filing into a collection.
- Search.
- Registration, Google sign-in, password reset and PIN flows. All exist in the
  backend; none is routed or built.
- Device and session management (`GET /auth/sessions`), deferred by D10.
- The Profile screen's account data. `GET /users/me` is not called.
- Automatic token renewal on a timer. Renewal is reactive only: a client that
  refreshes only when it must uses 0.67 of the `refresh-ip` budget per 10 minutes,
  and `auth-sessions.md` names aggressive client retry as the assumption most likely
  to require that ceiling be raised.
- Pending-URL queue and share intake. The URL field, Paste and Save URL are **rendered but
  not wired** (D25 is approved but not built — it depends on clipboard and Q13; secure
  storage now exists).
- Profile and account actions.
- Localization. `flutter_localizations` is absent and there are no ARB files; every
  string is inline English, including the sign-in copy. D20 fixes Flutter as the
  owner of all user-facing text and v1 is `en` + `id`, so this is a **recorded
  deviation, not a decision** — the sign-in strings are placeholders awaiting ARB.
- Clipboard, deep links, URL launching.

`lib/` now has `core/` (`error`, `network`, `storage`), `shared/widgets/` (`AppButton`,
`AppField`) and `features/auth/`, `features/inbox/`, `features/saved_items/`. It still has
no `l10n/`; each directory appears only when a real file needs it (`AGENTS.md` §2).

---

## Known gaps and open decisions

Carried from the discovery documents, plus what this milestone surfaced.

### Open items this milestone raised

1. **The ambiguous-renewal policy is a judgement, not a derivation.** On a `500` or
   a transport failure from `POST /auth/refresh`, the commit outcome is genuinely
   unknown — `auth-sessions.md` says a failed commit yields `500` rather than a false
   "you were revoked", and separately that a lost refresh response costs the
   session. The implemented policy keeps the credentials and does not retry
   automatically, on the reasoning that signing a user out on a network blip is
   worse than delaying it. **This is not derived from the contract and should be
   confirmed.** The trade: the user may need one further attempt, and that attempt
   may trip reuse detection and end the session — which is unavoidable either way.
   No copy claims that keeping the credentials guarantees recovery.
2. **Logout with an expired access token renews first** — now as a consequence of the
   interceptor rather than as separate logout code. The bearer guard would otherwise
   refuse the call and the server session would survive until it lapses, up to 90
   days. Renewal costs one rotation on a deliberate user action, bounded to a single
   replay. The trade is no longer a bespoke choice and needs no separate decision.
3. **`X-Installation-ID` is not sent** (`decisions.md` Q7 is still **[Open]**). It
   must parse as a UUID or login fails with `400 INVALID_INSTALLATION_ID`, and it
   is the one header that would force a `uuid` dependency for a device list this
   phase does not build. `X-Platform` and `X-Device-Name` are sent, so a future
   device list needs no retrofit.
4. **Two backend Swagger annotations under-document their routes** and were not
   changed here: `/auth/refresh` omits the `IP_RATE_LIMIT_*` codes its route
   middleware can emit, and `/auth/login`'s description omits
   `IP_RATE_LIMIT_EXCEEDED`, `CLIENT_IP_UNAVAILABLE` and
   `PASSWORD_WORK_UNAVAILABLE`. The Go implementation is authoritative and this
   client handles all of them. Worth reporting to the backend repository.
5. **Generated-file policy (gap 7 below) is now live.** Generated files exist
   alongside their sources and `.gitignore` ignores neither, so they will be
   committed. That was the pre-existing default, not a choice made here.
6. **A failed credential cleanup still leaves local auth state describing a
   session the backend has ended.** `_endSession` clears storage before it discards
   state, so a `clear()` that reports failure leaves `AuthStatus.signedIn` with the
   tokens still on disk. Deliberate for now — reversing the order would race a sign-in
   writing a fresh pair against an in-flight clear — but it is a real inconsistency,
   not a settled policy. The interceptor fix above only guarantees such a request
   *completes*; it does not decide what the app should then believe.

### Carried from the discovery documents

1. **The Inbox client integration is done, but was built without product sign-off.** The
   `GET /saved-items` contract is implemented end to end and the screen no longer runs on
   mock data. Nothing about the contract was guessed; nothing about the *presentation* of
   it was confirmed — see the two contract observations above and the copy flag below.
2. **Collection count display is undecided.** `GET /collections` now returns
   `saved_items_count` (0–99, capped) and `saved_items_count_overflow`. Whether to
   show it is still governed by **[Rec]** §2.7 ("show no counts") and the **[Open]**
   question in §D.5. Availability is not approval: the rationale behind §2.7 is now
   obsolete, but the recommendation itself is unchanged.
3. **Inbox UX partially settled by implementation, not by decision.** Loading and empty
   states exist, and the screen pages on scroll. The copy for both, and the saved-time
   wording, were chosen during implementation — the documents settle neither, so treat
   all three as revisitable. Bounded-end paging remains genuinely open: the screen has
   no end boundary.
4. **`flutter_localizations` absent.** Tolerable for a prototype, not for real screens.
5. **Secure storage undecided (V5).** §7.12 rejects plain files and shared preferences,
   so this is a decision to make, not a workaround to invent.
6. **No build-time configuration.** No `--dart-define`/flavour convention exists for
   the API base URL, so nothing can reach a backend yet.
7. **Generated-file policy undecided.** `.gitignore` ignores neither `*.g.dart` nor
   `*.freezed.dart`. First relevant when the first annotation is added.
8. **`riverpod_lint` enables no rules.** Registered in `analysis_options.yaml`, but no
   rule is listed, so it currently contributes nothing.
9. **Open product questions** any Inbox or queue work must respect: **Q13** (input
   validation timing), **Q10 / V14** (URL equivalence for local deduplication — no
   normalization may be implemented), **Q1 / Q2** (expiry notification form, queue
   capacity), **Q3** (discard vs retain on permanent validation failure).
10. **V7** — whether a URL should be redacted before display is unresolved; the row
   currently shows the query string, matching the approved wireframes.
11. **D23** — automatic retry remains a provisional v1 decision, not a permanent rule.
12. **No OpenAPI sync mechanism.** The backend contract is read from its Swagger and
    its source by hand. Nothing keeps the two repositories aligned, which is how the
    Inbox drift accumulated. Vendoring or generating the schema is a separate
    decision and has not been taken.

---

## Next milestone

**Network foundation and session.** Nothing can be fetched until a session exists, so
this is the first step toward any real screen.

- `core/network/` — Dio setup, timeouts, a narrow `TokenProvider` interface declared
  *inside* `core/network` (this is what breaks the auth↔network cycle, see
  `AGENTS.md` §2), and the auth interceptor.
- `core/error/` — the `ApiFailure` taxonomy for the **D15** categories (auth required,
  budget exhausted with `Retry-After`, server unavailable without a countdown, invalid
  link, malformed request, unreadable response, transport failure, offline) and the
  single mapper that branches on `error.code`. `error.message` is never displayed
  (D22). This must be done once, not per feature.
- `features/auth/` — login and session lifecycle, including the **serialized,
  single-flight refresh** that §F.4 records as a correctness requirement, not a nicety.

Grounding: the backend `swagger.json` for routes and payloads, `documentation/auth-sessions.md`
for token lifetimes and refresh semantics, `AGENTS.md` §2 for boundaries. **Take the
contract from the backend repository; do not infer it.**

---

## Next milestone

**Collections.** The network foundation and a session now exist, so the first real
data can be fetched.

- `features/collections/data/` — `GET /collections` against the verified contract.
  It is the root data dependency for S8/S9/S12/S13 and resolves Unsorted by
  `system_key`, never by display name (D2).
- **Settle the count question first** (gap 2 above), so the DTO is written once.
- The Inbox against `GET /saved-items` is **done** and no longer waits on the
  Collections DTO decision — it was built against the verified contract on its own.
- Profile account data from `GET /users/me`, replacing the placeholder.

Before any of that: retest manual sign-in on a device. The dependency cycle that
blocked it is fixed and covered by a regression test, but runtime behaviour after the
fix has not been observed.

One policy question is still open: the ambiguous-renewal behaviour recorded above.

---

## Reference

- Working rules: [`AGENTS.md`](./AGENTS.md)
- Approved product decisions: [`docs/product-discovery/decisions.md`](./docs/product-discovery/decisions.md)
- Reasoning, API mapping, state matrix: [`docs/product-discovery/ux-discovery.md`](./docs/product-discovery/ux-discovery.md)
- UX baseline: [`docs/wireframes/README.md`](./docs/wireframes/README.md)
- Backend contract (separate repository, authoritative for API behaviour):
  `docs/swagger.json`, `AGENTS.md`, `PROGRESS.md`, `documentation/*`
