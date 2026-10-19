import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/domain/saved_item_url.dart';

/// The local gate before `POST /saved-items`.
///
/// Two halves matter. The refused cases are the ones the gate exists for: the
/// common mistakes, answered without a round-trip. The accepted cases are the
/// ones that keep the gate honest — a local rule stricter than the server's turns
/// a valid link into a client-side dead end that no server response can undo, so
/// "still accepted" is as load-bearing as "refused".
void main() {
  group('accepts an absolute http or https URL', () {
    for (final url in <String>[
      'https://example.com',
      'http://example.com',
      'https://example.com/',
      'https://example.com/articles/chests-explained',
      'https://example.com/a/b?x=1&y=2',
      'https://example.com/a#section-3',
      'https://example.com:8443/deep/path?q=1#frag',
      'http://192.168.0.1:8080/a',
      'https://[::1]:8080/',
      // Case-insensitive scheme and host: the parser normalises both, and a link
      // typed with a capitalised scheme must not be refused for it.
      'HTTPS://EXAMPLE.COM/Path',
      // An internationalised host, as Dart's parser stores it (percent-encoded)
      // and as the server receives it (decoded).
      'https://例え.jp/パス',
      'https://xn--80ak6aa92e.com/',
      // Underscores are not valid DNS, but they are legal in a host and the server
      // is the authority on whether it will accept one.
      'https://my_host.example.com/',
      'https://user:pass@example.com/x',
      'https://example.com/%20',
    ]) {
      test(url, () => expect(isSubmittableUrl(url), isTrue));
    }
  });

  group('trims surrounding whitespace before judging', () {
    for (final url in <String>[
      '  https://example.com',
      'https://example.com  ',
      '\thttps://example.com\n',
      '  https://example.com/a?b=1  ',
    ]) {
      test(url.replaceAll('\t', r'\t').replaceAll('\n', r'\n'), () {
        expect(isSubmittableUrl(url), isTrue);
      });
    }
  });

  group('refuses what cannot be a saved item URL', () {
    const cases = <String, String>{
      '': 'empty',
      '   ': 'only whitespace',
      '\n\t': 'only whitespace',
      'example': 'no scheme, no host',
      'example.com': 'no scheme — a bare host is not an absolute URL',
      'example.com/articles/1': 'no scheme',
      '//example.com': 'no scheme',
      '/articles/1': 'a path, not a URL',
      'http:example.com': 'a scheme but no authority, so no host',
      'https://': 'a scheme and nothing to open',
      'https:///path': 'no host',
      'http://?q=1': 'no host',
      'https://#frag': 'no host',
      'https://user@': 'userinfo but no host',
      'ftp://example.com': 'unsupported scheme',
      'file:///tmp/x': 'unsupported scheme',
      'javascript:alert(1)': 'unsupported scheme',
      'mailto:a@b.c': 'not a web URL',
      'data:text/plain,hi': 'unsupported scheme',
      'https://exa mple.com': 'a space cannot be in a host',
      'https://example.com\nbad': 'a newline cannot be in a host',
      'https://%zz': 'a broken percent escape in the host',
      'https://example.com%': 'a bare percent in the host',
      'https://example.com:99999': 'a port no client can address',
      'https://example.com:abc': 'a port that is not a number',
      'https://[::1': 'an unterminated IPv6 literal',
      'not a url': 'not a URI at all',
    };

    for (final entry in cases.entries) {
      test('"${entry.key}" — ${entry.value}', () {
        expect(isSubmittableUrl(entry.key), isFalse);
      });
    }
  });

  group('leaves to the server what it cannot decide', () {
    test('a single-label host is an absolute URL with a host', () {
      // `intranet-host` has no dot. Requiring one would be a local DNS opinion
      // that refuses links the server accepts.
      expect(isSubmittableUrl('http://intranet-host/wiki'), isTrue);
      expect(isSubmittableUrl('http://localhost:3000/'), isTrue);
    });

    test('an unknown platform or domain is not an allowlist question', () {
      expect(isSubmittableUrl('https://not-a-known-site.example/x'), isTrue);
    });

    test('a URL beyond the server\'s length cap still passes locally', () {
      // The cap is real (`max=2048`), but its copy is not a format complaint, so
      // the server answers it. Asserted so a later "mirror the cap" change has to
      // be a deliberate one.
      final long = 'https://example.com/${'a' * 2100}';
      expect(isSubmittableUrl(long), isTrue);
    });
  });
}
