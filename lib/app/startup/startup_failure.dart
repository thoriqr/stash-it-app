import 'package:flutter/material.dart';
import 'package:stash_it_app/app/localization/locale_resolution.dart';
import 'package:stash_it_app/app/theme/app_theme.dart';
import 'package:stash_it_app/l10n/app_localizations.dart';

/// Writes a startup failure to the platform log.
///
/// The widget shown to the user stays plain; this log carries the exception
/// type, message, and stack trace needed to diagnose the failure from `adb
/// logcat` or the desktop console.
void logStartupFailure(
  Object error,
  StackTrace stackTrace, {
  required String stage,
}) {
  debugPrint('[startup] Stash-it could not start (stage: $stage).');
  debugPrint('[startup] error: ${error.runtimeType}: $error');
  debugPrint('[startup] stack trace:\n$stackTrace');
}

/// Minimal application shown when startup cannot complete.
///
/// It does not open the normal app, router, or account UI. The message is
/// intentionally plain, and the device language is used because the saved
/// language preference may be exactly what could not be read.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: (locale, supported) => resolveAppLocale(
        WidgetsBinding.instance.platformDispatcher.locales,
        supported,
      ),
      home: const _StartupFailureScreen(),
    );
  }
}

class _StartupFailureScreen extends StatelessWidget {
  const _StartupFailureScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTheme.tokensOf(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppMetrics.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.startupFailureTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.screenHeading.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppMetrics.space3),
                  Text(
                    l10n.startupFailureBody,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Self-contained fallback for [ErrorWidget.builder].
///
/// A build error can occur before or outside the localized application tree,
/// so this view owns its directionality and uses fixed plain copy. Technical
/// details go to [logStartupFailure] instead.
class StartupFailureView extends StatelessWidget {
  const StartupFailureView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Color(0xFFF5F7F9),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Stash-it couldn't start.\nPlease close the app and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF222A34),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
