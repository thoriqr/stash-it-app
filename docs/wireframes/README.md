# Stash It — low-fidelity wireframes

A **browser-viewable, grayscale-only, structural prototype** for the Stash It Flutter app.

It exists to answer layout, state-coverage and interaction-affordance questions **before** any widget
code is written. It is a review artifact, **not** an implementation, **not** a design system, and
**not** a decision record.

The source of truth for product behaviour is [`../product-discovery/`](../product-discovery/README.md).
Where this prototype and those documents disagree, **the documents win**.

---

## How to open

**Double-click `index.html`.**

No server. No install. No build step. No network request. Everything is plain HTML, CSS and a
small vanilla-JS file, and it runs from `file://`.

If you prefer a local server (optional):

```bash
python -m http.server 8000     # then open http://localhost:8000/docs/wireframes/
```

---

## Files

| File | Purpose |
| --- | --- |
| `README.md` | This document |
| `app.css` | Shared grayscale styling and responsive layout rules |
| `app.js` | Viewport presets, annotation toggle, state-variant switcher, sheet/dialog open-close |
| `index.html` | Navigation hub: viewport controls, coverage map, fidelity statement |
| `01-inbox-and-saving.html` | App shell, Inbox states, save flow, pending-URL state matrix |
| `02-item-presentation.html` | Enrichment states, fallback titles, detail, file sheet, delete |
| `03-collections.html` | Collections list, collection contents, deletion disposition |
| `04-search.html` | Search state family including the capped-results limitation |
| `05-auth-and-profile.html` | Auth journeys, auth gate, profile, server-error families |

---

## Screens and journeys represented

All fifteen screens in the discovery screen inventory are represented (S1–S15), grouped by
journey rather than one file per screen.

| Screen | Journey file |
| --- | --- |
| S1 Welcome / sign in | `05` |
| S2 Register (email) | `05` |
| S3 Verify PIN | `05` |
| S4 Complete account | `05` |
| S5 Account-link confirmation | `05` |
| S6 Password recovery | `05` |
| **S7 Inbox** | `01` |
| S8 Collections | `03` |
| S9 Collection contents | `03` |
| S10 Saved item detail | `02` |
| S11 Search | `04` |
| S12 File into collection (sheet) | `02` |
| S13 Delete collection (dialog) | `03` |
| S14 Profile | `05` |
| S15 Pending URLs (Inbox section) | `01` |

### Interaction state families

- **Navigation:** four destinations, each shown with its active state.
- **Inbox:** empty · initial loading · populated across collections · empty-with-pending-URLs.
- **Save flow:** input filled (nothing saved) · in flight · confirmed.
- **Pending URLs:** never submitted · rejected-auth · rejected-429 · rejected-503 · offline ·
  uncertain.
- **Enrichment:** `pending` · `completed` with metadata · `completed` with none · `failed` — shown
  **side by side** so the difference is directly comparable.
- **Preview image:** present · unavailable (reserved space, no error).
- **Collections:** three sorts · pagination · missing collection · empty collection.
- **Collection deletion:** empty shape · non-empty shape · protected collection · mid-operation conflict.
- **Search:** initial · query entered · results · capped · no results · rate limited.
- **Item actions:** detail · enrich retry in progress · missing item · file sheet · delete confirm ·
  post-delete advisory offer.
- **Auth:** full manual chain · social outcomes · account link · password recovery · session expired ·
  429 / 503 / offline families.

---

## Viewport presets

Use the **Viewport** buttons in the toolbar of any file.

| Preset | Frame | Used to evaluate |
| --- | --- | --- |
| **Fluid** | follows your browser window | Natural resizing; no fixed frame |
| **Narrow** | 320 × 568 | Smallest realistic phone; worst case for horizontal space |
| **Portrait** | 390 × 844 | **Primary layout reference** |
| **Landscape** | 844 × 390 | Cramped vertical space |
| **Tablet** | 834 × 1000 | Wider but still single-column-ish |
| **Desktop** | 1180 × 900 | Desktop-like arrangement |

### What to check at each size

- **Portrait** is the reference. Everything else is a stress test.
- **Landscape** is the most likely to break. Check: the URL input eating scarce vertical space,
  item-list density, whether the tab bar plus app bar plus input leave enough room for content, and
  whether actions stay reachable without scrolling.
