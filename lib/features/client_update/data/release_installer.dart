import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/release_install.dart';

/// Android uses a small native channel; Windows opens the ZIP in Explorer or
/// its default handler. No silent install is attempted on any platform.
class PlatformReleaseInstaller implements ReleaseInstaller {
  const PlatformReleaseInstaller();

  static const MethodChannel _channel = MethodChannel('stash_it/installer');

  @override
  Future<ReleaseInstallResult> open({
    required String filePath,
    required String platform,
  }) async {
    return switch (platform) {
      'android' => _openAndroid(filePath),
      'windows' => _openWindows(filePath),
      _ => const ReleaseInstallUnsupported(),
    };
  }

  Future<ReleaseInstallResult> _openAndroid(String filePath) async {
    try {
      final opened = await _channel.invokeMethod<bool>('openApk', {
        'path': filePath,
      });
      if (opened == true) return const ReleaseInstallHandedOff();

      _logFailure('openApk returned $opened', null, null, null);
      return const ReleaseInstallFailed(code: 'open_returned_false');
    } on PlatformException catch (error) {
      _logFailure(
        'PlatformException',
        error.code,
        error.message,
        error.details,
      );
      if (error.code == 'install_permission_required') {
        return ReleaseInstallPermissionRequired(
          code: error.code,
          message: error.message,
        );
      }
      return ReleaseInstallFailed(
        code: error.code,
        message: error.message,
        details: error.details,
      );
    } on MissingPluginException catch (error) {
      _logFailure(
        'MissingPluginException',
        'missing_plugin',
        error.message,
        null,
      );
      return ReleaseInstallFailed(
        code: 'missing_plugin',
        message: error.message,
      );
    } catch (error) {
      _logFailure(
        'Exception',
        error.runtimeType.toString(),
        error.toString(),
        null,
      );
      return ReleaseInstallFailed(code: 'exception', message: error.toString());
    }
  }

  Future<ReleaseInstallResult> _openWindows(String filePath) async {
    try {
      final opened = await launchUrl(
        Uri.file(filePath),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return const ReleaseInstallHandedOff();
      _logFailure('launchUrl returned false', null, null, null);
    } catch (error) {
      _logFailure('launchUrl failed', null, error.toString(), null);
      // Fall through to Explorer, which is always available on Windows.
    }

    try {
      await Process.start('explorer.exe', [
        filePath,
      ], mode: ProcessStartMode.detached);
      return const ReleaseInstallHandedOff();
    } on ProcessException catch (error) {
      _logFailure('explorer.exe failed', null, error.message, null);
      return ReleaseInstallFailed(
        code: 'explorer_failed',
        message: error.message,
      );
    }
  }

  void _logFailure(
    String kind,
    String? code,
    String? message,
    Object? details,
  ) {
    developer.log(
      'installer handoff failed [$kind] code=$code message=$message '
      'details=$details',
      name: 'client_update',
    );
  }
}
