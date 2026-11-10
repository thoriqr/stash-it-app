/// The note text to attach to a manual save, or null when none is meaningful.
///
/// A whitespace-only draft is treated as absent. Meaningful text is returned
/// exactly as entered, including line breaks and surrounding whitespace, so the
/// request keeps the user's content rather than rewriting it.
String? inboxNoteDraftText(String? draft) {
  final value = draft?.trim();
  if (value == null || value.isEmpty) return null;
  return draft;
}
