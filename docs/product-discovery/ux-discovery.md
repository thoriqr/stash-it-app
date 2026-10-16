# Stash It — UX Discovery

**Status:** Initial discovery. Analysis complete; recommendations in this document
are proposals, not approved decisions.

**Sources.** All backend behavior referenced here is drawn from the backend
repository (a sibling checkout named `stash-it-backend`, outside this
workspace) — primarily its `documentation/product.md`, `PROGRESS.md`,
`AGENTS.md`, `documentation/auth-sessions.md`, and the generated
`docs/swagger.json`. Claims traced to code rather than prose are marked
**[Verify]** or cited by file. The backend remains authoritative; where this
document and the backend disagree, the backend wins.

**Labels.** **[Doc]** documented fact · **[Confirmed]** approved decision ·
**[Rec]** recommendation awaiting approval · **[Verify]** technical verification
required · **[Open]** unresolved question.

---

## 1. Product understanding

### 1.1 The problem

**[Doc]** *"Discovery is a personal place for things a user finds on the internet.
They save an item and can find it and return to it later. The product exists to
shorten the distance between finding something worth keeping and actually going
back to it."* — `documentation/product.md`

Everything else in the product either supports that path or is optional.

### 1.2 The core loop

```
Discover -> Save -> Organize (optional) -> Come Back -> Take Action
```

**[Doc]** Two rules from `product.md` constrain the entire UX:

1. *"Saving must never depend on organizing, and organizing is never a
   precondition for keeping something."*
2. *"Saving must be fast… Deriving the domain locally from the URL keeps saving
   free of network calls entirely."*

**Design consequence:** the UI must never make filing a collection feel like a
step toward completing a save, and the save confirmation must never imply that
more is coming.

### 1.3 The core object

**[Doc]** A **Saved Item** is a URL plus optional enrichment metadata. Its initial
state is deliberately minimal:

| Field | At save time |
| --- | --- |
| `id`, `created_at`, `updated_at` | present |
| `url` | from the client |
| `domain` | **derived locally** from the URL — not fetched |
| `platform`, `title`, `description`, `image_url` | `null` until enrichment |
| `collection_id` | required; always the user's **Unsorted** collection |
| `enrichment_status` | `pending` |

**[Doc]** *"Saving answers 'did it work', not 'what does it look like'."* The
create response reports only `id`, `url`, `collection_id`, and
`enrichment_status` — deliberately withholding the nulls, *"at that moment none of
those have been looked up, and an empty-looking answer would be indistinguishable
from a page that really has nothing."*

**Design consequence:** the save confirmation can honestly show only the URL. This
is a gift, not a limitation to work around — it forces a confirmation that does
not over-promise.

### 1.4 Enrichment is additive, best-effort, and never a condition

**[Doc]** Enrichment has exactly three persisted states — `pending`, `completed`,
`failed` — and **deliberately no `processing` or `retrying` value**
(`AGENTS.md`, decision 9).

**[Doc]** Enrichment runs two ways, both writing identical rows:
- **Automatically** in the background after a save commits.
- **On demand** via `POST /saved-items/:id/enrich`, one item at a time. There is
  no bulk or inbox-wide version (`product.md`).

**[Doc]** Critical semantics:
- `completed` means *the process succeeded*, **not** that every field was found.
  An item whose page exposed nothing usable is still `completed`.
- `failed` means the process itself failed — the page could not be retrieved or
  read. The item keeps its URL, domain, collection, and presence in search.
- *"Enrichment never invalidates a Saved Item."*
- A failed enqueue leaves the item `pending` forever, with **no reconciliation
  pass** (`PROGRESS.md`, decision 16).

**Design consequence:** `pending` is not a reliable signal that work is happening.
The client can never know whether a `pending` item is queued, running, or
permanently stuck.

### 1.5 The Unsorted collection

**[Doc]** `Unsorted` is the default collection every user starts with. Every save
lands there. It may stay empty, is never removed when its items move elsewhere,
and **can never be deleted** — identified by `system_key = 'unsorted'`, never by
display name or `type` (`AGENTS.md`, decision 19b).

**[Doc]** There is **no endpoint that lists every saved item at once**
(`AGENTS.md`, decision 19g). The Inbox *is* the Unsorted collection seen through
`GET /collections/:id/saved-items`.

### 1.6 Collections

**[Doc]** A user collection is created **as a side effect of filing an item into
it by name**. `PUT /saved-items/:id/collection` takes `{"collection_name": "..."}`
and creates the collection if it does not exist, so *"a collection is never
created holding nothing."*

**[Doc]** There is no `POST /collections`. **A user cannot pre-create an empty
collection.**

**[Doc]** Names are unique per user; `"Wishlist"`, `"wishlist"` and `" Wishlist "`
are the same name. System collection names are reserved.

### 1.7 Search

**[Doc]** One query searches saved items and collections and returns both groups
together. Matched fields: item `title`, `domain`, `url`; collection `name`.
Nothing else is searchable — not platform, not identifiers, not dates.

**[Doc]** Capped rather than paged: **20 saved items by default, 50 maximum;
5 collections maximum**. No cursor pagination, no autocomplete, no suggestions.
Matching is exact-then-fuzzy with exact ranked above approximate; recency only
breaks ties. *"No meaningful match is a normal, successful outcome, not an
error."*

### 1.8 Currently implemented capabilities

**[Doc]** Per `product.md` "Current phase: Phase B — basic organization and
return", and confirmed against `docs/swagger.json`:

- **Auth:** manual registration with emailed PIN, Google login, social
  registration, account-link confirmation, login, logout, refresh, device listing
  and revocation, password reset with PIN.
- **Profile:** `GET /users/me`, `PATCH /users/me`, `PUT /users/me/password`.
- **Saved items:** save, detail, delete.
- **Collections:** file an item by name, list collections, list a collection's
  items, delete a collection with an explicit saved-item disposition.
- **Search:** one combined query.
- **Enrichment:** background after save, on-demand per item, plus automatic
  organization into a platform-named collection.

---

## 2. Navigation model

**[Confirmed]** Four primary destinations: **Inbox, Collections, Search, Profile**.

### 2.1 Resolving the Unsorted collection

**[Confirmed]** Inbox represents Unsorted, resolved from `GET /collections` using
`system_key: "unsorted"` — never by display name.

**[Doc]** This is load-bearing. `AGENTS.md` (decision 19b): *"Unsorted is
identified by `system_key` and is the only protected collection. Collection type
is not the criterion."* A user could name a collection `Unsorted`; it would be
rejected as reserved (`collections_system_key_check` and the reserved-name rule in
`product.md`), but the principle stands — identity is the key, not the string.

**Design consequence [Rec]:** the Unsorted collection ID is **not a constant in the
client**. It is server data. The Inbox destination cannot be constructed without a
prior `GET /collections` call, and the resolved ID must be available before the
Inbox screen can render. This is a data dependency, not an implementation detail.

### 2.2 Unsorted placement

**[Doc]** `GET /collections` pins Unsorted first under **every** sort, via a rank
over `system_key` in SQL — not filtered out, not special-cased per sort. It
appears on no later page.

**[Confirmed]** Do not introduce unnecessary client-side sorting. Render the
server's order.

**[Rec]** The Inbox tab and the Unsorted row in Collections should resolve to the
**same underlying screen or widget**, parameterised by collection ID. Building
them separately guarantees drift, particularly around enrichment states and
pagination.

### 2.3 Why Inbox gets a tab

**[Doc]** `product.md` uses "Inbox" throughout its own language: *"An inbox with
unsorted items is a valid, successful state"* and development-order step 1,
*"Share → Save → Inbox"*.

**[Rec]** The backend's "no separate inbox" rule (decision 19g) is an **API-shape**
argument — it exists so there is not one way to ask the database and another way
to get a poorer answer. It is not a claim that users should hunt for unsaved items
in a list where they happen to sit at row one. Exposing Unsorted as a first-class
tab *and* in Collections honours both the data model and the user's mental model,
at zero extra backend cost.

**[Rec]** The rejected alternative — three tabs with no Inbox — is more faithful to
the data model and marginally cheaper, at the cost of one extra tap on every
"where did I just save that?" moment. This trade-off was presented and Inbox-as-tab
was chosen.

---

## 3. Primary user journeys

### Journey A — Save a URL

#### A.1 Intake

**[Confirmed]** The OS share sheet is the primary intake method. An in-app URL
paste field is the fallback.

