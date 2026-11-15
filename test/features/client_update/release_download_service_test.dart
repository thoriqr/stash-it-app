import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/client_update/data/release_download_service.dart';
import 'package:stash_it_app/features/client_update/domain/client_update_release.dart';
import 'package:stash_it_app/features/client_update/domain/release_download.dart';
import 'package:stash_it_app/features/client_update/domain/release_file_name.dart';

import '../../support/fake_http.dart';

const _host = 'downloads.stashit.thoriqr.my.id';
const _path = '/android/stash-it-1.0.0-1.apk';
const _url = 'https://$_host$_path';
const _payload = 'artifact bytes for stash-it';
final _sha = sha256.convert(utf8.encode(_payload)).toString();
const _unset = Object();

ClientUpdateRelease _release({Object? sha256 = _unset, String url = _url}) {
  return ClientUpdateRelease(
    version: '1.1.0',
    build: 2,
    downloadUrl: Uri.parse(url),
    sha256: identical(sha256, _unset) ? _sha : sha256 as String?,
    fileSizeBytes: utf8.encode(_payload).length,
  );
}

Directory _tempDirectory() {
  final directory = Directory.systemTemp.createTempSync(
    'stash_it_update_test_',
  );
  addTearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });
  return directory;
}

({DioReleaseDownloadService service, FakeHttpAdapter adapter, Directory temp})
_setup() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://fake.test'))
    ..httpClientAdapter = adapter;
  final temp = _tempDirectory();
  return (
    service: DioReleaseDownloadService(
      dio: dio,
      tempDirectory: () async => temp,
    ),
    adapter: adapter,
    temp: temp,
  );
}

Directory _updatesDirectory(Directory temp) {
  return Directory('${temp.path}${Platform.pathSeparator}updates');
}

List<File> _downloadedFiles(Directory temp) {
  final directory = _updatesDirectory(temp);
  if (!directory.existsSync()) return const [];
  return directory.listSync().whereType<File>().toList();
}

void main() {
  group('DioReleaseDownloadService', () {
    test('downloads, reports progress, and verifies the saved bytes', () async {
      final (:service, :adapter, :temp) = _setup();
      adapter.on(_path, body: _payload);

      var progressCalls = 0;
      var verifying = false;

      final result = await service.download(
        release: _release(),
        platform: 'android',
        onProgress: (received, total) => progressCalls++,
        onVerifying: () => verifying = true,
      );

      final success = result as ReleaseDownloadSuccess;
      expect(await File(success.filePath).readAsString(), _payload);
      expect(success.bytes, utf8.encode(_payload).length);
      expect(progressCalls, greaterThan(0));
      expect(verifying, isTrue);
      expect(_downloadedFiles(temp), hasLength(1));
    });

    test('rejects a URL on another host before requesting it', () async {
      final (:service, :adapter, :temp) = _setup();

      final result = await service.download(
        release: _release(url: 'https://evil.example$_path'),
        platform: 'android',
      );

      expect(result, isA<ReleaseDownloadHostRejected>());
      expect(adapter.requests, isEmpty);
      expect(_downloadedFiles(temp), isEmpty);
    });

    test('rejects plain HTTP before requesting it', () async {
      final (:service, :adapter, :temp) = _setup();

      final result = await service.download(
        release: _release(url: 'http://$_host$_path'),
        platform: 'android',
      );

      expect(result, isA<ReleaseDownloadHostRejected>());
      expect(adapter.requests, isEmpty);
    });

    test('rejects a platform without an artifact handoff', () async {
      final (:service, :adapter, :temp) = _setup();

      final result = await service.download(
        release: _release(),
        platform: 'macos',
      );

      expect(result, isA<ReleaseDownloadUnsupportedPlatform>());
      expect(adapter.requests, isEmpty);
    });

    test('refuses a release without a usable checksum', () async {
      for (final sha256 in [null, '', 'not-a-checksum']) {
        final (:service, :adapter, :temp) = _setup();

        final result = await service.download(
          release: _release(sha256: sha256),
          platform: 'android',
        );

        expect(
          result,
          isA<ReleaseDownloadChecksumMissing>(),
          reason: 'sha256=$sha256',
        );
        expect(adapter.requests, isEmpty);
        expect(_downloadedFiles(temp), isEmpty);
      }
    });

    test('deletes the file when the checksum does not match', () async {
      final (:service, :adapter, :temp) = _setup();
      adapter.on(_path, body: _payload);

      final result = await service.download(
        release: _release(sha256: List.filled(64, '0').join()),
        platform: 'android',
      );

      expect(result, isA<ReleaseDownloadChecksumMismatch>());
      expect(_downloadedFiles(temp), isEmpty);
    });

    test('deletes a partial file after a transport failure', () async {
      final (:service, :adapter, :temp) = _setup();
      adapter.onOffline(_path);

      final result = await service.download(
        release: _release(),
        platform: 'android',
      );

      expect(result, isA<ReleaseDownloadFailed>());
      expect(_downloadedFiles(temp), isEmpty);
    });

    test('deletes a partial file after a server error', () async {
      final (:service, :adapter, :temp) = _setup();
      adapter.on(_path, status: 500, body: 'error');

      final result = await service.download(
        release: _release(),
        platform: 'android',
      );

      expect(result, isA<ReleaseDownloadFailed>());
      expect(_downloadedFiles(temp), isEmpty);
    });

    test('does not follow a redirect away from the allowed host', () async {
      final (:service, :adapter, :temp) = _setup();
      adapter.on(
        _path,
        status: 302,
        headers: const {
          'location': ['https://evil.example/redirected.apk'],
        },
      );

      final result = await service.download(
        release: _release(),
        platform: 'android',
      );

      expect(result, isA<ReleaseDownloadFailed>());
      expect(
        adapter.requests.where(
          (request) => request.path.contains('evil.example'),
        ),
        isEmpty,
      );
      expect(_downloadedFiles(temp), isEmpty);
    });
  });

  group('safeReleaseFileName', () {
    test('keeps the URL basename and expected extension', () {
      expect(
        safeReleaseFileName(Uri.parse(_url), extension: 'apk', build: 2),
        'stash-it-1.0.0-1.apk',
      );
    });

    test('replaces path separators and traversal segments', () {
      final name = safeReleaseFileName(
        Uri.parse('https://$_host/..%2F..%2Fevil.apk'),
        extension: 'apk',
        build: 2,
      );

      expect(name, isNot(contains('/')));
      expect(name, isNot(contains('\\')));
      expect(name, isNot(startsWith('..')));
      expect(name, endsWith('.apk'));
    });

    test('appends the platform extension when it is missing', () {
      expect(
        safeReleaseFileName(
          Uri.parse('https://$_host/windows/download'),
          extension: 'zip',
          build: 3,
        ),
        'download.zip',
      );
    });

    test('falls back to a build-based name for an empty path', () {
      expect(
        safeReleaseFileName(
          Uri.parse('https://$_host/'),
          extension: 'zip',
          build: 3,
        ),
        'stash-it-3.zip',
      );
    });

    test('bounds the base name without dropping the extension', () {
      final name = safeReleaseFileName(
        Uri.parse('https://$_host/${'a' * 200}.apk'),
        extension: 'apk',
        build: 2,
      );

      expect(name.length, lessThanOrEqualTo(104));
      expect(name, endsWith('.apk'));
    });
  });
}
