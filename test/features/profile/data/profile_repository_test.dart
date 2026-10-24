import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_error_codes.dart';
import 'package:stash_it_app/core/error/api_failure.dart';
import 'package:stash_it_app/features/profile/data/datasources/profile_api.dart';
import 'package:stash_it_app/features/profile/data/models/set_password_request.dart';
import 'package:stash_it_app/features/profile/data/profile_repository.dart';

import '../../../support/fake_http.dart';

/// The profile write boundary: exact request bodies, envelope decoding, and the
/// failures these two endpoints can actually answer with.
void main() {
  late FakeHttpAdapter adapter;
  late ProfileRepository repository;

  setUp(() {
    adapter = FakeHttpAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    repository = ProfileRepository(api: ProfileApi(dio));
  });

  Map<String, dynamic> user({
    String displayName = 'Reader',
    bool hasPasswordCredential = true,
  }) {
    return {
      'id': 'user-1',
      'email': 'reader@example.com',
      'display_name': displayName,
      'has_password_credential': hasPasswordCredential,
      'created_at': '2026-04-12T12:00:00Z',
      'identities': [
        {
          'provider': 'google',
          'linked_at': '2026-01-02T12:00:00Z',
          'email_snapshot': 'onfile@example.com',
          'display_name_snapshot': null,
        },
      ],
    };
  }

  Map<String, dynamic> profileEnvelope({
    String displayName = 'Reader',
    bool hasPasswordCredential = true,
  }) {
    return {
      'data': {
        'user': user(
          displayName: displayName,
          hasPasswordCredential: hasPasswordCredential,
        ),
      },
      'message': 'user updated successfully',
    };
  }

  Map<String, dynamic> bodyOf(String pathFragment) {
    return adapter.lastRequestTo(pathFragment)!.body as Map<String, dynamic>;
  }

  group('updateDisplayName', () {
    test('sends only display_name, exactly as typed', () async {
      adapter.onMethod(
        'PATCH',
        '/users/me',
        body: profileEnvelope(displayName: '  Ada Lovelace  '),
      );

      final profile = await repository.updateDisplayName('  Ada Lovelace  ');

      final sent = adapter.lastRequestTo('/users/me')!;
      expect(sent.method, 'PATCH');
      expect(bodyOf('/users/me'), {'display_name': '  Ada Lovelace  '});
      // The backend neither trims nor case-folds, so the client must not either.
      expect(profile.displayName, '  Ada Lovelace  ');
    });

    test('decodes the complete profile the endpoint returns', () async {
      adapter.onMethod(
        'PATCH',
        '/users/me',
        body: profileEnvelope(
          displayName: 'Ada Lovelace',
          hasPasswordCredential: false,
        ),
      );

      final profile = await repository.updateDisplayName('Ada Lovelace');

      expect(profile.id, 'user-1');
      expect(profile.email, 'reader@example.com');
      expect(profile.displayName, 'Ada Lovelace');
      expect(profile.hasPasswordCredential, isFalse);
      expect(profile.createdAt, DateTime.utc(2026, 4, 12, 12));
      expect(profile.identities.single.provider, 'google');
      expect(profile.identities.single.emailSnapshot, 'onfile@example.com');
    });

    test('USER_NOT_FOUND is the account, not a generic not-found', () async {
      adapter.onMethod(
        'PATCH',
        '/users/me',
        status: 404,
        body: errorBody(ApiErrorCode.userNotFound),
      );

      await expectLater(
        repository.updateDisplayName('Ada Lovelace'),
        throwsA(isA<ApiFailureUserNotFound>()),
      );
    });

    test('a 500 is a server fault, not a claim that nothing was written', () {
      // The repository only classifies. Whether a server fault is ambiguous for
      // this route is the controller's decision, because the handler commits the
      // name before reading identities.
      adapter.onMethod(
        'PATCH',
        '/users/me',
        status: 500,
        body: errorBody(ApiErrorCode.internalServerError),
      );

      return expectLater(
        repository.updateDisplayName('Ada Lovelace'),
        throwsA(isA<ApiFailureServerFault>()),
      );
    });

    test('an unreadable 200 is an unreadable response', () {
      adapter.onMethod(
        'PATCH',
        '/users/me',
        body: {'data': <String, dynamic>{}, 'message': 'user updated'},
      );

      return expectLater(
        repository.updateDisplayName('Ada Lovelace'),
        throwsA(isA<ApiFailureUnreadableResponse>()),
      );
    });
  });

  group('setPassword', () {
    test('create mode omits current_password entirely', () async {
      adapter.onMethod(
        'PUT',
        '/users/me/password',
        body: {'data': null, 'message': 'password created successfully'},
      );

      await repository.setPassword(newPassword: 'correct horse battery');

      expect(adapter.lastRequestTo('/users/me/password')!.method, 'PUT');
      expect(bodyOf('/users/me/password'), {
        'new_password': 'correct horse battery',
      });
      expect(
        bodyOf('/users/me/password').containsKey('current_password'),
        isFalse,
        reason: 'an absent key states the create operation on the wire',
      );
    });

    test('change mode sends current_password exactly as typed', () async {
      adapter.onMethod(
        'PUT',
        '/users/me/password',
        body: {'data': null, 'message': 'password changed successfully'},
      );

      await repository.setPassword(
        newPassword: 'a new password',
        currentPassword: '  old password  ',
      );

      expect(bodyOf('/users/me/password'), {
        'current_password': '  old password  ',
        'new_password': 'a new password',
      });
    });

    test(
      'a 200 with data null is success, not an unreadable response',
      () async {
        adapter.onMethod(
          'PUT',
          '/users/me/password',
          body: {'data': null, 'message': 'password changed successfully'},
        );

        await expectLater(
          repository.setPassword(
            newPassword: 'a new password',
            currentPassword: 'old password',
          ),
          completes,
        );
      },
    );

    test('CURRENT_PASSWORD_INVALID surfaces as its own refusal', () async {
      adapter.onMethod(
        'PUT',
        '/users/me/password',
        status: 401,
        body: errorBody(ApiErrorCode.currentPasswordInvalid),
      );

      await expectLater(
        repository.setPassword(
          newPassword: 'a new password',
          currentPassword: 'wrong password',
        ),
        throwsA(isA<ApiFailureCurrentPasswordInvalid>()),
      );
    });

    test('PASSWORD_ALREADY_CHANGED surfaces as a lost race', () async {
      adapter.onMethod(
        'PUT',
        '/users/me/password',
        status: 409,
        body: errorBody(ApiErrorCode.passwordAlreadyChanged),
      );

      await expectLater(
        repository.setPassword(
          newPassword: 'a new password',
          currentPassword: 'old password',
        ),
        throwsA(isA<ApiFailurePasswordAlreadyChanged>()),
      );
    });

    test('PASSWORD_WORK_UNAVAILABLE keeps its Retry-After', () async {
      adapter.onMethod(
        'PUT',
        '/users/me/password',
        status: 503,
        body: errorBody(ApiErrorCode.passwordWorkUnavailable),
        headers: {
          'retry-after': ['4'],
        },
      );

      await expectLater(
        repository.setPassword(newPassword: 'a new password'),
        throwsA(
          isA<ApiFailureRateLimited>().having(
            (failure) => failure.retryAfter,
            'retryAfter',
            const Duration(seconds: 4),
          ),
        ),
      );
    });
  });

  group('request serialization', () {
    test('SetPasswordRequest.toJson omits a null current password', () {
      expect(const SetPasswordRequest(newPassword: 'a new password').toJson(), {
        'new_password': 'a new password',
      });
    });

    test('SetPasswordRequest.toJson includes a supplied current password', () {
      expect(
        const SetPasswordRequest(
          currentPassword: 'old password',
          newPassword: 'a new password',
        ).toJson(),
        {'current_password': 'old password', 'new_password': 'a new password'},
      );
    });
  });
}
