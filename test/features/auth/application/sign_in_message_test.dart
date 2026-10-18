import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_error_body.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/presentation/sign_in_screen.dart';

/// The client-owned copy for a failed sign-in.
///
/// These strings are load-bearing in a way that is easy to break silently:
/// **[D22]** they are chosen from the typed failure and never from
/// `error.message`; **[D15]** a 429, a 503 and an offline device stay three
/// different things; **[D16]** an uncertain outcome never says the attempt did
/// not happen.
///
/// `messageFor` is a pure function of the typed failure, so it is tested here
/// directly rather than through a widget.
void main() {
  group('messageFor', () {
    test('a wrong password and an unknown address read identically', () {
      // The backend answers both with INVALID_CREDENTIALS so the endpoint
      // cannot be used to enumerate registered addresses. Describing them
      // differently here would undo that.
      expect(
        messageFor(const ApiFailureAuthRequired()),
        messageFor(const ApiFailureAuthRequired()),
      );
      expect(
        messageFor(const ApiFailureAuthRequired()),
        "That doesn't look like a valid email or password.",
      );
    });

    test(
      'a rate limit reports the countdown only when the server sent one',
      () {
        expect(
          messageFor(
            const ApiFailureRateLimited(
              code: 'LOGIN_RATE_LIMIT_EXCEEDED',
              retryAfter: Duration(seconds: 42),
            ),
          ),
          contains('42 seconds'),
        );
        expect(
          messageFor(
            const ApiFailureRateLimited(code: 'LOGIN_RATE_LIMIT_EXCEEDED'),
          ),
          'Too many attempts. Try again shortly.',
          reason: 'a countdown may never be fabricated',
        );
      },
    );

    test('a 503 and an offline device are not collapsed into one another', () {
      final unavailable = messageFor(
        const ApiFailureServerUnavailable(code: 'SERVICE_UNAVAILABLE'),
      );
      final offline = messageFor(const ApiFailureTransport());

      expect(unavailable, isNot(offline));
      expect(unavailable, contains('temporarily unavailable'));
      expect(offline, contains('could not confirm'));
    });

    test('an uncertain outcome never states that nothing happened', () {
      // [D16] the request may have been applied even though no answer arrived,
      // so the copy must not claim the account is untouched.
      final uncertain = messageFor(const ApiFailureTransport());

      expect(uncertain, contains('could not confirm'));
      expect(uncertain, isNot(contains("didn't")));
      expect(uncertain, isNot(contains('was not saved')));
      expect(uncertain, isNot(contains('nothing was saved')));
    });

    test('a server fault is not dressed as uncertainty', () {
      // A 5xx is a known failure of the server, so it must not borrow the
      // "we could not confirm" wording reserved for a lost request.
      final fault = messageFor(const ApiFailureServerFault());

      expect(fault, isNot(contains('could not confirm')));
      expect(fault, contains('could not reach the server'));
    });

    test('no variant claims the account or the service is broken', () {
      final everyFailure = <ApiFailure>[
        const ApiFailureAuthRequired(code: 'INVALID_ACCESS_TOKEN'),
        const ApiFailureValidation(<ApiErrorField>[]),
        const ApiFailureRateLimited(code: 'USER_RATE_LIMIT_EXCEEDED'),
        const ApiFailureServerUnavailable(code: 'SERVICE_UNAVAILABLE'),
        const ApiFailureServerFault(),
        const ApiFailureMalformedRequest(),
        const ApiFailureUnreadableResponse(code: 'SOMETHING_NEW'),
        const ApiFailureTransport(),
        const ApiFailureSessionEnded(code: 'SESSION_REVOKED'),
        const ApiFailureRefreshUncertain(cause: ApiFailureTransport()),
        const ApiFailureCredentialStorage(cause: 'platform error'),
      ];

      for (final failure in everyFailure) {
        final copy = messageFor(failure);
        expect(copy, isNotEmpty, reason: '${failure.runtimeType} has copy');
        expect(
          copy.toLowerCase(),
          isNot(contains('broken')),
          reason: '${failure.runtimeType} must not claim a broken service',
        );
        expect(
          copy.toLowerCase(),
          isNot(contains('unauthorized')),
          reason:
              '${failure.runtimeType} must not surface a backend status '
              'name as user-facing prose',
        );
      }
    });
  });
}
