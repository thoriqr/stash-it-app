// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_preference_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app-wide language choice.
///
/// Mirrors [ThemeModeController] exactly: `keepAlive` so the selection
/// outlives the Settings route, synchronous state before persistence so the
/// app repaints immediately, and a warning on a failed write.

@ProviderFor(LanguagePreferenceController)
final languagePreferenceControllerProvider =
    LanguagePreferenceControllerProvider._();

/// The app-wide language choice.
///
/// Mirrors [ThemeModeController] exactly: `keepAlive` so the selection
/// outlives the Settings route, synchronous state before persistence so the
/// app repaints immediately, and a warning on a failed write.
final class LanguagePreferenceControllerProvider
    extends
        $NotifierProvider<LanguagePreferenceController, LanguagePreference> {
  /// The app-wide language choice.
  ///
  /// Mirrors [ThemeModeController] exactly: `keepAlive` so the selection
  /// outlives the Settings route, synchronous state before persistence so the
  /// app repaints immediately, and a warning on a failed write.
  LanguagePreferenceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languagePreferenceControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languagePreferenceControllerHash();

  @$internal
  @override
  LanguagePreferenceController create() => LanguagePreferenceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LanguagePreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LanguagePreference>(value),
    );
  }
}

String _$languagePreferenceControllerHash() =>
    r'3c713c5980043dafa449136e4e8b516f67377c82';

/// The app-wide language choice.
///
/// Mirrors [ThemeModeController] exactly: `keepAlive` so the selection
/// outlives the Settings route, synchronous state before persistence so the
/// app repaints immediately, and a warning on a failed write.

abstract class _$LanguagePreferenceController
    extends $Notifier<LanguagePreference> {
  LanguagePreference build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LanguagePreference, LanguagePreference>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LanguagePreference, LanguagePreference>,
              LanguagePreference,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
