# AGENTS.md — Stash-it Flutter client

Operating guide for coding agents working in this repository. Use it to understand
what exists and how to work here. Update this file only if explicitly asked.

Three authorities apply here, and none of them silently overrides the others:

- **Current implementation behaviour** — inspect the code to learn what actually
  exists today. Code is the record of what has been built, not of what is correct.
- **Product behaviour** — `docs/product-discovery/decisions.md` §1 remains binding
  for confirmed product decisions, exactly as set out in §1 below.
- **Backend contracts and invariants** — the backend repository remains
  authoritative.

Existing code does **not** silently override an approved product decision or a
verified backend contract. If the code and either of those disagree, the code is
wrong or the decision has changed — report the conflict rather than adjusting one to
match the other.

- **What this repository is:** the Flutter mobile client for Stash-it.
- **What it is not:** a monorepo. The Go backend lives in a separate repository
  (sibling checkout, conventionally `../stash-it-backend`) and is authoritative for
  every API contract.
- **What this file is:** durable working guidelines. It records *how to work here*.
  It does not restate product behaviour — that lives in `docs/product-discovery/`,
  which this file cites rather than duplicates.

---

## Execution policy — the emulator and running the app

**Default: do not run the application, and do not touch the user's emulator.**

The user runs the app. Routine verification is limited to non-interactive commands
over the Dart sources.

- **Routine verification is limited to** `dart format` on changed Dart files,
  `flutter analyze`, and `flutter test`, as appropriate to the change.
- **Never run `flutter run` by default.**
- **Never launch, restart, stop, force-stop, reinstall, or otherwise manipulate the
  user's running Android emulator or app** without an explicit instruction. That
  includes `adb` lifecycle and input commands and `flutter install`. Read-only
  queries such as `flutter devices` are fine, but note they can start the adb server —
  if a daemon is already running, leave it alone.
- **Do not run commands or scripts that indirectly launch or alter the running
  application**, including anything backgrounded.
- **Do not treat a green build or test run as permission to launch.** Passing
  verification never authorizes running the app.
- The user is responsible for starting, hot-reloading, hot-restarting, and stopping
  the app during normal development.

### When the user explicitly authorizes a run or emulator operation

This is a default restriction, not an unconditional prohibition. If the user asks for
a run or for a particular emulator operation:

- Perform **only** the operation requested. Do not expand the permission into
  restarting, reinstalling, force-stopping, or otherwise resetting the session.
- **Preserve the existing emulator session** wherever the operation allows it.
- **Ask first** if the request is ambiguous about whether it would interrupt the
  current session. A confirmation is cheap; a lost dev session is not.

---

## 0. Current state — read this first

The repository holds a **running application shell and one presentation
prototype**. It is not an empty project, and it is not a working product either.

What exists today:

- `lib/main.dart` is a thin entry point, `lib/app/` is the composition root
  (app widget, router, theme), and the four destinations are Inbox, Collections,
  Search and Profile (D1) behind a `StatefulShellRoute`.
- A provisional **Paper & Ink** visual baseline: `lib/app/theme/app_theme.dart` and
  `AppTokens`. Provisional — the visual language is still undesigned
  (`decisions.md` §6).
- One reusable widget, the **saved-item row**, at
  `lib/features/saved_items/presentation/widgets/saved_item_row.dart`, with a mock
  presentation model beside it.
- The Inbox renders that row over **explicitly labelled mock data**.
  No API client, DTO, repository, or backend contract exists for the Inbox.
- `PROGRESS.md` records the current milestone, verification results, and gaps.

What does **not** exist: any network layer, authentication, saved-item flows,
collections functionality, search, the pending-URL queue, localization, or secure
storage.

Consequences for how you work:

- The target structure in §2 is a **direction, not a to-do list**. Introduce the
  directories a change actually needs. Never create empty or speculative folders.
- `docs/product-discovery/README.md` once stated that no Flutter project existed here.
  That sentence is stale and has been corrected. `decisions.md` §6 lists state
  management, API client and persistence as "not decided in this phase" — **that is
  resolved** by §2 of this file. The product documents remain authoritative for
  product behaviour; they no longer govern architecture.

---

## 1. Sources of truth

### Reading order

1. This file.
2. `docs/product-discovery/README.md` — orientation, rules for frontend work, labels.
3. `docs/product-discovery/decisions.md` — the decision record (binding).
4. `docs/product-discovery/ux-discovery.md` — the reasoning and the API mapping.
5. `docs/wireframes/README.md` and the five journey HTML files — UX baseline.
6. The backend repository — for anything contractual.

