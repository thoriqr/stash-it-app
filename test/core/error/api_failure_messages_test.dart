import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/core/error/api_failure_messages.dart';

void main() {
  group('genericReadFailureMessage', () {
    test('shares the rate-limit copy', () {
      expect(
        genericReadFailureMessage(
          const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
        ),
        'Too many attempts. Try again shortly.',
      );
    });

    test('shares the server-fault copy', () {
      expect(
        genericReadFailureMessage(const ApiFailureServerFault()),
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
        expect(genericReadFailureMessage(failure), expected);
      }
    });

    test('leaves failures that need screen context to the screen', () {
      for (final failure in const <ApiFailure>[
        ApiFailureSessionEnded(code: 'SESSION_EXPIRED'),
        ApiFailureAuthRequired(),
        ApiFailureServerUnavailable(code: 'IP_RATE_LIMIT_UNAVAILABLE'),
        ApiFailureTransport(),
      ]) {
        expect(genericReadFailureMessage(failure), isNull);
      }
    });
  });
}
