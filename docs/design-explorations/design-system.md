# Stash-it — design system v1

The approved visual direction, specified for implementation. This is a **specification**, not
an implementation: no Flutter widget, theme or dependency exists for any of it yet.

**Baseline:** B · Inventory (light) and B-Dark (dark). Every screen in this directory is built
on those two with one shared token set.

**Accent:** **Dusty Sage** — `#4C6B5F` in light, `#74A88C` in dark. One hue at two lightnesses,
and the only brand colour in the system.

---

## 1. Where things live

| Thing | Path |
| --- | --- |
| The prototypes | `docs/design-explorations/*.html` |
| **The token source of truth** | `docs/design-explorations/assets/tokens.css` |
| Shared components | `docs/design-explorations/assets/components.css` |
| Screen layouts | `docs/design-explorations/assets/screens.css` |
| Review chrome (not product UI) | `docs/design-explorations/assets/base.css` |
| Typeface declarations | `docs/design-explorations/assets/fonts.css` |

In the prototypes, **every** colour is a CSS custom property declared in `tokens.css`. No
screen file contains a literal colour, and the light and dark values live in the two theme
scopes of that one file.

**Themes.** `:root` (and `.theme-light`) carries the light values; `.theme-dark` overrides
them. The scope is applied to the phone element, so the review chrome around a screen stays
neutral.

**Fonts.** The three typefaces are self-hosted and are used by the HTML prototypes only.
Nothing is installed in the Flutter app, and `pubspec.yaml` has no font entries:

| Family | File (prototype asset) | Weights | Role |
| --- | --- | --- | --- |
| Silkscreen | `assets/fonts/silkscreen-400.woff2`, `assets/fonts/silkscreen-700.woff2` | 400, 700 | display only |
| Inter | `assets/fonts/inter-var.woff2` | 100–900 (variable) | all UI and saved-item copy |
| JetBrains Mono | `assets/fonts/jbmono-var.woff2` | 100–800 (variable) | domains, URLs, times, labels |

If the Flutter implementation uses different files, the **family names and the roles below
still hold** — only the asset paths change. Do not assume a font package exists.

---

## 2. Colour

Light and dark, side by side, for every semantic token. Contrast ratios are against
`--surface` unless noted.

| Token | Light | Dark | Used for |
| --- | --- | --- | --- |
| `--canvas` | `#F5F7F9` | `#14171A` | app background |
| `--surface` | `#FFFFFF` | `#1B1F23` | slots, header, tab bar, cards |
| `--surface-raised` | `#FFFFFF` | `#21262B` | sheets, dialogs |
| `--surface-inset` | `#EEF1F4` | `#1E2328` | recessed bands: the intake area |
| `--surface-sunken` | `#E4E9ED` | `#121518` | wells: thumbnail placeholders |
| `--text-primary` | `#222A34` (13.3:1) | `#DAE0E5` (12.5:1) | titles, headings |
| `--text-secondary` | `#4A545F` (7.7:1) | `#A3ACB5` (7.2:1) | descriptions, body copy |
| `--text-tertiary` | `#5F6975` (5.6:1) | `#848E99` (5.0:1) | domains, times, labels, hints |
| `--text-disabled` | `#A6AFBA` (2.4:1) | `#5D6771` (2.3:1) | disabled controls **only** |
| `--text-inverse` | `#FFFFFF` | `#14171A` | text on a filled accent |
| `--border` | `#DBE1E7` | `#2C333A` | default 1 px border |
| `--border-strong` | `#C3CCD6` | `#3B434B` | deliberate / emphasised border |
| `--border-subtle` | `#E9EDF1` | `#22272D` | hairline separators |
| `--accent` | `#4C6B5F` | `#74A88C` | identity and progress, never decoration |
| `--accent-strong` | `#3F5B50` | `#86BA9C` | accent pressed / text on light |
| `--accent-soft` | `#EBF1EE` | `#1B2620` | the accent's only filled surface |
| `--accent-border` | `#BDCFC6` | `#3A5548` | border of an accent chip |
| `--accent-contrast` | `#FFFFFF` | `#10140F` | text on a filled accent |
| `--selected` | `#4C6B5F` | `#74A88C` | selected navigation item |
| `--selected-soft` | `#EBF1EE` | `#1B2620` | selected-state surface |
| `--selected-mark` | `#4C6B5F` | `#74A88C` | the selected marker on the tab bar |
| `--success` | `#1D6E5E` | `#56BFA4` | a save that was confirmed |
| `--success-soft` | `#E6F1EE` | `#17241F` | success surface |
| `--success-border` | `#BBD8D0` | `#2E4C42` | success border |
| `--warning` | `#8A6A2F` | `#D9AE5F` | budget spent, expiry, uncertain |
| `--warning-soft` | `#F6F0E2` | `#262115` | warning surface |
| `--warning-border` | `#E0D2B4` | `#4A3F24` | warning border |
| `--danger` | `#A8463A` | `#E08C7A` | a failure that is known |
| `--danger-soft` | `#F6E9E6` | `#2B1F1C` | danger surface |
| `--danger-border` | `#E4C4BE` | `#4E322C` | danger border |
| `--disabled-bg` | `#EFF2F5` | `#1B1F23` | disabled control fill |
| `--disabled-border` | `#E2E7EC` | `#262C33` | disabled control border |
| `--focus-ring` | `rgba(76,107,95,.22)` | `rgba(116,168,140,.24)` | focus halo |
| `--slot-shadow` | `0 1px 2px rgba(16,20,24,.05)` | `inset 0 1px 0 rgba(255,255,255,.035)` | slot lift |
| `--slot-hatch-1` / `--slot-hatch-2` | `#EEF1F4` / `#E4E9ED` | `#1B2024` / `#272D33` | preview-image placeholder |

