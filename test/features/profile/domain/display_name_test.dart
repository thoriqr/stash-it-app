import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/profile/domain/display_name.dart';

void main() {
  group('display name bounds', () {
    test('accepts exactly two runes', () {
      expect(displayNameProblem('ab'), isNull);
    });

    test('rejects a single rune', () {
      expect(displayNameProblem('a'), DisplayNameProblem.tooShort);
    });

    test('accepts exactly one hundred runes', () {
      expect(displayNameProblem('a' * 100), isNull);
    });

    test('rejects one hundred and one runes', () {
      expect(displayNameProblem('a' * 101), DisplayNameProblem.tooLong);
    });

    test('counts runes rather than UTF-16 code units', () {
      // An emoji outside the BMP is one Go code point and two Dart code units.
      // Counting `String.length` would reject a name the server accepts.
      expect('😀'.length, 2);
      expect(displayNameProblem('😀😀'), isNull);
    });

    test('does not treat surrounding whitespace as trimming', () {
      // The backend stores the value verbatim; a whitespace-only name is two
      // runes and is therefore within the width bound. Approving it here is
      // deliberate — the backend owns the meaning of the value, and this client
      // must not be the only place that silently changes it.
      expect(displayNameProblem('  '), isNull);
    });
  });
}