### Hierarchy when sources conflict

| Source | Authority |
|---|---|
| Backend repository (`swagger.json`, `AGENTS.md`, `PROGRESS.md`, `documentation/*`) | **API behaviour, contracts, invariants.** Always wins. |
| `docs/product-discovery/decisions.md` §1 | **Product behaviour.** Binding. |
| `docs/product-discovery/ux-discovery.md` | Reasoning and analysis. Explains a decision; does not override one. |
| `docs/wireframes/` | Structural UX baseline. **Mock data throughout** — a prototype depicts a possible response shape, never an existing contract. |
| This file | Working conventions and architecture. |

### Decision labels are load-bearing

The discovery documents label every claim. Preserve the distinction:

- **[Doc]** — supported by a real source.
- **[Confirmed]** — approved. Treat as binding.
- **[Rec]** — a recommendation **awaiting approval**. Do not implement as decided.
- **[Verify]** — feasibility not yet confirmed. [Not decisions.]
- **[Open]** — undecided, and materially affects the work.

**Do not promote a [Rec] to a [Confirmed], and do not resolve an [Open] by
invention.** If a task cannot proceed without resolving an [Open], stop and say
which question blocks you, rather than quietly picking an answer. Record the
question in `docs/product-discovery/decisions.md` §3 if it is genuinely new; never
edit an existing decision to make it fit your implementation.

Watch for superseded decisions. They are retained in the document with an explicit
`SUPERSEDED` note, and the note wins. (Example: **D3** is superseded by **D26** — the
Inbox and the Unsorted collection contents no longer share a screen.)

---

## 2. Architecture

**Pragmatic hybrid, feature-first.** Feature slices, plus a small `app` composition
root and a `core` directory limited to genuinely cross-cutting capabilities.

This was chosen over pure feature-first because four concerns are cross-feature *by
definition in the product spec*: the shared `error.code` taxonomy, the serialized
session-refresh path, the durable pending-URL queue, and the one-per-session
collections read. It was chosen over layer-first because this client has exactly one
backend, one code-generation toolchain, and no second implementation of anything —
a layer-first tree would add indirection without adding a boundary that is actually
being enforced.

### Target layout

Introduce incrementally. Each folder appears when a real file first needs it.

```
lib/
├── main.dart                     Thin entry point only: bootstrap, then runApp
├── app/                          Composition root. Wiring, not business rules.
│   ├── app.dart                  App widget (router, locale, theme)
│   ├── bootstrap.dart            Pre-runApp async init
│   ├── config/                   Typed build-time configuration (base URL, defaults)
│   ├── router/                   GoRouter, the four destinations, auth redirect
│   └── theme/                    ThemeData, then tokens as designs land
├── core/                         CLOSED list. Every entry traces to a decision.
│   ├── network/                  Dio setup, TokenProvider interface, interceptors
│   ├── error/                    ApiFailure taxonomy + the one error mapper
│   └── storage/                  Secure-storage interface + implementation
├── l10n/                         ARB sources (en, id)
├── features/<feature>/
│   ├── data/                     Retrofit client, DTOs, mapper, repository
│   ├── application/              Riverpod providers
│   ├── presentation/             Screens, widgets
│   └── domain/                   ONLY where a documented rule lives — see below
└── shared/                       Promotion-gated. Only with ≥2 real consumers.
    └── widgets/
```

Feature list, grounded in the decision record: `auth`, `pending_urls`,
`collections`, `saved_items`, `search`, `inbox`, `profile`.

### Dependency rules

These are the rules that prevent drift. Everything else is your judgement.

1. `core/**` must not import `features/**`. This is what keeps the auth interceptor
   unit-testable: it depends on a narrow `TokenProvider` **interface declared inside
   `core/network`**, implemented by a provider in `features/auth`.
2. `shared/**` must not import `features/**`. If a shared widget needs feature data,
   the data is a parameter.
3. Feature → feature is **read-only and one-directional**. A feature may import
   another's `application`/`data`. If two features end up needing each other, the
   shared concept moves to `core/` or under one owner — it does not get a two-way
   import.
4. `presentation` never touches `Dio` or a Retrofit client directly. Screens read
   providers.
5. Only the router names routes. Screens navigate; they do not import each other.
6. `domain/` imports nothing from `data`, `application`, or `presentation`.

### Incrementality rules

- **No empty or speculative directories.** No scaffolding for offline mode, design
  system, analytics, or a macOS target.
