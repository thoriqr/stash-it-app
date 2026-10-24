// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_name_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One `PATCH /users/me` per explicit Save.
///
/// **The status is a plain `bool`, set synchronously before the first `await`**, so
/// a double tap cannot issue two writes. Keep-alive so a request already sent is
/// not abandoned when the sheet or route rebuilds.
///
/// The success response is the complete profile, so the loaded profile is replaced
/// with it rather than merged. An ambiguous outcome — a `500`, a transport failure,
/// or an unreadable success body — is reconciled by refetching; the name is never
/// reported as unsaved when the client cannot establish that.

@ProviderFor(DisplayNameUpdate)
final displayNameUpdateProvider = DisplayNameUpdateProvider._();

/// One `PATCH /users/me` per explicit Save.
///
/// **The status is a plain `bool`, set synchronously before the first `await`**, so
/// a double tap cannot issue two writes. Keep-alive so a request already sent is
/// not abandoned when the sheet or route rebuilds.
///
/// The success response is the complete profile, so the loaded profile is replaced
/// with it rather than merged. An ambiguous outcome — a `500`, a transport failure,
/// or an unreadable success body — is reconciled by refetching; the name is never
/// reported as unsaved when the client cannot establish that.
final class DisplayNameUpdateProvider
    extends $NotifierProvider<DisplayNameUpdate, bool> {
  /// One `PATCH /users/me` per explicit Save.
  ///
  /// **The status is a plain `bool`, set synchronously before the first `await`**, so
  /// a double tap cannot issue two writes. Keep-alive so a request already sent is
  /// not abandoned when the sheet or route rebuilds.
  ///
  /// The success response is the complete profile, so the loaded profile is replaced
  /// with it rather than merged. An ambiguous outcome — a `500`, a transport failure,
  /// or an unreadable success body — is reconciled by refetching; the name is never
  /// reported as unsaved when the client cannot establish that.
  DisplayNameUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayNameUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayNameUpdateHash();

  @$internal
  @override
  DisplayNameUpdate create() => DisplayNameUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$displayNameUpdateHash() => r'3a9a052fb2c14e3f0b984b29cc8f8d1b3c0f434d';

/// One `PATCH /users/me` per explicit Save.
///
/// **The status is a plain `bool`, set synchronously before the first `await`**, so
/// a double tap cannot issue two writes. Keep-alive so a request already sent is
/// not abandoned when the sheet or route rebuilds.
///
/// The success response is the complete profile, so the loaded profile is replaced
/// with it rather than merged. An ambiguous outcome — a `500`, a transport failure,
/// or an unreadable success body — is reconciled by refetching; the name is never
/// reported as unsaved when the client cannot establish that.

abstract class _$DisplayNameUpdate extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
