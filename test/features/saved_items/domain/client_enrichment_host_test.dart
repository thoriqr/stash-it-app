import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/client_enrichment_host.dart';

void main() {
  group('clientEnrichmentPlatformForUrl', () {
    test('recognizes the allowlisted Instagram hosts', () {
      expect(
        clientEnrichmentPlatformForUrl('https://instagram.com/reel/abc/'),
        'Instagram',
      );
      expect(
        clientEnrichmentPlatformForUrl('https://www.instagram.com/reel/abc/'),
        'Instagram',
      );
    });

    test('matches the host without case or surrounding whitespace', () {
      expect(
        clientEnrichmentPlatformForUrl(
          '  HTTPS://WWW.INSTAGRAM.COM/reel/abc/  ',
        ),
        'Instagram',
      );
    });

    test('does not match other hosts or subdomains', () {
      expect(
        clientEnrichmentPlatformForUrl('https://m.instagram.com/reel/abc/'),
        isNull,
      );
      expect(
        clientEnrichmentPlatformForUrl('https://example.com/instagram.com'),
        isNull,
      );
      expect(clientEnrichmentPlatformForUrl('not a url'), isNull);
      expect(clientEnrichmentPlatformForUrl(''), isNull);
    });

    test('isClientEnrichmentUrl mirrors the host decision', () {
      expect(isClientEnrichmentUrl('https://instagram.com/p/1'), isTrue);
      expect(isClientEnrichmentUrl('https://example.com/p/1'), isFalse);
    });
  });
}
