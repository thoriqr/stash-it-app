# AGENTS.md

Instructions for coding agents working in this repository.

## Before changing code

- Inspect the relevant implementation and follow established project patterns.
- If the requested behaviour is ambiguous or conflicts with the existing
  implementation, clarify it before making assumptions.
- For API changes, verify the contract against the separate Go backend repository.
  Do not infer endpoints, payloads, response fields, or server guarantees.

## Project conventions

- This is a Flutter client using Dart, Riverpod 3, Dio/Retrofit, Freezed, and
  `go_router`. Check the existing implementation before introducing another
  pattern or dependency.
- Follow the existing feature-first structure. Avoid speculative folders,
  unnecessary abstractions, and unrelated refactoring.
- Keep presentation code independent of API clients; use the existing provider
  and repository boundaries.
- Do not use legacy Riverpod 2 provider APIs.
- Preserve the SDK and dependency versions in `pubspec.yaml` and
  `pubspec.lock`. Do not upgrade packages unless the task requires it.
- Use the existing localization setup for app-owned UI text. Keep localization
  out of domain and data code.
- Prefer clear names and straightforward code. Add short comments only when they
  explain non-obvious reasoning or an important invariant.
- Keep code comments scoped to this repository and its responsibilities.
  Explain client-side behaviour, constraints, and API contracts only when they
  are relevant to understanding the current code.
  Do not reference backend implementation details such as internal function
  names, source file paths, line numbers, database operations, or backend
  documentation. The client may depend on the backend's API contract, but
  comments should describe only the observable contract and its implications
  for this client.
  Avoid references to unrelated repositories, external project structure, or
  historical implementation context that is not needed to understand the code.

## Code generation

When changing Riverpod, Retrofit, Freezed, or JSON serialization annotations,
run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run generation before analysis. Never edit generated `.g.dart` or `.freezed.dart`
files by hand.

## Verification

Run the checks relevant to the change:

```bash
dart format <changed dart files>
flutter analyze
flutter test
```

- Do not claim a check passed unless you ran it.
- Tests must not make real network calls; use the existing fakes and provider
  overrides.
- Add or update tests for changed behaviour.

## Emulator

Do not run the app or manipulate the user's emulator unless explicitly asked.
In particular, do not run `flutter run`, `flutter install`, or adb commands that
launch, stop, restart, reinstall, or interact with the running app. If authorised,
perform only the requested operation and preserve the current session.

## Workflow

- Keep changes within the requested scope. Report unrelated findings instead of
  fixing them opportunistically.
- After every implementation task, update `PROGRESS.md` according to the
  instructions in that file.
- Do not modify `AGENTS.md` or agent configuration unless explicitly authorised.
- Do not stage or commit changes, or rewrite Git history.
- In the final report, state what changed and which checks were actually run.
