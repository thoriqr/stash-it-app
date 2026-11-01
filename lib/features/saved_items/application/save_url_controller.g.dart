// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_url_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Handles one `POST /saved-items` request per explicit user action.
///
/// ## State
///
/// The boolean state indicates only whether a save is in flight. Outcomes are
/// published through the app-wide feedback channel rather than provider errors,
/// preventing a failed mutation from being retried automatically by Riverpod.
///
/// ## Lifecycle
///
/// The notifier stays alive while a save is in progress, even if the user leaves
/// the screen. This allows the operation to publish its outcome and refresh the
/// listing after the screen is closed.
///
/// ## Request behavior
///
/// Each submission sends at most one request. There is no automatic retry or
/// resubmission after an uncertain outcome. A second call while a request is in
/// flight is ignored rather than queued.
///
/// The authentication interceptor may replay a request after a `401` when
/// session renewal succeeds. That replay follows a request rejected before the
/// save operation ran; it is not a retry of a completed save.
///
/// [build] performs no I/O and cannot fail, so no provider retry override is
/// needed.

@ProviderFor(SaveUrl)
final saveUrlProvider = SaveUrlProvider._();

/// Handles one `POST /saved-items` request per explicit user action.
///
/// ## State
///
/// The boolean state indicates only whether a save is in flight. Outcomes are
/// published through the app-wide feedback channel rather than provider errors,
/// preventing a failed mutation from being retried automatically by Riverpod.
///
/// ## Lifecycle
///
/// The notifier stays alive while a save is in progress, even if the user leaves
/// the screen. This allows the operation to publish its outcome and refresh the
/// listing after the screen is closed.
///
/// ## Request behavior
///
/// Each submission sends at most one request. There is no automatic retry or
/// resubmission after an uncertain outcome. A second call while a request is in
/// flight is ignored rather than queued.
///
/// The authentication interceptor may replay a request after a `401` when
/// session renewal succeeds. That replay follows a request rejected before the
/// save operation ran; it is not a retry of a completed save.
///
/// [build] performs no I/O and cannot fail, so no provider retry override is
/// needed.
final class SaveUrlProvider extends $NotifierProvider<SaveUrl, bool> {
  /// Handles one `POST /saved-items` request per explicit user action.
  ///
  /// ## State
  ///
  /// The boolean state indicates only whether a save is in flight. Outcomes are
  /// published through the app-wide feedback channel rather than provider errors,
  /// preventing a failed mutation from being retried automatically by Riverpod.
  ///
  /// ## Lifecycle
  ///
  /// The notifier stays alive while a save is in progress, even if the user leaves
  /// the screen. This allows the operation to publish its outcome and refresh the
  /// listing after the screen is closed.
  ///
  /// ## Request behavior
  ///
  /// Each submission sends at most one request. There is no automatic retry or
  /// resubmission after an uncertain outcome. A second call while a request is in
  /// flight is ignored rather than queued.
  ///
  /// The authentication interceptor may replay a request after a `401` when
  /// session renewal succeeds. That replay follows a request rejected before the
  /// save operation ran; it is not a retry of a completed save.
  ///
  /// [build] performs no I/O and cannot fail, so no provider retry override is
  /// needed.
  SaveUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveUrlHash();

  @$internal
  @override
  SaveUrl create() => SaveUrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$saveUrlHash() => r'58f633e1b02f70a4054734d4a7c0956c50e713c3';

/// Handles one `POST /saved-items` request per explicit user action.
///
/// ## State
///
/// The boolean state indicates only whether a save is in flight. Outcomes are
/// published through the app-wide feedback channel rather than provider errors,
/// preventing a failed mutation from being retried automatically by Riverpod.
///
/// ## Lifecycle
///
/// The notifier stays alive while a save is in progress, even if the user leaves
/// the screen. This allows the operation to publish its outcome and refresh the
/// listing after the screen is closed.
///
/// ## Request behavior
///
/// Each submission sends at most one request. There is no automatic retry or
/// resubmission after an uncertain outcome. A second call while a request is in
/// flight is ignored rather than queued.
///
/// The authentication interceptor may replay a request after a `401` when
/// session renewal succeeds. That replay follows a request rejected before the
/// save operation ran; it is not a retry of a completed save.
///
/// [build] performs no I/O and cannot fail, so no provider retry override is
/// needed.

abstract class _$SaveUrl extends $Notifier<bool> {
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
