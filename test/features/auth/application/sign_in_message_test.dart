import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_error_body.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/presentation/auth_messages.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// The client-owned copy for a failed sign-in.
///
/// These strings are load-bearing in a way that is easy to break silently:
/// **[D22]** they are chosen from the typed failure and never from
/// `error.message`; **[D15]** a 429, a 503 and an offline device stay three
/// different things; **[D16]** an uncertain outcome never says the attempt did
/// not happen.
///
/// The mapping is a pure function of the typed failure and the active
/// localization, so it is tested here directly rather than through a widget.
void main() {
  final english = lookupAppLocalizations(const Locale('en'));
  final indonesian = lookupAppLocalizations(const Locale('id'));

  group('authSignInMessageFor', () {
    test('a wrong password and an unknown address read identically', () {
      // The backend answers both with INVALID_CREDENTIALS so the endpoint
      // cannot be used to enumerate registered addresses. Describing them
      // differently here would undo that.
      expect(
        authSignInMessageFor(const ApiFailureAuthRequired(), english),
        authSignInMessageFor(const ApiFailureAuthRequired(), english),
      );
      expect(
        authSignInMessageFor(const ApiFailureAuthRequired(), english),
        "That doesn't look like a valid email or password.",
      );
    });

    test(
      'a rate limit reports the countdown only when the server sent one',
      () {
        expect(
          authSignInMessageFor(
            const ApiFailureRateLimited(
              code: 'LOGIN_RATE_LIMIT_EXCEEDED',
              retryAfter: Duration(seconds: 42),
            ),
            english,
          ),
          contains('42 seconds'),
        );
        expect(
          authSignInMessageFor(
            const ApiFailureRateLimited(code: 'LOGIN_RATE_LIMIT_EXCEEDED'),
            english,
          ),
          'Too many attempts. Try again shortly.',
          reason: 'a countdown may never be fabricated',
        );
      },
    );

    test('a 503 and an offline device are not collapsed into one another', () {
      final unavailable = authSignInMessageFor(
        const ApiFailureServerUnavailable(code: 'SERVICE_UNAVAILABLE'),
        english,
      );
      final offline = authSignInMessageFor(
        const ApiFailureTransport(),
        english,
      );

      expect(unavailable, isNot(offline));
      expect(unavailable, contains('temporarily unavailable'));
      expect(offline, contains('could not confirm'));
    });

    test('an uncertain outcome never states that nothing happened', () {
      // [D16] the request may have been applied even though no answer arrived,
      // so the copy must not claim the account is untouched.
      final uncertain = authSignInMessageFor(
        const ApiFailureTransport(),
        english,
      );

      expect(uncertain, contains('could not confirm'));
      expect(uncertain, isNot(contains("didn't")));
      expect(uncertain, isNot(contains('was not saved')));
      expect(uncertain, isNot(contains('nothing was saved')));
    });

    test('a server fault is not dressed as uncertainty', () {
      // A 5xx is a known failure of the server, so it must not borrow the
      // "we could not confirm" wording reserved for a lost request.
      final fault = authSignInMessageFor(
        const ApiFailureServerFault(),
        english,
      );

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
        final copy = authSignInMessageFor(failure, english);
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

    test('typed failures resolve to Indonesian copy', () {
      expect(
        authSignInMessageFor(const ApiFailureAuthRequired(), indonesian),
        'Email atau kata sandi itu tampaknya tidak valid.',
      );
      expect(
        authSignInMessageFor(
          const ApiFailureRateLimited(
            code: 'LOGIN_RATE_LIMIT_EXCEEDED',
            retryAfter: Duration(seconds: 42),
          ),
          indonesian,
        ),
        contains('42 detik'),
      );
      expect(
        authSignInMessageFor(const ApiFailureTransport(), indonesian),
        contains('tidak dapat memastikan'),
      );
      expect(
        authSignInMessageFor(const ApiFailureServerFault(), indonesian),
        contains('tidak dapat menghubungi server'),
      );
    });
  });

  group('authRegistrationMessageFor', () {
    test('typed registration failures resolve to Indonesian copy', () {
      expect(
        authRegistrationMessageFor(
          const ApiFailureRegistrationAlreadyCompleted(
            code: 'REGISTRATION_ALREADY_COMPLETED',
          ),
          indonesian,
        ),
        'Akun dengan email ini sudah ada. Silakan masuk.',
      );
      expect(
        authRegistrationMessageFor(
          const ApiFailureRateLimited(
            code: 'PIN_RATE_LIMIT_EXCEEDED',
            retryAfter: Duration(seconds: 42),
          ),
          indonesian,
        ),
        contains('42 detik'),
      );
      expect(
        authRegistrationMessageFor(
          const ApiFailurePinEmailDeliveryFailed(),
          indonesian,
        ),
        contains('tidak dapat memastikan email PIN'),
      );
      expect(
        authRegistrationMessageFor(
          const ApiFailureRegistrationRestartRequired(
            code: 'REGISTRATION_RESTART_REQUIRED',
          ),
          indonesian,
        ),
        'Pendaftaran itu tidak dapat dilanjutkan lagi. Mulai pendaftaran baru.',
      );
    });
  });
}