**Rules that come with the palette**

1. The accent carries **identity and progress only** — the collection chip, the pending marker,
   the selected destination, the retry action, the primary button. It is never decoration.
2. Only **failure** uses `--danger`. A missing preview image, a title-less item and a
   `completed` enrichment with no metadata are all normal states and are never coloured as
   problems.
3. **Dark is layered charcoal, never black.** `--canvas` is `#14171A`; surfaces step up from
   it by one or two values, and separation is carried by the border plus one step of surface
   value, never by a glow.
4. **Light is cool white-grey.** No cream, beige, sepia or reading-mode warmth anywhere.
5. Every text step used for copy meets **WCAG AA (4.5:1)**. `--text-disabled` is the only
   step below it and is reserved for disabled controls.
6. **One brand hue, two lightnesses.** The accent is the same 157° hue in both themes. Never
   substitute the light value for the dark one, and never introduce a second accent hue to
   fill a gap — an unfilled gap is better than a second identity.

> **The accent is settled: Dusty Sage.** The light theme is `#4C6B5F`, the dark theme is
> `#74A88C`. That is **one hue (157°) at two lightnesses**, not two hues — so the app no
> longer changes identity when the theme changes. There is no second accent anywhere in the
> system.
>
> The lightness split is what contrast requires, not a stylistic preference:
>
> - The original candidate `#648779` is **3.97:1** on white. It cannot carry the 10.5 px chip
>   text, the 9.5 px tab label or the 11.5 px state line — all of them are small text and
>   need 4.5:1.
> - `#4C6B5F` keeps that hue at 36 % lightness: **5.87:1** on white, and white on it
>   **5.87:1** for the primary button label. On its own chip tint `#EBF1EE` it holds
>   **5.13:1**, so the chip keeps its margin after the fill changes beneath it.
> - The same value cannot serve charcoal, so dark is the same hue lightened: `#74A88C`,
>   **6.10:1** on `#1B1F23`, with a near-black label on it at **6.84:1**.

---

## 3. Typography