- **Keep `core/` small and justified.** There is no `core/utils`, `core/models`,
  `core/extensions`, `core/constants`, or `core/theme`. Feature-scoped constants
  belong to the feature — the backend does the same thing with
  `internal/api/saved_item/constants.go`.
- **No `shared/` until there is a second consumer.** Code stays in its owning feature
  and is imported. A widget that renders a feature's model is *owned by that
  feature*, not promoted to `shared/`.
- **No repository interfaces for single-implementation data sources.** Write a
  concrete class and override the provider in tests. Extract an interface only when
  a second implementation genuinely exists.
- **No use cases, no one-method-per-class abstractions, no `IXxx`/`XxxImpl` pairs.**
- **A `domain/` layer is earned** when it holds a rule that is documented, tested,
  and would otherwise be duplicated in the UI. That currently justifies the
  pending-URL lifecycle (an eight-state machine with explicit restart rules), the
  error taxonomy, and the saved-item display rules (title fallback chain,
  enrichment semantics, `system_key` resolution). It does not justify one for search,
  profile, or the auth forms.
- Prefer **mapper functions** over mapper classes.
- Keep generated files next to their sources (`part 'x.g.dart'`).

### Presentation boundaries

Screens and widgets render state and dispatch user intent. They do not decide what a
failure *means*, they do not parse API responses, and they do not branch on raw
`error.code`. Mapping happens once, in `core/error`.

---

## 3. Product constraints

### Never invent the backend

**Do not invent endpoints, fields, request or response shapes, pagination
behaviour, ordering, or server-side guarantees.** The backend repository is
authoritative. Where a contract is unverified, record the limitation in
`docs/product-discovery/decisions.md` — do not implement around it client-side.

Treat any code outside the verified lists as **unmapped**. Handle it defensively;
never display a backend message for it.

### The Inbox has no data source

**No endpoint that lists recently saved items across collections exists.** The
Inbox is a confirmed product requirement and a *planned* backend capability
(D26, §5.1). No path, schema, pagination contract, or ordering may be invented.

- Any Inbox UI built before that contract exists runs on mock data, and the mock
  data **must be explicitly labelled as mock** in the code — do not let it read as
  a real contract.
- Do not design an API client for it "in advance".

### Behaviours that are easy to get wrong

Cite the decision when implementing these. Read the decision in full before coding.

| Area | Rule | Ref |
|---|---|---|
| Navigation | Four destinations: Inbox · Collections · Search · Profile. Pending URLs are a section within the Inbox, not a fifth destination. | D1, D18 |
| Unsorted | Resolved by `system_key`, never by display name. **The Unsorted ID is server data, not a client constant** — resolve it from `GET /collections`. | D2 |
| Collection contents | One parameterised screen serves **every** collection including Unsorted. Enrichment presentation, pagination, and empty handling must not drift between them. | D3 (surviving part), §4.1 |
| Ordering | Render the server's order; no unnecessary client-side sorting. A held cursor must be discarded when `sort` changes, because a cursor must match the requested sort. | D4 |
| Saving | A save confirmation confirms **only** that the item was created. It must not imply enrichment completed, metadata exists, organization completed, or the item will be moved. | D26 |
| Intake | URL field visible on the Inbox; separate **Paste** and **Save URL**; pasting alone does not save; the value is editable before submission. | D25 |
| Share | A URL received before sign-in is a *first submission*, not a retry. It survives authentication and is never discarded. | D6 |
| Pending queue | Owned entirely by the client. Entry is removed the moment a `201` confirms the save — not when enrichment finishes. It is not an aggregate saved-items view. Seven-day retention; expiry removal must be a notified event. | D7, D13, D14, D17 |
| Retry | Manual retry is the v1 default and is **provisional**. No automatic resubmission on startup, foreground, or connectivity restore. No retry loops. Manual retry uses the existing `POST /saved-items`, one URL at a time. | D23, D24 |
| Enrichment | Three states: `pending`, `completed`, `failed`. `completed` does **not** mean metadata was found. A title-less item is normal, not broken. | D8, D17 |
| Search | Zero results is a successful `200`, not an error, and must not assert the item was never saved. Capped results must be disclosed. | §5, [Rec] 2.5 |
| Delete | Hard delete, irreversible, no undo in v1. Collection deletion has a disposition requirement. | §5, [Rec] 2.3 |
| Session | A concurrent double-refresh revokes the session server-side. The client **must serialize refresh requests** — this is a correctness requirement, not a nicety. | §F.4, [Rec] 2.10 |
| Errors | Branch on `error.code`, **never** on `error.message`. `message` is human-facing prose and is never shown to users. The error envelope is not guaranteed — a non-JSON body is possible. | D15, D22, V12 |
| Certainty | "Known not saved" and "uncertain outcome" are different states and must stay distinguishable in copy, in every language. An uncertain outcome must never be described as definitely unsaved. | D15, D16, §12.4 |
| Localization | Flutter owns all user-facing UI text. v1 ships `en` and `id` via ARB. Saved page content stays in its original language — that is correct, not a bug. | D20, D21, D22 |
| Platforms | Android and iOS. Share intake needs **two different native implementations**; do not assume they are equivalent. | D12, §8 |

