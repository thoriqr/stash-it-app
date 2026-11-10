import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/inbox/presentation/inbox_note_draft.dart';

/// The manual-intake draft rule: absent when blank, otherwise exactly as typed.
void main() {
  group('inboxNoteDraftText', () {
    test('null and whitespace-only drafts are absent', () {
      expect(inboxNoteDraftText(null), isNull);
      expect(inboxNoteDraftText(''), isNull);
      expect(inboxNoteDraftText('  \n\t '), isNull);
    });

    test('multiline content is preserved exactly', () {
      const note =
          'Compare this with other options.\nCheck the specifications.';
      expect(inboxNoteDraftText(note), note);
    });

    test('meaningful text keeps surrounding whitespace', () {
      const note = '  Keep this text exactly.  \n';
      expect(inboxNoteDraftText(note), note);
    });
  });
}
