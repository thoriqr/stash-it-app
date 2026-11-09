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
  final hasExistingNote = initialNote != null && initialNote.trim().isNotEmpty;

  if (enteredText.trim().isEmpty) {
    return hasExistingNote ? NoteSaveDecision.delete : NoteSaveDecision.none;
  }

  if (hasExistingNote && enteredText == initialNote) {
    return NoteSaveDecision.none;
  }

  return NoteSaveDecision.save;
}