- **Narrow** is the horizontal worst case. Check that long URLs wrap rather than overflow, and that
  chips and counts do not push the row past the viewport.
- **Tablet / Desktop** must **not** simply stretch mobile content across the window. A content
  column is capped and, on the widest preset, the screen can move to a two-column arrangement
  (main content + supporting panel) without changing the information hierarchy.

### How this is implemented, and its limits

Presets drive layout through a `data-vp` attribute on `<body>`, so a given preset always renders
identically — which is what makes review reproducible. The **Fluid** preset removes the fixed frame
and lets media queries respond to your real window.

**These presets are review instruments.** They test structural possibilities. They do **not** decide
the final Flutter layout, and the arrangement shown at Desktop is a **proposal**, not a decision.

Known rough edges, documented rather than hidden:

- The two-column arrangement is only applied to the Inbox-family screens at the Desktop preset. It is
  an early structural sketch, not a responsive system.
- Nothing here has been tested on a real device or in a real Flutter build.
- **A browser prototype cannot prove, and does not prove, native macOS compatibility.** See the
  platform note below.

---

## Annotations

Toggle **Annotations** in the toolbar. Each screen then shows, underneath it, what it represents:

- which screen or journey it is,
- which decision or constraint it implements,
- the label — `[Doc]`, `[Confirmed]`, `[Rec]`, `[Verify]` or `[Open]`,
- any mock data or missing backend dependency,
- anything deliberately unresolved.

Annotations are visually distinct from the simulated product UI (dotted border, grey background) so
you can judge the screen itself without confusing explanatory notes with user-facing copy.

**Labels mean what the discovery documents say they mean.** A `[Rec]` drawn here is still awaiting
approval. Approving a screen in this artifact does **not** promote it — that happens only in
`decisions.md`.

---

## Which data is mocked

**Everything.** Every URL, title, domain, image placeholder, timestamp, count and state is
fabricated for layout review.

| Mocked content | Why |
| --- | --- |
| All Inbox items | **[Open]** The Inbox listing API **does not exist**. This is the single most important caveat in the artifact. |
| All collection names and contents | Sample data for a real endpoint |
| All search results | Sample data for a real endpoint |
| All profile and identity data | Sample data for real endpoints |
| The item count in the delete-collection dialog | `GET /collections` carries **no count**; the number is a placeholder |
| How many recent items the Inbox shows | **Not decided** — the bounded end-marker is a placeholder |

### The Inbox dependency, stated plainly

The Inbox is a **confirmed product direction**: a bounded history of recently saved items across
collections, each showing its current collection.

**The endpoint that would serve it does not exist.** No path, schema, pagination contract or
ordering has been designed, and **none may be invented**. Every Inbox screen in this prototype is
representative of a *possible* response shape, nothing more. Treat the Inbox screens as
**design proposals awaiting a backend capability**, not as a depiction of existing behaviour.

Mock data in a prototype is a design technique. **It is not evidence that the endpoint exists.**

---

## Confirmed, recommended, and unresolved

### Implemented as confirmed decisions

Four-destination navigation · Inbox as recent-saved history across collections · Collections as a
separate browser · the Inbox URL input with separate **Paste** and **Save URL** · paste-does-not-save ·
editable before submission · save confirmation implying only persistence · pending URLs as a count
and list inside the Inbox (not a fifth destination) · the pending queue being distinct from saved
items · save-certainty wording (known-not-saved vs uncertain) · 429 countdown vs 503 no-countdown ·
manual retry as the v1 default · seven-day retention with prior notification · the four enrichment
states and their presentation rules · fallback title chain · routine broken images · one
parameterised collection-contents screen · Unsorted identified by `system_key` · no item counts · no
create-collection action · cursor reset on sort change · the collection-deletion disposition
requirement · capped-search disclosure · zero results not an error · no automatic deletion of
collections.

### Shown as recommendations (awaiting approval)

Row composition and rhythm · state-line wording · file-sheet ordering and labels · post-delete
advisory offer · the empty-collection dialog shape · holding the URL visible during auth · single
enrich-retry treatment · `has_password_credential` as the password-action hint · most chip and
placeholder styling · all tab-bar and navigation presentation.

### Deliberately unresolved — not drawn

