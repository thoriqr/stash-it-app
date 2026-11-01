# Stash-it Flutter — Project Progress

> Last updated: 2026-10-31  
> Scope: Flutter application (`stash-it-app`).

## Current Status

The app has its core saved-link experience in place, including authentication, collections, search, profile and account settings, Google Sign-In, and Android link sharing for device-local saves.

The latest completed milestone is **Localization Phase 0**: users can choose English, Bahasa Indonesia, or the device's supported system language.

**Current focus:** continue app-wide localization, beginning with shared navigation, common actions, and feedback messages.

## Implemented

### Saved links

- Save links to an account, view their details, and open the original links.
- View link metadata and enrichment status, and refresh metadata.
- Move and delete saved links.
- Preview saved-link images, including pending and unavailable states.

### Collections

- Browse collections and view their saved links.
- Search collections and saved links.
- Move saved links between collections.
- Delete collections using the supported server options.

### Authentication and account

- Email registration, PIN verification, and registration recovery.
- Google Sign-In, account linking, and social registration.
- Password reset and recovery.
- Profile display-name updates and password management.
- Persistent theme and language preferences.

### Save links on this device

- Share links to the app on Android without signing in.
- Keep shared links on the device for seven days.
- Consolidate exact duplicate links.
- Explicitly submit locally saved links to an account.
- Distinguish confirmed saves from outcomes that could not be confirmed.

### Localization

- English and Bahasa Indonesia are supported.
- The initial language follows the device language when supported; otherwise, English is used.
- Users can choose System default, English, or Bahasa Indonesia in Settings.
- An explicit language choice is retained on the device and takes precedence over the device language.
- The selected language is restored before the app is shown.

## In Progress and Next Steps

- [ ] Complete Localization Phase 1: shared navigation, common actions, tooltips, session-expiry messages, and general read errors.
- [ ] Complete Localization Phase 2: shared feedback messages, retry guidance, saved-time labels, profile dates and identity labels, local URL summaries, and share-result messages.
- [ ] Localize feature-specific screens and remaining app-owned messages.
- [ ] Review Indonesian translations with a native speaker.
- [ ] Verify the app on a physical Android device.

## Known Limitations

- Search results are limited by the server.
- Physical-device verification has not yet been completed.
- Android link sharing still needs verification in cases such as the app being closed, the user being signed out, or the device being offline.
- If a local-link submission is interrupted, its outcome may be uncertain. Retrying an operation with an uncertain outcome can create a duplicate.
- A link rejected by the server may remain in the device-local list until it expires or the list is otherwise cleared.
- Some operations started under a previous account may finish after the account changes. User-specific data must remain isolated across account changes.

## Project Constraints

- Preserve the existing project structure and separation of responsibilities.
- Keep user-facing messages under app control; do not display raw server error messages.
- Do not report an operation as successful unless its result is confirmed.
- Keep uncertain outcomes distinct from operations known to have been rejected.
- Do not introduce automatic retries or background synchronization unless explicitly planned.
- Preserve pagination behaviour and account-data isolation.
- Device-local saved links must remain available when the user signs out.
- Keep credentials and authentication continuations in secure storage. Ordinary preferences and the local link list do not require secure storage.
- Do not expand an app-only task into backend changes unless explicitly requested.
- Do not modify `AGENTS.md`, decision records, or agent configuration unless explicitly authorized.

## Updating This Document

Keep this file focused on the project's current state, completed work, known limitations, and next steps.

- Describe completed capabilities and user-visible outcomes, not implementation steps.
- Update verification status when new checks are completed; do not imply that older results cover later changes.
- Mark work complete only after implementation and relevant verification are finished.
- Do not resolve open product decisions by assumption.
