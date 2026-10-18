# Stash-it — design system v1

Browser mockups of the Stash-it screens, and the specification behind them.

**Nothing here changes the Flutter app.** These are presentation artifacts: no widget,
theme, routing, networking or product behaviour is implemented, and no file in this directory
is imported by `lib/`. Every item, collection, result and account shown here is fabricated
mock data, and the screens say so on screen.

---

## How to view

**Double-click `index.html`.** No server, no build step, no network request.

The three typefaces are self-hosted in `assets/fonts/`, so the pages render offline. They are
responsive too, so a screen can be opened on a phone.

---

## Files

| File | What it is |
| --- | --- |
| `index.html` | The hub: every screen, the specification, and the open questions |
| `inbox.html` | **Inbox** — the URL intake (field, Paste, Save URL) above the recent saved items, plus the five intake states. Light and dark |
| `collections.html` | **Collections** — the collection browser as a grid of inventory slots. Light and dark |
| `search.html` | **Search** — initial, results and zero-results. Light and dark |
| `profile.html` | **Profile** — the account facts and the two supported actions. Light and dark |
| `pending-urls.html` | **Pending URLs** — a section inside the Inbox, with its five documented states. Light and dark |
| `auth.html` | **Authentication** — welcome, email sign-in, invalid credentials, emailed PIN. Light and dark |
| `components.html` | Every component in both themes |
| `design-system.md` | **The specification** — tokens, typography, spacing, icons, component states and the light/dark mapping |
| `direction-b.html` | The approved **light** baseline (B · Inventory), at full size |
| `b-dark.html` | The approved **dark** baseline (B-Dark), at full size |

### Assets

| File | What it holds |
| --- | --- |
| `assets/tokens.css` | **The token source of truth.** Primitives plus every semantic colour, in a light scope and a dark scope |
| `assets/components.css` | Shared components: buttons, inputs, inventory slot, collection cell, chips, states, feedback, tab bar |
| `assets/screens.css` | Layout that belongs to one screen only: the intake, collections, search, profile, auth, pending |
| `assets/base.css` | Review chrome: page shell, phone bezel, comparison grid, tables. Not product UI |
| `assets/fonts.css` | The three `@font-face` declarations, pointing at local files |
| `assets/fonts/*.woff2` | Silkscreen, Inter and JetBrains Mono — latin subsets, self-hosted |

**Where the tokens are:** `assets/tokens.css`. Every colour used anywhere in the prototypes
comes from there; no screen file contains a literal colour. The theme scope
(`.theme-light` / `.theme-dark`) sits on the phone element, so the review chrome around a
screen stays neutral.

---

## The approved direction

- **B · Inventory** is the light baseline; **B-Dark** is the dark baseline.
- **Dusty Sage is the brand accent**: `#4C6B5F` in light, `#74A88C` in dark. One hue at two
  lightnesses, so the identity does not change when the theme does.
- Cool white-grey surfaces in light mode — no cream, beige, sepia or reading-mode warmth.
- Layered charcoal in dark mode, never pure black.
- The accent carries identity and progress only — never decoration.
- Squared inventory slots, restrained radii (nothing above 4 px on a control), deliberate
  borders.
- Crisp sans-serif for all UI and saved-item content; the pixel-inspired face is kept to the
  wordmark, screen titles and small labels.
- A single coherent outline icon family for the four destinations.

---

## Reading order

1. `index.html` — the hub and the open questions.
2. `inbox.html` — the screen that changed the most: the intake area.
3. `components.html` — the parts the screens are built from.
4. `design-system.md` — the written specification, to hand to the Flutter implementation.

---

## Provenance

- Product behaviour: `docs/product-discovery/decisions.md`, `docs/product-discovery/ux-discovery.md`.
- Information architecture and states: `docs/wireframes/`.
- Mock data: the Flutter prototype's `lib/features/inbox/presentation/inbox_mock_data.dart`,
  plus the collection names the wireframes already use.
