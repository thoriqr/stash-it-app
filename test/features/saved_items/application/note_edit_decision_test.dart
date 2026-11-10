import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/application/note_edit_decision.dart';

/// The Save rules for the one note editor.
///
/// Emptiness is decided with `trim`; the submitted text is compared exactly so
/// the client never rewrites valid user input.
void main() {
  group('noteDeleteAvailable', () {
    test('only a persisted, non-blank note enables the shortcut', () {
      expect(noteDeleteAvailable(null), isFalse);
      expect(noteDeleteAvailable(''), isFalse);
      expect(noteDeleteAvailable('  \n '), isFalse);
      expect(noteDeleteAvailable('A saved note'), isTrue);
    });
  });

  group('restoredNoteText', () {
    test('restores the snapshot exactly, including line breaks', () {
      const saved = 'First line\nSecond line  \nThird line';
      expect(restoredNoteText(saved), saved);
    });

    test('a missing note restores an empty editor', () {
      expect(restoredNoteText(null), '');
    });
  });

  group('noteSaveDecision', () {
    test('no existing note and no text is a no-op', () {
      expect(
        noteSaveDecision(initialNote: null, enteredText: ''),
        NoteSaveDecision.none,
      );
      expect(
        noteSaveDecision(initialNote: null, enteredText: '   \n'),
        NoteSaveDecision.none,
      );
    });

    test('no existing note and valid text saves', () {
      expect(
        noteSaveDecision(initialNote: null, enteredText: 'A note'),
        NoteSaveDecision.save,
      );
    });

    test('a changed non-empty note saves', () {
      expect(
        noteSaveDecision(initialNote: 'Old', enteredText: 'New'),
        NoteSaveDecision.save,
      );
    });

    test('unchanged text is not written again', () {
      expect(
        noteSaveDecision(initialNote: 'Same', enteredText: 'Same'),
        NoteSaveDecision.none,
      );
    });

    test('clearing an existing note asks to delete', () {
      expect(
        noteSaveDecision(initialNote: 'Old', enteredText: ''),
        NoteSaveDecision.delete,
      );
      expect(
        noteSaveDecision(initialNote: 'Old', enteredText: '  \n '),
        NoteSaveDecision.delete,
      );
    });

    test('whitespace changes are real changes and are preserved', () {
      // The client does not trim or rewrite valid text, so adding a trailing
      // line break is a save rather than an unchanged-content no-op.
      expect(
        noteSaveDecision(initialNote: 'Same', enteredText: 'Same\n'),
        NoteSaveDecision.save,
      );
    });

    test('a whitespace-only stored value is treated as no note', () {
      expect(
        noteSaveDecision(initialNote: '   ', enteredText: ''),
        NoteSaveDecision.none,
      );
    });
  });
}