**[Doc]** No backend contract exists for intake. It is entirely a platform concern.
See [§7 Pending URLs](#7-pending-urls--ownership-lifecycle-and-errors).

#### A.2 Receiving the URL

| App state | Behavior |
| --- | --- |
| Not running | The share target starts the app. It reads the pending-share store on launch. |
| Running, foreground | The platform delivers a new share event. It is appended to the store. |
| Running, background | Same as foreground — the event is delivered on resume. |

**[Doc → Verify]** On iOS, a Share Extension is a **separate process** from the
Flutter app. Flutter's own documentation (`docs.flutter.dev/platform-integration/ios/app-extensions`)
states: *"The containing app and the app extension don't communicate directly. The
containing app might not be running while the device user interacts with the
extension."* **[Verify]** This means the extension cannot write into the Dart heap;
it must hand the URL off through a shared container. Android's `ACTION_SEND` intent
is delivered to the activity instead. **The two platforms do not share an
implementation.**

#### A.3 Unauthenticated receipt

**[Confirmed]** The intended experience supports receiving a shared URL before
authentication, preserving it through the auth flow, and saving after.

**[Doc]** Every saved-item route requires a Bearer access token via
`middleware.Auth`. There is no anonymous save and no pending-save concept on the
server.

**[Confirmed]** At this point the URL is **pending locally** — Flutter holds it, and
**the backend has not confirmed any save**. It is not a saved item, and the backend
has no record of it. The local queue exists precisely to cover the gap.

**[Confirmed]** A received URL **must be persisted to durable local storage before**
routing to authentication. **[Confirmed]** An in-memory-only queue is insufficient:
the OS may terminate the app during a multi-step flow that includes waiting on an
emailed PIN. See [§7](#7-pending-urls--ownership-lifecycle-and-errors).

#### A.4 Preserving through authentication

**[Doc]** Authentication is genuinely multi-step and cannot be compressed:

- **Manual registration:** `POST /auth/register/manual` → `POST .../pin` →
  `GET .../verification/{id}` (polling) → `.../resend` → `.../verify` →
  `GET /auth/register/continuation` → `POST /auth/register/finalize/manual` →
  **then a separate `POST /auth/login`.** Manual finalization creates **no
  session** (`auth-sessions.md`, "Manual registration finalization creates no
  session").
- **Social registration:** `POST /auth/register/finalize/social` **does** mint a
  session and returns both tokens.
- **Account link:** `GET /auth/login/google/account-link/{id}` then
  `POST .../confirm` with `{"id_token": "..."}`.

**[Doc]** The finalization paths are **not interchangeable from a client's point of
view**. The difference lives in the result types, not in a flag. A client that
assumes registration signs the user in will break on the manual path.

**[Doc]** `GET /auth/register/verification/{id}` and
`GET /auth/register/continuation` are **deliberately exempt from rate limiting**
precisely *"because the client polls"* them (`PROGRESS.md`, decision 27). Polling
is the intended pattern, and the endpoint returns `status`, `pin_issued`, and
`resend_in_seconds` — the ingredients for a countdown UI.

**[Doc]** The client must persist `verification_id` and
`registration_continuation_token` across process restarts. A registration that
takes more than one app session is normal, not an edge case.

#### A.5 Saving

**[Doc]** `POST /saved-items`

```http
POST /saved-items
Authorization: Bearer <access token>
Content-Type: application/json

{ "url": "https://example.com/articles/1" }
```

**[Verify]** `saved_item/request.go` declares
`URL string \`json:"url" validate:"required,url,max=2048"\``. A second check in
`service.go` (`deriveDomain`, lines 324–349) parses the URL and rejects an empty
hostname. Two distinct 400 codes therefore exist for a bad URL.

**Response — 201:**
```json
{
  "data": { "saved_item": {
    "id": "…", "url": "https://example.com/a",
    "collection_id": "…", "enrichment_status": "pending"
  } },
  "message": "saved item created successfully"
}
```

**[Doc]** Note what is absent: no `domain`, `title`, `platform`, `description`,
`image_url`, `last_enriched_at`.

**Errors:**
| Code | Condition |
| --- | --- |
| `VALIDATION_ERROR` | `url` missing, not a URL, or over 2048 characters |
| `INVALID_URL` | unparseable, or no host |
| `INVALID_AUTHORIZATION_HEADER` / `INVALID_ACCESS_TOKEN` / `ACCESS_TOKEN_EXPIRED` | 401 |
| `USER_RATE_LIMIT_EXCEEDED` | **429** + `Retry-After` — 60 per 10 minutes per user |
| `USER_RATE_LIMIT_UNAVAILABLE` | **503, no `Retry-After`** — limiter fails closed |

#### A.6 Communicating the result

**[Confirmed]** Do not imply metadata enrichment has completed.

**[Doc]** `AGENTS.md`: *"Saving answers 'did it work', not 'what does it look
like'."*

**[Rec]**
- Confirmation states **"Saved"** and shows the URL. Nothing more.
- The response contains `id`, `url`, `collection_id`, and `enrichment_status`,
  which is everything needed to render an honest optimistic row — so **optimistic
  insertion into the Inbox is fully supported and safe here.**
- No spinner implying data is arriving. The server never signals that enrichment
  has started.
- Do not warn on duplicates — **[Confirmed]** duplicate saved URLs are allowed with
  no warning or confirmation. See [§7.6](#76-local-pending-url-deduplication) for
  local pending-URL coalescing, and R9 for the uncertain-outcome risk.

#### A.7 After the save — the boundary, then two separate background lifecycles

**[Confirmed]** On a confirmed `201`, the URL's **pending queue entry is removed**.
This is the ownership boundary: from here the item is **backend-owned**, and the
local queue has no further involvement.

**[Doc]** From that point, two background processes act without client
involvement. They are **separate lifecycles that happen after successful
persistence**:

1. **Enrichment** may populate `title`, `platform`, `description`, `image_url` and
   set `enrichment_status` to `completed` or `failed`.
2. **Automatic organization** may then move the item into a collection named
   after the detected platform — **but only if it is still in Unsorted**
   (`PROGRESS.md`, decision 13a).

**[Confirmed]** The consequences, which are easy to get wrong:

- **[Doc]** Enrichment failure **does not remove** the saved item.
- **[Confirmed]** Enrichment failure **does not** put the URL back into the local
  pending queue. The item is saved, durable and fully valid.
- **[Confirmed]** Enrichment failure **must not** trigger automatic organization.
- **[Confirmed]** A successful save must **never** be communicated as implying that
  enrichment has completed.

**[Confirmed]** A failed save request and a failed enrichment task are **different
events**. A failed save leaves the URL in the local queue (§7). A failed
enrichment leaves a saved item in Unsorted and does not touch the queue at all.

**Design consequence:** the Inbox list mutates without the client acting. See
risk **R1**.

---

### Journey B — Find a previously saved item

**[Confirmed]** No aggregate view in v1. Three access paths: Inbox, Collections,
Search.

#### B.1 Browsing the Inbox

**[Doc]** `GET /collections` → locate Unsorted by `system_key` →
`GET /collections/{unsorted_id}/saved-items`.

**[Doc]** Ordering is fixed at `created_at DESC, id DESC` with **no sort
parameter** (`AGENTS.md`). "Newest first" is the only ordering.

**[Doc]** Cursor-paginated: `limit` defaults to 20, capped at 50. A cursor is a
**position, not a row reference** (decision 19e), so it survives its anchor item
being deleted or renamed. A cursor pointing past the end returns an empty page
rather than an error.

**Response — 200:**
```json
{
  "data": {
    "collection": { "id": "…", "name": "Unsorted" },
    "saved_items": [ { "id": "…", "url": "…", "domain": "…",
      "platform": null, "title": null, "description": null, "image_url": null,
      "collection_id": "…", "enrichment_status": "pending",
      "last_enriched_at": null, "created_at": "…", "updated_at": "…" } ]
  },
  "meta": { "cursor": { "next_cursor": null, "has_more": false } }
}
```

**[Doc]** `data.collection` carries only `id` and `name`, and is reported on
**every** response including an empty page, *"because an empty collection is still
a named collection and omitting the field would make 'nothing in it'
indistinguishable from 'no match'"* (decision 19h).

#### B.2 Browsing Collections

**[Doc]** `GET /collections?sort=newest|oldest|name&limit=20&cursor=`

**Response — 200:**
```json
{
  "data": { "collections": [ {
    "id": "…", "name": "Unsorted", "type": "system",
    "system_key": "unsorted", "created_at": "…", "updated_at": "…"
  } ] },
  "meta": { "cursor": { "next_cursor": "…", "has_more": true } }
}
```

**[Doc]** There is **no `total` and no `total_pages`** — `has_more` comes from
fetching one extra row.

**[Doc]** **There is no item count on a collection.** The Collections screen cannot
show "Wishlist (12)" from this payload.

#### B.3 Opening collection contents

**[Doc]** `GET /collections/{id}/saved-items` — identical response shape to §B.1,
including `data.collection` with that collection's name. Unsorted arrives through
the same object as anything else; nothing is special-cased.

#### B.4 Searching

**[Doc]** `GET /search?q=<query>` — query must be **2–128 characters after
trimming**. Case is ignored throughout.

**Response — 200:**
```json
{
  "data": {
    "saved_items": [ { "id": "…", "title": "…", "url": "…", "domain": "…",
      "image_url": "…", "enrichment_status": "…",
      "collection": { "id": "…", "name": "Camera Gear" },
      "created_at": "…" } ],
    "collections": [ { "id": "…", "name": "Camera Gear" } ]
  },
  "message": "search completed successfully"
}
```

**[Doc]** Caps: 20 saved items by default, 50 max; **5 collections max**. No
cursor, no pagination, no autocomplete, no suggestions.

**[Doc]** Search is rate limited: **30 requests per minute per user**
(`search-user`). Cost is linear in the account's own rows — measured at 483 ms
for 50,000 items on the development container.

#### B.5 No results

**[Confirmed]** No-match is a **successful `200` with empty arrays**, not an error.

**[Doc]** *"No meaningful match is a normal, successful outcome, not an error"*
(`product.md`).

#### B.6 Truncated results

**[Doc]** The caps are not surfaced anywhere in the API. There is no "showing N of
M", no `has_more`, and no way to request a different page.

**[Rec]** Disclose truncation plainly — *"Showing the 20 closest matches."*
Presenting a capped list as exhaustive makes the product look like it lost the
item.

#### B.7 Missing results do not mean never saved

**[Confirmed]** Make it clear that a missing search result does not necessarily
mean the item was never saved.

**[Doc]** Three independent reasons a saved item may not appear:
1. It is genuinely not searchable under that query — only `title`, `domain`, and
   `url` match. A `pending` item has **no title at all**, and `product.md` is
   explicit that *"a title is never invented from the URL or the site name."*
2. Results were truncated at 20 items / 5 collections.
3. The collection exists but the query exceeded the 5-collection cap.

**[Rec]** Zero-result copy should name the possibility of truncation and suggest
browsing Collections, rather than asserting *"You haven't saved anything like
this."* That assertion would be false for any `pending` item.

---

### Journey C — Open and manage an item

#### C.1 Detail

**[Doc]** `GET /saved-items/{id}` — the complete item plus the collection by name:

```json
{
  "data": {
    "saved_item": { "id": "…", "url": "…", "domain": "…", "platform": null,
      "title": null, "description": null, "image_url": null,
      "collection_id": "…", "enrichment_status": "pending",
      "last_enriched_at": null, "created_at": "…", "updated_at": "…" },
    "collection": { "id": "…", "name": "Wishlist" }
  }
}
```

**[Doc]** *"Opening a saved item shows everything, including what is still
unknown… so someone looking at one item can tell a missing title from a title that
has not arrived yet."* Looking never fetches and never changes anything.

#### C.2 Fallback content

**[Rec]** Because `title` is nullable in four distinct situations — never
enriched, `failed`, `completed` with no title exposed, or the page genuinely has
none — the detail screen needs a defined fallback chain:

1. `title` when present.
2. Otherwise the URL, rendered readably.
3. `domain` and `platform` as supporting metadata when present.

**[Confirmed]** Never render a missing title as an error, a warning colour, or a
placeholder implying a fault.

#### C.3 Opening the original URL

**[Rec]** This is a **platform action, not an API call**. There is no endpoint for
it and no server-side validation of the outbound navigation — the app hands a
user-supplied URL to the OS. The backend's SSRF policy governs *server-side*
fetching during enrichment only.

#### C.4 Filing into a collection

**[Doc]** `PUT /saved-items/{id}/collection`

```http
{ "collection_name": "Wishlist" }
```

**[Doc]** The endpoint takes a **name, not an ID**, and creates the collection if
it does not exist. Filings into the current collection is **idempotent** — success,
no change — so retrying after a dropped connection is harmless.

**[Doc]** `AGENTS.md` states collections are addressed by ID and names *"are not a
way to address one."* The one endpoint that files an item takes a name. Selecting
an existing collection therefore means the client resolves the chosen row's name
and sends that.

**Design consequence [Rec]:** the file sheet **requires `GET /collections` to be
already loaded** to offer existing options. There is no "list options for this
item" endpoint.

**[Doc]** Name rules: trimmed, case-insensitively unique per user, system names
reserved. Errors include `INVALID_COLLECTION_NAME`.

#### C.5 Deleting a saved item

**[Doc]** `DELETE /saved-items/{id}` — hard delete, no soft delete, no `deleted_at`.

**Response — 200:**
```json
{ "data": { "collection_id": "…", "collection_empty": true,
  "collection_deletable": true } }
```

**[Doc]** All three values are **advisory**: *"This is information for the caller to
act on or ignore; it is not a promise about what happens next."* The collection is
never touched by a saved-item delete.

**[Confirmed]** Handle the advisory collection-deletion information **without
automatically deleting collections**.

**[Rec]** Show at most a dismissible secondary offer — *"This was the last item in
Wishlist — delete the collection?"* — and never act on the flags automatically.
An empty collection is a perfectly good state, so auto-removing one would take an
action nobody asked for (`product.md`).

---

### Journey D — Manage collections

#### D.1 Listing and pagination

**[Doc]** `GET /collections` — cursor-paginated, `limit` 1–50 defaulting to 20,
three sort orders. Unknown `sort` values are a `400`, never guessed.
`limit=0` is read as absent; 51+ is a `VALIDATION_ERROR`.

**[Doc]** A cursor **must match the requested `sort`**. Changing sort invalidates
any held cursor.

**[Rec]** Reset the held cursor when the user changes sort. Reusing a
`name`-ordered cursor against a `newest` query is a client bug the backend cannot
prevent.

#### D.2 Unsorted

**[Doc]** Pinned first under every sort, appears on no later page, identified by
`system_key`.

**[Rec]** Recognise Unsorted by `system_key === "unsorted"` throughout the app —
in the Collections list, the file sheet, the delete dialog, and delete-confirmation
logic. Never by name, never by `type`.

#### D.3 Empty collections

**[Doc]** A collection may be permanently empty. Nothing removes it automatically.

**[Rec]** An empty collection shows "Nothing here yet" with a save-URL affordance.
The collection's **name is already in `data.collection` even on an empty page**,
so the screen has a title without any extra request.

#### D.4 Deleting a collection — the disposition requirement

**[Doc]** `DELETE /collections/{id}`

```json
{ "saved_items_action": "delete", "target_collection_id": null }
{ "saved_items_action": "move",   "target_collection_id": "<uuid>" }
```

**[Doc]** `saved_items_action` is **required** and nothing is defaulted, *"because
the two actions have opposite consequences and one of them discards saved
items."* `target_collection_id` must be `null` for `delete` and a collection ID
for `move`. Unsorted is a valid move target **named by its ID** like any other.

**[Doc]** Any collection may be deleted regardless of `type` — **Unsorted is the
single exception**.

#### D.5 The empty-collection problem

**[Verified from source]** `collection/request.go` lines 72–80 declare
`saved_items_action` with no validation tag and no default, and
`collection/service.go` line 603 rejects a missing target with
`INVALID_COLLECTION_DELETE_TARGET`. **[Doc]** The field is described as always
required. **`saved_items_action` is therefore required even when the collection
holds zero items.**

This is the most awkward documented interaction in the v1 surface. The user is
asked to choose the fate of items that do not exist.

**[Rec] Recommended UX:**
- For a collection known to be empty, the dialog does **not** ask the question.
  It says *"This collection is empty"* and offers only **Delete**.
- The client still **must send** `saved_items_action` — but it sends
  `{"saved_items_action": "delete", "target_collection_id": null}` internally,
  because for an empty collection the two options are indistinguishable in effect.

**This is honest, not a workaround:** the backend does not accept "no action"
because it cannot infer intent. When there is nothing to dispose of, `"delete"` is
a statement about zero rows, and it is the only value that is true. The request
satisfies the documented contract; the user is not asked a meaningless question.

**[Rec]** Do **not** infer emptiness client-side as the only mechanism, because the
count is not available from `GET /collections`. Emptiness is known in exactly two
places: a `collection_empty: true` returned by a just-performed item delete, and an
empty `saved_items` array from `GET /collections/{id}/saved-items`. Both are
available at the point of use.

**For a non-empty collection**, show the real choice with equal visual weight on
both options:
- **"Delete N items and the collection"** — destructive styling.
- **"Move N items to…"** — requires selecting a target collection, including
  Unsorted.

**[Rec]** Never preselect one option. **[Doc]** *"The choice is never made on the
caller's behalf."*

#### D.6 Failures

| Code | Meaning | UX |
| --- | --- | --- |
| `UNSORTED_COLLECTION_PROTECTED` | Unsorted was targeted | Not reachable via UI; guard anyway and omit the action |
| `COLLECTION_NOT_EMPTY` | An item was filed mid-operation; the FK refused and everything rolled back | Explain that the collection is no longer empty and reload |
| `COLLECTION_DELETE_TARGET_NOT_FOUND` | Target absent or not the user's | Re-prompt for the target |
| `INVALID_COLLECTION_DELETE_ACTION` / `..._TARGET` | Malformed request | Client bug; never surfaced |
| `COLLECTION_NOT_FOUND` | Unknown or foreign | Distinct not-found state, not an empty list |

**[Doc]** *"Everything happens together or not at all"* — on `COLLECTION_NOT_EMPTY`
nothing changed, and the caller is told why.

---

### Journey E — Enrichment

#### E.1 The three states

**[Doc]** `pending`, `completed`, `failed`. No `processing`, no `retrying`.

| State | Means | Must not be presented as |
| --- | --- | --- |
| `pending` | Not successfully completed yet | In-progress, or broken |
| `completed` | The process succeeded | Proof that metadata was found |
| `failed` | The page could not be retrieved or read | A broken or invalid saved item |

**[Confirmed]** Represent the states accurately and distinguish pending messaging
from actual failure.

**[Rec] Presentation:**

| State | List row | Detail |
| --- | --- | --- |
| `pending` | URL + domain. Muted "Reading page…". **Retry available.** | Same, with an inline retry action |
| `completed` with data | Image, title, domain, description excerpt | Full preview |
| `completed` without data | URL + domain. **No warning styling.** | Same, no error framing |
| `failed` | URL + domain, muted "Couldn't read this page". Retry prominent. | Same, retry prominent |

**[Doc]** Supporting facts:
- A `completed` item may have **no title, no image, no description** — or none of
  them. *"A page that exposes nothing usable is normal too. Missing metadata is
  not a defect in the Saved Item and not a defect in enrichment."*
- `failed` items keep their URL, domain, collection, and searchability.
- `last_enriched_at` is `null` until an enrichment has **succeeded at least once**;
  a failed attempt does not set it. A useful secondary signal: an item with
  `last_enriched_at: null` and `failed` has never had a successful read.

#### E.2 Retry semantics

**[Confirmed]** Retry is available for **pending and failed**.

**[Doc]** Justification: a `pending` item can be permanently stuck — a failed
enqueue has **no reconciliation pass** (decision 16), and exhausted retries leave
it `pending` with the queue task archived. The user has no other recourse.

**[Doc]** `POST /saved-items/{id}/enrich`:
- Authenticated and owner-scoped.
- Always returns **200**, for both `completed` and `failed` outcomes. The outcome
  is in `enrichment_status`; internal failure detail is logged, not exposed.
- Repeatable from any state and not gated on current status.
- On success, missing fields are written as `NULL` — stale metadata is not
  retained.
- On failure, existing metadata is **preserved** and `last_enriched_at` is
  unchanged.
- Never touches `url`, `domain`, or `collection_id`. Never organizes.

**[Doc]** Rate limited to **10 per minute per user**, the tightest budget in the
application — it is the only route that performs an outbound fetch inside the API
process.

#### E.3 Long-running retry

**[Verify, from source]** `internal/security/outbound_fetch.go` line 51:
`OutboundFetchTimeout = 10 * time.Second`, with a 5 s response-header timeout, 3
redirects max, and a 2 MiB response cap.

**[Rec]** This is **the only place in the app where a blocking spinner is fully
justified**, because it is the only request whose completion the server actually
performs on demand. A 10-second wait is long enough that copy must acknowledge it
— e.g. *"Reading the page…"*, not an unexplained freeze.

**[Doc]** Retry failures:
- `429 USER_RATE_LIMIT_EXCEEDED` + `Retry-After` — disable and count down.
- `503 USER_RATE_LIMIT_UNAVAILABLE` — **no `Retry-After`**; the limiter fails
  closed, so nothing is known about recovery time (`product.md`/`AGENTS.md`
  decision 25: *"a 503 must carry no `Retry-After` at all — there is no known
  recovery time and a fabricated one would be a guess presented as a fact."*).

#### E.4 Broken preview images

**[Doc]** `product.md`: *"Preview images are references to images provided by the
original source. Discovery does not own or guarantee the availability of those
external images."*

**Design consequence [Rec]:** a broken `image_url` is an **expected, routine**
outcome — hotlink protection, deleted assets, expired CDN links, oversized files.
Not an error state. Reserve layout space, render a neutral placeholder, and never
show an error or retry affordance for the image itself. Image loading must not
affect whether the row is tappable or whether its title is readable.

---

### Journey F — Authentication and account

**[Confirmed]** Do not simplify multi-step authentication into an assumed
single-step flow.

#### F.1 Manual registration

| Step | Endpoint | Response |
| --- | --- | --- |
| 1 | `POST /auth/register/manual` `{email}` | `{verification_id}` |
| 2 | `POST /auth/register/verification/{id}/pin` | issues the PIN by email |
| 3 | `GET /auth/register/verification/{id}` | `{status, pin_issued, resend_in_seconds, verification_id}` |
| 4 | `POST /auth/register/verification/{id}/resend` | resends |
| 5 | `POST /auth/register/verification/{id}/verify` `{pin}` | `{registration_continuation_token}` |
| 6 | `GET /auth/register/continuation` | `{email, registration_type, requires_password}` |
| 7 | `POST /auth/register/finalize/manual` `{display_name, password}` | `{email, display_name}` — **no session** |
| 8 | `POST /auth/login` | session |

**[Doc]** Step 7 returns **no tokens**. The client must then call `POST /auth/login`
separately. Display name is 2–100 characters; password minimum 8.

**[Doc]** Steps 3 and 6 are deliberately **rate-limit free** because clients poll
them.

#### F.2 Social registration and login

| Step | Endpoint | Notes |
| --- | --- | --- |
| `POST /auth/login/google` `{id_token}` | returns `outcome`, tokens, user |
| `POST /auth/register/finalize/social` | `{display_name}` — **does** return tokens |
| `GET /auth/login/google/account-link/{id}` | `{id, provider, masked_user_email, display_name_snapshot}` |
| `POST /auth/login/google/account-link/{id}/confirm` `{id_token}` | completes the link, returns a session |

**[Doc]** The account-link screen is a **yes/no gate, not a picker** — the backend
has already matched the email. A masked address leaves the user nothing to
mis-pick (`PROGRESS.md`).

**[Doc]** *"A caller who loses a Google token mid-flow must re-prompt… a 401 on
confirm means 're-obtain the token', not 'wrong confirmation'."*

#### F.3 Password recovery

**[Doc]** `POST /auth/password-reset` `{email}` → `{verification_id}`, then a PIN
flow (`/pin`, `/verification/{id}`, `/resend`, `/verify`) producing a
`password_reset_continuation_token`, then `GET /auth/password-reset/continuation`
→ `{email, has_password_credential}`, then `POST /auth/password-reset/finalize`.

**[Doc]** A password reset **revokes every session** the user has, in the same
transaction that writes the new credential.

#### F.4 Session lifecycle and its UX consequences

**[Doc]** `auth-sessions.md`:

| Constant | Value |
| --- | --- |
| `AccessTokenLifetime` | **15 minutes** |
| `SessionAbsoluteLifetime` | **90 days** |
| `SessionIdleLifetime` | **30 days** |

**[Doc]** *"A concurrent double-refresh logs the user out."* The implementation
cannot distinguish a client retry from an attacker's replay; the alternative leaves
reuse detection unenforceable.

**[Rec — and this is a correctness requirement, not a nicety]** The client **must
serialize refresh requests**. A second concurrent refresh presents an
already-replaced token, which trips reuse detection and **revokes the whole
session**. The user-visible symptom of getting this wrong is being logged out of
the app at random. Single-flight refresh is the mitigation; the backend cannot
provide it.

**[Doc]** Additional accepted trade-offs that shape copy and retry behaviour:
- Revocation **does not** invalidate an already-issued access token — up to 15
  minutes of continued validity. Stateless by design.
- *"A lost refresh response costs the session."*
- Refresh is rate limited **per client address** (60 per 10 min) and **fails
  closed**: during a Redis outage it answers `503 IP_RATE_LIMIT_UNAVAILABLE`,
  and a user whose access token has expired **cannot renew** until Redis recovers.
  Lockout of up to 15 minutes is a documented consequence.

#### F.5 Profile

**[Confirmed]** Keep v1 to profile and essential account functionality supported by
the backend.

**[Doc]** `GET /users/me` returns `id`, `email`, `display_name`,
`has_password_credential`, `created_at`, and an `identities` array (`provider`,
`linked_at`, `email_snapshot`, `display_name_snapshot`). `PATCH /users/me` changes
`display_name` only. `PUT /users/me/password` creates or replaces a credential.

**[Rec]** `has_password_credential` is the rendering hint for one endpoint serving
two cases: "Set a password" versus "Change password".

**[Doc]** Explicitly absent and therefore not to be designed for: no avatar, no
email change, no email verification, no provider unlinking, no `GET
/users/me/password`.

**[Doc]** `provider` is free-text from storage with no registry — only `google` is
written today. **[Rec]** Render any provider value received rather than switching
on a client-maintained set.

#### F.6 Device and session management — deferred

**[Confirmed]** Deferred.

**[Doc]** `GET /auth/sessions` and `DELETE /auth/sessions/{id}` exist and are
implemented. The list is populated from `X-Device-Name`, `X-Platform`, and
`X-Installation-ID` headers supplied at session creation.

**[Rec]** Deferring this cleanly means also deferring those headers — a device list
built without them shows `null` device names. **[Open]** Whether the client
should still send `X-Platform` and `X-Device-Name` now, purely for future benefit,
is a small decision worth making deliberately rather than by omission.

#### F.7 Account deletion

**[Confirmed]** Record as an unresolved release consideration. Do not invent a
frontend-only solution.

**[Doc]** No account-deletion endpoint exists in the backend. `PROGRESS.md` lists
*"Email change, email verification, account deletion, avatars, provider
unlinking"* as explicitly out of scope.

**Assessment:** this is a **release blocker**, not a UX gap. Apple App Store
guideline 5.1.1(v) and Google Play's account-deletion requirement both apply to
apps that create accounts. It requires a backend feature and a design pass.
Recorded in [`decisions.md`](./decisions.md) as an unresolved requirement.

---

## 4. Screen inventory

**Principle:** not every endpoint requires a screen. Several screens are built
from several endpoints; several endpoints feed one screen.

| # | Screen | Entry points | Exit paths | Primary endpoints |
| --- | --- | --- | --- | --- |
| S1 | Welcome / Sign in | Cold launch, unauthenticated, sign-out | → S2, S4, S6, S7 | `POST /auth/login`, `POST /auth/login/google` |
| S2 | Register (email) | S1 | → S3 | `POST /auth/register/manual` |
| S3 | Verify PIN | S2, deep link, app resume | → S4 | `pin`, `verification/{id}`, `resend`, `verify` |
| S4 | Complete account | S3, social finalization | → S1 or S7 | `GET /auth/register/continuation`, `finalize/manual`, `finalize/social` |
| S5 | Account link confirmation | S1 Google login | → S7 or error | `GET/POST /auth/login/google/account-link/{id}` |
| S6 | Password recovery | S1 | → S1 | 4-step `/auth/password-reset/*` |
| **S7** | **Inbox** | Tab, cold start with pending share | → S10, S1 | `GET /collections` → `GET /collections/{unsorted}/saved-items` |
| **S8** | **Collections** | Tab | → S9, S13 | `GET /collections` |
| **S9** | **Collection contents** | S8, S7 (Unsorted row), S11 | → S10 | `GET /collections/{id}/saved-items` |
| **S10** | **Saved item detail** | S7, S9, S11 | → S7/S9, external browser | `GET /saved-items/{id}`, `POST /:id/enrich`, `PUT /:id/collection`, `DELETE /:id` |
| **S11** | **Search** | Tab, search affordance | → S10, S9 | `GET /search?q=` |
| S12 | File into collection (sheet) | S10 | → S10 | `PUT /saved-items/{id}/collection` |
| S13 | Delete collection (dialog) | S8, S10, post-item-delete offer | → S8, S9 | `DELETE /collections/{id}` |
| S14 | Profile | Tab | → S14 sub-states, S1 | `GET /users/me`, `PATCH /users/me`, `PUT /users/me/password` |
| S15 | Pending URLs (Inbox section) | Unobtrusive Inbox indicator when entries exist | → S7, S1 (sign in) | *(local only — **no backend endpoint**)* |

**[Confirmed] S15 is not a navigation destination.** The four main destinations
remain **Inbox · Collections · Search · Profile**. It is a section *within* the
Inbox, surfaced by an unobtrusive indicator, per the minimal v1 UX in §7.4.

**[Confirmed] S15 is not an aggregate saved-items view.** It lists URLs the backend
has **not** confirmed saving. Saved items are served only from the backend through
S7, S9 and S11. The queue must never be presented as a substitute for a
"all saved items" endpoint, and must not grow into one.

### 4.1 Screen notes

**S7 / S9 — one screen, two entry points.** **[Confirmed]** Reuse the same
underlying screen or widget. Parameterised by collection ID and title. They differ
in no behaviour; a collection's items are fetched from the same endpoint either
way. **[Rec]** Implement once. Divergence between an "Inbox" list and a "collection
list" would be a defect, since the backend treats them identically.

**S7 — data dependency.** Unsorted's ID comes from `GET /collections`. The Inbox
screen cannot render until that resolves. **[Rec]** Load the collection list once
per session and share it across the tab; treat it as the app's root data source,
since S8, S9, S12, and S13 all need it too.

**S8 — no item counts.** **[Doc]** `GET /collections` carries no count.
**[Rec]** Do not show counts in v1. Deriving them would require one request per
collection, which is unbounded work on an unbounded list. *(This is a recorded
limitation, not a solved problem.)*

**S8 — no create action.** **[Doc]** No `POST /collections`. **[Rec]** The
Collections screen is a pure browser. Do not present a "New collection" affordance
that would have to be faked — collections are created by filing an item into a
named collection (see S12).

**S12 — needs the collection list.** **[Doc]** There is no "list options for this
item" endpoint. **[Rec]** The sheet shows existing collections first, with a
create-by-name input below. The distinction must be visible: **"Move to
Wishlist"** versus **"Create Wishlist"**. Accidental near-duplicate collection
creation is risk **R6**.

### 4.2 Reusable patterns

| Pattern | Used by |
| --- | --- |
| **Saved-item row** | S7, S9, S11 |
| **Collection-scoped item list** (cursor pagination + empty + not-found) | S7, S9 — identical |
| **Enrichment state indicator** | Row, detail, search results |
| **Fallback title resolution** (`title` → URL → `domain`) | Row, detail, search |
| **Preview image with placeholder** | Row, detail, search |
| **Error banner from `error.code`** | Every screen |
| **Auth gate wrapper** | S7–S13 |
| **Countdown from `Retry-After` / `resend_in_seconds`** | S3, S6, S10 (enrich), S7 (save) |
| **Poll-and-countdown panel** | S3, S6 |

---

## 5. Interaction-state matrix

| State | Trigger | Treatment |
| --- | --- | --- |
| **Initial loading** | First page in flight | Neutral skeleton rows. No spinner text. |
| **Pagination loading** | Cursor fetch | Footer indicator. **Append, never replace.** |
| **Refresh** | Pull-to-refresh | Keep existing rows visible; do not blank the list. |
| **Empty Inbox** | `200`, empty `saved_items`, `collection.name == "Unsorted"` | "Nothing saved yet" + save-URL affordance. **[Rec]** If pending URLs exist, the S15 indicator takes precedence — see §7.4. |
| **Empty named collection** | `200`, empty `saved_items` | "Nothing in *{name}*" + save-URL affordance. The name is already in `data.collection`. |
| **Empty search** | `200`, both arrays empty | "No matches for **{q}**". **Not an error.** Must not assert the item was never saved — see §3, Journey B.7. |
| **Truncated search** | 20 items or 5 collections reached | "Showing the 20 closest matches." Disclose; do not imply completeness. |
| **Missing collection** | `404 COLLECTION_NOT_FOUND` | **Distinct screen**, distinct from empty. Route back to Collections. |
| **Missing item** | `404 RESOURCE_NOT_FOUND` | Distinct state with a return path. Unknown and foreign return the same code by design. |
| **Pending enrichment** | `enrichment_status: "pending"` | URL + domain, muted "Reading page…". **Retry available.** Never an infinite spinner. **Backend-saved item — nothing to do with the pending queue.** |
| **Completed, partial metadata** | `completed` with some nulls | Show what exists. **No warning styling.** |
| **Completed, no metadata** | `completed`, all metadata null | URL + domain only. **No warning styling. This is success.** |
| **Failed enrichment** | `failed` | URL + domain, muted "Couldn't read this page". Retry prominent. **Never styled as a broken item, and never returned to the pending queue.** |
| **Broken preview image** | `image_url` fails to load | Neutral placeholder, reserved layout. **Routine — no error, no retry.** |
| **Enrich retry in progress** | `POST /:id/enrich` | **Inline, up to ~10 s.** The one justified blocking spinner. |
| **Token expired** | `401 ACCESS_TOKEN_EXPIRED` | Refresh once, then retry once, then sign in. **Serialize refresh.** |
| **Refresh revoked** | `401 SESSION_REVOKED` / `REFRESH_TOKEN_INVALID` | Sign in. Explain plainly; do not blame the user. |
| **Rate limited** | `429` + `Retry-After` | Countdown from the header. Disable the action. |
| **Service unavailable** | `503` — **no `Retry-After`** | "Temporarily unavailable — try again." **Never a fabricated countdown.** Saving and enriching both fail closed. |
| **Offline (transport)** | No response from the network — **there is no `error.code`** | "You're offline." **Distinct from 503** — see §5.1. Retain any typed URL. |
| **Pending URL — awaiting auth** | Unauthenticated, entries held | Blocked behind the auth gate. Surfaced on return with a sign-in path. Category: **auth required**. |
| **Pending URL — ready to save** | Authenticated, entry held | S15; auto-attempt save. |
| **Pending URL — save failed (auth)** | `401` codes (§7.7) | **Retain.** Show reason. **Offer a sign-in path.** Do not retry until authenticated. |
| **Pending URL — save failed (server)** | `503` / `500` | **Retain.** Show reason. No countdown. **Manual retry only.** |
| **Pending URL — save failed (budget)** | `429` + `Retry-After` | **Retain.** Countdown from the header. Suspend the queue until it elapses; entries then wait for the user. |
| **Pending URL — save failed (connectivity)** | No response at all | **Retain.** **Manual retry only** — no automatic resume on connectivity regain. See §7.8. |
| **Pending URL — uncertain** | No HTTP response at all; the row may or may not exist | **Manual retry only (provisional).** State plainly that the app cannot confirm it. Offer an explicit retry action plus a "check your Inbox" pointer. |
| **Pending URL — explicitly rejected** | Any coded error, §7.7 groups A-F | Retain. Reason shown. **Manual retry only** — known not saved, so a retry carries no duplication risk. |
| **Pending URL — expiry warning** | Past 7 days, not yet notified | **Not removed.** Notify the user first — §7.9. |
| **Pending URL — confirmed saved** | `201` received | **Entry removed immediately.** Do **not** keep pending because enrichment is unfinished or failed. |

**[Confirmed]** Do not use success messaging until the relevant operation has
actually succeeded.

**[Confirmed]** None of the pending-URL states above may be reached by an
**enrichment** failure. Enrichment operates on a backend-saved item and has no
effect on the queue (§7.1).

### 5.1 Offline versus 503 — and the uncertain-outcome case

**[Doc]** These are different failures and must not be merged.

| | Offline / transport failure | `503` |
| --- | --- | --- |
| Cause | No route to the server | Server reachable, refusing |
| `error.code` | **None exists** — there is no response | A verified code is present |
| Backend state | **Unknown** | **Nothing was written** |
| Message | "You're offline. Check your connection." | "Temporarily unavailable. Try again shortly." |
| Retry | **User-initiated** (v1 default, provisional) | **User-initiated** (v1 default, provisional) |
| Countdown | None | **None — `Retry-After` is deliberately absent** |

**[Doc]** On `503`, a refused save **writes no row and enqueues nothing**; a
refused enrichment **performs no fetch and writes no enrichment state** (decision
22 — *"A limiter that cannot answer refuses; it never allows"*). This makes a 503
safe to retry verbatim: nothing partial was persisted.

**[Confirmed] The offline case is not merely "retry and it will be fine."** A
transport failure after `POST /saved-items` may have **committed server-side** while
the client never saw the response.

**[Confirmed] Do not claim retries are guaranteed to be idempotent.** **[Doc]** The
backend offers no idempotency key, no request identifier, and no unique constraint
on `url` (`AGENTS.md` decision 5), so it cannot be made idempotent from the client.

**[Confirmed]** The pending queue therefore provides **at-least-once submission
semantics**, not exactly-once. A duplicate saved item is possible after an
uncertain outcome plus a retry. **[Confirmed]** This is accepted, because duplicate
URLs are allowed and must not warn — but it is recorded as a **trade-off**, not
described as safe retry behaviour. See §7.8.

---

## 6. API mapping summary

| Journey | Endpoint | Success | Notable errors |
| --- | --- | --- | --- |
| A | `POST /saved-items` | `201` minimal body | `VALIDATION_ERROR`, `INVALID_URL`, 429, 503 |
| B | `GET /search?q=` | `200` two groups, capped | `VALIDATION_ERROR`, 429 (30/min) |
| B | `GET /collections` | `200` + `meta.cursor` | `VALIDATION_ERROR`, `INVALID_CURSOR` |
| B | `GET /collections/{id}/saved-items` | `200` + `meta.cursor` | `COLLECTION_NOT_FOUND`, `INVALID_CURSOR` |
| C | `GET /saved-items/{id}` | `200` full item + collection | `RESOURCE_NOT_FOUND` |
| C | `PUT /saved-items/{id}/collection` | `200` | `INVALID_COLLECTION_NAME`, `RESOURCE_NOT_FOUND` |
| C | `DELETE /saved-items/{id}` | `200` advisory fields | `RESOURCE_NOT_FOUND` |
| D | `DELETE /collections/{id}` | `200` `data: null` | `UNSORTED_COLLECTION_PROTECTED`, `COLLECTION_NOT_EMPTY`, `COLLECTION_DELETE_TARGET_NOT_FOUND` |
| E | `POST /saved-items/{id}/enrich` | `200` (both outcomes) | 429 (10/min), 503 |
| F | Auth routes | see §F | 429 on most, 503 on refresh |
| F | `GET`/`PATCH`/`PUT /users/me*` | `200` | `RESOURCE_NOT_FOUND`, `409` on password races |

**[Doc]** All responses use `{data, message, meta?}`. All errors use
`{error: {code, message, fields?}}`.

**[Doc]** **Branch on `error.code`, never `error.message`.**

---

## 7. Pending URLs — ownership, lifecycle, and errors

**[Confirmed]** Two distinct states of ownership govern this entire section.

| State | Meaning | Owner |
| --- | --- | --- |
| **Pending locally** | Flutter has received a shared or pasted URL, but **the client has not confirmed the backend saved it** | **Flutter** |
| **Saved remotely** | The backend has confirmed successful creation of the saved item | **Backend** |

**[Confirmed] A locally pending URL is not a confirmed backend-saved item.** The
local queue exists solely to prevent shared URLs from being lost when
authentication, connectivity, or backend availability prevents a confirmed save.

**[Confirmed] The local queue is entirely a Flutter responsibility.** The backend
does not know about, and does not need to know about, URLs that have not been
submitted successfully. There is no backend endpoint for pending URLs, and none is
implied.

### 7.1 The boundary, stated explicitly

```
Share sheet / paste
      |
      v
Durable local pending queue          <-- Flutter-owned, seven-day retention
      |
      | POST /saved-items  (confirmed 201)
      v
Entry REMOVED from the local queue    <-- the boundary
      |
      v
Backend saved item in Unsorted       <-- backend-owned, no expiry
      |
      +-- enrichment (separate, may fail)
      +-- automatic organization (separate, may move it)
```

**[Confirmed] Once a URL is confirmed saved, its pending entry is removed.** It is
**not** kept pending because enrichment has not finished or has failed. The queue
tracks one thing only:

> **Has the client confirmed that the save operation succeeded?**

**[Confirmed] Enrichment and automatic organization are separate lifecycles that
occur after successful persistence.** Specifically:

- **[Doc]** A successfully created item is saved in **Unsorted** initially.
- **[Doc]** Enrichment is a **subsequent** metadata-extraction process.
- **[Doc]** Enrichment failure **does not remove** the saved item.
- **[Confirmed]** Enrichment failure **does not** put the URL back into the local
  pending queue.
- **[Confirmed]** Enrichment failure **must not** trigger automatic organization.
- **[Confirmed]** A successful save must **never** be presented as implying that
  metadata enrichment has completed.

**A failed save request and a failed enrichment task are different events.** A
failed save leaves the URL in the local queue. A failed enrichment leaves a
saved, durable, fully valid item in Unsorted and changes nothing about the queue.

**[Confirmed] The pending queue is not an aggregate saved-items view.** It shows
URLs the backend has not confirmed. It is not, and must not become, a client-side
substitute for a backend "all saved items" endpoint (see §10 and
[`decisions.md` §5.1](./decisions.md)).

### 7.2 Platform reality

**[Doc → Verify]** Android and iOS **do not share an implementation** and must not
be assumed equivalent. Full comparison in §8.

**iOS.** A Share Extension is a **separate process**. Flutter's documentation
(`docs.flutter.dev/platform-integration/ios/app-extensions`) states that the
containing app and the extension *"don't communicate directly"* and that *"the
containing app might not be running while the device user interacts with the
extension."*

Consequences:
- **[Verify]** The extension cannot write into the Dart heap. It must hand the URL
  off through a shared **App Group container**, with the app reading it after
  launch via a deep link.
- **[Verify]** The extension **cannot reliably launch the containing app**; the
  deep link is the sanctioned path.
- **[Verify]** iOS extensions have **limited memory**. Flutter advises *"only
  modify an app extension's UI if the app extension supports at least 100MB of
  memory"* and warns that a physical device may run out of memory running an
  extension UI. A URL share needs no UI — write and redirect is the low-risk
  shape.
- **[Verify]** Apple's review guidelines require extensions to follow the App
  Extension Programming Guide. A custom launch mechanism is a rejection risk.

**Android.** `ACTION_SEND` with `text/plain` is delivered to the activity. A warm
share arrives via `onNewIntent` (`launchMode` `singleTask`/`singleTop`); a cold
share is available from the launching intent at `onCreate`.

### 7.3 Required persistence guarantees

**[Confirmed] An in-memory-only queue is insufficient.** The queue must survive
application termination.

| Situation | Why memory fails |
| --- | --- |
| **App terminated when the URL is shared** | On iOS the extension is a separate process with no Dart heap. On Android the app may be cold. |
| **App already running** | Memory works here, but durability is still required for the cases below. |
| **User unauthenticated** | Auth is multi-step and includes waiting on an emailed PIN — minutes of wall time and several OS suspend cycles. |
| **User abandons authentication** | The URL must survive until they return, possibly much later. |
| **OS terminates the app during authentication** | Explicitly permitted at any point. Memory is gone. |
| **Several URLs shared in sequence** | A single-slot field cannot hold a queue. |

**[Rec]** Therefore: a **durable, multi-entry queue** with explicit lifecycle
states.

**[Confirmed] Startup and screen-open behaviour.** Read the durable queue on app
startup, or when the relevant screen is opened:

1. If the queue is **non-empty**, show the pending indicator and allow the user to
   view the entries.
2. If it is **empty**, show **no** pending UI at all.
3. **[Confirmed] This is a read, not a submission** 
—
 seeing the queue never
   triggers a save.

**[Confirmed] No entry is resubmitted automatically** on startup, on connectivity
restoration, on foreground, or in background execution. An entry in `uncertain` waits for
the user; see
[§7.5](#75-lifecycle) and [§7.11](#711-retry-policy-for-v1-provisional).

### 7.4 v1 UX — minimal by confirmation

**[Confirmed]** The v1 experience stays simple.

| Requirement | Detail |
| --- | --- |
| Inbox stays primary | The Inbox remains the destination for the Unsorted collection. |
| Unobtrusive indication | When pending URLs exist, show a visible but unobtrusive indicator that some URLs are not yet saved to the backend. |
| Understandable waiting | Users can see the pending URLs and understand why they are waiting, **when the reason is known**. |
| Categorized reasons | Authentication problems must be distinguished from connectivity and server availability, using the backend's actual error contract (§7.7). |
| Path back to sign-in | Provide an appropriate path to sign in again when authentication is the blocker. |
| Retry policy | **[Confirmed] Manual retry is the v1 default** and is provisional ([§7.11](#711-retry-policy-for-v1-provisional)). A resubmission after a failure or uncertain outcome is user-initiated; a never-submitted entry is still sent on sign-in. **No retry loops.** |
| No offline mode | **Not** building a complete offline mode, a separate offline navigation destination, or elaborate synchronization UX in v1. |
| Extensible | The queue design should not preclude a future offline mode exposing locally stored content through a dedicated experience. **[Confirmed] This is future extensibility, not a v1 feature commitment.** |

**[Confirmed]** The four main destinations remain **Inbox · Collections · Search ·
Profile**. The pending queue does **not** become a fifth destination. See §4 (S15).

### 7.5 Lifecycle

**[Confirmed] Manual retry is the v1 default policy, and it is provisional.**
See [§7.11](#711-retry-policy-for-v1-provisional). The lifecycle below reflects
that policy.

The distinction that makes it coherent: a **first submission** is not a retry. An
entry that has never been sent (because the user was not authenticated) is
submitted on sign-in, completing the original share action. Anything sent *again*
after a failure or an uncertain outcome is a retry, and is user-initiated.

```
received --> awaiting_auth --(session exists)--> saving --> saved --> (entry removed)
                |
                |                      ^                    |
                |                      |                    +--> failed_rejected
                |                      |                         (known NOT saved;
                |                      |                          user-initiated retry)
                |                      |
                +--(user retry)--> saving +--> uncertain (no response)
                                                   |
                                                   +--(user retry)--> saving
                                                          (waits again if uncertain)
```

| State | Meaning | On app restart |
| --- | --- | --- |
| `received` | Handed off by the platform, not yet processed | Resumed |
| `awaiting_auth` | Never submitted; held because there is no usable session | **Surfaced**, with a resume affordance. **[Confirmed]** Submitted once a session exists — a **first submission**, not a retry |
| `saving` | Request in flight | **[Confirmed]** Not resubmitted automatically. Waits for the user |
| `failed_rejected` | An HTTP response was received and the save was refused ([§7.7](#77-save-error-mapping--verified-and-resolved-v12) groups A–F) | Retained with the reason shown. **Retry is user-initiated** |
| **`uncertain`** | **No response at all.** The row may or may not exist | Retained. **[Confirmed]** Retry is user-initiated; it never resumes on its own |
| `saved` | Confirmed by a backend response | **Entry removed** — the boundary in §7.1 |
| `expiry_warning` | Past the retention period, user not yet notified | **Not yet removed** |
| `expired_removed` | Retention elapsed and the user has been notified | **Entry removed** |

**[Confirmed] Do not silently discard pending URLs when the retention period
expires.** The `expiry_warning` state exists specifically to make removal a
notified event rather than a silent one.

**[Confirmed] No entry is resubmitted automatically** — not on app startup, on
connectivity restoration, on foreground, or in background execution. If a manual
retry is itself uncertain, it does not repeat; it waits again.

**[Doc] Purpose of the current policy.** **[Doc]** The backend has no idempotency
key or equivalent (`AGENTS.md` decision 5). An automatic resubmission after an
uncertain outcome is an uncontrolled source of duplicate saved items, so v1 keeps
that under the user's control.

**[Confirmed] This is a v1 default, not a permanent rule.** Whether to introduce
automatic retry — under which conditions, and with what safeguards — is a future
review, once Flutter development makes the real UX and queue behaviour concrete.
See [§11](#11-remaining-questions).

#### Startup behaviour

**[Confirmed]** On app startup, or when the relevant screen is opened:

1. Read the durable local pending queue.
2. If it is **non-empty**, show the pending indicator and allow the user to view
   the entries.
3. If it is **empty**, show **no** pending UI at all.
4. **[Confirmed] This is a read, not a submission** — seeing the queue never
   triggers a save.

**[Confirmed] The pending experience is a simple count plus a list of URLs.** No
local metadata extraction, page previews, titles, descriptions, or thumbnails. A
pending entry shows the URL it holds and nothing else. The list stays a section
within the Inbox, not a fifth destination.

### 7.6 Local pending-URL deduplication

**[Confirmed]** When a URL is shared or pasted while an **equivalent URL already
exists in the local pending queue**:

| Rule | Detail |
| --- | --- |
| **Overwrite, do not append** | Update the existing pending entry instead of adding another entry. |
| **Preserve queue position** | The existing entry keeps its position. **[Confirmed]** Do not move it to the newest position. |
| **No duplicate warning** | **[Confirmed]** No duplicate warning and no confirmation dialog. |
| **Other entries unaffected** | **[Confirmed]** Keep the queue's existing ordering behaviour for all other entries. |
| **Scope** | **[Confirmed]** Applies **only** to URLs currently in the local pending queue. |

**[Doc] Purpose.** Prevent repeated sharing of the same pending URL from creating
redundant local queue entries, while preserving predictable queue order.

#### This is local queue deduplication, not backend deduplication

| | Local queue deduplication | Backend deduplication |
| --- | --- | --- |
| Where it happens | **Flutter**, in the local pending queue | **Backend**, on saved items |
| What it covers | URLs **not yet confirmed saved** | Saved items in Unsorted and other collections |
| Duplicate warning | **[Confirmed] None** | **[Confirmed] None** — duplicates allowed silently (`AGENTS.md` decision 5) |
| Changes the saved-item model? | **No** | No |

**Boundaries — recorded so this is not over-claimed:**

- **[Confirmed] Flutter cannot detect duplicates already stored in the backend.**
  No such capability exists, and none is requested.
- **[Confirmed] Do not add a backend lookup or invent an endpoint for checking
  duplicates.** None exists.
- **[Confirmed] The existing product decision is unchanged:** duplicate saved URLs
  are allowed without a warning.
- **[Confirmed] This does not solve uncertain save outcomes.** A request the
  backend persisted but whose response never reached Flutter produces a duplicate
  **saved item**, not a duplicate pending entry. Local coalescing never touches
  saved items, so it has no effect on the at-least-once risk in §7.8 or risk R9.

#### Consistency with "queue everything, never newest-wins"

These rules are consistent, and the distinction matters:

- **[Confirmed]** Every shared URL is **queued** — nothing is silently discarded
  merely because it arrived later.
- **[Confirmed]** **Newest-URL-wins behaviour is not used.** The newer share never
  replaces the queue *ordering*; the pre-existing entry keeps its original position
  rather than being promoted to the newest one.
- **[Confirmed]** Coalescing applies to **equivalent URLs only**. A different URL is
  a genuinely distinct entry and is appended normally.
- **[Confirmed] Different query parameters must NOT be discarded or treated as
  equivalent** merely because the URL paths match. Two URLs differing in their query
  string are **[Confirmed] distinct entries** and are never coalesced.

A repeated share of the same URL is therefore not new work — it is the same intent
restated. Overwriting in place preserves both the entry's meaning and the queue's
stability.

#### Open: URL equivalence and normalization

**[Open — technical verification required.]** The comparison rule that decides
whether two URLs are "equivalent" is **not defined**, and must not be invented.

**[Doc] There is no existing backend definition to reuse:**

- **[Doc]** The backend derives a `domain` by lowercasing the hostname and removing
  one leading `www.` — but that is a **display and ownership derivation**, not a
  URL-identity rule. Two different paths on one host produce the same `domain`.
- **[Doc]** The extractor may report a canonical URL, but **[Doc]** *"canonical
  URLs are not automatically applied"* (`PROGRESS.md`, decision 17). Verified: the
  canonical URL is **not persisted** to `saved_items` and is not used for comparison.
- **[Doc]** `saved_items` has **no `url_hash`**, **no unique constraint on `url`**,
  and no content-language or locale column (verified against
  `internal/database/baseline/schema.sql`).

**[Open]** The precise comparison behaviour therefore needs deciding: whether
equivalence means exact string match after trimming, or something more aggressive
such as scheme/host case normalization, trailing-slash handling, or fragment
stripping. **[Confirmed]** Until that is decided, no normalization rule may be
assumed, and none may be implemented.
### 7.7 Save error mapping — verified and resolved (V12)

**[Confirmed] V12 is resolved.** The mapping below was produced by tracing the
actual `POST /saved-items` execution path in the backend source, not by enumerating
defined constants. **[Confirmed] Do not invent, rename, or assume codes.**

#### The verified execution path

**[Doc]** `internal/api/saved_item/routes.go` lines 33–38 mount exactly three
things on the create route, in this order:

```
POST /saved-items
  1. middleware.Auth(verifier)          -> internal/middleware/auth.go:22-65
  2. middleware.UserRateLimit(...)      -> internal/middleware/user_ratelimit.go:66-100
  3. handler.Create                    -> internal/api/saved_item/handler.go:51-81
       -> httpx.BindBody                -> internal/httpx/bind.go:12-33
       -> service.Create                -> internal/api/saved_item/service.go:94-150
            -> deriveDomain             -> service.go:324-355
            -> GetUnsortedCollectionByUser -> repository.go:93-111
            -> CreateSavedItem          -> repository.go:63-91
            -> enqueueEnrichment (errors swallowed) -> service.go:165+
```

**[Doc]** All errors are serialized by `httpx.NewErrorHandler`
(`internal/httpx/error_handler.go:24-80`) as
`{"error": {"code", "message", "fields"}}`.

#### Codes that can reach the client

**[Doc]** Verified reachable, in execution order:

| # | Code | HTTP | Produced by | Condition |
| --- | --- | --- | --- | --- |
| 1 | `INVALID_AUTHORIZATION_HEADER` | 401 | `middleware/auth.go:29,38` | `Authorization` header absent, not `Bearer `-prefixed, or empty after the prefix |
| 2 | `ACCESS_TOKEN_EXPIRED` | 401 | `middleware/auth.go:48` | `verifier.Verify` returns `jwt.ErrTokenExpired` |
| 3 | `INVALID_ACCESS_TOKEN` | 401 | `middleware/auth.go:55` | Any other verification failure — bad signature, malformed token, missing `sub`/`sid` |
| 4 | `INTERNAL_SERVER_ERROR` | 500 | `middleware/user_ratelimit.go:74` | Claims missing or `sub` empty. **[Doc]** Unreachable through correct wiring — documented as a wiring fault |
| 5 | `USER_RATE_LIMIT_UNAVAILABLE` | 503 | `middleware/user_ratelimit.go:84` | Redis limiter error. **Fails closed, no `Retry-After`** |
| 6 | `USER_RATE_LIMIT_EXCEEDED` | 429 | `middleware/user_ratelimit.go:92` | Budget spent. Namespace `saved-item-create-user`, 60 / 10 min. **Carries `Retry-After`** |
| 7 | `INTERNAL_SERVER_ERROR` | 500 | `saved_item/handler.go:56` | `uuid.Parse(claims.Subject)` fails. **[Doc]** Unreachable — `sub` is a UUID by construction |
| 8 | `BAD_REQUEST` | 400 | `httpx/bind.go:29` | Body could not be parsed (malformed JSON). **[Doc]** Client-side defect in practice |
| 9 | `VALIDATION_ERROR` | 400 | `httpx/bind.go:26` | `url` fails `validate:"required,url,max=2048"`. Carries `fields[]` |
| 10 | `INVALID_URL` | 400 | `saved_item/service.go:329,340,347` | `url.Parse` failed, or the hostname is empty |
| 11 | `INTERNAL_SERVER_ERROR` | 500 | `saved_item/repository.go:104,107` via `service.go:357-358` | Unsorted row missing (broken server-side invariant) or any database error |

#### Codes verified **not** reachable on this route

**[Doc]** Each was checked against the mounted middleware and the `apperror`
constructor calls actually present in the `saved_item` package.

| Code | Why it cannot occur here |
| --- | --- |
| `IP_RATE_LIMIT_EXCEEDED` | `IPRateLimit` is **not mounted** on the create route (`routes.go:33-38` mounts only `Auth` + `UserRateLimit`) |
| `IP_RATE_LIMIT_UNAVAILABLE` | Same — `middleware/ratelimit.go` is not in this chain |
| `CLIENT_IP_UNAVAILABLE` | Same — only `IPRateLimit` emits it |
| `SESSION_REVOKED` | `session/error_codes.go`; emitted only by `/auth/refresh`, never by the save route |
| `SESSION_EXPIRED` | Same |
| `REFRESH_TOKEN_INVALID` | Same |
| `RESOURCE_NOT_FOUND` | `apperror.NotFound` is called only at `repository.go:138` (Get) and `repository.go:181` (Delete) |
| `UNAUTHORIZED` | `UnauthorizedWith` is always called with an explicit code, never `""` |
| `FORBIDDEN` | No `apperror.Forbidden` call anywhere in `saved_item` |
| `CONFLICT` | No `apperror.Conflict` call anywhere in `saved_item` |
| `TOO_MANY_REQUESTS` | Only a *default* when `TooManyRequestsWith` is passed `""`; `user_ratelimit.go:92` passes `CodeUserRateLimitExceeded` |
| `SERVICE_UNAVAILABLE` | Only a *default* when `ServiceUnavailableWith` is passed `""`; `user_ratelimit.go:84` passes `CodeUserRateLimitUnavailable` |

**[Confirmed] Any code outside the reachable table is unmapped.** Handle it
defensively; do not assume it exists, and do not display a backend message for it.

#### Save certainty — the key finding

**[Doc] `CreateSavedItem` is a single autocommit statement**
(`service.go:154-158`: *"CreateSavedItem is a single autocommit statement, so the
row exists by the time this is called"*). The only work after it —
`enqueueEnrichment` — **has its failure logged and swallowed**
(`service.go:160-164`), so it can never turn a successful save into an error.

**Therefore, verified:**

> **Every HTTP-received error on this route means the URL was *not* persisted.**

| Outcome | Meaning |
| --- | --- |
| `201` | The row committed. Remove the pending entry. |
| Any code in the table above | The request was rejected **before or instead of** the insert. **Known not saved.** Safe to retry. |
| **No HTTP response at all** | **Uncertain.** The insert may have committed. |

**[Doc]** The application sets no `ReadTimeout` or `WriteTimeout`
(`cmd/api/main.go:102-109`), so the server imposes no response deadline on this
route. The uncertain window therefore comes from the **client or network side** —
connectivity loss, a mobile network handover, or the OS suspending the app — not
from a server-side timeout.

**This narrows [§7.8](#78-uncertain-save-outcomes---the-product-answer-and-what-stays-open)
considerably.** The at-least-once duplicate risk applies **only** to the
no-response case. It does **not** apply to any coded error.

#### The error envelope is not guaranteed

**[Doc]** `httpx.NewErrorHandler` delegates to `fiber.DefaultErrorHandler`
whenever the error is (or wraps) a `*fiber.Error` — checked **before** the
`AppError` branch, and `AppError.Unwrap()` returns its wrapped error
(`apperror/error.go:107-109`). Fiber's `DefaultErrorHandler` (v3.5.0) responds
with **`text/plain` and a bare message, not the JSON envelope**.

**[Doc]** On the verified save path this is reachable only if a panic carries a
`*fiber.Error` value (`middleware/recoverer` `DefaultPanicHandler` returns the
panic value as an error). A non-`*fiber.Error` panic becomes
`INTERNAL_SERVER_ERROR` with a normal envelope via `apperror.FromError`
(`apperror/error.go:111-116`).

**[Confirmed] The client must therefore treat `error.code` as possibly absent.**
A non-JSON error body is a real, verified possibility, not a theoretical one.

#### Actionable UX mapping

**[Confirmed] Localization changes presentation, not error semantics.** Messages
below are selected by `error.code` in Flutter; `error.message` is never displayed.

**[Rec] The English and Indonesian strings are drafts pending native-speaker
review.** Wording is a UX decision, not a translation exercise.

| Group | Codes | Save certainty | Flutter action | English | Indonesian |
| --- | --- | --- | --- | --- | --- |
| **A. Authentication required** | `INVALID_AUTHORIZATION_HEADER`, `INVALID_ACCESS_TOKEN`, `ACCESS_TOKEN_EXPIRED` | **Known not saved** | For `ACCESS_TOKEN_EXPIRED`: single-flight refresh, retry **once**, silently. If that fails, route to sign-in. For the other two: **do not attempt refresh** — the token is not usable — route straight to sign-in. Keep the pending entry. | "Sign in again to save this link." | "Masuk lagi untuk menyimpan tautan ini." |
| **B. Budget exhausted** | `USER_RATE_LIMIT_EXCEEDED` | **Known not saved** | Show a countdown from the **`Retry-After` header**. Suspend the queue until it elapses; entries then wait for the user. | "You're saving too quickly. Try again in {countdown}." | "Terlalu sering menyimpan. Coba lagi dalam {countdown}." |
| **C. Server temporarily unavailable** | `USER_RATE_LIMIT_UNAVAILABLE`, `INTERNAL_SERVER_ERROR` | **Known not saved** | Retain. **No countdown** — no recovery time is known. **Manual retry only** ([§7.11](#711-retry-policy-for-v1-provisional)). | "We couldn't save this link just now. It's still queued — try again shortly." | "Kami belum berhasil menyimpan tautan ini. Tautan masih dalam antrean — coba lagi sebentar lagi." |
| **D. Invalid link** | `VALIDATION_ERROR`, `INVALID_URL` | **Known not saved** | **[Confirmed]** Not the queue's primary scenario. Surface clearly, offer edit-and-retry. **Do not auto-retry** — the same input fails identically. | "That doesn't look like a valid link. Check the URL and try again." | "Tautan itu tidak valid. Periksa URL-nya lalu coba lagi." |
| **E. Malformed request** | `BAD_REQUEST` | **Known not saved** | Retain and offer retry. **[Doc]** Should never fire from a well-formed client — log it as a client defect. | "Something went wrong sending that link. It's still queued — try again." | "Terjadi kesalahan saat mengirim tautan itu. Tautan masih dalam antrean — coba lagi." |
| **F. Response not understood** | *(no `error.code`)* non-JSON error body, or any unrecognized code | **Known not saved** (a non-2xx response was received) | Retain and offer retry. **Never display a raw body.** | "We couldn't read the server's reply. This link is still queued — try again." | "Kami tidak dapat membaca balasan server. Tautan ini masih dalam antrean — coba lagi." |
| **G. Transport failure** | *(no response at all)* | **UNCERTAIN** | Retain. **Do not state the item is unsaved.** Prompt the user to check the Inbox before retrying. | "We couldn't confirm this save. It may or may not have gone through — check your Inbox before trying again." | "Kami tidak dapat mengonfirmasi bahwa tautan ini tersimpan. Bisa jadi sudah, bisa jadi belum — periksa Inbox Anda sebelum mencoba lagi." |
| **H. Offline** | *(no response, connectivity known)* | **UNCERTAIN** | As G. **Manual retry only**, but **check the Inbox first**. | "You appear to be offline. We couldn't confirm this save — check your Inbox when you're back online." | "Sepertinya perangkat Anda sedang luring. Kami tidak dapat mengonfirmasi bahwa tautan ini tersimpan — periksa Inbox Anda setelah kembali daring." |

**Grouping rationale.** **[Confirmed]** Groups D and F–H are kept distinct from
A–C even where the user action looks similar, because the **save-certainty
difference is load-bearing**: A–F are *known not saved*, G–H are *uncertain*. Only
G and H may mention checking the Inbox, and only G and H may not claim the item is
unsaved.

**Retry constraints, consolidated:**

| Constraint | Detail |
| --- | --- |
| **[Confirmed]** Safe to retry | A–F. Every one is a *known rejection*. |
| **[Confirmed]** Retry may duplicate | **G, H only.** The insert may have committed. This is why they wait for the user. |
| **[Confirmed]** Countdown sources | B from `Retry-After`. **C has none** — never fabricate one. |
| **[Confirmed]** No retry loops | B suspends the whole queue; G–H wait for a condition, not a timer. |
| **[Confirmed]** Serialized refresh | A's silent refresh must be single-flight (§3, Journey F.4). |

**[Rec] `{countdown}` is formatted from the `Retry-After` header value in the
active language.** The header is seconds; the client formats it.

### 7.8 Uncertain save outcomes - the product answer, and what stays open

**[Doc, narrowed by §7.7]** The uncertain case is now **precisely bounded**: it
occurs **only when no HTTP response is received at all.** Every coded error on the
save route is a *known rejection* that happened before or instead of the insert,
because `CreateSavedItem` is a single autocommit statement and the post-write
enqueue failure is swallowed.

| Case | Save certainty |
| --- | --- |
| `201` | Committed |
| Any `error.code` (§7.7 groups A–F) | **Known not saved** |
| Non-JSON error body (§7.7 group F) | **Known not saved** |
| **No response — transport failure or offline** (groups G, H) | **UNCERTAIN** |

**[Confirmed] V11 is resolved for v1** as the provisional manual-retry policy: a
resubmission after an uncertain outcome is user-initiated. **[Confirmed] This is not a
permanent rule** - whether to add automatic retry later is a future review. See [7.5](#75-lifecycle) and [7.11](#711-retry-policy-for-v1-provisional).

**[Confirmed] The underlying technical risk is *not* solved, and is not claimed to be.**
The protocol still cannot report whether the row committed, so **a duplicate saved
item remains possible after a user-initiated retry.** Manual retry bounds
*uncontrolled* duplication; it does not eliminate it.

**[Confirmed] Do not claim that retries are guaranteed to be idempotent.** The
backend contract does not guarantee it: **[Doc]** `AGENTS.md` decision 5 —
*"Duplicate URLs are allowed. There is no unique constraint, deduplication, or
`url_hash`."* There is no idempotency key, no request identifier, and no
client-supplied handle that could be used to detect a prior success.

**[Confirmed] The existing product decision stands unchanged: duplicate URLs are
allowed and must not trigger a duplicate warning.**

**Consequence, stated plainly [Confirmed]:** for groups G and H the pending queue
provides **at-least-once submission semantics**. A user may end up with two
identical saved items after an uncertain outcome followed by a retry. Given that
duplicates are permitted silently, this is an accepted trade-off — but it must be
**documented as a trade-off**, not described as safe retry behaviour.

**[Confirmed] The scope of the risk is now known and small.** It does **not** apply
to any coded error, so the common failure paths — an expired session, a spent
budget, an unreachable Redis, a bad URL — are all safe to retry without
duplication risk.

**[Doc]** The uncertain window comes from the client or network side. The
application sets no `ReadTimeout` or `WriteTimeout` (`cmd/api/main.go:102-109`),
so the server imposes no response deadline that could cut a committed insert off
from its reply.

**[Open] Technical question.** Whether the uncertain case can be narrowed without
backend changes — for example by treating the first attempt after a transport
failure as *possibly successful* and surfacing a "check your Inbox" prompt rather
than an automatic blind retry. This is a UX design question as much as a technical
one, and it is **not resolved**.

**[Open] What remains genuinely unverifiable client-side:** whether the row
committed. Nothing in the protocol distinguishes the two cases. Only a
server-side idempotency key, or an endpoint that could report "did this URL
already save", would resolve it — neither exists and neither is requested.

### 7.9 Retention — seven days, pending URLs only

**[Confirmed]** Seven days is the **initial product policy** for URLs that remain
locally pending and have not been confirmed saved.

**Scope. The policy applies ONLY to the local pending queue. It explicitly does
NOT apply to:**

- **[Confirmed]** URLs already saved in the backend. A saved item does **not**
  expire after seven days and has no such TTL.
- **[Confirmed]** Anything resembling a backend TTL or backend persistence
  requirement. The backend stores no pending-URL concept.
- **[Confirmed]** Enrichment status or worker execution. A seven-day-old pending
  URL is not an enrichment state.

**[Confirmed] Do not silently discard pending URLs when retention expires.**
**[Confirmed] Notify the user before removing an expired pending URL.** The
`expiry_warning` state in §7.5 exists for this.

**[Open]** The exact notification presentation, and any keep/retry action offered
alongside it, remain open — see [`decisions.md` §3](./decisions.md).

**[Confirmed] Seven days is the agreed *initial* policy and may be reconsidered
based on future product usage.** It is a client-side policy constant, not a
backend constraint.

**[Rec]** Enforce expiry on read and on app foreground rather than via a background
timer — mobile OSes do not guarantee background execution, so a timer-based sweeper
would be unreliable.

### 7.10 Queue capacity and overflow

**[Open]** No capacity has been specified. **[Confirmed]** All shared URLs are
queued; newest-URL-wins behaviour is **not** used. Equivalent pending URLs are
coalesced in place per [§7.6](#76-local-pending-url-deduplication); distinct URLs are never merged.

**[Rec]** A **soft cap with visible overflow** rather than a hard drop. Hard-dropping
entries would silently reintroduce the data-loss failure the retention period
exists to prevent. The specific number is a product decision, not a technical one.

**[Doc]** The save budget is **60 per 10 minutes per user**
(`saved-item-create-user`). **[Confirmed]** Suspend the queue on
`USER_RATE_LIMIT_EXCEEDED` until `Retry-After` elapses, rather than burning the
remaining budget. **[Confirmed]** Elapsing the window does **not** resume submissions - the entries
wait for the user.

### 7.11 Retry policy for v1 (provisional)

**[Confirmed] Manual retry is the v1 default policy.** A user must explicitly
initiate a submission when a URL needs to be sent again.

**[Confirmed] This is provisional.** It is not a permanent prohibition on
automatic retry. See "Future review" below.

#### The four scenarios

| # | Scenario | A retry? | v1 behaviour |
| --- | --- | --- | --- |
| **A** | Never submitted — user not authenticated | **No** | **[Confirmed]** Sent once a session exists. This completes the original share action, so it is a **first submission**, not a retry. |
| **B** | Rejected by the backend with a known error response ([§7.7](#77-save-error-mapping--verified-and-resolved-v12) groups A–F) | **Yes** | **[Confirmed]** Retained with the reason shown; retry is user-initiated. |
| **C** | Uncertain outcome — timeout, missing response | **Yes** | **[Confirmed]** Retained with a plain explanation that the app cannot confirm; retry is user-initiated. |
| **D** | A retry the user explicitly initiates | — | **[Confirmed]** One URL at a time via `POST /saved-items`. |

**[Confirmed] Scenario A is documented explicitly so the distinction is not
implicit.** A URL shared before login is never discarded, survives authentication,
and is submitted when a session exists — this is
[D6](./decisions.md#d6--a-shared-url-is-preserved-through-authentication)'s core promise and is
unaffected by the retry policy.

#### Manual retry uses the existing single-item endpoint

**[Confirmed]** A user-initiated retry submits **one URL at a time** through the
endpoint that already exists — `POST /saved-items`.

- **[Confirmed] No bulk saved-item endpoint is added or required.**
- **[Confirmed] The backend is not modified** to support this UX.
- **[Confirmed]** The local queue manages ordering and individual entries; the
  backend is unaware of the queue entirely.
- **[Confirmed]** An entry is removed when the client receives a response
  confirming success.
- **[Confirmed]** If success cannot be confirmed, the entry waits again as
  `uncertain`.

**[Confirmed] This does not eliminate duplicate saved items.** It bounds
*uncontrolled* duplication. **[Confirmed] A future bulk-save endpoint may be
reconsidered** if actual usage or infrastructure capacity justifies it — **not a v1
commitment**.

#### Future review

**[Confirmed] The retry policy will be reviewed again once Flutter development has
made sufficient progress**, and the real UX, queue behaviour, and user interaction
patterns become concrete.

**[Confirmed] Automatic retry remains a possible future improvement, not part of
v1 scope.** The open questions for that review are whether to introduce it, **under
which conditions**, and **with what safeguards**.

**[Confirmed] No timeline or evaluation criteria are defined here.** They are
deliberately left open so this record does not prejudge the review.

#### Ordering within a batch

**[Rec]** When a batch of entries is submitted, process **oldest-first, strictly
sequentially**, with at most one save in flight.

- Sequential processing keeps the `saved-item-create-user` budget predictable
  (60 / 10 min, [§7.7](#77-save-error-mapping--verified-and-resolved-v12) group B).
- Oldest-first is the least surprising order — the first link shared is the one the
  user was thinking about first.
- On success, remove the entry and continue.
- On failure, stop and surface the failing entry, so one problematic URL does not
  block the rest silently.
- **[Confirmed] No retry loops.** A batch run ends; remaining entries wait for the
  user.

### 7.12 Privacy

**[Open — requires a decision]**

**[Doc]** A shared URL can carry credentials in its query string — session tokens,
signed-URL parameters, reset tokens. Persisting one to disk makes it durable local
data.

**[Rec]**
- Persist pending URLs in the platform's **secure storage** (Keychain on iOS,
  Keystore-backed storage on Android), not plain files or shared preferences.
- **[Confirmed]** Remove the entry immediately once the save is confirmed. The
  saved URL lives server-side regardless; the local copy is transient.
- **[Verify]** Whether URLs should be redacted before display. This affects the
  saved-item detail screen too, since `GET /saved-items/{id}` returns the full URL
  by design.
- **[Verify]** Store privacy declaration requirements for on-device URL
  persistence.

### 7.13 The paste field

**[Confirmed]** The in-app paste field writes into the **same queue** as the share
sheet and follows the same lifecycle.

One store means one expiry rule, one retry path, and one privacy posture. A pasted
URL faces the identical persistence problem as a shared one.

**[Rec]** Record provenance — a shared URL arrives unattended and may belong to a
session the user is no longer in, while a pasted URL is deliberate. Provenance lets
the pending list label them differently: a user returning to "3 links waiting"
benefits from knowing one came from a share they no longer remember making.
---

## 8. Platform differences

| Aspect | Android | iOS |
| --- | --- | --- |
| **Mechanism** | `ACTION_SEND` + `text/plain` intent filter | Share Extension, separate process |
| **Delivery — cold** | Launching intent at `onCreate` | Extension writes to App Group, opens deep link |
| **Delivery — warm** | `onNewIntent` | Extension writes to App Group, opens deep link |
| **Shared storage** | App-private storage | **App Group container** |
| **Launch into the app** | Native, by the system | **Not directly** — deep link |
| **Memory constraints** | None comparable | **Limited extension memory; UI in the extension discouraged** |
| **Native code required** | Manifest + activity handling | Share Extension target + App Group capability + Podfile changes |
| **Review risk** | Low | **[Verify]** Extension must follow the App Extension Programming Guide |

**[Doc]** Flutter's own testing constraint: *"You must use an iOS simulator to
test your extension in debug mode."*

**[Rec]** Treat iOS as the harder case and Android as the simpler one. **[Verify]**
Confirm both before committing to a schedule, since the iOS path involves Xcode
target configuration that cannot be exercised without a Mac.

---

## 9. UX risk assessment

Ranked by severity. Each is mitigated **within documented constraints** — none
invents capability.

### R1 — Items appear to vanish from the Inbox · **Critical**

**[Doc]** After enrichment reports a platform, a background step may file the item
into a platform-named collection — **but only if it is still in Unsorted**
(`PROGRESS.md`, decision 13a). The client is not notified.

**[Why highest]** It is the only scenario where the product appears to *lose user
data*. Everything else degrades; this looks destructive. A user who saved ten
links, watched the Inbox, and found four missing has no way to tell a background
worker from a bug.

**[Mitigation]**
- **[Rec]** Never animate or dismiss an item that leaves the list between refreshes.
- **[Rec]** Do not claim "moved to YouTube" — the transition is unobservable.
- **[Rec]** Plain reconciliation on refresh: the item is simply no longer in the
  Inbox and now appears in its platform collection.
- **[Rec]** Collections may also gain entries without user action. Never frame a
  system-created collection as user-created.
- **[Open]** Whether the app should proactively surface automatic organization at
  all. **[Doc]** *"It is automatic, not invisible"* — that phrase in `product.md`
  suggests the intended answer is yes, but no endpoint reports organization
  events, so there is nothing to surface.

### R2 — Shared URLs lost during auth or termination · **Critical**

**[Confirmed]** Fully analysed in §7. A received URL is **pending locally** and
**not** a backend-saved item; it exists only in the Flutter-owned durable queue.

- **[Doc]** An in-memory-only queue is insufficient. **[Confirmed]** The queue must
  survive application termination.
- **[Confirmed]** Retention is seven days, scoped **only** to pending local URLs.
- **[Confirmed]** Entries are retained on every failure category and are **never
  silently discarded** at expiry — the user is notified first.
- **[Residual risk — Verify]** Platform handoff implementation on both OSes (§8).

**[Mitigation]** Durable queue written before the auth gate; unobtrusive Inbox
indicator; visible pending list with categorized reasons (§7.7); sign-in path when
authentication is the blocker; the v1 manual-retry policy governs resubmission.

### R3 — Registration friction before the first save · **High**

**[Doc]** A user who shares a link into the app may face a seven-step manual
registration **before** the link is saved, including waiting for an emailed PIN.

**[Why high]** This is the first run of the core loop and the product's headline
promise is that saving is fast. The promise is technically true — `POST
/saved-items` is cheap — but the *user-perceived* time to first save is not, and
the perception is what the product is judged on.

**[Mitigation]**
- **[Rec]** Keep the held URL visible throughout auth so the user knows it is safe
  and pending. This converts an anxious wait into a confident one.
- **[Confirmed]** Do not simplify the auth flow to make it *look* shorter.
- **[Open]** Whether Google sign-in should be surfaced first on the welcome
  screen, since it reaches a session in far fewer steps. **[Doc]** Social
  finalization mints a session; manual finalization does not.

### R4 — Incorrect refresh behaviour · **High**

**[Doc]** A concurrent double-refresh **revokes the session**.

**[Why high]** The symptom is random, unexplained logout. Users report it as
corruption, not as a bug.

**[Mitigation] [Rec]** Single-flight refresh is a **correctness requirement**, not
an optimization. One refresh at a time, app-wide. **[Doc]** Additionally, refresh
fails closed during a Redis outage, locking out users whose access token has
expired for up to 15 minutes — copy must acknowledge this is temporary.

### R5 — Service unavailability and rate limits · **Medium-High**

**[Doc]** Every limiter **fails closed**. A Redis outage blocks login,
registration, password reset, **refresh**, save, and enrichment simultaneously.
**[Doc]** A refused save writes nothing; a refused enrichment fetches nothing.

**[Mitigation] [Rec]** Distinguish 429 (countdown from `Retry-After`) from 503 (no
countdown — none exists) from offline (no server state). Never merge them into one
generic error.

### R6 — Accidental collection creation · **Medium**

**[Doc]** Filing by name **creates** the collection if absent. Names are
case-insensitively unique, so `"wishlist"` finds `"Wishlist"` — which is good —
but near-misses create clutter that cannot be merged, because there is no rename
or merge endpoint.

**[Mitigation] [Rec]** Show existing collections **first** in the sheet, with the
create-by-name input visually secondary and explicitly labelled *"Create"*. Show
the resolved destination before confirming. **[Doc]** No rename and no merge
exists; both are recorded in [`decisions.md`](./decisions.md) as backend-requiring.

### R7 — Deleting empty collections · **Medium**

**[Doc]** `saved_items_action` is required even when the collection is empty.

**[Mitigation] [Rec]** Do not ask the question when there is nothing to dispose of;
send `"delete"` internally and say plainly that the collection is empty (§D.5).
This satisfies the documented contract rather than working around it.

### R8 — Search truncation · **Medium**

**[Doc]** 20 items / 5 collections, unpaged, undisclosed by the API.

**[Mitigation] [Rec]** Disclose truncation. Make search a *find the thing* tool in
the user's mental model, not a browsing tool — Inbox and Collections carry
browsing. **[Open]** Whether the cap is acceptable in practice is unknown until
there is real usage.

### R9 — Duplicate saves after an uncertain outcome · **Medium**

**[Confirmed]** Duplicate URLs are allowed and must **not** trigger a warning. That
decision is unchanged.

**[Doc]** There is no unique constraint, no `url_hash`, no idempotency key and no
request identifier (`AGENTS.md` decision 5).

**[Confirmed] Local pending-URL coalescing ([§7.6](#76-local-pending-url-deduplication)) does **not** mitigate this.**
It merges only entries still in the local queue; a request the backend already
persisted is a duplicate **saved item**, which local logic never sees.

**[Risk]** A `POST /saved-items` may commit server-side while the client never sees
the response. Retrying then produces **two identical saved items** that the user
cannot distinguish. **[Confirmed]** Retries are **not** guaranteed to be
idempotent, and the pending queue therefore offers at-least-once semantics only
(§7.8).

**[Mitigation]** **[Confirmed] Bounded, not eliminated.** Under the v1 manual-retry policy a duplicate requires a deliberate user action ([§7.11](#711-retry-policy-for-v1-provisional)). **[Confirmed] None available client-side** for the
underlying detection problem - the backend contract does not support idempotency,
and duplicates must not warn. Recorded as an accepted trade-off.
**[Confirmed] Answered for v1:** resubmission is user-initiated under the— provisional manual-retry policy. Automatic retry remains a
the next attempt. The residual question - whether a duplicate still results - is
accepted, not solved.

### R10 — Broken preview images · **Low**

**[Doc]** Images are external references the backend does not guarantee.

**[Mitigation] [Rec]** Treat as routine. Placeholder + reserved layout. No error,
no retry, no layout shift, no impact on tappability.

### R11 — Pending-URL expiry and overflow · **Medium**

**[Confirmed]** Seven-day retention, **scoped only to the local pending queue**. All
URLs are queued; newest-URL-wins is not used. Equivalent pending URLs are coalesced
in place per [§7.6](#76-local-pending-url-deduplication); distinct URLs are never merged.
No capacity has been specified.

**[Risk]** Silent expiry discards deliberate user intent; a hard capacity cap does
the same. **[Confirmed]** Neither may happen silently.

**[Mitigation]** **[Confirmed]** Notify before removing an expired entry. **[Rec]**
Soft cap with visible overflow rather than a hard drop. **[Open]** The exact
notification presentation, any keep/retry action, and the cap size still need
approval (§7.9, §7.10).

### R12 — Platform divergence · **Medium**

**[Verify]** iOS requires an App Group, a Share Extension target, and deep linking;
Android requires an intent filter and activity handling. **[Doc]** iOS extensions
are memory-constrained and cannot be tested on a physical device in debug mode.

**[Mitigation]** Verify both early. iOS is the schedule risk, not Android.

### R13 — Search field coverage · **Low-Medium**

**[Doc]** Only `title`, `domain`, `url` are searchable. A `pending` item has **no
title**, so it is findable only by domain or URL.

**[Mitigation] [Rec]** Zero-result copy must not assert the item was never saved
(§B.7). **[Doc]** Not solvable client-side; fuzzy matching already mitigates typos.

### R14 — Missing item counts · **Low-Medium**

**[Doc]** `GET /collections` carries no count. **[Rec]** Omit counts in v1.
Deriving them would cost one request per collection on an unbounded list.

### R15 - Local deduplication mistaken for backend deduplication - **Medium**

**[Confirmed]** Local pending-URL coalescing ([§7.6](#76-local-pending-url-deduplication))
overwrites an equivalent pending entry in place and preserves its queue position. It
is easy to over-read this as general duplicate protection.

**[Why medium]** The word "deduplication" invites the assumption that the app now
handles duplicate URLs generally. It does not. The rule touches **only** URLs still
in the local pending queue. Once a URL is confirmed saved, its entry is removed and
the saved item is out of the queue's reach entirely.

**[Confirmed] Boundaries:**
- Flutter **cannot** detect duplicates already stored in the backend. No capability
  exists, and none is requested.
- The rule does **not** change the backend product decision: duplicate saved URLs
  are allowed without a warning (`AGENTS.md` decision 5).
- The rule does **not** mitigate uncertain save outcomes (R9). A duplicate produced
  by a lost response is a duplicate **saved item**, not a duplicate pending entry.

**[Mitigation]** **[Rec]** Describe the behaviour as "re-sharing a pending link
refreshes it" rather than as deduplication in user-facing copy. **[Open]** Whether
the user is told anything at all when a share coalesces; **[Confirmed]** no warning
or confirmation dialog is shown.

### R16 - URL equivalence undefined - **Medium**

**[Open]** Whether two URLs are "equivalent" for the purposes of
[§7.6](#76-local-pending-url-deduplication) is **not decided**.

**[Doc]** There is no backend rule to reuse: `domain` derivation is a display and
ownership step rather than a URL-identity rule; canonical URLs are reported by the
extractor but **not persisted and not applied** (`PROGRESS.md`, decision 17); and
`saved_items` has no `url_hash` and no unique constraint on `url`.

**[Risk]** An aggressive equivalence rule would merge genuinely different pages and
silently drop a share the user made deliberately. A too-strict rule would simply
fail to coalesce, which is the milder failure.

**[Mitigation]** **[Confirmed]** Default to the strictest sensible comparison until
decided, and do not implement normalization. **[Open]** Exact comparison behaviour
needs a decision.
---

## 10. Search sufficiency assessment

**[Confirmed]** Evaluate search sufficiency and document limitations as UX risks;
do not request backend changes merely to eliminate them during discovery.

**Verdict: sufficient for v1, with bounded limits.**

**What search covers well**
- A half-remembered word — fuzzy matching recovers typos (`camra` → `camera`).
- A remembered site — `domain` is searchable.
- A partial URL — `url` is searchable.
- *"Which collection was that in?"* — every item result carries its collection name.
- Collections by name, including `unsorted`.

**Recorded limitations** (all in §9): hard caps (R8), limited searchable fields
(R13), no filters or autocomplete, no paging, and `pending` items being
title-less.

**[Rec]** These bounds are coherent with the product. Search answers *"where is the
thing I saved?"* — not *"show me everything"*. The honest v1 answer for a user who
has forgotten both the collection and any searchable token is *"we don't support
that yet"*, and the UI should not pretend otherwise.

---

## 11. Remaining questions

### Open product questions
1. **Pending-URL expiry notification presentation** - silent discard is
   **[Confirmed] ruled out**. The specific notification form, and any keep/retry
   action offered with it, remain open. ([§7.9](#79-retention--seven-days-pending-urls-only))
2. **URL equivalence and normalization for local coalescing** - what makes two
   pending URLs "equivalent"? **[Open]** No backend rule exists to reuse, and
   **[Confirmed]** none may be invented. ([§7.6](#76-local-pending-url-deduplication), R16)
3. **Whether the user is told anything when a share coalesces** - refreshing an
   existing pending entry is silent by confirmation, but whether a subtle
   acknowledgement is worthwhile is undecided. ([§7.6](#76-local-pending-url-deduplication), R15)
4. **Manual language selection in Profile** - device locale is the **proposed**
   default; a user-facing language override is **[Open]**. ([§12.2](#122-v1-language-scope))
5. **Pending-URL queue capacity** - soft cap value and overflow presentation.
   ([§7.10](#710-queue-capacity-and-overflow))
6. **Pending-URL failure on a permanent validation error** (VALIDATION_ERROR,
   INVALID_URL) - discard or retain for correction? **[Confirmed]** This is *not*
   the queue's primary failure scenario, but it still needs an answer.
   ([§7.7](#77-save-error-mapping--verified-and-resolved-v12))
7. **Should automatic retry be introduced later?** **[Confirmed] Reopened as a future
   review**, not settled. Whether to introduce it, under which conditions, and with
   what safeguards is undecided, and the review point is "once Flutter development has
   made sufficient progress". No timeline or criteria are set. See
   [§7.11](#711-retry-policy-for-v1-provisional).
   ([§7.8](#78-uncertain-save-outcomes---the-product-answer-and-what-stays-open), R9)
8. **Where does the paste field live** - always visible on the Inbox, or behind an action?
9. **Whether Google sign-in leads the welcome screen**, given it reaches a session
   in fewer steps. (R3)
10. **Whether to send X-Platform / X-Device-Name now** despite deferring device
    management. ([§3](#3-primary-user-journeys), Journey F.6)
11. **Whether search result ordering should be surfaced** - results are best-match
    first, with recency only as a tie-break, which may surprise users expecting
    newest-first.

### Technical verification required
12. **iOS share extension handoff** - App Group container, deep link, and
    confirmation that a cold-start share is read reliably. ([§7.2](#72-platform-reality))
13. **Android intent delivery** - cold and warm paths, and behaviour after process
    death. ([§7.2](#72-platform-reality))
**[Confirmed] V11 is resolved for v1** as the provisional manual-retry policy: a
[§7.8](#78-uncertain-save-outcomes---the-product-answer-and-what-stays-open):
resubmission after an uncertain outcome is user-initiated. **[Open]** Whether
automatic retry is introduced later is a future review.
The residual protocol limitation is unchanged.
15. **URL equivalence comparison rule** - exact match after trimming, or scheme/host
    case normalization, trailing-slash and fragment handling?
    ([§7.6](#76-local-pending-url-deduplication), R16)
16. **Secure storage availability and cost** on both platforms for the seven-day
    queue. ([§7.12](#712-privacy))
**[Confirmed] V12 is resolved.** The save-endpoint `error.code` mapping was
produced by tracing `POST /saved-items` through `saved_item/routes.go`,
`middleware.Auth`, `middleware.UserRateLimit`, `httpx.BindBody`, `service.Create`
and the repository. The reachable codes, the codes verified **absent** from this
route, the save-certainty rule, and the English/Indonesian messages are in
[§7.7](#77-save-error-mapping--verified-and-resolved-v12).

**[Confirmed] V11 is resolved.** The product answer is recorded in
[§7.8](#78-uncertain-save-outcomes---the-product-answer-and-what-stays-open):
resubmission after an uncertain outcome is user-initiated. **[Open]** Automatic retry
is a future review, not a settled question.


### Backend-requiring decisions
Recorded in [`decisions.md`](./decisions.md). None are requested now.

---

## 12. Localization and localized error messaging

### 12.1 Ownership

**[Confirmed] Flutter owns localization of all user-facing UI text.**

**[Doc] The backend does no localization at all.** Verified: there is no
`Accept-Language` handling, no locale detection, and no message catalogue. The only
localization-adjacent item in the codebase is a schema comment noting that
`lower(btrim(name))` is *"not locale-stable"* - a comment about collation, not
translation. `golang.org/x/text` appears in `go.mod` only as an indirect
transitive dependency.

**Consequence.** There is no server-side locale contract to design around. Every
user-facing string the app renders is authored in Flutter.

### 12.2 V1 language scope

**[Confirmed] V1 supports two languages: English (`en`) and Indonesian (`id`).**

**[Confirmed] Use Flutter's standard localization approach with ARB translation
resources and generated localization accessors**, subject to final architecture
decisions. **[Confirmed] Do not implement localization code or initialize the
Flutter project in this phase.**

**[Rec] Proposed default: device locale.** The app selects the language from the
device setting. **[Open]** Manual language selection in Profile is **not confirmed**
- see §11.

### 12.3 UI localization is separate from saved content

**[Confirmed] UI localization is separate from saved webpage metadata and content
language.**

**[Doc] Supporting facts:**

- `saved_items` stores `title`, `description`, `image_url` and `platform` **exactly
  as the page supplied them**, in whatever language the page used. There is **no
  content-language column** on `saved_items` (verified against
  `internal/database/baseline/schema.sql`).
- **[Doc]** Metadata is page-derived, never translated or rewritten:
  *"Extracted text is tidied of the whitespace markup introduces, and otherwise left
  alone. A title is something a person reads, so it is not lowercased, shortened,
  or rewritten."* (`product.md`)

**Consequence.** Switching the app's language does **not** change the language of
saved item titles or descriptions. That is correct behaviour, not a defect - the
user saved what the page said. It also means a list can legitimately mix languages
when the user's sources do.

### 12.4 Localized error messages

**[Confirmed] Flutter must use the backend's structured `error.code` to select an
appropriate localized, user-readable message.**

**[Confirmed] Do not display backend `error.message` directly to users.** **[Doc]**
`message` is human-facing English prose that is not a stable contract; `code` is the
machine-readable discriminator (`internal/httpx`, `swagger.APIError`).

| Rule | Detail |
| --- | --- |
| **[Confirmed]** `code` selects the message | The localized string is chosen by `error.code`, in Flutter. |
| **[Confirmed]** `message` is never shown | Backend prose is not user-facing copy. |
| **[Confirmed]** Localization changes presentation only | **Error semantics are unchanged.** A `USER_RATE_LIMIT_EXCEEDED` means the same thing in `id` as in `en`. |
| **[Confirmed]** Codes and meanings stay authoritative | The backend remains the source of truth for what each code means. |
| **[Confirmed]** Verify against the real route | Codes were checked against `POST /saved-items` and its middleware - see §7.7. |
| **[Confirmed]** Do not assume every defined code can occur here | A constant existing in `internal/apperror` does not mean the save route emits it. |
| **[Confirmed]** Do not invent codes | No code may be created, renamed, or inferred without source evidence. |
| **[Confirmed]** No response means no code | A transport failure has no `error.code` and must be handled separately. Do not invent one. |

**[Verified]** The codes confirmed as reachable on the save route are listed in
[§7.7](#77-save-error-mapping--verified-and-resolved-v12). Any code outside that list is
**unmapped** and must be treated as such. See §7.7.

**[Confirmed] Category distinctions must survive localization.** Authentication
failures, rate limiting, service availability, transport failures, and uncertain
save outcomes are conceptually distinct and must remain so in every language:

| Category | Localized message must convey |
| --- | --- |
| **Authentication required** | Sign in to continue |
| **Budget exhausted** | A real wait, with a countdown where `Retry-After` exists |
| **Server temporarily unavailable** | A temporary condition, and **no** fabricated countdown |
| **Connectivity unavailable** | No connection - **distinct from "server is down"** |
| **Uncertain outcome** | See below - the strictest requirement |

#### The uncertain-outcome wording constraint

**[Confirmed] The displayed message must not falsely claim an item is definitely
unsaved if the backend may have persisted it but the response was lost.**

This is the one localization requirement that is a correctness constraint rather
than a style preference. A translated string such as *"Not saved. Try again."* is
**wrong** in the uncertain case: the backend may have created the item, and the user
would then reasonably assume nothing happened.

**[Confirmed] The unresolved technical risk around uncertain save outcomes and
retry behaviour is preserved.** Localizing the message does not resolve it, and the
message must not imply it has. **[Open]** Whether an uncertain outcome should
suppress the automatic retry in favour of prompting the user to check the Inbox -
see §11 and risk R9.

### 12.5 States that carry translatable copy

**[Rec]** Every state in the [§5](#5-interaction-state-matrix) matrix with
user-facing text is a localization surface, including the ones that must **not**
say something:

| State | Requirement |
| --- | --- |
| Save confirmation | **[Confirmed]** Must not imply enrichment completed. |
| Pending enrichment | Must not read as a failure. |
| Completed with no metadata | **Must not** read as an error in any language. |
| Failed enrichment | Must not read as a broken item. |
| Empty / truncated search | Must not assert the item was never saved. |
| Empty vs missing collection | Must stay **distinguishable** after translation. |
| 429 vs 503 vs offline | Must stay **distinguishable** after translation. |
| Pending URL reasons | Categories from [§7.7](#77-save-error-mapping--verified-and-resolved-v12), in the active language. |

---
## 13. Sources

| Source | Used for |
| --- | --- |
| `documentation/product.md` | Purpose, core loop, saved-item behavior, enrichment, collections, search semantics |
| `PROGRESS.md` | Implementation status, request/response shapes, rate limits, Important Decisions 1–30 |
| `AGENTS.md` | Contract invariants: ownership, `system_key`, address-by-ID, cursor semantics, enrichment rules |
| `documentation/auth-sessions.md` | Token lifetimes, rotation, reuse detection, device listing, accepted trade-offs |
| `docs/swagger.json` | Generated OpenAPI contract — routes, parameters, payload field sets |
| `internal/saved_item/request.go`, `service.go` | Save validation; `deriveDomain` |
| `internal/security/outbound_fetch.go` | `OutboundFetchTimeout = 10s`, response limits |
| `internal/collection/request.go`, `service.go` | Collection delete disposition requirement |
| `internal/api/saved_item/routes.go` | Save route middleware chain (Auth -> UserRateLimit -> handler)
| `internal/middleware/user_ratelimit.go` | `USER_RATE_LIMIT_EXCEEDED`, `USER_RATE_LIMIT_UNAVAILABLE` (per-user, the only limiter on the save route)
| `internal/httpx/bind.go` | `VALIDATION_ERROR` (field errors) and `BAD_REQUEST` (body parse failure) |
| `internal/httpx/error_handler.go` | Envelope, status, `Retry-After` emission
| `internal/api/saved_item/repository.go` | `CreateSavedItem` single autocommit statement; Unsorted invariant error
| `cmd/api/main.go` | `fiber.New` config - no `ReadTimeout` / `WriteTimeout`; `recoverer` wiring
| fiber v3.5.0 `DefaultErrorHandler`, `middleware/recoverer` | Panic and `*fiber.Error` paths return `text/plain`, not the JSON envelope
| `internal/apperror/error.go` | Error envelope, generic status codes, `Retry-After` policy |
| `internal/httpx/*.go` | `{error: {code, message, fields}}` envelope |
| `internal/middleware/auth.go` | `INVALID_AUTHORIZATION_HEADER`, `INVALID_ACCESS_TOKEN`, `ACCESS_TOKEN_EXPIRED` |
| `internal/middleware/ratelimit.go` | `*_RATE_LIMIT_EXCEEDED`, `*_RATE_LIMIT_UNAVAILABLE`, `CLIENT_IP_UNAVAILABLE` |
| `internal/api/auth/session/error_codes.go` | `SESSION_REVOKED`, `SESSION_EXPIRED`, `REFRESH_TOKEN_INVALID` |
| `internal/database/baseline/schema.sql` | `saved_items` columns; absence of `url_hash`, canonical URL, and any content-language column |
| `go.mod`; absence of any `Accept-Language` or locale handling | Backend performs no localization - see [§12](#12-localization-and-localized-error-messaging) |
| `docs.flutter.dev/.../ios/app-extensions` | iOS extension process isolation and memory constraints |

**Not read:** `documentation/pin-email-budgets.md` (email budget policy — relevant
only to resend UX), `concept/*.txt` design drafts (pre-implementation, dated
2026-10-04, superseded by `product.md` and `PROGRESS.md`), and `gpt checkpoint/*.txt`.
