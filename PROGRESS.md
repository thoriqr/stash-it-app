# PROGRESS.md — Stash-it Flutter client

Handoff document for the next coding session. Rules live in [`AGENTS.md`](./AGENTS.md);
product behaviour lives in [`docs/product-discovery/`](./docs/product-discovery/README.md).
Neither is duplicated here.

**Status:** the application shell, one presentation prototype, and the **authentication
and network foundation** are complete. Manual sign-in, secure credential storage,
startup restoration, access-token attachment, single-flight renewal, session
invalidation and logout all work and are tested. **No product feature beyond
authentication is implemented** — the Inbox still runs on labelled mock data, and
Collections, Search and Profile data are not fetched. Registration, Google sign-in
and password reset are not built.

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

### Theme — Paper & Ink (provisional)

`lib/app/theme/app_theme.dart` plus `AppTokens` in `lib/app/theme/app_tokens.dart`.

**This is a provisional visual baseline the user accepted for further work. It is not
an approved brand identity and not a design system.** The visual language is still
undesigned (`decisions.md` §6), so expect these values to move.

| Role | Value |
| --- | --- |
| Paper background | `#FAFBF9` |
| Primary surface | `#FFFFFF` |
| Secondary neutral | `#F0F2EF` |
| Primary text | `#202522` |
| Secondary text | `#5B625C` |
| Primary accent (deep pine) | `#315B49` |
| Soft accent surface | `#E6EDE9` |
| Border / divider | `#E2E5E2` |
| Semantic danger | `#A15C43` |

Material 3 only. No custom fonts, no assets, no dependencies beyond the template set.
`AppTheme.dark()` currently returns the light theme rather than inventing a dark
palette.

**Paper grain was evaluated and not implemented.** A genuine per-device-pixel grain
needs a tiled texture asset or a runtime shader; a logical-pixel `CustomPainter` grain
at this device's pixel ratio reads as visible speckle. Solid paper was used instead.

### Saved-item row

`lib/features/saved_items/presentation/widgets/saved_item_row.dart` — one reusable
widget, matching the anatomy in `docs/wireframes/02-item-presentation.html`: optional
thumbnail, title, compact source with saved-time label, optional description, then a
metadata line carrying the current collection and the enrichment state.

No cards and no shadows: separation comes from hairline dividers drawn by the parent
list. Colour carries one rule — the accent marks identity and progress (collection
pill, pending marker, retry), factual copy is neutral, and only failure uses danger.

Beside it, `lib/features/saved_items/domain/saved_item_summary.dart` is a **mock
presentation model**, not a DTO. It holds the `title → URL → domain` fallback chain
and the three `EnrichmentStatus` values from **D8**. The field set reflects what a row
needs to render; **no field has been agreed with the backend.**

### Inbox — contract available, client not integrated

`lib/features/inbox/presentation/inbox_screen.dart` renders six fabricated items from
`lib/features/inbox/presentation/inbox_mock_data.dart`, under a visible notice stating
that every item is mock data.

**`GET /saved-items` now exists and is implemented in the backend.** Verified in the
backend source and its Swagger:

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

**There is still no API client, DTO, repository, or mapper for it in this
repository.** That is a client gap, not a backend gap.

**Saved-time labels are pre-written mock strings** (`Saved 12 min ago`, `Saved
yesterday`, …). They are deliberately `String`s rather than timestamps so the model
cannot imply a format, ordering rule or timezone policy. The contract exposes
`created_at` on every read, but the relative-formatting policy — which thresholds,
which phrases, which locale — is still undefined client copy under D20/D22. **Future
integration must follow the actual API contract, not these strings.**

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

---

## Not implemented

- Inbox loading, empty states, pagination behaviour, and any real data. The listing
  contract exists; nothing consumes it yet.
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
- Pending-URL queue, share intake, the URL field, Paste and Save URL (D25 is approved
  but not built — it depends on clipboard and Q13; secure storage now exists).
- Profile and account actions.
- Localization. `flutter_localizations` is absent and there are no ARB files; every
  string is inline English, including the sign-in copy. D20 fixes Flutter as the
  owner of all user-facing text and v1 is `en` + `id`, so this is a **recorded
  deviation, not a decision** — the sign-in strings are placeholders awaiting ARB.
- Clipboard, deep links, URL launching.

`lib/` now has `core/` (`error`, `network`, `storage`) and `features/auth/`. It
still has no `l10n/` and no `shared/`; each appears only when a real file needs it
(`AGENTS.md` §2).

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

### Carried from the discovery documents

1. **The Inbox client integration is not started.** The `GET /saved-items` contract
   exists and is verified; no API client, DTO, repository, or mapper has been
   written. The screen still runs on labelled mock data.
2. **Collection count display is undecided.** `GET /collections` now returns
   `saved_items_count` (0–99, capped) and `saved_items_count_overflow`. Whether to
   show it is still governed by **[Rec]** §2.7 ("show no counts") and the **[Open]**
   question in §D.5. Availability is not approval: the rationale behind §2.7 is now
   obsolete, but the recommendation itself is unchanged.
3. **Inbox UX still open** — loading and empty-state copy, whether the screen pages on
   scroll or stops at a bounded end, and the saved-time display policy. None of these
   is settled by the backend contract.
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
- Then the Inbox against `GET /saved-items`, which is no longer blocked on anything
  except the Collections DTO decision.
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