### Proposing changes to confirmed behaviour

If implementation pressure suggests an approved decision is wrong, **do not change
it silently.** Write the change down as a proposal — what breaks, what the
alternative is, what it costs — and flag that it needs review. A confirmed decision
changes only through `docs/product-discovery/decisions.md`.

---

## 4. Flutter and dependencies

### Versions

Flutter **3.47.7**, Dart **3.13.5**, `environment: sdk: ^3.12.2`. Do not change the
SDK constraint, upgrade packages, or swap a package without being asked. Preserve
what is declared in `pubspec.yaml` and `pubspec.lock`.

Add a dependency only when a specific implementation requirement cannot be met
without it, and say which one.

**Known gaps.** Several confirmed behaviours need capabilities that are *not yet*
in `pubspec.yaml`: localization (`flutter_localizations`), secure storage for the
pending queue (V5), clipboard (D25), deep links for share intake (V1–V4), and
opening the source URL (§Journey C.3). These are real requirements, not optional
polish. Note in `PROGRESS.md` when one becomes the blocker for a feature, and
propose the specific package — do not work around a missing capability with a
home-grown substitute, and in particular do not substitute plain shared preferences
for the secure storage the decision record requires (§7.12).

### Riverpod 3 — verified behaviours, not Riverpod 2 habits

Most Riverpod tutorials, Stack Overflow answers, and AI-generated code on the
internet describe Riverpod 2. **This project is on `flutter_riverpod` 3.4.x.** The
following are the traps:

- `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider` live in
  `package:flutter_riverpod/legacy.dart`. **Do not use them.** Use `Provider`,
  `FutureProvider`, and `AsyncNotifier`.
- `@riverpod` generates an **auto-dispose** provider. Anything that must survive
  navigation or be shared app-wide (session, collections list, pending queue) needs
  an explicit `@Riverpod(keepAlive: true)`. Do not reach for
  `only_use_keep_alive_inside_keep_alive`-style workarounds; set `keepAlive`
  deliberately.
- `Ref` is a single type. There are no generated `...ProviderRef` subclasses, and
  `FutureProviderRef.future` does not exist — use an `AsyncNotifier`.
- Providers compare values with `==` to decide whether to notify. Give state objects
  value equality (Freezed) rather than relying on identity.
- `AsyncValue.value` is `null` while in an error state, and `valueOrNull` was
  removed. Check `.hasValue` / `.hasError`.
- `Ref.mounted` exists and matters after an `await`. Other `ref` methods throw if
  used after disposal.
- `Mutation` is not part of the public export surface in 3.4.x. Do not build on it.

### Code generation

Four generators run from `build_runner`: `riverpod_generator`, `retrofit_generator`,
`freezed`, and `json_serializable`.

```bash
dart run build_runner build          # generate
dart run build_runner build --delete-conflicting-outputs   # after changing annotations
```

Run generation after adding or changing any `@riverpod`, `@RestApi`, `@freezed`,
`@JsonSerializable`, or `@JsonKey` annotation, and before `flutter analyze` — stale
or missing generated files produce misleading errors. Never hand-edit a `.g.dart` or
`.freezed.dart` file.

There is no `build.yaml` in this repository, so generated files are written next to
their sources. **Whether generated files are committed is an undecided question**;
`.gitignore` currently ignores neither, so they are committed by default. Do not
change that policy without being asked.

### Retrofit and Freezed notes

- Retrofit clients are per-feature `@RestApi` abstract classes with an injected
  `Dio`, a `factory XApi(Dio dio, {String? baseUrl}) = _XApi;` constructor, and a
  `part 'x_api.g.dart'`. Register the client against a `Dio` built in
  `core/network` so auth and error handling stay in one place.
- Return the API envelope types (`{data, message, meta?}`), not bare models.
- Freezed 4.x supports primary constructors and no longer accepts `final` in
  constructor parameters (Dart 3.13 removed the syntax).

