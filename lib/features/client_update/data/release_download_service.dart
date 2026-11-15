import 'dart:developer' as developer;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../../app/config/download_config.dart';
import '../domain/client_update_release.dart';
import '../domain/download_url.dart';
import '../domain/release_download.dart';
import '../domain/release_file_name.dart';

/// Downloads a release artifact to app-managed storage and verifies it.
abstract interface class ReleaseDownloadService {
  Future<ReleaseDownloadResult> download({
    required ClientUpdateRelease release,
    required String platform,
    CancelToken? cancelToken,
    void Function(int received, int? total)? onProgress,
    void Function()? onVerifying,
  });
}

class DioReleaseDownloadService implements ReleaseDownloadService {
  DioReleaseDownloadService({required this.dio, required this.tempDirectory});

  final Dio dio;
  final Future<Directory> Function() tempDirectory;

  @override
  Future<ReleaseDownloadResult> download({
    required ClientUpdateRelease release,
    required String platform,
    CancelToken? cancelToken,
    void Function(int received, int? total)? onProgress,
    void Function()? onVerifying,
  }) async {
    final uri = validatedDownloadUrl(
      release.downloadUrl.toString(),
      allowedHost: DownloadConfig.host,
    );
    if (uri == null) return const ReleaseDownloadHostRejected();

    final extension = _extensionFor(platform);
    if (extension == null) return const ReleaseDownloadUnsupportedPlatform();

    final expectedSha256 = _normalizedSha256(release.sha256);
    if (expectedSha256 == null) return const ReleaseDownloadChecksumMissing();

    File? target;
    try {
      final base = await tempDirectory();
      final updatesDir = Directory(
        '${base.path}${Platform.pathSeparator}updates',
      );
      await updatesDir.create(recursive: true);
      await _clearDirectory(updatesDir);

      final fileName = safeReleaseFileName(
        uri,
        extension: extension,
        build: release.build,
      );
      target = File('${updatesDir.path}${Platform.pathSeparator}$fileName');

      final response = await dio.download(
        uri.toString(),
        target.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total > 0 ? total : null);
        },
        options: Options(
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      final status = response.statusCode;
      if (status == null || status < 200 || status >= 300) {
        await _deleteQuietly(target);
        return const ReleaseDownloadFailed();
      }

      onVerifying?.call();
      final actualSha256 = await _sha256OfFile(target);
      if (actualSha256 != expectedSha256) {
        await _deleteQuietly(target);
        return const ReleaseDownloadChecksumMismatch();
      }

      return ReleaseDownloadSuccess(
        filePath: target.path,
        bytes: await target.length(),
      );
    } on DioException catch (error) {
      await _deleteQuietly(target);
      if (error.type == DioExceptionType.cancel) {
        return const ReleaseDownloadCancelled();
      }
      _log('download failed: ${error.type}');
      return const ReleaseDownloadFailed();
    } catch (error) {
      await _deleteQuietly(target);
      _log('download failed: ${error.runtimeType}');
      return const ReleaseDownloadFailed();
    }
  }

  static String? _extensionFor(String platform) {
    return switch (platform) {
      'android' => 'apk',
      'windows' => 'zip',
      _ => null,
    };
  }

  static String? _normalizedSha256(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(normalized)) return null;
    return normalized;
  }

  static Future<String> _sha256OfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static Future<void> _clearDirectory(Directory directory) async {
    try {
      await for (final entity in directory.list()) {
        if (entity is File) await entity.delete();
      }
    } catch (_) {
      // Cleanup is best effort; the new download overwrites its own target.
    }
  }

  static Future<void> _deleteQuietly(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // A failed cleanup must not turn into a crash or a successful install.
    }
  }

  static void _log(String message) {
    developer.log(message, name: 'client_update');
  }
}
