import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash_it_app/app/feedback/app_feedback.dart';
import 'package:stash_it_app/app/feedback/feedback_controller.dart';

import '../data/language_preference_store.dart';
import '../domain/language_preference.dart';

part 'language_preference_controller.g.dart';

/// The language preference `bootstrap` restored before the first frame.
///
/// A plain provider rather than generated state: it is an immutable startup
/// fact, supplied once as a `ProviderScope` override. Its System default is
/// also the correct answer for a fresh installation and for a test container
/// that does not need persistence.
final Provider<LanguagePreference> initialLanguagePreferenceProvider =
    Provider<LanguagePreference>((ref) => LanguagePreference.system);

/// The app-wide language choice.
///
/// Mirrors [ThemeModeController] exactly: `keepAlive` so the selection
/// outlives the Settings route, synchronous state before persistence so the
/// app repaints immediately, and a warning on a failed write.
@Riverpod(keepAlive: true)
class LanguagePreferenceController extends _$LanguagePreferenceController {
  @override
  LanguagePreference build() => ref.watch(initialLanguagePreferenceProvider);

  /// Applies [preference] immediately, then persists it.
  ///
  /// The immediate state change is deliberate even if persistence fails: the
  /// user asked for this language, and reverting it would make the control
  /// appear broken. The warning explains the choice will not survive a restart.
  Future<void> select(LanguagePreference preference) async {
    if (state == preference) return;

    state = preference;

    final saved = await ref
        .read(languagePreferenceStoreProvider)
        .write(preference);
    if (!saved && ref.mounted) {
      ref
          .read(feedbackProvider.notifier)
          .show(
            const AppFeedback(
              tone: FeedbackTone.warning,
              copy: 'Language changed, but the preference could not be saved.',
            ),
          );
    }
  }

  /// The [Locale] this preference resolves to for [MaterialApp.locale].
  ///
  /// `null` for System default — `MaterialApp` then follows the device, and the
  /// `localeResolutionCallback` installed in `app.dart` picks the first
  /// supported locale from the device's ordered list.
  Locale? get locale => state.locale;
}
