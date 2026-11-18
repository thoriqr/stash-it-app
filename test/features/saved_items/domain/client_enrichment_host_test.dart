import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/client_enrichment_host.dart';

void main() {
  group('isClientEnrichmentHost', () {
    test('recognizes the allowlisted Instagram hosts', () {
      expect(isClientEnrichmentHost('https://instagram.com/reel/abc/'), isTrue);
      expect(
        isClientEnrichmentHost('https://www.instagram.com/reel/abc/'),
        isTrue,
      );
    });

    test('matches the host without case or surrounding whitespace', () {
      expect(
        isClientEnrichmentHost('  HTTPS://WWW.INSTAGRAM.COM/reel/abc/  '),
        isTrue,
      );
    });

    test('does not match other hosts or subdomains', () {
      expect(
        isClientEnrichmentHost('https://m.instagram.com/reel/abc/'),
        isFalse,
      );
      expect(
        isClientEnrichmentHost('https://example.com/instagram.com'),
        isFalse,
      );
      expect(isClientEnrichmentHost('not a url'), isFalse);
      expect(isClientEnrichmentHost(''), isFalse);
    });
  });
}
