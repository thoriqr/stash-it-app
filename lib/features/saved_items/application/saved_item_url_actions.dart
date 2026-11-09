import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/feedback/app_feedback.dart';
import '../../../app/feedback/feedback_controller.dart';
import 'saved_item_feedback.dart';

/// How the native share sheet ended.
enum SavedItemShareOutcome {
  /// The user selected a destination.
  shared,

  /// The user dismissed the sheet without selecting a destination.
  dismissed,

  /// The sheet could not be opened or its result is unavailable.
  failed,
}

/// The native share handoff, behind one method.
///
/// This is a seam for tests: the platform channel must never be opened from a
/// test. Android owns the list of installed applications that can receive the
/// URL; this client only supplies the text.
class SavedItemShareLauncher {
  const SavedItemShareLauncher();

  Future<SavedItemShareOutcome> share(String text) async {
    try {
      final result = await SharePlus.instance.share(ShareParams(text: text));
      return switch (result.status) {
        ShareResultStatus.success => SavedItemShareOutcome.shared,
        ShareResultStatus.dismissed => SavedItemShareOutcome.dismissed,
        ShareResultStatus.unavailable => SavedItemShareOutcome.failed,
      };
    } on Exception {
      // A missing plugin, a refused intent or a platform error all mean the
      // sheet did not give us a usable result.
      return SavedItemShareOutcome.failed;
    }
  }
}

/// The clipboard handoff used by the explicit Copy URL action.
class SavedItemClipboard {
  const SavedItemClipboard();

  /// Writes [text] and reports whether the platform accepted it.
  Future<bool> write(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } on Exception {
      return false;
    }
  }
}

/// The share launcher the app uses.
final Provider<SavedItemShareLauncher> savedItemShareLauncherProvider =
    Provider<SavedItemShareLauncher>((ref) => const SavedItemShareLauncher());

/// The clipboard the app uses.
final Provider<SavedItemClipboard> savedItemClipboardProvider =
    Provider<SavedItemClipboard>((ref) => const SavedItemClipboard());

/// Whether the current platform exposes the native share action.
///
/// Android uses its system Sharesheet. Windows, macOS and the remaining
/// supported targets expose Copy URL only.
bool get showsSavedItemShareAction =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Copy and share actions for one saved item's complete original URL.
///
/// Copying always publishes the existing app-wide feedback. Sharing is silent
/// when the sheet is dismissed: that is ordinary cancellation, not a failure.
/// A share that cannot be opened falls back to copying the same URL.
class SavedItemUrlActions {
  const SavedItemUrlActions(this._ref);

  final Ref _ref;

  /// Copies [url] exactly as stored and publishes the outcome.
  Future<void> copy(String url) async {
    if (url.trim().isEmpty) {
      _publish(urlCopyFailedFeedback);
      return;
    }

    final written = await _ref.read(savedItemClipboardProvider).write(url);
    _publish(written ? urlCopiedFeedback : urlCopyFailedFeedback);
  }

  /// Opens the native share sheet for [url].
  ///
  /// A dismissed sheet does nothing. A failure to open the sheet is followed by
  /// [copy], which produces the copy success or failure feedback.
  Future<void> share(String url) async {
    if (url.trim().isEmpty) {
      _publish(urlCopyFailedFeedback);
      return;
    }

    final outcome = await _ref.read(savedItemShareLauncherProvider).share(url);
    switch (outcome) {
      case SavedItemShareOutcome.shared:
      case SavedItemShareOutcome.dismissed:
        return;
      case SavedItemShareOutcome.failed:
        await copy(url);
    }
  }

  void _publish(AppFeedback feedback) =>
      _ref.read(feedbackProvider.notifier).show(feedback);
}

/// The URL actions the detail screen uses.
final Provider<SavedItemUrlActions> savedItemUrlActionsProvider =
    Provider<SavedItemUrlActions>((ref) => SavedItemUrlActions(ref));
