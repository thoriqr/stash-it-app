import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/core/error/api_envelope.dart';
import 'package:stash_it_app/features/auth/data/models/register_manual_request.dart';
import 'package:stash_it_app/features/auth/data/models/register_manual_response.dart';

void main() {
  group('RegisterManual DTOs', () {
    test('serializes exactly the documented email request field', () {
      const request = RegisterManualRequest(email: 'user@example.com');

      expect(request.toJson(), {'email': 'user@example.com'});
    });

    test('decodes the verification id from the success envelope', () {
      final response = ApiEnvelope<RegisterManualResponse>.fromJson(
        {
          'data': {'verification_id': '01a0f359-093b-737a-963a-80f7ca6768ed'},
          'message': 'registration requested',
        },
        (data) =>
            RegisterManualResponse.fromJson(data! as Map<String, dynamic>),
      );

      expect(
        response.data?.verificationId,
        '01a0f359-093b-737a-963a-80f7ca6768ed',
      );
      expect(response.message, 'registration requested');
      expect(response.meta, isNull);
    });

    test('rejects a success payload without its required verification id', () {
      expect(
        () => RegisterManualResponse.fromJson(const {}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
