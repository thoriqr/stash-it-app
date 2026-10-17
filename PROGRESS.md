# PROGRESS.md — Stash-it Flutter client

Handoff document for the next coding session. Rules live in [`AGENTS.md`](./AGENTS.md);
product behaviour lives in [`docs/product-discovery/`](./docs/product-discovery/README.md).
Neither is duplicated here.

**Status:** application shell and one presentation prototype are complete. **No product
feature is implemented.** The `flutter create` template is gone; what exists is a shell,
a provisional visual direction, and a mock-data demonstration.

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

## Verification actually performed

Run from the repository root, Flutter 3.47.7 / Dart 3.13.5:

| Command | Result |
| --- | --- |
| `flutter analyze` | `No issues found!` |
| `flutter test` | `All tests passed!` — 16 tests |

**Device verification is not part of this record.** During the visual iteration, the
app was built and run once on an Android Pixel 8 emulator so a human could judge the
direction on real hardware. That was a deliberate one-off review, not routine
verification, and it is not reproduced by the commands above. No automated device or
integration test has ever run in this repository.

Test coverage today: the shell (four destinations reachable, selection state, router
path), the saved-item row (title, source, collection, the three enrichment states,
fallback title, truncation at 320 px, the saved-time label, unparseable URLs), and the
Inbox screen (six rows, the mock-data notice, one state line per row that needs one).

---

## Not implemented

- Inbox loading, empty states, pagination behaviour, and any real data. The listing
  contract exists; nothing consumes it yet.
- Collections list, collection contents, deletion.
- Saved-item detail, enrichment retry, filing into a collection.
- Search.
- Authentication, session lifecycle, serialized refresh.
- Pending-URL queue, share intake, the URL field, Paste and Save URL (D25 is approved
  but not built — it depends on clipboard, secure storage and Q13).
- Profile and account actions.
- Localization. `flutter_localizations` is absent and there are no ARB files; every
  string is inline English. D20 fixes Flutter as the owner of all user-facing text and
  v1 is `en` + `id`.
- Secure storage, clipboard, deep links, URL launching.
- Any API client, DTO, repository, error mapping, or `core/` directory.

`lib/` has no `core/`, no `l10n/`, and no `shared/`. Each appears only when a real
file needs it (`AGENTS.md` §2).

---

## Known gaps and open decisions

Carried from the discovery documents; none is resolved here.

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

Prerequisite to settle first: how the API base URL is supplied (see gap 6).

Follow-on, once a session exists:

- **Collections**, because `GET /collections` is fully specified, it is the root data
  dependency for S8/S9/S12/S13, and it resolves Unsorted by `system_key` rather than
  by name (D2).
- **The Inbox**, against `GET /saved-items`. The contract is now verified, so this is
  no longer blocked on the backend — only on the network and session work above.
  Decide the count question (gap 2) before building the Collections screen, so the
  DTO is written once.

---

## Reference

- Working rules: [`AGENTS.md`](./AGENTS.md)
- Approved product decisions: [`docs/product-discovery/decisions.md`](./docs/product-discovery/decisions.md)
- Reasoning, API mapping, state matrix: [`docs/product-discovery/ux-discovery.md`](./docs/product-discovery/ux-discovery.md)
- UX baseline: [`docs/wireframes/README.md`](./docs/wireframes/README.md)
- Backend contract (separate repository, authoritative for API behaviour):
  `docs/swagger.json`, `AGENTS.md`, `PROGRESS.md`, `documentation/*`