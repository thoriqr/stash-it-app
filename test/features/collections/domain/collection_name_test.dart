import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/collections/domain/collection_name.dart';

/// The backend's trimmed, 100-rune shape rule and the comparison used by the
/// move sheet.
void main() {
  group('collectionNameProblem', () {
    test('rejects blank and whitespace-only names', () {
      expect(collectionNameProblem(''), CollectionNameProblem.blank);
      expect(collectionNameProblem('   '), CollectionNameProblem.blank);
      expect(collectionNameProblem('\t\n'), CollectionNameProblem.blank);
    });

    test('accepts 100 runes after trimming', () {
      final name = '${'a' * 100}  ';

      expect(collectionNameProblem(name), isNull);
    });

    test('rejects 101 runes after trimming', () {
      expect(
        collectionNameProblem(' ${'a' * 101} '),
        CollectionNameProblem.tooLong,
      );
    });

    test('counts code points, not UTF-16 code units', () {
      // A surrogate pair is two code units in Dart but one rune for Go's
      // utf8.RuneCountInString. Using String.length would reject a valid name.
      final accepted = '😀' * 100;
      final rejected = '😀' * 101;

      expect(
        accepted.length,
        200,
        reason: 'the test would be vacuous otherwise',
      );
      expect(collectionNameProblem(accepted), isNull);
      expect(collectionNameProblem(rejected), CollectionNameProblem.tooLong);
    });
  });

  group('normalization', () {
    test('trims but preserves display casing', () {
      expect(normalizedCollectionName('  Reading List  '), 'Reading List');
      expect(normalizedCollectionName('WISHlist'), 'WISHlist');
    });
  });

  group('sameCollectionName', () {
    test('ignores case and surrounding whitespace', () {
      expect(sameCollectionName('  Wishlist ', 'wishLIST'), isTrue);
    });

    test('does not collapse different names', () {
      expect(sameCollectionName('Wishlist', 'Reading List'), isFalse);
    });
  });
}
