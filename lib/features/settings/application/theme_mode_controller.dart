import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';

import '../data/theme_preference_store.dart';

part 'theme_mode_controller.g.dart';

/// The theme mode `bootstrap` restored before the first frame.
///
/// A plain provider rather than generated state: it is an immutable startup fact,
/// supplied once as a `ProviderScope` override. Its System default is also the
/// correct answer for a fresh installation and for a test container that does not
/// need persistence.
final Provider<ThemeMode> initialThemeModeProvider = Provider<ThemeMode>(
  (ref) => ThemeMode.system,
);

/// The app-wide appearance choice.
///
/// `keepAlive` because the selection must outlive the Settings route that changed
/// it: a dark theme chosen there remains dark on every destination and after a
/// restart. State is written synchronously before persistence is attempted, so
/// the app repaints immediately; a failed write is reported rather than silently
/// presented as saved.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  /// Applies [mode] immediately, then persists it.
  ///
  /// The immediate state change is deliberate even if persistence fails: the user
  /// asked for this appearance, and reverting it would make the control appear
  /// broken. The warning explains that the choice will not survive a restart.
  Future<void> select(ThemeMode mode) async {
    if (state == mode) return;

    state = mode;

    final saved = await ref.read(themePreferenceStoreProvider).write(mode);
    if (!saved && ref.mounted) {
      ref
          .read(feedbackProvider.notifier)
          .show(
            const AppFeedback(
              tone: FeedbackTone.warning,
              copy: 'Theme changed, but the preference could not be saved.',
            ),
          );
    }
  }
}