| Role | Family | Size / line-height / weight | Notes |
| --- | --- | --- | --- |
| Wordmark | Silkscreen | 10 / 1 / 700, tracking `.20em`, uppercase | the only place the brand is set |
| Screen title | Silkscreen | 15 / 1 / 700, tracking `.02em`, uppercase | app bar |
| Section label (eyebrow) | Silkscreen | 9.5 / 1 / 700, tracking `.14em`, uppercase | section headers, small labels |
| Screen heading | Inter | 19 / 1.1 / 600, tracking `-.02em` | auth and profile headings |
| Item title | Inter | 15 / 1.3 / 600, tracking `-.012em` | 2-line clamp |
| Body | Inter | 13 / 1.5 / 400 | descriptions, 2-line clamp |
| Label | Inter | 10.5 / 1 / 600 | field labels, chips |
| Meta | Inter | 11.5 / 1.35 / 500 | state lines, hints |
| Mono | JetBrains Mono | 11 / 1.3 / 500 | domains, URLs |
| Mono small | JetBrains Mono | 10 / 1.25 / 500 | saved-time labels |
| Micro | JetBrains Mono | 9 / 1.2 / 500 | mock markers, timers, notices |

**The pixel face is restrained on purpose.** It carries the wordmark, the screen title, section
labels and the step counter — nothing else. Saved-item titles, descriptions, domains and
metadata never use it.

**The mono face is for machine text**: domains, URLs, timestamps, timers and the mock-data
markers. It is not used for prose.

---

## 4. Spacing, radii, borders

| Scale | Values |
| --- | --- |
| Spacing | 4 · 8 · 12 · 16 · 20 · 24 · 32 px |
| Radii | 0 · 2 · 3 · 4 px — **nothing above 4 px on a control** |
| Border width | 1 px default · 2 px for focus and error |
| Slot corner | 3 px |
| Input corner | 2 px |
| Chip corner | 2 px |

Screen padding is 16 px horizontally, 20 px for the profile and search groups. Inventory slots
use 11–12 px of internal padding with a 9 px gap between slots; the list canvas is
`--canvas` and the slots are `--surface`.

---

## 5. Icons

One family, one treatment.

| Property | Value |
| --- | --- |
| Viewbox | 16 × 16 units |
| Rendered size | 18 px (`--icon-size`) |
| Stroke | 1.5 px (`--icon-stroke`), mitred joins, butt caps |
| Search handle | 2 px, because the lens ring carries less visual weight |
| Style | outline only, no fills except the occluding card in the Collections glyph |
| Selected state | accent colour **plus** an 18 × 3 px accent bar on the tab bar's top edge |
| Unselected state | `--text-tertiary` |

| Destination | Glyph |
| --- | --- |
| Inbox | an open tray with a notched front wall |
| Collections | two stacked cards; the front card is filled with the surface colour so it occludes the one behind |
| Search | a small ring lens with a heavier square-ended handle |
| Profile | a squircle head over an open shoulder curve |

The square head and the mitred geometry are the only pixel traces; there is no pixel-art icon
in the navigation.

---

## 6. Components

### 6.1 Buttons

| Variant | Fill | Border | Text | Height |
| --- | --- | --- | --- | --- |
| Primary | `--accent` | `--accent` | `--accent-contrast` | 34 px |
| Secondary | `--surface` | `--border-strong` | `--text-primary` | 34 px |
| Quiet | transparent | transparent | `--accent` | 34 px |
| Danger | `--danger-soft` | `--danger-border` | `--danger` | 34 px |
| Disabled | `--disabled-bg` | `--disabled-border` | `--text-disabled` | 34 px |
| Small | as above | | | 24 px |
| Block | full width | | | 34 px |

A **primary** button is the only filled button on a screen. The Inbox intake therefore has
exactly one: **Save URL**. **Paste** is a secondary outline button, so pasting can never be
mistaken for saving.

### 6.2 Inputs

| State | Treatment |
| --- | --- |
| Default | `--surface` fill, 1 px `--border`, 2 px radius, 40 px height |
| Focused | 2 px `--accent` border **and** a 3 px `--focus-ring` halo |
| Filled | same as default; the value stays editable |
| Invalid | 2 px `--danger` border, with a `--danger` message under the field |
| Disabled | `--disabled-bg` fill, `--disabled-border` border, `--text-disabled` text |

A visible label (`--size-label`, `--text-secondary`) sits above every field. The URL field
uses the mono face; name and password fields use the UI face.

### 6.3 Inventory slot — one saved item

