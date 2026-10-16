# Stash It — Product Discovery

This directory holds the initial UX discovery for the Stash It mobile frontend
(Flutter). It exists to answer *what the product should do and feel like* before
any UI, routing, state management, or API client code is written.

**No Flutter project has been initialized and no application code exists in this
repository.** These documents are the only content here.

## Documents in this directory

| File | Purpose |
| --- | --- |
| [`ux-discovery.md`](./ux-discovery.md) | Consolidated UX analysis: product understanding, user journeys, screen inventory, interaction states, API mapping, pending-share lifecycle, risk ranking. |
| [`decisions.md`](./decisions.md) | Confirmed decisions and their rationale, provisional recommendations, open product questions, and technical verification items. |

Read `decisions.md` alongside `ux-discovery.md` — the analysis and the decision
record are only meaningful together, and neither should be read as a substitute
for the other.

## Product summary

Stash It is a personal place for things a user finds on the internet. They save
an item and can find it and return to it later. The product exists to shorten the
distance between *finding something worth keeping* and *actually going back to it*.

The core loop is:

```
Discover -> Save -> Organize (optional) -> Come Back -> Take Action
```

Two invariants drive nearly every UX decision in this discovery:

- **Saving never depends on organizing.** An unsorted pile is a successful state,
  not a failure or an unfinished one.
- **Saving must be fast.** Saving a URL performs no network call to the source
  page. Metadata enrichment happens afterwards, or never.

The core object is a **Saved Item**: a URL plus metadata enriched from the
original source. The default collection is **Unsorted**, where every save lands.

### Scope for v1

In scope: authentication, saving a URL, the Inbox, saved-item detail and deletion,
collections, search, and metadata enrichment.

**[Confirmed] The Inbox is a bounded history of recently saved items across
collections.** It helps the user verify that a URL was saved and see which
collection the item currently belongs to. **[Confirmed] Collections remains the
collection browser.** **[Confirmed] The Inbox is not an alias for the `unsorted`
collection.** See [`decisions.md` D26](./decisions.md).

**[Open] The Inbox needs a backend listing that does not exist yet.** This is a
recorded product requirement, not an available capability. **[Confirmed]** No
endpoint, request or response schema, pagination contract, or ordering is
specified or implied by these documents, and the backend repository remains
authoritative for any contract that is later designed.

Explicitly out of scope for v1: a full "browse every saved item" view, device and
session management, a separate mobile-web experience, a complete offline mode, a
separate offline navigation destination, and any feature not already supported by
the backend.

Not yet built in the backend, and therefore not designed here: reminders / a
"return later" loop, saved-item editing, bulk operations, favorites or tagging,
idempotent saves, and account deletion.

### Pending URLs

The app distinguishes **pending local URLs** from **backend-saved items**. A
shared or pasted URL is *pending* until the client confirms the backend saved it;
a pending URL is not a saved item, and the local queue is a Flutter responsibility
the backend knows nothing about. A confirmed save removes the queue entry
immediately — the queue tracks whether a save was confirmed, never whether
enrichment finished.

This is a client-side concern with a seven-day retention policy. It is **not** an
offline mode, **not** an aggregate saved-items view, and **not** a fifth
navigation destination. The exact rules live in
[§7 Pending URLs](./ux-discovery.md#7-pending-urls--ownership-lifecycle-and-errors) and [§1](./decisions.md#1-confirmed-decisions); this paragraph
is orientation only.

**Retry (provisional).** Manual retry is the v1 default: when a URL needs to be
sent again after a failure or an uncertain save outcome, the user initiates it.
This is **not a permanent rule** — whether to introduce automatic retry later,
under which conditions, and with what safeguards is a future review, once Flutter
development has made the real UX and queue behaviour concrete.

A URL shared before sign-in is a **first submission**, not a retry: it is never
discarded, survives authentication, and is sent once a session exists.

**Pending UI.** A count and a list of URLs, and nothing more: no local metadata,
previews, titles, or thumbnails, and no dedicated offline mode. Manual retry
submits one URL at a time through the existing `POST /saved-items`.

**Local duplicate handling.** Re-sharing a URL that is *already pending* refreshes
that existing entry in place and keeps its queue position — it does not append a
second entry and does not show a warning. URLs that differ in their query string are
always distinct. This is **local queue behaviour only**: Flutter cannot detect
duplicates the backend has already stored, and it does not change the rule that
duplicate *saved* items are allowed.

**Localization.** Flutter owns all user-facing UI text. V1 ships English (`en`)
and Indonesian (`id`), using ARB resources and generated accessors. Backend
`error.code` values select localized messages; backend `error.message` text is
never shown. Saved item titles and descriptions stay in whatever language the
source page used. Full rules are in [§12 Localization](./ux-discovery.md#12-localization-and-localized-error-messaging) and decisions.md D20–D22.

## For coding agents working in this repository

**Read this file first, then `ux-discovery.md`, then `decisions.md`.**

### Backend documentation is authoritative for backend contracts

Everything in this directory was derived from the backend repository (a
sibling checkout named `stash-it-backend`, outside this workspace). That
repository is the source of truth for API behavior. These documents are a
*summary with reasoning attached* — they are not a contract, and where they
differ from the backend, the backend wins.

Before implementing any screen or API interaction, consult the backend sources
directly. The primary references are:

| Backend source | Use it for |
| --- | --- |
| `documentation/product.md` | Product intent, core loop, saved-item behavior, enrichment rules, collections, search semantics |
| `PROGRESS.md` | Implementation status, exact request/response shapes, rate-limit policies, and the numbered "Important Decisions" list |
| `AGENTS.md` | Contract invariants that must not be broken (ownership, address-by-ID, `system_key` rules, cursor semantics) |
| `documentation/auth-sessions.md` | Token lifetimes, refresh rotation, device listing, accepted session trade-offs |
| `docs/swagger.json` | The generated OpenAPI contract — authoritative for routes, parameters, and payload field sets |

### Rules for frontend work

- **Do not invent endpoints, fields, or behaviors.** If a UX need is not
  supported, it is recorded as a limitation in `decisions.md`, not implemented
  client-side.
- **Branch on `error.code`, never on `error.message`.** Messages are
  human-facing and not stable.
- **Respect the distinction between `pending`, `completed`, and `failed`
  enrichment.** `completed` does not mean metadata was found. A title-less item
  is a normal item, not a broken one.
- **Do not treat `search` returning zero results as an error.** It is a
  successful `200` with empty arrays.
- **Serialize refresh-token requests.** A concurrent double-refresh revokes the
  session server-side.
- **The Inbox's data source does not exist yet.** Do not assume an endpoint that
  lists recently saved items across collections, and do not design against an
  invented contract. See [§1 D26](./decisions.md#d26--inbox-is-a-recent-saved-history-across-collections).
- **Nothing here is an approved architecture decision.** Navigation libraries,
  state management, API clients, and design systems are all still open.

### Labeling convention used throughout

| Label | Meaning |
| --- | --- |
| **[Doc]** | Documented fact, supported by an existing backend source |
| **[Confirmed]** | Explicitly approved product decision |
| **[Rec]** | UX recommendation, **awaiting approval** |
| **[Verify]** | Technical feasibility or behavior that must be investigated before implementation |
| **[Open]** | A decision that materially affects the product or architecture and is not yet made |

Do not silently promote a **[Rec]** to a **[Confirmed]**.
