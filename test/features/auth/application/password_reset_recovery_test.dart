import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/auth/application/password_reset_recovery.dart';

void main() {
  group('passwordResetContinuationOutcomeFor', () {
    test('a consumed token means the reset completed', () {
      expect(
        passwordResetContinuationOutcomeFor(
          const ApiFailurePasswordResetContinuationConsumed(
            code: 'PASSWORD_RESET_CONTINUATION_CONSUMED',
          ),
        ),
        PasswordResetContinuationOutcome.consumed,
      );
    });

    test('every terminal non-consumed refusal requires a restart', () {
      for (final failure in <ApiFailure>[
        const ApiFailurePasswordResetContinuationExpired(
          code: 'PASSWORD_RESET_CONTINUATION_EXPIRED',
        ),
        const ApiFailurePasswordResetContinuationRequired(
          code: 'PASSWORD_RESET_CONTINUATION_REQUIRED',
        ),
        const ApiFailurePasswordResetNotPending(
          code: 'PASSWORD_RESET_NOT_PENDING',
        ),
        const ApiFailurePasswordResetExpired(code: 'PASSWORD_RESET_EXPIRED'),
      ]) {
        expect(
          passwordResetContinuationOutcomeFor(failure),
          PasswordResetContinuationOutcome.restartRequired,
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
        const ApiFailurePasswordResetAlreadyPending(
          code: 'PASSWORD_RESET_ALREADY_PENDING',
        ),
      ]) {
        expect(
          passwordResetContinuationOutcomeFor(failure),
          PasswordResetContinuationOutcome.unconfirmed,
          reason: '$failure must not discard a token',
        );
      }
    });
  });
}
