import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final indonesian = lookupAppLocalizations(const Locale('id'));

  group('genericReadFailureMessage', () {
    test('shares the rate-limit copy', () {
      expect(
        genericReadFailureMessage(
          const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
          english,
        ),
        'Too many attempts. Try again shortly.',
      );
    });

    test('shares the server-fault copy', () {
      expect(
        genericReadFailureMessage(const ApiFailureServerFault(), english),
        'We could not reach the server. Try again shortly.',
      );
    });

    test('shares the unreadable-reply copy for request-shape failures', () {
      const expected = "We couldn't read the server's reply. Try again.";
      for (final failure in const <ApiFailure>[
        ApiFailureUnreadableResponse(),
        ApiFailureMalformedRequest(),
        ApiFailureValidation([]),
      ]) {
        expect(genericReadFailureMessage(failure, english), expected);
      }
    });

    test('resolves the shared copy in Indonesian', () {
      expect(
        genericReadFailureMessage(
          const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
          indonesian,
        ),
        'Terlalu banyak percobaan. Coba lagi sebentar lagi.',
      );
      expect(
        genericReadFailureMessage(const ApiFailureServerFault(), indonesian),
        'Kami tidak dapat menghubungi server. Coba lagi sebentar lagi.',
      );
      expect(
        genericReadFailureMessage(
          const ApiFailureUnreadableResponse(),
          indonesian,
        ),
        'Kami tidak dapat membaca balasan server. Coba lagi.',
      );
    });

    test('leaves failures that need screen context to the screen', () {
      for (final failure in const <ApiFailure>[
        ApiFailureSessionEnded(code: 'SESSION_EXPIRED'),
        ApiFailureAuthRequired(),
        ApiFailureServerUnavailable(code: 'IP_RATE_LIMIT_UNAVAILABLE'),
        ApiFailureTransport(),
      ]) {
        expect(genericReadFailureMessage(failure, english), isNull);
      }
    });
  });
}
