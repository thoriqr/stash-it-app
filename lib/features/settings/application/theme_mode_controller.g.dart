// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide appearance choice.
///
/// `keepAlive` because the selection must outlive the Settings route that changed
/// it: a dark theme chosen there remains dark on every destination and after a
/// restart. State is written synchronously before persistence is attempted, so
/// the app repaints immediately; a failed write is reported rather than silently
/// presented as saved.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// The app-wide appearance choice.
///
/// `keepAlive` because the selection must outlive the Settings route that changed
/// it: a dark theme chosen there remains dark on every destination and after a
/// restart. State is written synchronously before persistence is attempted, so
/// the app repaints immediately; a failed write is reported rather than silently
/// presented as saved.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// The app-wide appearance choice.
  ///
  /// `keepAlive` because the selection must outlive the Settings route that changed
  /// it: a dark theme chosen there remains dark on every destination and after a
  /// restart. State is written synchronously before persistence is attempted, so
  /// the app repaints immediately; a failed write is reported rather than silently
  /// presented as saved.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'64d4770f97090e58c6efa23505756e0de263440c';

/// The app-wide appearance choice.
///
/// `keepAlive` because the selection must outlive the Settings route that changed
/// it: a dark theme chosen there remains dark on every destination and after a
/// restart. State is written synchronously before persistence is attempted, so
/// the app repaints immediately; a failed write is reported rather than silently
/// presented as saved.

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