| Unresolved | Why nothing is drawn |
| --- | --- |
| **Q13** — when/whether the Inbox input validates | No validation, invalid-URL, or clipboard-failure state exists, because inventing one would pre-empt a product decision |
| **Q1 / Q2** — expiry-notification form, queue capacity | An overflow screen needs a capacity number and a notification form that do not exist yet |
| **Q3** — discard vs retain on a permanent validation failure | Would determine whether the queue needs an edit affordance |
| **Q6** — whether Google leads the welcome screen | Both orderings are shown as labelled alternatives rather than one being chosen |
| **Q9** — whether to explain automatic organization at all | The direction is confirmed (do not depend on a per-item notification); the wording is not decided |
| **Q8** — whether to surface search result ordering | Results are best-match first; whether to say so is undecided |
| **D11** — account deletion | **No backend endpoint exists.** Drawing a flow would imply support. Flagged on the Profile screen instead. |
| Collection rename / merge | No endpoints exist |
| Saved-item editing, favourites, tags, bulk operations | Not implemented in the backend |
| Device / session management | Deferred in v1 |

---

## Out of scope for wireframing

### Platform behaviour

Wireframes cannot represent, and this artifact does not attempt to represent:

- **Android sharing.** `ACTION_SEND` with `text/plain`, delivered to the activity. The cold path
  reads the launching intent; the warm path arrives via `onNewIntent`.
- **iOS Share Extension.** A **separate process** from the Flutter app. It cannot reach the Dart
  heap. It writes to a shared App Group container and the app reads it on launch via a deep link.
  Extensions have **limited memory** and cannot be reliably used to launch the containing app.
- **The two platforms do not share an implementation** and must not be assumed equivalent.

These are native-integration concerns, not layout concerns. All of them remain `[Verify]` items
(V1–V4) and are **not** resolved by anything in this directory.

### Running on a Mac versus a Mac app — two different things

These are frequently conflated. They are not.

| | iOS app on Apple silicon Mac | A native macOS Flutter target |
| --- | --- | --- |
| What it is | The **existing iOS app** running on a Mac that has Apple silicon | A **separate Flutter build target** |
| Who runs it | The developer, from Xcode | An end user, from the App Store |
| What it needs | An iOS simulator or a Mac with Apple silicon | A new target, entitlements, signing, a Mac App Store listing |
| Status | Not designed here | **Not designed here** |

**This prototype is a browser artifact.** It does not simulate a macOS application window, does not
imply native window chrome, and **cannot demonstrate that Stash It would work as a Mac app**. Any
statement to that effect would be unfounded.

**Mac distribution strategy is deliberately undecided.** It is not a design question this artifact
can answer. It is recorded as a **future technical verification item**, alongside:

- **[Verify]** Whether a macOS Flutter target is wanted at all, and who it is for.
- **[Verify]** What that implies for the Share Extension, which would need a macOS counterpart.
- **[Verify]** Whether the Inbox and Collections split behaves sensibly at desktop widths — the
  presets here give a first structural impression only.
- **[Verify]** Accessibility strategy, which is undecided.

**Do not read any Desktop-preset layout in this artifact as a decision about a Mac app.**

---

## What this artifact does not do

- It does not implement Flutter, Dart, a backend, an API client, or any application code.
- It does not perform real network calls, authentication, clipboard access, or storage.
- It does not install dependencies or start a server.
- It does not modify the product-discovery documents.
- It does not create a design system. Greyscale, system fonts, structural placeholders only.

Every simulated interaction reveals a **different static representation of a documented state**. It
is never a real save and never an API operation.

---

## Reviewing effectively

1. Open `index.html` and read the coverage table.
2. Work through `01` first — the save loop and its failure surface carry the highest-severity risks.
3. Turn **Annotations** on. Most review value is in the constraints, not the pixels.
4. Switch to **Landscape**, then **Narrow**, then **Desktop** on the same screen. That is where
   problems appear.
5. For any state family, compare the states **side by side** rather than one at a time.
6. Record decisions in `decisions.md` — not here.

**The stage is complete enough to move on when:** every state in the interaction matrix that is
reachable in v1 has a reviewed representation; the save-certainty distinction holds under
inspection (no string shared between known-rejected and uncertain, no countdown on a 503); every
confirmed decision with a spatial consequence has been signed off or is listed with its blocking
question; no `[Open]` question has been silently resolved; and nobody is arguing about colour,
typography or spacing — because none of that is decided yet.