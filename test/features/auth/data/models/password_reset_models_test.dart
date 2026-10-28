import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/auth/data/models/finalize_password_reset_request.dart';
import 'package:stash_it_app/features/auth/data/models/password_reset_continuation_response.dart';
import 'package:stash_it_app/features/auth/data/models/request_password_reset_request.dart';
import 'package:stash_it_app/features/auth/data/models/request_password_reset_response.dart';
import 'package:stash_it_app/features/auth/data/models/verify_password_reset_request.dart';
import 'package:stash_it_app/features/auth/data/models/verify_password_reset_response.dart';

void main() {
  group('password reset DTOs', () {
    test('the request serializes exactly the email field', () {
      expect(
        const RequestPasswordResetRequest(email: 'user@example.com').toJson(),
        {'email': 'user@example.com'},
      );
    });

    test('the request response decodes the verification id', () {
      final response = RequestPasswordResetResponse.fromJson(const {
        'verification_id': '01a0f359-093b-737a-963a-80f7ca6768ed',
      });

      expect(response.verificationId, '01a0f359-093b-737a-963a-80f7ca6768ed');
    });

    test('the verify request serializes exactly the pin', () {
      expect(const VerifyPasswordResetRequest(pin: '123456').toJson(), {
        'pin': '123456',
      });
    });

    test('the verify response decodes the continuation token', () {
      final response = VerifyPasswordResetResponse.fromJson(const {
        'password_reset_continuation_token': 'raw-token',
      });

      expect(response.passwordResetContinuationToken, 'raw-token');
    });

    test('the continuation response decodes both documented fields', () {
      final response = PasswordResetContinuationResponse.fromJson(const {
        'email': 'user@example.com',
        'has_password_credential': false,
      });

      expect(response.email, 'user@example.com');
      expect(response.hasPasswordCredential, isFalse);
    });

    test('the finalize request serializes exactly the password', () {
      expect(
        const FinalizePasswordResetRequest(password: 'password123').toJson(),
        {'password': 'password123'},
      );
    });

    test('required fields are not silently defaulted', () {
      expect(
        () => RequestPasswordResetResponse.fromJson(const {}),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => VerifyPasswordResetResponse.fromJson(const {}),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => PasswordResetContinuationResponse.fromJson(const {
          'email': 'user@example.com',
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
