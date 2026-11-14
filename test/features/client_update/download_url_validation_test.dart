import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/client_update/domain/download_url.dart';

void main() {
  const host = 'downloads.stashit.thoriqr.my.id';
  const releasePath = '/android/stash-it-1.0.0-1.apk';

  group('validatedDownloadUrl', () {
    test('accepts the documented release URL', () {
      final uri = validatedDownloadUrl(
        'https://$host$releasePath',
        allowedHost: host,
      );

      expect(uri, isNotNull);
      expect(uri!.host, host);
      expect(uri.path, releasePath);
    });

    test('compares only the host and ignores case and whitespace', () {
      final uri = validatedDownloadUrl(
        '  https://DOWNLOADS.STASHIT.THORIQR.MY.ID/windows/other.exe  ',
        allowedHost: ' Downloads.StashIt.Thoriqr.My.Id ',
      );

      expect(uri, isNotNull);
      expect(uri!.host, host);
    });

    test('rejects a different host', () {
      expect(
        validatedDownloadUrl(
          'https://downloads.example.com$releasePath',
          allowedHost: host,
        ),
        isNull,
      );
    });

    test('rejects a host that only contains the allowed host', () {
      expect(
        validatedDownloadUrl(
          'https://$host.evil.example$releasePath',
          allowedHost: host,
        ),
        isNull,
      );
    });

    test('rejects plain HTTP', () {
      expect(
        validatedDownloadUrl('http://$host$releasePath', allowedHost: host),
        isNull,
      );
    });

    test('rejects malformed, relative, and empty values', () {
      for (final value in [
        null,
        '',
        '   ',
        'not a url',
        '/android/stash-it-1.0.0-1.apk',
        'https://',
        'ftp://$host$releasePath',
      ]) {
        expect(
          validatedDownloadUrl(value, allowedHost: host),
          isNull,
          reason: '$value must not be usable',
        );
      }
    });
  });
}
