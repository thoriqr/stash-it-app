import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/feedback/app_feedback.dart';
import '../../../app/feedback/feedback_controller.dart';
import '../../settings/application/package_info_provider.dart';
import '../data/client_update_providers.dart';
import '../domain/client_update_release.dart';
import '../domain/client_update_status.dart';

part 'client_update_controller.g.dart';

/// The current update check and any prompt the app should present.
@immutable
class ClientUpdateState {
  const ClientUpdateState({
    this.checking = false,
    this.prompt,
    this.dismissedBuild,
  });

  /// Whether a check is in flight.
  final bool checking;

  /// The prompt to present, or null when there is nothing to show.
  final ClientUpdatePrompt? prompt;

  /// An optional release the user already postponed.
  ///
  /// Automatic checks do not prompt again for this build. A manual check still
  /// prompts, because the user asked for it.
  final int? dismissedBuild;

  ClientUpdateState copyWith({
    bool? checking,
    ClientUpdatePrompt? prompt,
    bool clearPrompt = false,
    int? dismissedBuild,
  }) {
    return ClientUpdateState(
      checking: checking ?? this.checking,
      prompt: clearPrompt ? null : (prompt ?? this.prompt),
      dismissedBuild: dismissedBuild ?? this.dismissedBuild,
    );
  }
}

/// Reads the release policy at launch and on resume, and when the user asks.
///
/// Every failure is fail-open: the check never blocks the app and an automatic
/// check never shows an error. A manual check publishes a short notice because
/// the user explicitly asked for a result.
@Riverpod(keepAlive: true)
class ClientUpdate extends _$ClientUpdate {
  /// Guards concurrent checks without making the UI busy while the platform
  /// package lookup is still pending.
  bool _running = false;

  @override
  ClientUpdateState build() => const ClientUpdateState();

  /// Runs one check.
  ///
  /// [automatic] suppresses notices for failures and skips an optional release
  /// the user already postponed. A required update is never replaced by a
  /// second automatic check while it is showing.
  Future<void> check({required bool automatic}) async {
    if (_running) return;
    if (automatic && state.prompt?.isRequired == true) return;

    _running = true;

    try {
      final info = await ref.read(packageInfoProvider);
      final build = int.tryParse(info.buildNumber.trim());
      if (build == null || build < 1) {
        _log('skipped: build number is not a usable integer');
        return;
      }
      if (!ref.mounted) return;

      state = state.copyWith(checking: true);

      final platform = ref.read(clientPlatformProvider);
      final result = await ref
          .read(clientReleaseRepositoryProvider)
          .check(platform: platform, build: build);

      if (!ref.mounted) return;
      _apply(result, automatic: automatic);
    } catch (error) {
      _log('check failed: ${error.runtimeType}');
      if (!ref.mounted) return;
      if (!automatic) _publishCheckFailed();
    } finally {
      _running = false;
      if (ref.mounted) state = state.copyWith(checking: false);
    }
  }

  /// Postpones an optional update.
  ///
  /// A required update cannot be dismissed; the dialog only offers download or
  /// exit.
  void dismiss() {
    final prompt = state.prompt;
    if (prompt == null || prompt.isRequired) return;

    state = ClientUpdateState(
      checking: state.checking,
      dismissedBuild: prompt.release.build,
    );
  }

  /// The download action for the current prompt.
  ///
  /// Downloading is not implemented yet; this is the single callback the
  /// download flow will replace.
  void requestDownload() {
    final prompt = state.prompt;
    if (prompt == null) return;
    _log('download requested for build ${prompt.release.build}');
  }

  void _apply(ClientUpdateCheckResult result, {required bool automatic}) {
    switch (result) {
      case ClientUpdateNone():
        state = state.copyWith(clearPrompt: true);
        if (!automatic) _publishUpToDate();

      case ClientUpdateAvailable(:final prompt):
        final postponed =
            automatic &&
            prompt.status == ClientUpdateStatus.optional &&
            state.dismissedBuild == prompt.release.build;
        if (!postponed) state = state.copyWith(prompt: prompt);

      case ClientUpdateInvalidManifest():
        _log('ignored invalid release manifest');

      case ClientUpdateUnavailable():
        _log('release check unavailable');
        if (!automatic) _publishCheckFailed();
    }
  }

  void _publishUpToDate() {
    ref
        .read(feedbackProvider.notifier)
        .show(
          AppFeedback.localized(
            tone: FeedbackTone.success,
            message: (l10n) => l10n.clientUpdateUpToDate,
          ),
        );
  }

  void _publishCheckFailed() {
    ref
        .read(feedbackProvider.notifier)
        .show(
          AppFeedback.localized(
            tone: FeedbackTone.warning,
            message: (l10n) => l10n.clientUpdateCheckFailed,
          ),
        );
  }

  void _log(String message) {
    developer.log(message, name: 'client_update');
  }
}
