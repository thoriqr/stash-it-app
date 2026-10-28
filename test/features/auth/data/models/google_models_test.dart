import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/auth/data/models/account_link_confirmation_response.dart';
import 'package:stash_it_app/features/auth/data/models/confirm_account_link_request.dart';
import 'package:stash_it_app/features/auth/data/models/finalize_social_registration_request.dart';
import 'package:stash_it_app/features/auth/data/models/login_google_request.dart';
import 'package:stash_it_app/features/auth/data/models/login_google_response.dart';
import 'package:stash_it_app/features/auth/data/models/login_response.dart';

void main() {
  group('LoginGoogleResponse', () {
    test('authenticated decodes tokens and the user summary', () {
      final response = LoginGoogleResponse.fromJson({
        'outcome': 'authenticated',
        'access_token': 'access',
        'refresh_token': 'refresh',
        'user': {
          'id': 'user-1',
          'email': 'google@example.com',
          'display_name': 'Google User',
        },
      });

      expect(response.outcome, 'authenticated');
      expect(response.accessToken, 'access');
      expect(response.refreshToken, 'refresh');
      expect(response.user?.id, 'user-1');
      expect(response.user?.email, 'google@example.com');
      expect(response.user?.displayName, 'Google User');
      expect(response.provider, isNull);
      expect(response.confirmationId, isNull);
      expect(response.verificationId, isNull);
    });

    test('account-link-required decodes the confirmation fields', () {
      final response = LoginGoogleResponse.fromJson({
        'outcome': 'account_link_required',
        'provider': 'google',
        'confirmation_id': 'confirmation-1',
      });

      expect(response.outcome, 'account_link_required');
      expect(response.provider, 'google');
      expect(response.confirmationId, 'confirmation-1');
      expect(response.accessToken, isNull);
      expect(response.user, isNull);
    });

    test('registration-required decodes the verification id', () {
      final response = LoginGoogleResponse.fromJson({
        'outcome': 'registration_required',
        'verification_id': 'verification-1',
      });

      expect(response.outcome, 'registration_required');
      expect(response.verificationId, 'verification-1');
      expect(response.accessToken, isNull);
      expect(response.confirmationId, isNull);
    });
  });

  test('Google requests send exactly the documented id_token field', () {
    expect(LoginGoogleRequest(idToken: 'token').toJson(), {
      'id_token': 'token',
    });
    expect(ConfirmAccountLinkRequest(idToken: 'token').toJson(), {
      'id_token': 'token',
    });
    expect(
      FinalizeSocialRegistrationRequest(displayName: 'Google User').toJson(),
      {'display_name': 'Google User'},
    );
  });

  test('account-link confirmation decodes every documented field', () {
    final confirmation = AccountLinkConfirmationResponse.fromJson({
      'id': 'confirmation-1',
      'provider': 'google',
      'display_name_snapshot': 'Google User',
      'masked_user_email': 'g***@example.com',
    });

    expect(confirmation.id, 'confirmation-1');
    expect(confirmation.provider, 'google');
    expect(confirmation.displayNameSnapshot, 'Google User');
    expect(confirmation.maskedUserEmail, 'g***@example.com');
  });

  test('LoginResponse also decodes the social finalize payload', () {
    final response = LoginResponse.fromJson({
      'access_token': 'access-social',
      'refresh_token': 'refresh-social',
      'user': {
        'id': 'user-1',
        'email': 'social@example.com',
        'display_name': 'Social User',
      },
    });

    expect(response.accessToken, 'access-social');
    expect(response.refreshToken, 'refresh-social');
    expect(response.user.email, 'social@example.com');
    expect(response.user.displayName, 'Social User');
  });
}
