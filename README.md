# Stash-it — Flutter App

The Flutter application for **Stash-it**, a mobile app for saving and organizing links and other content found on the internet.

## Tech Stack

- Flutter and Dart
- Riverpod for state management
- Dio and Retrofit for API communication
- Freezed for immutable models and serialization
- GoRouter for navigation

## Requirements

- Flutter SDK compatible with the version specified in `pubspec.yaml`
- Dart SDK compatible with the version specified in `pubspec.yaml`

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Development Commands

```bash
# Format Dart files
dart format .

# Static analysis
flutter analyze

# Run tests
flutter test

# Generate code
dart run build_runner build
```

Run code generation after modifying annotations or source files that require generated output.

## Project Structure

```text
lib/
├── app/          # Application configuration, routing and theme
├── core/         # Core application infrastructure
├── features/     # Feature-specific implementation
└── shared/       # Reusable components and utilities

test/             # Application tests
docs/             # Supporting project references
```

## Backend

The Go backend is maintained in a separate repository. Backend API contracts and behavior are defined by the backend implementation.

## Project Guidance

- `AGENTS.md` — Instructions and conventions for coding agents.
- `PROGRESS.md` — Current project status and development handoff.
