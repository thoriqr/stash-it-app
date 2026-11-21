import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:stash_it_app/app/feedback/feedback_host.dart';
import 'package:stash_it_app/app/localization/locale_resolution.dart';
import 'package:stash_it_app/app/router/app_router.dart';
import 'package:stash_it_app/app/session/session_boundary.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/features/client_update/application/client_update_controller.dart';
import 'package:stash_it_app/features/client_update/application/client_update_download_controller.dart';
import 'package:stash_it_app/features/client_update/presentation/client_update_host.dart';
import 'package:stash_it_app/features/pending_urls/application/pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/save_pending_urls_controller.dart';
import 'package:stash_it_app/features/pending_urls/application/shared_url_intake.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_channel.dart';
import 'package:stash_it_app/features/pending_urls/presentation/share_intake_localization.dart';
import 'package:stash_it_app/features/saved_items/application/saved_items_controller.dart';
import 'package:stash_it_app/features/settings/application/language_preference_controller.dart';
import 'package:stash_it_app/features/settings/application/theme_mode_controller.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Root application widget.
///
/// Stateful because it owns two app-lifetime responsibilities:
/// - The live Android share channel, which reuses the current session
///   controller when a shared URL arrives while the app is running.
/// - Refreshing the device-local URL list when the app resumes, so changes
///   made while backgrounded and expired entries are reflected in the UI.
class StashItApp extends ConsumerStatefulWidget {
  const StashItApp({super.key, this.router});

  /// Optional router override, primarily for tests that need isolated
  /// navigation state or want to bypass authentication redirects.
  ///
  /// When omitted, the router is obtained from [appRouterProvider].
  final GoRouter? router;

  @override
  ConsumerState<StashItApp> createState() => _StashItAppState();
}

class _StashItAppState extends ConsumerState<StashItApp>
    with WidgetsBindingObserver {
  static const MethodChannel _shareChannel = MethodChannel(
    shareIntakeChannelName,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // The update check is best effort and never blocks the first frame. It is
    // scheduled after the first build because a provider cannot be modified
    // during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(clientUpdateProvider.notifier).check(automatic: true));
    });

    // Handles shares in the live UI engine. Reusing its session controller
    // keeps token renewal under the same serialized session flow.
    bindShareIntakeChannel(
      _shareChannel,
      (raw, {note}) => ref.read(sharedUrlIntakeProvider).save(raw, note: note),
      messageFor: (outcome) => shareOutcomeMessage(
        outcome,
        shareIntakeLocalizations(
          ref.read(languagePreferenceControllerProvider),
        ),
      ),
      onOutcome: _afterShare,
    );
  }

  @override
  void dispose() {
    _shareChannel.setMethodCallHandler(null);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    final handled = ref.read(clientUpdateProvider.notifier).handleSystemBack();
    if (!handled) return false;

    // An optional prompt was dismissed, so its download must not continue. A
    // required prompt remains, so a back action must not cancel its download.
    if (ref.read(clientUpdateProvider).prompt == null) {
      ref.read(clientUpdateDownloadProvider.notifier).reset();
    }

    return true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check after background activity so a release published meanwhile is
      // seen. The controller ignores a required prompt already on screen.
      unawaited(ref.read(clientUpdateProvider.notifier).check(automatic: true));
    }

    if (state == AppLifecycleState.resumed &&
        !ref.read(savePendingUrlsProvider).isRunning) {
      // Refresh the local list after background activity, including shares
      // handled by the headless engine. Reading the store also enforces expiry.
      //
      // Do not invalidate during a bulk save: that operation reconciles its
      // current list as entries are confirmed. An invalidation could replace
      // that snapshot with a read taken before those removals.
      ref.invalidate(pendingUrlsProvider);
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // Only System default depends on the device locale. Rebuilding here keeps
    // that choice current when the device language changes while the app runs.
    if (!mounted) return;
    setState(() {});
  }

  void _afterShare(ShareSaveOutcome outcome) {
    if (!mounted) return;
    if (outcome.touchedStore) ref.invalidate(pendingUrlsProvider);

    if (outcome == ShareSaveOutcome.saved) {
      // Refresh the Inbox head independently. This is best-effort and cannot
      // turn a confirmed save into an error.
      unawaited(ref.read(savedItemsProvider.notifier).refreshHead());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the session-boundary listener alive for the lifetime of the app.
    // It clears account-scoped caches but leaves device-local URLs untouched.
    ref.watch(sessionBoundaryProvider);

    // Root-level subscriptions ensure theme and language changes are applied
    // across all routes without recreating the router or losing navigation state.
    final themeMode = ref.watch(themeModeControllerProvider);

    final language = ref.watch(languagePreferenceControllerProvider);

    // Always resolve a concrete locale. Passing null back to MaterialApp for
    // System default does not restore the device locale: Flutter's
    // LocalizationsResolver keeps its previous resolved locale unless the
    // supported-locale list changes. Resolving here also makes the first frame
    // deterministic when the device locale list is empty.
    final appLocale =
        language.locale ??
        resolveAppLocale(
          WidgetsBinding.instance.platformDispatcher.locales,
          supportedAppLocales,
        );

    // Use the same router instance for the app and the update host, including
    // when a caller supplies one for a test.
    final GoRouter router = widget.router ?? ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Stash-it',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: appLocale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Place shared presentation above the router so every route uses the
      // same skeleton configuration and feedback host.
      //
      // FeedbackHost wraps SkeletonizerConfig so notices remain above routed
      // content, including authentication screens and the navigation bar.
      builder: (context, child) => ClientUpdateHost(
        child: FeedbackHost(
          child: SkeletonizerConfig(
            data: appSkeletonizerConfig(
              Theme.of(context).brightness,
              reducedMotion: MediaQuery.disableAnimationsOf(context),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      // The router is watched above so its authentication refresh listener
      // remains alive for the lifetime of the application.
      routerConfig: router,
    );
  }
}
