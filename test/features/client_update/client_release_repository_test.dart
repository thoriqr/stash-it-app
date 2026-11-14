import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/client_update/data/client_release_repository.dart';
import 'package:stash_it_app/features/client_update/data/datasources/client_release_api.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_status.dart';

import '../../support/fake_http.dart';

const _validUrl =
    'https://downloads.stashit.thoriqr.my.id/android/stash-it-1.0.0-1.apk';

Map<String, dynamic> _releaseBody({
  String status = 'optional',
  String? downloadUrl = _validUrl,
  bool includeLatest = true,
}) {
  return {
    'data': {
      'status': status,
      'current_build': 1,
      'platform': 'android',
      'min_supported': {'version': '1.0.0', 'build': 1},
      if (includeLatest)
        'latest': {
          'version': '1.1.0',
          'build': 2,
          'download_url': downloadUrl,
          'sha256': 'abc123',
          'file_size_bytes': 48231001,
          'release_notes': '- Fixed things',
          'published_at': '2026-11-01T10:00:00Z',
        },
    },
    'message': 'client release check completed successfully',
  };
}

({ClientReleaseRepository repository, FakeHttpAdapter adapter}) _setup() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://fake.test',
      contentType: Headers.jsonContentType,
    ),
  )..httpClientAdapter = adapter;

  return (
    repository: ClientReleaseRepository(api: ClientReleaseApi(dio)),
    adapter: adapter,
  );
}

void main() {
  group('ClientReleaseRepository', () {
    test('returns the validated optional release', () async {
      final (:repository, :adapter) = _setup();
      adapter.on('/client-releases/latest', body: _releaseBody());

      final result = await repository.check(platform: 'android', build: 1);

      final available = result as ClientUpdateAvailable;
      expect(available.prompt.status, ClientUpdateStatus.optional);
      expect(available.prompt.release.version, '1.1.0');
      expect(available.prompt.release.build, 2);
      expect(available.prompt.release.downloadUrl.toString(), _validUrl);
      expect(available.prompt.release.fileSizeBytes, 48231001);
      expect(available.prompt.release.releaseNotes, '- Fixed things');
      expect(
        available.prompt.release.publishedAt,
        DateTime.utc(2026, 11, 1, 10),
      );
    });

    test('returns a required release', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'required'),
      );

      final result = await repository.check(platform: 'android', build: 1);

      expect((result as ClientUpdateAvailable).prompt.isRequired, isTrue);
    });

    test('returns none when the server reports no action', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'none', downloadUrl: null),
      );

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateNone>(),
      );
    });

    test('rejects a manifest whose download host is not allowed', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(downloadUrl: 'https://evil.example/app.apk'),
      );

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateInvalidManifest>(),
      );
    });

    test('rejects a manifest whose download URL is plain HTTP', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(
          status: 'required',
          downloadUrl: 'http://downloads.stashit.thoriqr.my.id/android/app.apk',
        ),
      );

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateInvalidManifest>(),
      );
    });

    test('rejects a release without usable required fields', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(includeLatest: false),
      );

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateInvalidManifest>(),
      );
    });

    test('rejects an unknown status', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        body: _releaseBody(status: 'mandatory-ish'),
      );

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateInvalidManifest>(),
      );
    });

    test('fails open on a server error', () async {
      final (:repository, :adapter) = _setup();
      adapter.on(
        '/client-releases/latest',
        status: 500,
        body: errorBody('INTERNAL_SERVER_ERROR'),
      );

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateUnavailable>(),
      );
    });

    test('fails open on a transport failure', () async {
      final (:repository, :adapter) = _setup();
      adapter.onOffline('/client-releases/latest');

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateUnavailable>(),
      );
    });

    test('fails open when the body is not valid JSON', () async {
      final (:repository, :adapter) = _setup();
      adapter.on('/client-releases/latest', body: 'not json');

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateUnavailable>(),
      );
    });

    test('fails open on a receive timeout', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://fake.test'))
        ..httpClientAdapter = _ReceiveTimeoutAdapter();
      final repository = ClientReleaseRepository(api: ClientReleaseApi(dio));

      expect(
        await repository.check(platform: 'android', build: 1),
        isA<ClientUpdateUnavailable>(),
      );
    });
  });
}

class _ReceiveTimeoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.receiveTimeout,
    );
  }

  @override
  void close({bool force = false}) {}
}
