import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/registration_recovery.dart';
import 'package:stash_it_app/features/auth/data/models/register_manual_response.dart';
import 'package:stash_it_app/features/auth/data/registration_continuation_store.dart';

void main() {
  const email = 'Reader@Example.com';
  const normalized = 'reader@example.com';

  RegisterManualResponse response(String? status) => RegisterManualResponse(
    verificationId: '01a0f359-093b-737a-963a-80f7ca6768ed',
    verificationStatus: status,
  );

  const matching = StoredRegistrationContinuation(
    email: normalized,
    token: 'raw-token',
  );

  group('registrationStartFor', () {
    test('pending requests a PIN', () {
      expect(
        registrationStartFor(
          response: response('pending'),
          stored: matching,
          email: email,
        ),
        RegistrationStart.requestPin,
      );
    });

    test('a missing status from an older backend requests a PIN', () {
      expect(
        registrationStartFor(
          response: response(null),
          stored: matching,
          email: email,
        ),
        RegistrationStart.requestPin,
      );
    });

    test('an unknown status requests a PIN rather than guessing', () {
      expect(
        registrationStartFor(
          response: response('something-new'),
          stored: matching,
          email: email,
        ),
        RegistrationStart.requestPin,
      );
    });

    test('verified with a matching stored token opens finalization', () {
      expect(
        registrationStartFor(
          response: response('verified'),
          stored: matching,
          email: email,
        ),
        RegistrationStart.openFinalize,
      );
    });

    test('the email comparison ignores case and surrounding whitespace', () {
      expect(
        registrationStartFor(
          response: response('verified'),
          stored: matching,
          email: '  READER@EXAMPLE.COM  ',
        ),
        RegistrationStart.openFinalize,
      );
    });

    test('verified with no record is blocked, never a PIN flow', () {
      expect(
        registrationStartFor(
          response: response('verified'),
          stored: null,
          email: email,
        ),
        RegistrationStart.verifiedWithoutToken,
      );
    });

    test('a token for another email is never applied', () {
      expect(
        registrationStartFor(
          response: response('verified'),
          stored: const StoredRegistrationContinuation(
            email: 'other@example.com',
            token: 'other-token',
          ),
          email: email,
        ),
        RegistrationStart.verifiedWithoutToken,
      );
    });
  });

  group('continuationOutcomeFor', () {
    test('a consumed token means the registration completed', () {
      expect(
        continuationOutcomeFor(
          const ApiFailureRegistrationContinuationConsumed(
            code: 'REGISTRATION_CONTINUATION_CONSUMED',
          ),
        ),
        ContinuationOutcome.consumed,
      );
    });

    test('every terminal non-consumed refusal requires a restart', () {
      for (final failure in <ApiFailure>[
        const ApiFailureRegistrationContinuationExpired(
          code: 'REGISTRATION_CONTINUATION_EXPIRED',
        ),
        const ApiFailureRegistrationContinuationRequired(
          code: 'REGISTRATION_CONTINUATION_REQUIRED',
        ),
        const ApiFailureRegistrationRestartRequired(
          code: 'REGISTRATION_NOT_PENDING',
        ),
        const ApiFailureInvalidRegistrationType(
          code: 'INVALID_REGISTRATION_TYPE',
        ),
      ]) {
        expect(
          continuationOutcomeFor(failure),
          ContinuationOutcome.restartRequired,
          reason: '$failure is terminal',
        );
      }
    });

    test('nothing that might be transient is ever terminal', () {
      for (final failure in <ApiFailure>[
        const ApiFailureTransport(),
        const ApiFailureUnreadableResponse(),
        const ApiFailureUnreadableResponse(code: 'CONFLICT'),
        const ApiFailureRateLimited(code: 'IP_RATE_LIMIT_EXCEEDED'),
        const ApiFailureServerUnavailable(code: 'SERVICE_UNAVAILABLE'),
        const ApiFailureServerFault(),
        const ApiFailureValidation([]),
        const ApiFailureMalformedRequest(),
        const ApiFailureRegistrationAlreadyCompleted(
          code: 'REGISTRATION_ALREADY_COMPLETED',
        ),
      ]) {
        expect(
          continuationOutcomeFor(failure),
          ContinuationOutcome.unconfirmed,
          reason: '$failure must not discard a token',
        );
      }
    });
  });
}
