# Stash It — UX Decision Record

**Status:** Initial discovery. Section 1 is approved. Sections 2–5 are **not**.

**Companion document:** [`ux-discovery.md`](./ux-discovery.md) holds the analysis
behind every entry here. Read both — this record says *what was decided and what
was not*; the discovery document says *why*.

## How to read this

| Section | Status |
| --- | --- |
| [1. Confirmed decisions](#1-confirmed-decisions) | **Approved.** Treat as binding. |
| [2. Provisional recommendations](#2-provisional-recommendations) | **Awaiting approval.** Do not implement as decided. |
| [3. Open product questions](#3-open-product-questions) | Undecided. Materially affects product or architecture. |
| [4. Technical verification required](#4-technical-verification-required) | Feasibility to confirm before implementation. |
| [5. Decisions requiring backend changes](#5-decisions-requiring-backend-changes) | Known UX needs the backend does not support. **Not requested.** |

**Nothing in this document approves an architecture decision.** Navigation
libraries, state management, API clients, persistence mechanisms, and design
systems are all unselected and out of scope for discovery.

---

## 1. Confirmed decisions

### D1 — Navigation has four destinations

**Inbox · Collections · Search · Profile**

*Rationale.* **[Confirmed] The four destinations are unchanged.** `product.md` uses
"Inbox" throughout its own language — *"An inbox with unsorted items is a valid,
successful state"* and development-order step 1, *"Share → Save → Inbox"*.

> **[Confirmed] Rationale updated by
> [D26](#d26--inbox-is-a-recent-saved-history-across-collections).** This entry
> originally argued that the backend's "no separate inbox" rule (`AGENTS.md`,
> decision 19g) is an API-shape argument and therefore not a reason to withhold an
> Inbox tab. That argument is superseded by a stronger one: the Inbox is a distinct
> destination with its own responsibility, not a view over the `unsorted`
> collection. **[Doc]** The backend still exposes no separate inbox endpoint, which
> is why D26 records a *planned* backend requirement rather than an available
> capability.

*Cost.* One extra tab versus a three-tab variant that has no Inbox.

*Rejected alternative.* Three tabs (`Collections | Search | Profile`) with Unsorted
pinned at the top of Collections — more faithful to the data model, marginally
cheaper, one extra tap on every *"where did I just save that?"*.

*See:* ux-discovery §2.3

---

### D2 — Unsorted is resolved by `system_key`, never by name

The Inbox destination is derived from `GET /collections` by matching
`system_key === "unsorted"`.

*Rationale.* **[Doc]** `AGENTS.md` decision 19b: *"Unsorted is identified by
`system_key` and is the only protected collection. Collection type is not the
criterion: `type = 'system'` describes who created a collection, not what it is."*
A user collection may not use a reserved system name, but identity is still the key,
never the display string.

*Consequence.* **The Unsorted collection ID is server data, not a client constant.**
It must be resolved by a prior `GET /collections` call before any screen can show
Unsorted. That call is also needed by Collections, the file sheet, and the delete
dialog, so it remains the app's root data dependency.

> **[Confirmed] Scope of this rule, updated by
> [D26](#d26--inbox-is-a-recent-saved-history-across-collections).** The Inbox no
> longer depends on the Unsorted ID, because it no longer renders the `unsorted`
> collection. **[Confirmed] Resolution by `system_key` is unchanged everywhere
> Unsorted still appears as a collection** — the Collections list, the file sheet,
> and the delete dialog.

*See:* ux-discovery §2.1

---

### D3 — Inbox and Unsorted collection contents share one screen

> **[Confirmed] SUPERSEDED by
> [D26](#d26--inbox-is-a-recent-saved-history-across-collections).** The Inbox is
> no longer an alias for the `unsorted` collection, so it no longer shows the same
> thing and no longer shares a screen with it. This entry is retained for history
> and must not be implemented.
>
> **[Confirmed] The underlying API fact survives.** Unsorted collection contents are
> still served by `GET /collections/{id}/saved-items`. That is now a **Collections**
> concern (S9), not an Inbox one.

*Original rationale, retained:* **[Doc]** `product.md`: the inbox "is that
collection seen through the same lens as any other." Both are served by
`GET /collections/{id}/saved-items` with identical response shapes.

*Original consequence, retained as history:* One screen parameterised by collection
ID and name. **[Confirmed]** What survives is narrower: a single parameterised
collection-contents screen still serves *every* collection, including Unsorted,
and must not drift between them — see ux-discovery §4.1.

*See:* ux-discovery §4

---

### D4 — No unnecessary client-side sorting

Collections render in the server's order. **[Doc]** `GET /collections` pins
Unsorted first under **every** sort via a rank in SQL — not filtered out, not
special-cased per sort — so all three sorts inherit the rule from one place.

*Consequence.* Held cursors must be discarded when the user changes `sort`: a
cursor **must match the requested sort**, and the backend cannot prevent a mismatch.

*See:* ux-discovery §3, Journey D

---

### D5 — Share sheet primary, in-app paste fallback

The OS share sheet is the primary intake. An in-app URL paste field is the
fallback and the recovery path for a failed share extension.

**[Doc] There is no backend contract for intake.** It is entirely a platform
concern. No API endpoint exists or is implied.

*Platform reality — see D8.*

---

### D6 — A shared URL is preserved through authentication

The intended experience: receive a shared URL before authentication, preserve it
through the auth flow, save it after successful authentication.

**[Confirmed] In-memory storage is explicitly ruled out as sufficient.**

*Rationale.* **[Doc]** Authentication is multi-step and includes waiting on an
emailed PIN; **[Doc]** on iOS the share extension is a *separate process* that
cannot reach the Flutter app's memory (D8). A URL must be persisted durably
**before** the auth gate.

*Scope limit.* This decision confirms the *behavior*. The persistence mechanism,
queue capacity, notification presentation, and recovery behaviour remain open — see
§3 and §4. The retention policy itself is set in
[D7](#d7--pending-urls-seven-day-retention-queued-duplicates-silent).

*See:* ux-discovery §7

---

### D7 — Pending URLs: seven-day retention, queued, duplicates silent

Three confirmed product requirements:

| Requirement | Value |
| --- | --- |
| **Retention** | **Seven days** — the initial policy, scoped **only** to the local pending queue |
| **Multiple pending URLs** | **Queued** — not newest-wins |
| **Duplicate URLs** | Allowed with **no warning and no confirmation** |

**[Confirmed] Retention applies ONLY to the local pending queue.** It explicitly
does **not** apply to:

- URLs already saved in the backend — a saved item does **not** expire after seven
  days and has no such TTL;
- anything resembling a backend TTL or backend persistence requirement — the
  backend stores no pending-URL concept;
- enrichment status or worker execution — a seven-day-old pending URL is not an
  enrichment state.

**[Confirmed] Seven days is the agreed *initial* policy** and may be reconsidered
based on future product usage. It is a client-side policy constant, not a backend
constraint. **[Confirmed]** Expiry behaviour is specified in
[D14](#d14--user-is-notified-before-an-expired-pending-url-is-removed).

*Rationale for queueing.* **[Doc]** The backend has no pending-save concept and no
anonymous save. **[Doc]** `POST /saved-items` is idempotency-free by design —
*"Duplicate URLs are allowed. There is no unique constraint, deduplication, or
`url_hash`"* (decision 5). A newest-wins policy would silently discard a share the
user deliberately made.

*Consequence.* D7 requires a durable **multi-entry** queue, not a nullable field.
See D13 for the ownership boundary.

**[Confirmed] "Queued" does not mean every entry is distinct.** Equivalent URLs
already in the local queue are coalesced in place per
[D19](#d19--local-pending-url-deduplication-overwrite-and-preserve-position); distinct
URLs are never merged, and the existing entry keeps its original queue position rather
than moving to the newest position.

*See:* ux-discovery §7.8

---

### D8 — Enrichment states are represented accurately, with retry on `pending` and `failed`

**[Doc]** `enrichment_status` has exactly three values — `pending`, `completed`,
`failed` — and deliberately **no `processing` or `retrying`** (`AGENTS.md`,
decision 9). The client must not invent an intermediate state.

| Requirement | Detail |
| --- | --- |
| Distinguish pending from failed | `pending` is *not* in-progress and *not* broken; `failed` is *not* a broken item |
| Retry on `pending` **and** `failed` | **[Doc]** A `pending` item can be permanently stuck — a failed enqueue has no reconciliation pass (decision 16), and exhausted retries leave it `pending`. The user has no other recourse. |
| Respect rate limits | **[Doc]** Enrichment is **10 per minute per user**; save is **60 per 10 minutes** |
| Handle 429 and 503 correctly | **[Doc]** 429 carries `Retry-After`. **503 carries none** — the limiter fails closed and no recovery time is known (decision 25) |

**[Doc]** Supporting invariant: *"`completed` means the enrichment process
succeeded, not that every field was found."* A `completed` item with no title, no
image and no description is **normal and successful**, and must not be styled as a
problem.

*See:* ux-discovery §3, Journey E

---

### D9 — No endpoint lists every saved item at once

> **[Confirmed] Scope updated by
> [D26](#d26--inbox-is-a-recent-saved-history-across-collections).** A
> cross-collection listing *is* now required — for the Inbox. This entry is retained
> in the corrected form below rather than deleted.

**[Doc] Still true.** Decision 19g: there is deliberately no backend endpoint
listing every saved item at once, and none exists today.

**[Confirmed] What this now means.** The absence of an aggregate endpoint remains a
backend fact, but it is no longer the reason the product has no cross-collection
view. **[Confirmed] The Inbox's cross-collection listing is recorded as a planned
backend requirement** — see [D26](#d26--inbox-is-a-recent-saved-history-across-collections)
and [§5.1](#51-recently-saved-items-across-collections-inbox). **[Confirmed] Nothing
in that requirement may be treated as implemented or available.**

**[Confirmed] Unchanged from the original decision.** Rediscovery uses Inbox,
Collections, and Search only; there is no separate "browse everything" destination.
**[Doc]** No backend change is requested merely to remove a search limitation during
discovery.

*Assessment recorded.* Search is **sufficient for v1** with bounded limits — see
[§2.5](#25-recommendation--search-framing-and-truncation-disclosure) and
[§5.1](#51-recently-saved-items-across-collections-inbox).

*See:* ux-discovery §10

---

### D10 — Profile and essential account functionality only

`GET /users/me`, `PATCH /users/me` (`display_name`), `PUT /users/me/password`.

**Device and session management is deferred**, even though `GET /auth/sessions` and
`DELETE /auth/sessions/{id}` exist and work.

**[Open]** Deferring device management cleanly also defers the `X-Device-Name` /
`X-Platform` / `X-Installation-ID` headers, since those populate the device list.
Whether to send them now for future benefit is a small decision — see §3.

*See:* ux-discovery §3, Journey F

---

### D11 — Account deletion is an unresolved release consideration

**No frontend-only solution is to be invented.**

**[Doc]** No account-deletion endpoint exists. `PROGRESS.md` lists account
deletion, email change, email verification, avatars, and provider unlinking as
explicitly out of scope.

*Classification.* This is a **release blocker, not a UX gap**. Apple App Store
guideline 5.1.1(v) and Google Play's account-deletion requirement both apply to
apps that create accounts. It requires a backend feature **and** a design pass.

*See:* ux-discovery §3, Journey F and [§5.2](#52-account-deletion)

---

### D12 — Target platforms are Android and iOS

No separate mobile-web experience is designed in this phase.

*Consequence.* **[Verify]** The two platforms require **different** native
implementations for share intake and must not be assumed equivalent. See
V1 below, and ux-discovery §8.

---

### D13 — Pending local URLs and backend-saved items are distinct states of ownership

Two states, with different owners:

| State | Meaning | Owner |
| --- | --- | --- |
| **Pending locally** | Flutter received a shared or pasted URL, but **the client has not confirmed the backend saved it** | **Flutter** |
| **Saved remotely** | The backend confirmed successful creation of the saved item | **Backend** |

**[Confirmed] A locally pending URL is not a confirmed backend-saved item.** The
queue exists solely to prevent shared URLs from being lost when authentication,
connectivity, or backend availability prevents a confirmed save.

**[Confirmed] The local queue is entirely a Flutter responsibility.** The backend
does not know about, and does not need to know about, URLs that have not been
submitted successfully. There is no backend endpoint for pending URLs, and none is
implied.

**The boundary:**

```
Share sheet / paste
      |
      v
Durable local pending queue          <-- Flutter-owned, seven-day retention (D7)
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
tracks exactly one thing:

> **Has the client confirmed that the save operation succeeded?**

**[Confirmed] The pending queue is not an aggregate saved-items view.** It shows
URLs the backend has **not** confirmed. Saved items are served only from the
backend. The queue must not become a client-side substitute for an "all saved
items" endpoint - see [§5.1](#51-recently-saved-items-across-collections-inbox).

*See:* ux-discovery §7.1

---

### D14 — User is notified before an expired pending URL is removed

**[Confirmed] Do not silently discard pending URLs when the seven-day retention
period expires.** **[Confirmed] Notify the user before removing an expired pending
URL.**

*Rationale.* A shared URL represents deliberate user intent. Silent removal
converts a failed save into data loss — the exact outcome
[D6](#d6--a-shared-url-is-preserved-through-authentication) and
[D7](#d7--pending-urls-seven-day-retention-queued-duplicates-silent) exist to
prevent.

**[Open]** The exact notification presentation, and any keep/retry action offered
alongside it, remain open — see [§3 Q1](#3-open-product-questions).

**[Rec]** Enforce expiry on read and on app foreground rather than via a background
timer — mobile OSes do not guarantee background execution, so a timer-based sweeper
would be unreliable.

*See:* ux-discovery §7.8

---

### D15 - Save failures are categorized by verified `error.code` values (V12 resolved)

**[Confirmed] V12 is resolved.** The mapping was produced by tracing
`POST /saved-items` through its real execution path, not by enumerating defined
constants. **[Confirmed] Do not invent, rename, or assume codes.**

#### The verified execution path

**[Doc]** `internal/api/saved_item/routes.go` lines 33-38 mount exactly three
things on the create route:

```
POST /saved-items
  1. middleware.Auth(verifier)       -> internal/middleware/auth.go:22-65
  2. middleware.UserRateLimit(...)   -> internal/middleware/user_ratelimit.go:66-100
  3. handler.Create                 -> internal/api/saved_item/handler.go:51-81
       -> httpx.BindBody             -> internal/httpx/bind.go:12-33
       -> service.Create             -> internal/api/saved_item/service.go:94-150
```

#### Codes that can reach the client

**[Doc]** Verified reachable, in execution order:

| # | Code | HTTP | Produced by | Condition |
| --- | --- | --- | --- | --- |
| 1 | `INVALID_AUTHORIZATION_HEADER` | 401 | `middleware/auth.go:29,38` | `Authorization` absent, not `Bearer `-prefixed, or empty after the prefix |
| 2 | `ACCESS_TOKEN_EXPIRED` | 401 | `middleware/auth.go:48` | `verifier.Verify` returns `jwt.ErrTokenExpired` |
| 3 | `INVALID_ACCESS_TOKEN` | 401 | `middleware/auth.go:55` | Any other verification failure |
| 4 | `INTERNAL_SERVER_ERROR` | 500 | `middleware/user_ratelimit.go:74` | Claims missing or `sub` empty. **[Doc]** Unreachable through correct wiring |
| 5 | `USER_RATE_LIMIT_UNAVAILABLE` | 503 | `middleware/user_ratelimit.go:84` | Redis limiter error. **Fails closed, no `Retry-After`** |
| 6 | `USER_RATE_LIMIT_EXCEEDED` | 429 | `middleware/user_ratelimit.go:92` | Budget spent. Namespace `saved-item-create-user`, 60 / 10 min. **Carries `Retry-After`** |
| 7 | `INTERNAL_SERVER_ERROR` | 500 | `saved_item/handler.go:56` | `uuid.Parse(claims.Subject)` fails. **[Doc]** Unreachable by construction |
| 8 | `BAD_REQUEST` | 400 | `httpx/bind.go:29` | Body unparseable (malformed JSON). **[Doc]** A client defect in practice |
| 9 | `VALIDATION_ERROR` | 400 | `httpx/bind.go:26` | `url` fails `validate:"required,url,max=2048"`. Carries `fields[]` |
| 10 | `INVALID_URL` | 400 | `saved_item/service.go:329,340,347` | `url.Parse` failed, or hostname empty |
| 11 | `INTERNAL_SERVER_ERROR` | 500 | `saved_item/repository.go:104,107` | Unsorted row missing (broken invariant) or any database error |

#### Codes verified **not** reachable on this route

**[Doc]** Each checked against the mounted middleware and the `apperror` calls
actually present in the `saved_item` package.

| Code | Why it cannot occur here |
| --- | --- |
| `IP_RATE_LIMIT_EXCEEDED` | `IPRateLimit` is **not mounted** on the create route |
| `IP_RATE_LIMIT_UNAVAILABLE` | Same |
| `CLIENT_IP_UNAVAILABLE` | Only `IPRateLimit` emits it |
| `SESSION_REVOKED` | Emitted only by `/auth/refresh` |
| `SESSION_EXPIRED` | Same |
| `REFRESH_TOKEN_INVALID` | Same |
| `RESOURCE_NOT_FOUND` | `apperror.NotFound` is called only at `repository.go:138` (Get) and `repository.go:181` (Delete) |
| `UNAUTHORIZED` | `UnauthorizedWith` is always called with an explicit code, never `""` |
| `FORBIDDEN` | No `apperror.Forbidden` call in `saved_item` |
| `CONFLICT` | No `apperror.Conflict` call in `saved_item` |
| `TOO_MANY_REQUESTS` | Only a *default* when the code is `""`; `user_ratelimit.go:92` passes `CodeUserRateLimitExceeded` |
| `SERVICE_UNAVAILABLE` | Only a *default* when the code is `""`; `user_ratelimit.go:84` passes `CodeUserRateLimitUnavailable` |

**[Confirmed] Any code outside the reachable table is unmapped.** Handle it
defensively; do not display a backend message for it.

#### Actionable mapping

**[Confirmed]** Messages are selected by `error.code` in Flutter.
**[Confirmed]** `error.message` is never displayed.
**[Rec]** The English and Indonesian strings are drafts pending native-speaker review.

| Group | Codes | Save certainty | Flutter action | English | Indonesian |
| --- | --- | --- | --- | --- | --- |
| **A. Auth required** | `INVALID_AUTHORIZATION_HEADER`, `INVALID_ACCESS_TOKEN`, `ACCESS_TOKEN_EXPIRED` | **Known not saved** | `ACCESS_TOKEN_EXPIRED`: single-flight refresh, retry once, silently; on failure go to sign-in. The other two: **do not attempt refresh** - the token is unusable - go straight to sign-in. Keep the entry. | "Sign in again to save this link." | "Masuk lagi untuk menyimpan tautan ini." |
| **B. Budget exhausted** | `USER_RATE_LIMIT_EXCEEDED` | **Known not saved** | Countdown from the **`Retry-After` header**. Suspend the queue until it elapses; entries then wait for the user. | "You're saving too quickly. Try again in {countdown}." | "Terlalu sering menyimpan. Coba lagi dalam {countdown}." |
| **C. Server unavailable** | `USER_RATE_LIMIT_UNAVAILABLE`, `INTERNAL_SERVER_ERROR` | **Known not saved** | Retain. **No countdown** - no recovery time is known. **Manual retry only** ([D23](#d23---manual-retry-is-the-v1-default-policy-provisional)). | "We couldn't save this link just now. It's still queued - try again shortly." | "Kami belum berhasil menyimpan tautan ini. Tautan masih dalam antrean - coba lagi sebentar lagi." |
| **D. Invalid link** | `VALIDATION_ERROR`, `INVALID_URL` | **Known not saved** | **[Confirmed]** Not the queue's primary scenario. Surface clearly, offer edit-and-retry. **Do not auto-retry** - the same input fails identically. | "That doesn't look like a valid link. Check the URL and try again." | "Tautan itu tidak valid. Periksa URL-nya lalu coba lagi." |
| **E. Malformed request** | `BAD_REQUEST` | **Known not saved** | Retain and offer retry. **[Doc]** Should never fire from a well-formed client - log as a client defect. | "Something went wrong sending that link. It's still queued - try again." | "Terjadi kesalahan saat mengirim tautan itu. Tautan masih dalam antrean - coba lagi." |
| **F. Response not understood** | *(no `error.code`)* non-JSON body, or an unrecognized code | **Known not saved** - a non-2xx response was received | Retain and offer retry. **Never display a raw body.** | "We couldn't read the server's reply. This link is still queued - try again." | "Kami tidak dapat membaca balasan server. Tautan ini masih dalam antrean - coba lagi." |
| **G. Transport failure** | *(no response at all)* | **UNCERTAIN** | Retain. **Do not state the item is unsaved.** Prompt the user to check the Inbox before retrying. | "We couldn't confirm this save. It may or may not have gone through - check your Inbox before trying again." | "Kami tidak dapat mengonfirmasi bahwa tautan ini tersimpan. Bisa jadi sudah, bisa jadi belum - periksa Inbox Anda sebelum mencoba lagi." |
| **H. Offline** | *(no response, connectivity known)* | **UNCERTAIN** | As G. **Manual retry only** ([D23](#d23---manual-retry-is-the-v1-default-policy-provisional)), and **check the Inbox first**. | "You appear to be offline. We couldn't confirm this save - check your Inbox when you're back online." | "Sepertinya perangkat Anda sedang luring. Kami tidak dapat mengonfirmasi bahwa tautan ini tersimpan - periksa Inbox Anda setelah kembali daring." |

**[Confirmed]** Groups D and F-H stay distinct from A-C even where the user
action looks similar, because **save certainty is load-bearing**: A-F are *known
not saved*, G-H are *uncertain*. Only G and H may mention checking the Inbox, and
only G and H may not claim the item is unsaved.

#### The envelope is not guaranteed

**[Doc]** `httpx.NewErrorHandler` delegates to `fiber.DefaultErrorHandler`
whenever the error is, or wraps, a `*fiber.Error` - checked **before** the
`AppError` branch, and `AppError.Unwrap()` returns its wrapped error. Fiber's
default handler (v3.5.0) responds with **`text/plain` and a bare message, not the
JSON envelope**. On the verified save path this is reachable only if a panic
carries a `*fiber.Error` value.

**[Confirmed] The client must treat `error.code` as possibly absent.** Group F.

*See:* ux-discovery [§7.7](./ux-discovery.md#77-save-error-mapping--verified-and-resolved-v12)
---

### D16 - Uncertain save outcomes, and their verified boundary

**[Confirmed] This is recorded as an unresolved technical risk. It is not solved
here.**

#### The boundary is now verified

**[Doc]** `CreateSavedItem` is a **single autocommit statement**
(`saved_item/service.go:154-158`). The only work after it, ``enqueueEnrichment``,
**has its failure logged and swallowed** (`service.go:160-164`), so it can never
turn a successful save into an error.

**[Confirmed] Therefore: every HTTP-received error on this route means the URL was
NOT persisted.**

| Case | Save certainty |
| --- | --- |
| ``201`` | Committed |
| Any code in the reachable table (D15 groups A-F) | **Known not saved** |
| Non-JSON error body (group F) | **Known not saved** |
| **No response at all** (groups G, H) | **UNCERTAIN** |

**[Doc]** The application sets no ``ReadTimeout`` or ``WriteTimeout``
(`cmd/api/main.go:102-109`), so the server imposes no response deadline that could
cut a committed insert off from its reply. The uncertain window comes from the
**client or network side** - connectivity loss, a mobile network handover, or the
OS suspending the app.

**[Confirmed] Do not claim that retries are guaranteed to be idempotent.**
**[Doc]** ``AGENTS.md`` decision 5 - *"Duplicate URLs are allowed. There is no unique
constraint, deduplication, or `url_hash`."* There is no idempotency key, no request
identifier, and no client-supplied handle that could detect a prior success.

**[Confirmed] The duplicate-URL decision is unchanged:** duplicates are allowed and
must not trigger a warning.

**Consequence, stated plainly. [Confirmed]** For groups G and H the queue provides
**at-least-once submission semantics**. A duplicate saved item is possible after an
uncertain outcome plus a retry. That is an accepted trade-off - but it must be
**documented as a trade-off**, not described as safe retry behaviour.

**[Confirmed] The scope of the risk is now known and small.** It does **not** apply
to any coded error, so the common failure paths - an expired session, a spent
budget, an unreachable Redis, a bad URL - are all safe to retry without duplication
risk.

**[Open] Technical questions.**
- Whether the uncertain case can be narrowed without backend changes - for example
  by treating the first attempt after a transport failure as *possibly successful*
  and prompting the user to check the Inbox rather than retrying blindly.
- Whether the row committed. **Nothing in the protocol distinguishes the two
  cases.** Only a server-side idempotency key, or an endpoint reporting "did this
  URL already save", would resolve it - neither exists and neither is requested.

*See:* ux-discovery [§7.8](./ux-discovery.md#78-uncertain-save-outcomes---the-product-answer-and-what-stays-open), risk R9

**[Confirmed] V11 is resolved for v1** as the provisional manual-retry policy: a
resubmission after an uncertain outcome is user-initiated
([D23](#d23---manual-retry-is-the-v1-default-policy-provisional)). **[Open]** Whether
automatic retry is introduced later is a future review, not a settled question.
**[Confirmed] The underlying technical risk is unchanged** - the protocol still
cannot report whether the row committed, so a duplicate remains possible after
a user-initiated retry. Manual retry bounds *uncontrolled* duplication; it does
not eliminate it.

---

### D17 — Enrichment failure never affects persistence or triggers auto-organization

**[Confirmed]** Preserving existing backend behaviour and documented terminology:

| Rule | Detail |
| --- | --- |
| Creation is the primary operation | Creating a saved item is the primary operation. |
| Initial placement | **[Doc]** A successfully created item is saved in **Unsorted** initially. |
| Enrichment is subsequent | Enrichment is a **later** metadata-extraction process, not part of the save. |
| Enrichment failure keeps the item | **[Doc]** Enrichment failure **does not remove** the saved item. |
| Enrichment failure does not requeue | Enrichment failure **does not** put the URL back into the local pending queue. |
| Enrichment failure does not organize | Enrichment failure **must not** trigger automatic organization. |
| Save success is not enrichment success | A successful save must **never** be communicated as implying enrichment has completed. |

**[Confirmed] A failed save request and a failed enrichment task are different
events.** A failed save leaves the URL in the local queue
([D13](#d13--pending-local-urls-and-backend-saved-items-are-distinct-states-of-ownership)).
A failed enrichment leaves a saved, durable, fully valid item in Unsorted and does
not touch the queue at all.

**[Doc]** Supporting: `product.md` — *"Enrichment never invalidates a Saved Item.
The URL is the user's real data."*

*See:* ux-discovery §7.1, §3 Journey A.7

---

### D18 — Minimal pending-URL UX for v1

**[Confirmed]** The v1 experience stays simple.

| Requirement | Detail |
| --- | --- |
| Inbox stays primary | The Inbox remains the destination for the Unsorted collection. |
| Unobtrusive indication | When pending URLs exist, show a visible but unobtrusive indicator that some URLs are not yet saved to the backend. |
| Understandable waiting | Users can see the pending URLs and understand why they are waiting, **when the reason is known** (categories per [D15](#d15---save-failures-are-categorized-by-verified-errorcode-values-v12-resolved)). |
| Path back to sign-in | Provide an appropriate path to sign in again when authentication is required. |
| Retry policy | **[Confirmed] Manual retry is the v1 default policy** ([D23](#d23---manual-retry-is-the-v1-default-policy-provisional), provisional). Any resubmission after a failure or an uncertain outcome is user-initiated. A never-submitted entry is still sent on sign-in - that is a first submission, not a retry. **No retry loops.** |
| Read on startup | **[Confirmed]** On app startup, or when opening the relevant screen, read the durable local queue. If it is non-empty, show the pending indicator and allow the user to view the entries. If empty, show **no** pending UI. |
| Count and list are sufficient | **[Confirmed]** A simple count plus a list of the pending URLs. No more. |
| No local metadata | **[Confirmed]** Do **not** require local metadata extraction, page previews, titles, descriptions, or thumbnails. A pending entry shows the URL it holds and nothing else. |
| No offline mode | **Not** building a complete offline mode, a separate offline navigation destination, or elaborate synchronization UX in v1. |
| Extensible | The queue design must not preclude a future offline mode exposing locally stored content through a dedicated experience. **[Confirmed] This is future extensibility, not a v1 feature commitment.** |

**[Confirmed]** The four main destinations remain **Inbox · Collections · Search ·
Profile**. The pending queue does **not** become a fifth destination — it is a
section within the Inbox, surfaced by an indicator.

*See:* ux-discovery §7.4, §4 (S15)

---

### D19 — Local pending-URL deduplication: overwrite and preserve position

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

#### Boundaries — recorded so this is not over-claimed

- **[Confirmed] This is local queue deduplication, not backend deduplication.**
  Flutter cannot detect duplicates already stored in the backend; no such
  capability exists and none is requested.
- **[Confirmed] Do not add a backend lookup or invent an endpoint for checking
  duplicates.** None exists.
- **[Confirmed] The existing product decision is unchanged:** duplicate **saved**
  URLs are allowed without a warning (`AGENTS.md` decision 5).
- **[Confirmed] This does not solve uncertain save outcomes.** A request the
  backend persisted but whose response never reached Flutter produces a duplicate
  **saved item**, not a duplicate pending entry. See
  [D16](#d16---uncertain-save-outcomes-and-their-verified-boundary).
- **[Confirmed] Different query parameters must NOT be discarded or treated as equivalent**
  merely because the URL paths match. Two URLs that differ in their query string are
  **[Confirmed] distinct entries** and are never coalesced.
- **[Open] URL equivalence and normalization are otherwise not defined.** See §3.

#### Consistency with existing queue decisions

- **[Confirmed]** Every shared URL is **queued** — nothing is silently discarded
  merely because it arrived later.
- **[Confirmed]** **Newest-URL-wins behaviour is not used.** The newer share never
  replaces the queue *ordering*; the pre-existing entry keeps its original position
  rather than being promoted.
- **[Confirmed]** Coalescing applies to **equivalent URLs only**. A different URL is
  a genuinely distinct entry and is appended normally.
- **[Confirmed]** Unaffected: the queue must still survive application termination
  ([D6](#d6--a-shared-url-is-preserved-through-authentication)) and apply the
  seven-day retention in [D7](#d7--pending-urls-seven-day-retention-queued-duplicates-silent).

*See:* ux-discovery §7.6, risks R15 and R16

---

### D20 — Flutter owns localization of user-facing UI text

| Decision | Detail |
| --- | --- |
| **[Confirmed] Ownership** | Flutter localizes all user-facing UI text. |
| **[Confirmed] V1 languages** | English (`en`) and Indonesian (`id`). |
| **[Confirmed] Approach** | Flutter's standard localization approach with **ARB translation resources and generated localization accessors**, subject to final architecture decisions. |
| **[Rec] Default selection** | **Device locale** is the proposed default language-selection behaviour. |
| **[Open] Manual selection** | Manual language selection in Profile is **not confirmed** — see §3. |

**[Doc] The backend performs no localization.** Verified: there is no
`Accept-Language` handling, no locale detection, and no message catalogue. The only
localization-adjacent item is a schema comment noting `lower(btrim(name))` is
*"not locale-stable"* — a collation comment, not translation. `golang.org/x/text`
appears in `go.mod` only as an indirect transitive dependency.

**Consequence.** There is no server-side locale contract to design around.

**[Confirmed] Do not implement localization code or initialize the Flutter project
in this phase.**

*See:* ux-discovery §12

---

### D21 — UI localization is separate from saved webpage metadata and content language

**[Confirmed]** Saved item content is **not** localized or translated by the app.

**[Doc]** `saved_items` stores `title`, `description`, `image_url` and `platform`
**exactly as the page supplied them**, in whatever language the page used. There is
**no content-language column** on `saved_items` (verified against
`internal/database/baseline/schema.sql`), and no `lang` or `locale` field anywhere
in the saved-item model.

**[Doc]** Metadata is page-derived, never translated or rewritten: *"Extracted text
is tidied of the whitespace markup introduces, and otherwise left alone. A title is
something a person reads, so it is not lowercased, shortened, or rewritten."*
(`product.md`)

**Consequence.** Switching the app's language does **not** change the language of
saved item titles or descriptions. That is correct behaviour, not a defect — the
user saved what the page said. A list may legitimately mix languages when the
user's sources do.

*See:* ux-discovery §12.3

---

### D22 — Localized error messages are selected by `error.code`

**[Confirmed]** Flutter must use the backend's structured `error.code` to select an
appropriate localized, user-readable message.

| Rule | Detail |
| --- | --- |
| **[Confirmed]** `code` selects the message | The localized string is chosen by `error.code`, in Flutter. |
| **[Confirmed]** Never display `message` | **[Doc]** `error.message` is human-facing English prose and is not a stable contract. |
| **[Confirmed]** Presentation only | **Localization changes presentation, not error semantics.** A `USER_RATE_LIMIT_EXCEEDED` means the same thing in `id` as in `en`. |
| **[Confirmed]** Codes stay authoritative | Backend error codes and their meanings remain authoritative. |
| **[Confirmed]** Verify against the real route | Mappings must be checked against `POST /saved-items` and its middleware — see V12. |
| **[Confirmed]** Do not assume reachability | A constant existing in `internal/apperror` does not mean the save route emits it. |
| **[Confirmed]** Do not invent codes | No code may be created, renamed, or inferred without source evidence. |
| **[Confirmed]** No response, no code | A transport failure has **no** `error.code` and is handled separately. Do not invent one. |

**Verified codes** reachable on the save route are listed in ux-discovery §7.7. Any
code outside that list is **unmapped** and must be treated as such until verified
(V12).

**[Confirmed] Category distinctions must survive localization.** Authentication
failures, rate limiting, service availability, transport failures, and uncertain
save outcomes are conceptually distinct and must remain distinct in every language.

#### The uncertain-outcome constraint on wording

**[Confirmed] The displayed message must not falsely claim an item is definitely
unsaved if the backend may have persisted it but the response was lost.**

This is a correctness constraint, not a style preference. A translated string such
as *"Not saved. Try again."* is **wrong** in the uncertain case: the backend may have
created the item, and the user would reasonably assume nothing happened.

**[Confirmed] The unresolved technical risk around uncertain save outcomes and retry
behaviour is preserved.** Localizing the message does not resolve it, and the
message must not imply it has.

*See:* ux-discovery §12.4,
[D16](#d16---uncertain-save-outcomes-and-their-verified-boundary)

---

### D23 - Manual retry is the v1 default policy (provisional)

**[Confirmed] Manual retry is the current policy for Flutter v1.** A user must
explicitly initiate a submission when a URL needs to be sent **again** after a
failure or an uncertain save outcome.

**[Confirmed] This policy is PROVISIONAL.** It is the v1 default, **not a permanent
prohibition** on automatic retry.

#### The four scenarios, kept distinct

The policy governs **resubmission**. Whether an attempt is a *first submission* or a
*resubmission* is the distinction that makes this coherent.

| # | Scenario | Is it a retry? | v1 behaviour |
| --- | --- | --- | --- |
| **A** | Never submitted, because the user is not authenticated | **No** — the first submission | **[Confirmed]** Submitted once authentication succeeds. This is the continuation of the original user action (share → sign in → save), governed by [D6](#d6--a-shared-url-is-preserved-through-authentication), **not** by the retry policy. |
| **B** | Rejected by the backend with a known error response (D15 groups A–F) | **Yes** | **[Confirmed]** Manual. Retained in durable storage with the reason shown. |
| **C** | Uncertain outcome — timeout, missing response, no HTTP response at all | **Yes** | **[Confirmed]** Manual. Retained, with a plain explanation that the app cannot confirm the save. |
| **D** | A retry the user explicitly initiates | — | **[Confirmed]** One URL at a time via `POST /saved-items` ([D24](#d24--manual-retry-uses-the-existing-single-item-save-endpoint)). |

**[Confirmed] Scenario A is not a retry.** The user shared a link and the app is
completing that same action after sign-in. Treating it as a retry would require the
user to perform a second, redundant action to finish something they already asked
for, and would leave post-login behaviour ambiguous. **It is recorded explicitly
here so the distinction is not left implicit.**

**[Confirmed] Scenario A must not be lost.** A URL shared before login stays in the
durable queue through authentication, is never discarded, and is submitted
automatically once a session exists — see [D7](#d7--pending-urls-seven-day-retention-queued-duplicates-silent)
and [D13](#d13--pending-local-urls-and-backend-saved-items-are-distinct-states-of-ownership).

#### Rules that hold under the current policy

| Rule | Detail |
| --- | --- |
| **[Confirmed]** Manual default | Scenarios B and C are resubmitted **only** by explicit user action. |
| **[Confirmed]** Keep the entry | A failed or uncertain entry stays in durable local storage. It is never discarded on failure. |
| **[Confirmed]** No automatic repeat | If a manual retry is itself uncertain, it does not repeat automatically; it waits again. |
| **[Confirmed]** Explain clearly | The UI must state plainly that the app cannot confirm whether the URL was saved. |
| **[Confirmed]** Do not conflate | An explicit HTTP rejection and an uncertain transport outcome stay **distinct**, in code and in copy. |
| **[Confirmed]** No retry loops | No tight timers, no unbounded retry loops. |

#### This policy will be revisited

**[Confirmed] The retry policy will be reviewed again once Flutter development has
made sufficient progress**, and the actual UX, queue behaviour, and user
interaction patterns become concrete.

**[Confirmed] Automatic retry remains a possible future improvement, not part of
the v1 scope.** At that review, the questions to decide are whether automatic
retries should be introduced, **under which conditions**, and **with what
safeguards**.

**[Confirmed] No timeline and no evaluation criteria are set here.** They are
deliberately left undefined until the review, so this record does not prejudge it.

**[Doc] The underlying technical constraint is unchanged regardless of the outcome
of that review:** the backend has no idempotency key or equivalent (`AGENTS.md`
decision 5 — *"Duplicate URLs are allowed. There is no unique constraint,
deduplication, or `url_hash`"*). Any future automatic-retry policy must work within
that constraint.

#### Decision history

**[Doc]** An earlier revision of this record stated a flat prohibition on automatic
retry and treated it as permanent. That framing is superseded by the current
provisional policy. The retained substance is unchanged: the entry is kept, the
reason is explained, rejections stay distinct from uncertainty, and no retry loops
run.

*See:* ux-discovery §7.5, §7.8, §7.11

---

### D24 — Manual retry uses the existing single-item save endpoint

**[Confirmed]** For v1, a user-initiated retry submits **one URL at a time** through
the endpoint that already exists: `POST /saved-items`.

| Rule | Detail |
| --- | --- |
| **[Confirmed]** Existing endpoint | `POST /saved-items`, one URL per request. No new route. |
| **[Confirmed]** No bulk endpoint | A bulk saved-item endpoint is **not** added or required. |
| **[Confirmed]** No backend change | The backend is **not** modified to support this UX. |
| **[Confirmed]** The queue manages the rest | Ordering, individual entries, and per-entry state remain a client concern. |
| **[Confirmed]** Remove on confirmation | An entry is removed when the client receives a response confirming success. |
| **[Confirmed]** Uncertain behaviour preserved | If success cannot be confirmed, the entry returns to `uncertain` per [D23](#d23---manual-retry-is-the-v1-default-policy-provisional). |
| **[Confirmed]** Do not over-claim | This approach does **not** eliminate duplicate saved items. It bounds *uncontrolled* duplication. |

**[Confirmed] A future bulk-save endpoint may be reconsidered** if actual usage or
infrastructure capacity justifies it. **[Confirmed] This is not a v1 commitment.**

*See:* ux-discovery §7.11

---

### D25 — Inbox input: a URL field with Paste and Save URL

**[Confirmed] The Inbox screen carries a visible URL input.** This resolves the
placement question previously recorded as **Q5**.

| Element | Rule |
| --- | --- |
| **URL input** | **[Confirmed]** A URL text field is **visible directly on the Inbox screen** — not hidden behind an action, sheet, or menu. |
| **Paste** | **[Confirmed]** A separate **Paste** button reads a URL from the clipboard and places it into the input. |
| **Save URL** | **[Confirmed]** A separate **Save URL** button submits **the URL currently in the input**. |
| **Pasting is not saving** | **[Confirmed]** **Pasting alone does not save the URL.** It only fills the field. |
| **Inspect and edit** | **[Confirmed]** The user can inspect or edit the URL before saving it. |

*Rationale.* This input is the in-app fallback and the recovery path for the OS
share sheet ([D5](#d5--share-sheet-primary-in-app-paste-fallback)). Making it
visible on the Inbox keeps intake first-class rather than two actions away.
Separating **Paste** from **Save URL** keeps two distinct decisions distinct:
putting a URL into a field is not the same act as committing it to the queue. The
edit-before-save step is what lets a user correct a bad share before it becomes a
pending entry.

*Scope limits — this decision fixes the interaction shape only.*

- **[Confirmed] It does not decide** clipboard behaviour beyond placing a URL in the
  field, validation timing, success timing, or error handling. None of those is
  decided here.
- **[Confirmed] The input is a route into the same durable pending queue** used by
  the share sheet ([D13](#d13--pending-local-urls-and-backend-saved-items-are-distinct-states-of-ownership)).
  It is not a second storage path, and it does not bypass the queue.
- **[Open] When, and whether, the input validates a URL before submission is not
  decided.** See **Q13**. [§2.9](#29-recommendation--client-mirrors-server-url-validation)
  remains a **[Rec]**.

*Relationship to [D6](#d6--a-shared-url-is-preserved-through-authentication).*
Unchanged. A URL placed in this input and not yet submitted is **not** a saved item,
and is covered by the same durable queue, the same seven-day retention
([D7](#d7--pending-urls-seven-day-retention-queued-duplicates-silent)), and the same
rules on never being silently discarded.

*See:* ux-discovery §3 Journey A.1, §7.13

---

### D26 — Inbox is a recent-saved history across collections

**[Confirmed] The Inbox is not the `unsorted` collection.** It is a separate
destination with its own responsibility.

| Rule | Detail |
| --- | --- |
| **What the Inbox shows** | **[Confirmed]** A bounded history of **recently saved items across collections**. |
| **What it is for** | **[Confirmed]** Helping the user **verify that a URL was saved** and **understand which collection the item currently belongs to**. |
| **What it is not** | **[Confirmed]** Not an alias for the `unsorted` collection. **[Confirmed]** Not a "browse everything" view — it is *recent*-saved history. |
| **Collections** | **[Confirmed]** Unchanged. Collections remains the **collection browser**: it lists collections, and a collection is opened to browse the items inside it. |

*Consequence — this supersedes [D3](#d3--inbox-and-unsorted-collection-contents-share-one-screen)
and narrows [D9](#d9--no-endpoint-lists-every-saved-item-at-once).* The Inbox and
the Unsorted collection no longer share a screen because they no longer show the
same thing. **[Confirmed] `system_key === "unsorted"` continues to govern
identification of Unsorted everywhere it still appears as a collection** —
Collections list, file sheet, delete dialog — per
[D2](#d2--unsorted-is-resolved-by-system_key-never-by-name).

#### What a save confirmation may and may not say

**[Confirmed] A save confirmation confirms only that the saved item was created.**
It must not imply any of the following:

- **[Confirmed]** that **enrichment has completed**;
- **[Confirmed]** that **metadata is guaranteed to exist**;
- **[Confirmed]** that **automatic organization has completed**;
- **[Confirmed]** that the item **will definitely be moved to a particular collection**.

#### Asynchronous background processing

**[Confirmed]** Enrichment and automatic organization are asynchronous. Work may
still be queued, may be in progress, or may fail.

**[Confirmed] The UX must not depend on a per-item notification announcing
automatic organization.** **[Doc]** The backend exposes no event for that
transition, so there is nothing reliable to announce — announcing one would be a
claim the client cannot support.

**[Confirmed] Refreshing the Inbox shows the latest data available from the
backend.** It must not imply that a refresh guarantees worker completion, and it
must not be presented as proving *why* an item changed location.

**[Open]** A general, non-per-item explanation of automatic organization may be
considered separately. **[Confirmed] No specific notification, surface, or wording
is decided here**, and none may be invented.

#### Backend dependency — implemented

**[Doc] The backend capability this decision asked for now exists.** `GET /saved-items`
is implemented: a cursor-paginated history of recent saved items across every
collection the user owns, each item carrying its current collection and its
enrichment status. **The product requirement below is unchanged and still governs what
the screen is for.**

**[Confirmed]** The product-level requirement, and nothing beyond it:

> The Inbox needs a **bounded list of recently saved items across collections**,
> including **each item's current collection** and **its relevant enrichment
> status**, based on the **latest data available from the backend**.

**[Confirmed] This decision still specifies no endpoint path, request schema, response
schema, pagination contract, ordering, or backend behaviour.** The concrete contract
was designed in the backend repository, which remains authoritative for backend
behavior; it is recorded here only so the Flutter client does not invent a different
one. See [§5.1](#51-recently-saved-items-across-collections-inbox).

*Prototype note.* **[Confirmed] Mock data in a prototype is a design technique and is
not evidence that an endpoint exists** — which is now the reason the Flutter Inbox
still labels its sample content as mock while the real listing goes unused.

*See:* ux-discovery §1.5, §2, §4 (S7), §6

---

## 2. Provisional recommendations

**Awaiting approval.** These are proposals produced by the discovery analysis.
They are not decisions and must not be treated as such.

### 2.1 Recommendation — enrichment presentation

| State | List row | Detail |
| --- | --- | --- |
| `pending` | URL + domain, muted "Reading page…", **retry available** | Same + inline retry |
| `completed` with data | Image, title, domain, description excerpt | Full preview |
| `completed` without data | URL + domain. **No warning styling.** | Same, no error framing |
| `failed` | URL + domain, muted "Couldn't read this page", retry prominent | Retry prominent |

*Supporting facts.* **[Doc]** Missing metadata is *"not a defect in the Saved Item
and not a defect in enrichment"*; a `failed` item keeps its URL, domain, collection
and searchability; `last_enriched_at` is `null` until an enrichment has **succeeded
at least once**.

*Also recommended.* **[Verify]** `OutboundFetchTimeout = 10 * time.Second`
(`internal/security/outbound_fetch.go:51`) means retry blocks for up to ten seconds.
This is **the only request in the app whose completion the server performs on
demand**, so it is the only place a blocking spinner is fully justified. Copy
should acknowledge the wait.

*See:* ux-discovery §3, Journey E

---

### 2.2 Recommendation — save confirmation

State **"Saved"** and show the URL. Nothing more.

**[Doc]** `AGENTS.md`: *"Saving answers 'did it work', not 'what does it look like'."*
The create response reports only `id`, `url`, `collection_id`, `enrichment_status` —
no `domain`, `title`, `platform`, `description`, or `image_url`.

*Supporting consequence.* The response contains everything needed to render an
honest optimistic row, so **optimistic insertion into the Inbox is fully
supported** — this is the one place optimistic UI is unambiguously correct.

*Explicitly not recommended.* No shimmer or skeleton implying data is arriving. The
server never signals that enrichment has begun, so an indefinite spinner is a
claim the client cannot support.

*See:* ux-discovery §3, Journey A

---

### 2.3 Recommendation — deleting an empty collection does not ask the question

**[Verified from source]** `saved_items_action` is required even when the
collection holds zero items (`internal/collection/request.go:72-80`,
`service.go:603`).

**Recommendation.** When the collection is known to be empty, the dialog says
*"This collection is empty"* and offers only **Delete**. The client still sends
`{"saved_items_action": "delete", "target_collection_id": null}` internally, because
for an empty collection the two options are indistinguishable in effect.

*Why this is honest rather than a workaround.* **[Doc]** The backend cannot default
the field *"because the two actions have opposite consequences and one of them
discards saved items."* When there is nothing to dispose of, `"delete"` is a true
statement about zero rows and is the only value that is accurate. The request
satisfies the documented contract; the user is not asked a meaningless question.

*Emptiness is knowable in exactly two places.* **[Doc]** `GET /collections` carries
no item count, so it cannot be the mechanism. Emptiness is known from (a)
`collection_empty: true` returned by a just-performed item delete, and (b) an empty
`saved_items` array from `GET /collections/{id}/saved-items`. Both are available at
the point of use.

*For a non-empty collection.* Show the real choice, with equal visual weight on
both options, and **never preselect** — **[Doc]** *"The choice is never made on the
caller's behalf."*

*See:* ux-discovery §3, Journey D

---

### 2.4 Recommendation — advisory collection flags never trigger an action

**[Doc]** `DELETE /saved-items/{id}` returns `collection_empty` and
`collection_deletable`, described as *"information for the caller to act on or
ignore; it is not a promise about what happens next."*

**Recommendation.** Show at most a dismissible secondary offer — *"This was the last
item in Wishlist — delete the collection?"* — and never act on the flags
automatically.

*Rationale.* **[Doc]** *"An empty collection is a perfectly good state, so quietly
removing one would take an action nobody asked for."*

*See:* ux-discovery §3, Journey C

---

### 2.5 Recommendation — search framing and truncation disclosure

**[Doc]** Search is capped at 20 items (50 max) and 5 collections, with no paging,
no autocomplete, and no suggestion. The caps are not surfaced anywhere in the API.

**Recommendation.**
- **Zero results is a success.** It must never render as an error.
- **Zero-result copy must not assert the item was never saved.** **[Doc]** A
  `pending` item has no title, and *"a title is never invented from the URL or the
  site name."* An item can exist and be unsearchable by the query used.
- **Disclose truncation:** *"Showing the 20 closest matches."*
- **Frame search as "find the thing", not "browse everything".** Inbox and
  Collections carry browsing.

*See:* ux-discovery §3, Journey B–B.7

---

### 2.6 Recommendation — reconciliation rather than announcement for automatic organization

> **[Confirmed] Direction settled by
> [D26](#d26--inbox-is-a-recent-saved-history-across-collections).** The UX does
> not depend on a per-item notification announcing automatic organization, because
> no backend event reports that transition. **[Confirmed]** The specific
> presentation recommendations below remain **[Rec]** pending approval.

**[Doc]** A background step may move an item out of Unsorted into a platform-named
collection, **only if it is still in Unsorted** (decision 13a). The client is not
notified.

**Recommendation.**
- Never animate or dismiss an item that changes collection between refreshes.
- Never claim *"moved to YouTube"* — the transition is unobservable.
- Reconcile plainly: the item is still listed, and its current collection is shown.
- Never frame a system-created collection as user-created.

**[Open]** `product.md` says organization is *"automatic, not invisible"*. A
general, non-per-item explanation of automatic organization may be considered
separately. **[Confirmed] No specific notification, surface, or wording is decided
here**, and none may be invented — see
[D26](#d26--inbox-is-a-recent-saved-history-across-collections).

*See:* ux-discovery §9 (R1)

---

### 2.7 Recommendation — Collections screen shows no item counts and no create action

**[Doc]** `GET /collections` **now returns a per-collection count** —
`saved_items_count`, exact 0–99 and capped at 99, with `saved_items_count_overflow`
true above 99 — and there is still no `total`. The count describes the whole
collection on every page. There is also **no `POST /collections`** — a collection is
created only as a side effect of filing an item into it by name.

> **Superseded premise, recommendation unchanged.** This recommendation was written
> when the listing carried no count and deriving one would have cost a request per
> collection on an unbounded list. That reasoning is obsolete: the count now arrives
> in the same response. **[Rec] The recommendation below still stands** and has not
> been re-approved or withdrawn — whether to display the count is now a product
> decision, not a technical constraint.

**Recommendation.**
- Show no counts. *(Original rationale, now obsolete — see the note above.)*
- Show no "New collection" affordance. The screen is a pure browser. A create
  control would have to be faked by filing an item, which would be misleading.
- Accept "Collections with 0 items" as a normal, permanent state.

*See:* ux-discovery §4

---

### 2.8 Recommendation — file sheet shows existing collections first

**[Doc]** `PUT /saved-items/{id}/collection` takes a **name**, not an ID, and
creates the collection if absent. There is no "list options for this item"
endpoint, so the sheet depends on the already-loaded collection list.

**Recommendation.**
- Existing collections listed first; create-by-name input visually secondary.
- Label the two paths distinctly: **"Move to Wishlist"** versus **"Create
  Wishlist"**.
- Show the resolved destination before confirming.
- Case-insensitive matching is favourable — `"wishlist"` finds `"Wishlist"`.

*See:* ux-discovery §3, Journey C, risk R6

---

### 2.9 Recommendation — client mirrors server URL validation

**[Verify]** `internal/saved_item/request.go` declares
`validate:"required,url,max=2048"`, and `service.go:324-349` (`deriveDomain`)
rejects an empty hostname with a second code, `INVALID_URL`.

**Recommendation.** Validate client-side to the same rule so the common failure
never round-trips, and distinguish the two error codes in copy.

*See:* ux-discovery §3, Journey A

---

### 2.10 Recommendation — single-flight refresh is a correctness requirement

**[Doc]** *"A concurrent double-refresh logs the user out"* (`auth-sessions.md`,
accepted trade-offs). The server cannot distinguish a client retry from an
attacker's replay, and tolerating both would leave reuse detection unenforceable.

**Recommendation.** Exactly one refresh in flight, app-wide. This is a correctness
requirement, not an optimization — the user-visible symptom of getting it wrong is
random unexplained logout, reported as corruption.

**[Doc]** Additional copy-relevant facts: revocation does not invalidate an
already-issued access token (up to 15 minutes); refresh **fails closed** during a
Redis outage, locking out users whose access token has expired for up to 15 minutes.

*See:* ux-discovery §3, Journey F, risk R4

---

### 2.11 Recommendation — offline, 429, and 503 are three distinct states

**[Doc]** A limiter that cannot answer refuses — a Redis outage yields 503, and
*"a 503 must carry no `Retry-After` at all — there is no known recovery time and a
fabricated one would be a guess presented as a fact"* (decision 25).

| State | Cause | `error.code` | Backend state | Treatment |
| --- | --- | --- | --- | --- |
| **Offline** | No route to the server | **None exists** | **Unknown** | "You're offline." Retain typed input. |
| **429** | Budget spent | `*_RATE_LIMIT_EXCEEDED` | Nothing written | Countdown from `Retry-After`. Disable the action. |
| **503** | Reachable, refusing | `*_RATE_LIMIT_UNAVAILABLE` etc. | **Nothing written** | "Temporarily unavailable." **No countdown.** |

*Useful property.* **[Doc]** On 503, *"a refused save writes no row and enqueues
nothing, a refused enrichment performs no fetch and writes no enrichment state."*
Both are therefore safe to retry verbatim.

**Offline is the uncertain-outcome case and must not be described as safe.**
**[Confirmed]** See [D16](#d16---uncertain-save-outcomes-and-their-verified-boundary):
a transport failure after the server committed is possible, retries are **not**
guaranteed idempotent, and the queue therefore offers **at-least-once** semantics.
This was previously written here as *"at-least-once save is an accepted
consequence"*; that framing understated the risk, because it did not say that
idempotency is unavailable from the client.

*See:* ux-discovery §5.1, [D15](#d15---save-failures-are-categorized-by-verified-errorcode-values-v12-resolved),
[D16](#d16---uncertain-save-outcomes-and-their-verified-boundary)

---

### 2.12 Recommendation — broken preview images are routine

**[Doc]** *"Preview images are references to images provided by the original source.
Discovery does not own or guarantee the availability of those external images."*

**Recommendation.** Neutral placeholder, reserved layout space, no error state, no
retry affordance, no layout shift, no effect on whether the row is tappable.

*See:* ux-discovery §3, Journey E, risk R10

---

## 3. Open product questions

Undecided. Each materially affects product or architecture.

| # | Question | Why it matters |
| --- | --- | --- |
| Q1 | **How is the pending-URL expiry notification presented, and what keep/retry action accompanies it?** | Silent discard is **[Confirmed] ruled out** by [D14](#d14--user-is-notified-before-an-expired-pending-url-is-removed). The specific form remains open. **Recommendation:** one-time notification with an optional keep action. |
| Q2 | **What is the pending-URL queue capacity, and how is overflow shown?** | A hard drop silently reintroduces data loss. **Recommendation:** generous soft cap with visible overflow. The number is a product call. |
| Q3 | **On a permanent validation failure (`VALIDATION_ERROR`, `INVALID_URL`), discard the entry or retain it for correction?** | **[Confirmed]** This is *not* the queue's primary failure scenario ([D15](#d15---save-failures-are-categorized-by-verified-errorcode-values-v12-resolved)), but it still needs an answer. Discard loses a share the user made deliberately; retain needs a UI for editing a queue entry. |
| Q4 | **Should automatic retry be introduced after Flutter development progresses?** | **RESOLVED for v1** as the provisional manual-retry policy ([D23](#d23---manual-retry-is-the-v1-default-policy-provisional)). **Reopened as a future review**, not settled: whether to introduce it, under which conditions, and with what safeguards is undecided. |
| Q5 | ~~**Where does the paste field live** — always visible on the Inbox, or behind an action?~~ | **RESOLVED.** **[Confirmed]** The URL input is **visible directly on the Inbox screen**, with separate **Paste** and **Save URL** actions, and the URL can be inspected or edited before saving. **[Confirmed] Pasting alone does not save.** See [D25](#d25--inbox-input-a-url-field-with-paste-and-save-url). The remaining sub-question — validation timing — is preserved separately as **Q13**. |
| Q6 | **Should Google sign-in lead the welcome screen?** | **[Doc]** Social finalization mints a session; manual finalization does not and needs a separate login. Google reaches a session in far fewer steps, which bears directly on risk R3. |
| Q7 | **Send `X-Platform` / `X-Device-Name` now, despite deferring device management?** | **[Doc]** These headers populate `GET /auth/sessions`. Sending them now costs nothing and avoids a retrofit; not sending them is fine if deferral is genuine. |
| Q8 | **Should search result ordering be surfaced to users?** | **[Doc]** Results are best-match first with recency only as a tie-break. Users may expect newest-first and be surprised. |
| Q9 | ~~**Should automatic organization be acknowledged in the UI at all?**~~ | **RESOLVED for v1.** **[Confirmed]** The UX must **not** depend on a per-item notification announcing automatic organization; the client cannot announce a specific event because the backend exposes none. **[Confirmed]** Refreshing the Inbox shows the latest data available and must not imply it guarantees worker completion or proves why an item changed collection. **[Open]** A general, non-per-item explanation of automatic organization may be considered separately — no specific notification, surface, or wording is decided. See [D26](#d26--inbox-is-a-recent-saved-history-across-collections). |
| Q10 | **What makes two pending URLs "equivalent" for [D19](#d19--local-pending-url-deduplication-overwrite-and-preserve-position)?** | **[Open]** Not defined, and **no backend rule exists to reuse**: `domain` derivation is not a URL-identity rule; canonical URLs are reported but **not persisted and not applied**; `saved_items` has no `url_hash`. **[Confirmed]** Do not implement normalization until decided. An aggressive rule would merge genuinely different pages; a strict rule merely fails to coalesce. |
| Q11 | **Is the user told anything when a share coalesces?** | **[Confirmed]** No warning or confirmation dialog — the refresh is silent by decision. Whether a subtle acknowledgement is worth adding is undecided. **Recommendation:** stay silent; the queue should feel stable, not eventful. |
| Q12 | **Is there a manual language override in Profile?** | Device locale is the **proposed** default per [D20](#d20--flutter-owns-localization-of-user-facing-ui-text). **[Open]** A user-facing language switch is not confirmed, and v1 scope is `en` + `id`. |
| Q13 | **When, and whether, does the Inbox URL input validate before submission?** | Created by [D25](#d25--inbox-input-a-url-field-with-paste-and-save-url): with a visible editable field and an explicit **Save URL** action, *when* validation happens determines what the user sees before and after submitting. **[Rec]** Mirror the server's rule client-side ([§2.9](#29-recommendation--client-mirrors-server-url-validation)). **[Open]** If validation is client-side, whether an invalid URL blocks submission or is submitted and answered by the server is undecided; the server's codes for this are [D15](#d15---save-failures-are-categorized-by-verified-errorcode-values-v12-resolved) group D (`VALIDATION_ERROR`, `INVALID_URL`). **[Open]** Related and also undecided: because the field is editable, the submitted value may differ from what was pasted or shared, and how that interacts with the [D19](#d19--local-pending-url-deduplication-overwrite-and-preserve-position) coalescing rule is not specified. |

---

## 4. Technical verification required

Feasibility to confirm before implementation. **[Not decisions.]**

| # | Item | Notes |
| --- | --- | --- |
| V1 | **iOS share intake** | **[Doc]** The extension is a separate process: *"the containing app might not be running while the device user interacts with the extension"* (Flutter's iOS app-extensions documentation). Requires an App Group container and a deep link; the extension cannot reliably launch the app directly. Confirm cold-start delivery is read reliably. |
| V2 | **iOS extension memory** | **[Doc]** Flutter advises only modifying an extension UI if it supports ~100 MB, and that a physical device may run out of memory. A URL share needs no UI — write and redirect is the low-risk shape. |
| V3 | **iOS review risk** | **[Verify]** Extensions must follow the App Extension Programming Guide; a custom launch mechanism is a rejection risk. |
| V4 | **Android intent delivery** | Confirm `ACTION_SEND` cold path (launching intent) and warm path (`onNewIntent` with `singleTask`/`singleTop`), including after process death. |
| V5 | **Secure storage for the seven-day queue** | Confirm availability and cost of Keychain / Keystore-backed storage on both platforms. |
| V6 | **`Retry-After` on every reachable 429** | Confirm presence and exact semantics per rate-limit namespace. |
| V7 | **URL redaction in previews** | A shared URL can carry credentials in its query string. This also affects the saved-item detail screen, not just pending URLs. |
| V8 | **Third-party `image_url` behaviour** | Hotlink blocking, auth requirements, typical aspect ratios. |
| V9 | **Store privacy declarations** | Accuracy requirements for on-device URL persistence, and for account deletion. |
| V10 | **macOS/Xcode availability** | **[Doc]** Flutter requires the iOS simulator to test an extension in debug mode. iOS is the schedule risk, not Android. |
| V11 | ~~Uncertain save outcomes~~ | **RESOLVED for v1** as the provisional manual-retry policy ([D23](#d23---manual-retry-is-the-v1-default-policy-provisional)). **[Open]** The *protocol* limitation is unchanged - nothing reports whether the row committed, so a user-initiated retry may still produce a duplicate. |
| V12 | ~~Exhaustive `error.code` mapping for the save route~~ | **RESOLVED.** The reachable codes, the codes verified **absent** from this route, the save-certainty rule, and the English/Indonesian messages are recorded in [D15](#d15---save-failures-are-categorized-by-verified-errorcode-values-v12-resolved). | The generic constants in `internal/apperror/error.go` (`UNAUTHORIZED`, `FORBIDDEN`, `CONFLICT`, `TOO_MANY_REQUESTS`, `SERVICE_UNAVAILABLE`) are **defined** but their emission on `POST /saved-items` is not fully confirmed. **[Confirmed] Do not invent codes** — treat any unlisted code as unmapped until verified. See [D15](#d15---save-failures-are-categorized-by-verified-errorcode-values-v12-resolved). |
| V13 | **PIN email budgets** | `documentation/pin-email-budgets.md` was **not read** during this discovery. It governs PIN issuance and resend limits — directly relevant to the resend countdown UI in S3/S6. **Read it before building those screens.** |
| V14 | **URL equivalence comparison rule** | Exact string match after trimming, or scheme/host case normalization, trailing-slash and fragment handling? **[Confirmed]** No backend rule exists to reuse. Default to the strictest sensible comparison until decided; do not implement normalization. See [D19](#d19--local-pending-url-deduplication-overwrite-and-preserve-position). |
| V15 | **Backend localization surface** | Verified absent: no `Accept-Language` handling, no locale detection, no message catalogue. Re-confirm before relying on it, since it establishes that Flutter owns all UI copy per [D20](#d20--flutter-owns-localization-of-user-facing-ui-text). |

---

## 5. Decisions requiring backend changes

**[Confirmed] Not requested now.** Recorded so the gap is visible and not
rediscovered as a surprise. None of these is a blocker for v1.

### 5.1 Recently saved items across collections (Inbox)

> **[Confirmed] This entry records a product requirement that the backend has since
> met.** The Inbox's cross-collection listing was previously recorded here as
> *deferred*, and was still absent when this requirement was approved.

**[Doc] The backend gap is closed.** `AGENTS.md` decision 19g removed the standalone
listing deliberately: *"Two ways to ask the same question would be two answers to keep
in step, and the standalone one was also the poorer answer."* **[Doc] That position has
since been reversed in the backend**, which now implements `GET /saved-items` as the
Inbox's data source. The reasoning quoted above is retained as history.

**[Confirmed] The product requires it.** See
[D26](#d26--inbox-is-a-recent-saved-history-across-collections). The requirement is
stated **only at product level**:

> The Inbox needs a **bounded list of recently saved items across collections**,
> including **each item's current collection** and **its relevant enrichment
> status**, based on the **latest data available from the backend**.

**[Confirmed] No endpoint path, request schema, response schema, pagination
contract, ordering, or backend behaviour is specified by this document.** Those were
designed in the backend repository, which remains authoritative for the contract; the
Flutter client must read them there rather than infer them from here.

**[Confirmed] What stays deferred.** A full "browse every saved item" view is still
not in v1. The requirement above is for a **bounded recent-saved history**, which is
not the same thing. A user who has forgotten both the collection and any
searchable token still has no way to reach an old item; the UI must not pretend
otherwise — see [§2.5](#25-recommendation--search-framing-and-truncation-disclosure).

**[Confirmed] Not an aggregate view.** The pending-URL queue remains a separate
concern and is **not** a substitute for this — see
[D13](#d13--pending-local-urls-and-backend-saved-items-are-distinct-states-of-ownership).

---

### 5.2 Account deletion

**[Doc]** No endpoint exists. Classified in [D11](#d11--account-deletion-is-an-unresolved-release-consideration)
as a **release blocker** rather than a UX gap. Requires a backend feature and a
design pass.

---

### 5.3 Other known gaps

Recorded for completeness. None is a v1 blocker.

| Gap | **[Doc]** status | v1 handling |
| --- | --- | --- |
| **Collection rename / merge** | No endpoint. Near-duplicate collections from accidental creation are permanent. | Mitigate in UI ([§2.8](#28-recommendation--file-sheet-shows-existing-collections-first)); cannot be fixed properly without backend support. |
| **Collection item counts** | **[Doc]** `GET /collections` now carries `saved_items_count` (0–99, capped) and `saved_items_count_overflow`. | Still omit counts until the product re-approves (§2.7); availability is not approval. |
| **Search paging / filters** | Caps at 20 items / 5 collections, unpaged, no filters. | Disclose truncation ([§2.5](#25-recommendation--search-framing-and-truncation-disclosure)). |
| **Saved-item editing** | No `PATCH`/`PUT`. No rename, notes, tags, or favourites. | Not designed. |
| **Read/unread, archive, trash** | Delete is a hard delete, irreversible. | Not designed. **[Open]** No undo exists for any delete in v1. |
| **Bulk operations** | None on saved items. Batch move exists only inside collection deletion (decision 19d). | Not designed. |
| **Bulk enrichment** | Explicitly one item at a time (`product.md`). | Retry is per item ([D8](#d8--enrichment-states-are-represented-accurately-with-retry-on-pending-and-failed)). |
| **Reminder / return loop** | Development-order step 4; unimplemented. | "Come back later" has no product surface in v1. |
| **Notification of organization** | No endpoint reports it. | Reconcile rather than announce ([§2.6](#26-recommendation--reconciliation-rather-than-announcement-for-automatic-organization)). **[Confirmed]** The UX must not depend on such a notification ([D26](#d26--inbox-is-a-recent-saved-history-across-collections)). |
| **Idempotent saves** | No idempotency key, request identifier, or unique `url` constraint. | **At-least-once semantics only.** Documented as an unresolved risk, not solved ([D16](#d16---uncertain-save-outcomes-and-their-verified-boundary), V11). |
| **Bulk saved-item save** | No bulk endpoint exists; v1 retries one URL at a time via `POST /saved-items` ([D24](#d24--manual-retry-uses-the-existing-single-item-save-endpoint)). | **Not needed in v1.** May be reconsidered on usage or capacity evidence. |
| **Recovery of expired pending URLs** | Client-side only; the server has never seen them. | Do not promise recovery the app cannot deliver. |

---

## 6. Not decided in this phase

Explicitly out of scope. Listed so their absence is understood rather than assumed.

- UI design system, visual language, theming, typography, component library
- Wireframes, screen layouts, navigation library
- State management, API client, caching, persistence mechanism
- Offline-first strategy beyond the pending-share queue
- Analytics, telemetry, crash reporting
- Localization **mechanism and language scope** are decided ([D20](#d20--flutter-owns-localization-of-user-facing-ui-text),
  [D22](#d22--localized-error-messages-are-selected-by-errorcode)) - but the
  ARB/tooling setup, the accessor wiring, and any runtime locale store remain
  unselected. Accessibility strategy is also undecided.
- Release process, CI/CD, store listing
- Backend hosting or environment configuration

**[Confirmed] Do not begin visual design or application implementation.** The
recommended next step is toward UI direction and wireframes.