### Current analysis configuration

`analysis_options.yaml` excludes `build/`, `android/`, and `ios/`, includes
`flutter_lints`, and registers the `riverpod_lint` plugin — but **enables no
riverpod rules**, so the plugin currently contributes nothing. Enabling a small,
sensible set (`notifier_build`, `avoid_public_notifier_properties`,
`only_use_keep_alive_inside_keep_alive`, `avoid_build_context_in_providers`) is an
available improvement. Do not reformat or restructure existing files just to satisfy
a lint you enabled.

---

## 5. Testing and code quality

### Always run what you change

```bash
dart format <changed dart files>   # formatting, when Dart changed
flutter analyze
flutter test
```

**Never report that analysis or tests passed unless you actually ran them and saw
them pass.** If you did not run them, say so. If a command cannot run, say that
instead of guessing. A green claim that was never verified is worse than no claim.

These are the **only** routine verification commands. Running the app is not part of
verification — see the execution policy at the top of this file.

### Test structure

`test/` mirrors `lib/`:

```
test/
├── support/          Shared harnesses and fakes only
├── core/…
├── features/<feature>/…
└── shared/widgets/…
```

- Unit tests for pure logic — mappers, the error taxonomy, the pending-URL
  lifecycle, the title fallback chain.
- Widget tests for screens and shared widgets.
- **No test should make a real network call.** Put fakes behind providers. If a test
  needs a socket, a boundary was crossed — fix the boundary, not the test.
- Prefer fakes with real behaviour over mocks that assert call counts. Assert on
  outcomes and user-visible state; those survive refactors.
- Write a test that fails before the fix and passes after it. A test that passes
  both ways is noise.
- Cover the states the discovery documents call load-bearing: the four enrichment
  states, empty vs. not-found, 429 vs. 503 vs. offline, known-not-saved vs.
  uncertain, and the pending-URL lifecycle's restart rules.

### Riverpod 3 testing notes

- Prefer `ProviderContainer.test(...)` in unit tests; it registers a teardown that
  asserts the container was disposed.
- **Pass `retry: (_, __) => null` when a test deliberately drives a provider into an
  error state.** Riverpod 3 retries failed providers by default (up to 10 times with
  backoff), which makes error-path tests slow and can corrupt call-count
  assertions.
- Use `overrideWithBuild` to stub a notifier's `build` without constructing the
  notifier.
- Do not use legacy provider types in test overrides.

### Widget tests

`main()` is a bootstrap and cannot be pumped. Pump the app widget from `app/`, as
`test/widget_test.dart` does. Give each test its own router
(`createAppRouter()`) so navigation history does not leak between cases.

Note that a `ListView` only builds the rows that fit on screen. Tests that assert on
items further down a list must set a taller surface
(`tester.view.physicalSize` plus `addTearDown(tester.view.reset)`), or assert only on
what is actually visible.

---

## 6. Workflow and documentation

### Before starting implementation work

Read this file. For anything touching product behaviour, read the relevant decision
in `docs/product-discovery/decisions.md` in full — not just its heading. The
rationale sections carry constraints that the summary tables omit.

### `PROGRESS.md`

`PROGRESS.md` is the handoff document for the next session: what exists now, what was
verified and how, what is blocked, and the next milestone. Keep it **concise** and
keep it honest — record only verification that was actually run, and distinguish
completed work from planned work. Do not restate this file or the discovery documents
in it.

Update it when:

- a milestone completes;
- an important decision changes or a [Confirmed]/[Open] question is resolved;
- a blocker is discovered that affects subsequent work;
- an assumption turns out to be wrong about the backend.

The backend repository is a sibling, not a subdirectory; its `PROGRESS.md` is a
separate file.

### Documentation discipline

- **Do not update documentation for every change.** Update it when it would save a
  future agent real time.
- The product discovery documents are a curated record with a specific label system.
  Edits there are meaningful acts: preserve labels, preserve superseded-decision
  history, do not soften or delete a decision.
- The root `README.md` identifies the project, lists the development commands, and
  points here. Keep it accurate about what does and does not exist.

### Git

**Do not create commits.** Stage nothing, commit nothing, and do not rewrite history.
The repository owner handles commits. Leave changes in the working tree and report
exactly what you changed.

### Scope discipline

Change only what the task requires. Do not refactor adjacent code, rename things for
style, or "improve" files you were not asked to touch. If you believe something
else needs changing, say so in your report rather than doing it.