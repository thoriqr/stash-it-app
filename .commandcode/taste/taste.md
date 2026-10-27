# Taste

## Architecture
- Prefers extending existing architecture over adding new pieces: reuse existing screens, routes, providers, storage keys, DTOs and implementations, introducing no new dependency and no duplicate flow ("Do not create a new screen, route, provider, storage key, or dependency", "do not introduce speculative error codes or duplicate DTOs"); generated files are regenerated via the existing build_runner workflow and never hand-edited. Confidence: 0.7

## Workflow
- Prefers analysis and a written implementation plan first; implementation starts only after explicit approval ("stop after presenting the plan and wait for approval before implementation"). Confidence: 0.75
- Wants verification limited to static and test commands (`format`, `analyze`, test suite) and their genuinely observed results — never launching the app, touching the emulator/device, or committing. Confidence: 0.75
- Wants actual behavior — of this codebase or of another component (e.g. a sibling backend) — established from its current source code with exact file/method/line references, not from docs, generated specs, endpoint names, or intended design; findings the code proves must be explicitly separated from assumptions, recommendations, and things the code alone cannot establish. Confidence: 0.65