A 1 px bordered card on the canvas: 56 × 56 px thumbnail, title (2-line clamp) with the saved
time in the top-right corner, the domain in mono, a 2-line description, then a metadata line
carrying the collection chip, the enrichment state and — when the state allows it — a quiet
**Retry**.

**Thumbnail treatment.** A preview image is a 45° hatch in `--slot-hatch-1/2`; **no** preview
image is an empty dashed well with a dashed square in the middle. A missing preview is a
normal state: no error colour, no retry, and the space is always reserved so rows never
shift.

**Title fallback.** When the page supplied no title, the URL is shown instead, in
`--text-tertiary` at regular weight. It is never coloured as a warning.

**Enrichment states.** `pending` is a hollow accent pip and the words &ldquo;Reading
page&hellip;&rdquo;. `failed` is a filled danger pip and the words &ldquo;Couldn&rsquo;t read
this page&rdquo;, with a **Retry** action. `completed` says nothing at all when there is
metadata; when there is none, it says &ldquo;No details on this page&rdquo; in neutral copy.

### 6.4 Collection cell

A 2-up grid of cells: a 28 px outlined chest glyph, the name (2-line clamp), and — for the
system collection only — a pixel `system` tag and an accent border. Unsorted is marked by
what the server says it is, never by its display name.

### 6.5 Feedback

| Situation | Treatment |
| --- | --- |
| Neutral information | `--surface-inset` + `--border`, a neutral mark |
| Success (a save was confirmed) | `--success-soft` + `--success-border`, a `--success` mark |
| Warning (budget spent, expiry) | `--warning-soft` + `--warning-border` |
| Failure (known) | `--danger-soft` + `--danger-border`, a `--danger` mark |
| **Uncertain** (no answer) | `--warning-soft` + `--warning-border`, a **hollow** mark |

The uncertain treatment is deliberately distinct: it is the only state that may not claim the
item is unsaved, so it must not look like a confirmed failure.

**Copy rules carried by the components**

- A save confirmation says the item was **created**. It never implies that enrichment
  finished, that metadata exists, that organization finished, or that the item will move.
- A 429 shows the countdown the server sent. A 503, an offline device and an unknown outcome
  never show a fabricated countdown.
- Copy is selected from a typed error code, never from a server message.

---

## 7. Translating this into Flutter

This section is guidance, not a decision: the Flutter implementation has not started.

- The natural home for these tokens is a `ThemeExtension` beside `AppTokens` in
  `lib/app/theme/`, with a light and a dark instance. `AppTokens` already uses that pattern.
- A `ThemeData` in Material 3 has no equivalent of `--surface-inset`, `--border-subtle` or the
  slot hatch, so those need to live in the extension rather than in the `ColorScheme`.
- The pixel face is one family with two weights. Bundling the `.woff2` files above as
  Flutter assets is a small, self-contained addition; it needs a `pubspec.yaml` entry, which
  does not exist yet.
- Nothing in this document requires a new package.

---

## 8. Unresolved

Carried from the product decisions; the mockups do not answer them.

| # | Question | Where it is visible |
| --- | --- | --- |
| Q13 | when the URL input validates, and what the clipboard does when it holds nothing | Inbox intake |
| Q6 | whether Google leads the welcome screen | Authentication |
| Q8 | whether search result ordering is surfaced to users | Search |
| Q12 | whether a manual language override belongs in Profile | Profile |
| Q1–Q3 | expiry notification form, queue capacity, discard-or-retain | Pending URLs |
| D5 / §2.7 | whether collections show item counts, and whether the count question is reopened | Collections |
| D11 | account deletion has no endpoint, so no flow is drawn | Profile |
| D10 | device and session management are deferred | Profile |

---

## 9. Provenance

- Product behaviour: `docs/product-discovery/decisions.md` and
  `docs/product-discovery/ux-discovery.md`.
- Information architecture and states: `docs/wireframes/`.
- Mock data: the Flutter prototype's
  `lib/features/inbox/presentation/inbox_mock_data.dart`, plus the collection names already
  used by the wireframes.
- Visual baseline: B · Inventory and B-Dark, in this directory.
- Accent: Dusty Sage, decided after comparing three candidates on the same screens. The
  baseline's steel blue is not an active accent anywhere.
