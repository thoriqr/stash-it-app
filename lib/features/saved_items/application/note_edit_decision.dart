/// What the note editor should do when Save is tapped.
enum NoteSaveDecision {
  /// Nothing changed, or there was no note and nothing was entered.
  none,

  /// Send the entered text with `PUT /saved-items/{id}/note`.
  save,

  /// The existing note was cleared; confirm before
  /// `DELETE /saved-items/{id}/note`.
  delete,
}

/// Whether the editor should offer its dedicated delete shortcut.
///
/// Only the persisted note captured when the editor opened counts. Text the
/// user has typed into a new-note editor is deliberately not considered.
bool noteDeleteAvailable(String? persistedNote) =>
    persistedNote != null && persistedNote.trim().isNotEmpty;

/// The text the editor restores after a cancelled deletion.
///
/// The editor keeps the snapshot it captured when it opened, so restoring is
/// immediate and does not require a refetch. The value is returned exactly,
/// including multiline content and literal characters.
String restoredNoteText(String? persistedNote) => persistedNote ?? '';

/// Decides between leaving the note alone, saving it, and deleting it.
///
/// Emptiness is detected with `trim`, because the backend rejects a
/// whitespace-only note and a note with no readable content is effectively
/// removed. The text itself is compared exactly: the client never trims or
/// rewrites valid user input, so a change to its whitespace is a real change.
NoteSaveDecision noteSaveDecision({
  required String? initialNote,
  required String enteredText,
}) {
  final hasExistingNote = noteDeleteAvailable(initialNote);

  if (enteredText.trim().isEmpty) {
    return hasExistingNote ? NoteSaveDecision.delete : NoteSaveDecision.none;
  }

  if (hasExistingNote && enteredText == initialNote) {
    return NoteSaveDecision.none;
  }

  return NoteSaveDecision.save;
}
