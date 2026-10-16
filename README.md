# Stash-it — Flutter client

The Flutter mobile client for Stash-it: a place to save things found on the internet
and come back to them later.

**This repository is not a monorepo.** The Go backend is maintained separately (a
sibling checkout, conventionally `../stash-it-backend`) and is authoritative for every
API contract.

## Current state

An application shell with a provisional visual direction, plus one presentation
prototype. **No product feature is implemented.**

- Four destinations — Inbox, Collections, Search, Profile — behind a
  `StatefulShellRoute`.
- A provisional **Paper & Ink** visual baseline. Provisional: the visual language is
  not designed, so these values are expected to change.
- One reusable saved-item row, demonstrated on the Inbox over **explicitly labelled
  mock data**. No Inbox listing API exists yet, so there is no API client, DTO or
  repository.
- No authentication, networking, localization, or persistence.

[`PROGRESS.md`](./PROGRESS.md) is the current handoff document: what exists, what was
verified, what is blocked, and what comes next.

## Requirements

Flutter **3.47.7** / Dart **3.13.5** (`environment: sdk: ^3.12.2`). Android and iOS
targets (**D12**).

## Development commands

```bash
flutter pub get                  # fetch dependencies

dart format <changed dart files> # formatting
flutter analyze                  # static analysis
flutter test                     # unit and widget tests

dart run build_runner build      # code generation, after changing an annotation
```

Running the app is the user's job. Nothing here launches an emulator or a device;
see the execution policy in [`AGENTS.md`](./AGENTS.md) before running anything.

## Where things live

```
lib/
├── main.dart              Thin entry point
├── app/                   Composition root: app widget, router, theme
└── features/<feature>/    One slice per destination
test/                      Mirrors lib/
docs/                      Product discovery and wireframes
```

`core/`, `l10n/` and `shared/` appear only when a real file first needs them — see
`AGENTS.md` §2 for the dependency rules that keep them from becoming junk drawers.

## Documentation

| Document | What it is |
| --- | --- |
| [`AGENTS.md`](./AGENTS.md) | Working rules for coding agents. **Read this first.** |
| [`PROGRESS.md`](./PROGRESS.md) | Current milestone, verification status, next step. |
| [`docs/product-discovery/decisions.md`](./docs/product-discovery/decisions.md) | **Binding** product decisions. |
| [`docs/product-discovery/ux-discovery.md`](./docs/product-discovery/ux-discovery.md) | Reasoning, API mapping, interaction-state matrix. |
| [`docs/wireframes/`](./docs/wireframes/) | UX baseline. Open `index.html` in a browser. |

## Working rules that are easy to get wrong

- **Never invent a backend contract.** Endpoints, fields, pagination and ordering come
  from the backend repository.
- **Branch on `error.code`, never on `error.message`.** Backend messages are never shown
  to users (D22).
- **Mock data must always be labelled as mock**, in code and on screen.
- **Do not run the app or touch the emulator** without an explicit instruction.