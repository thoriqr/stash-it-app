import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Package information for the installed build.
///
/// Settings displays `version` only. `buildNumber` remains available here for
/// the planned backend update check.
///
/// A plain provider because the lookup crosses a platform channel: tests can
/// override it without opening the channel.
final Provider<Future<PackageInfo>> packageInfoProvider =
    Provider<Future<PackageInfo>>((ref) => PackageInfo.fromPlatform());
