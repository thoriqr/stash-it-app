// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrich_saved_item_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Handles one re-read request per explicit user action.
///
/// The state is a boolean indicating whether a request is in flight, not its
/// outcome. Keeping failures out of the provider's build path prevents Riverpod
/// from automatically retrying a write. Feedback is published separately.
///
/// The notifier stays alive while a request is running, even if the screen is
/// closed. The in-flight flag also prevents duplicate requests after rebuilds.
///
/// The flag is set synchronously before the first `await`, so multiple taps in
/// the same frame still produce only one request.
///
/// The endpoint returns the complete result of the attempt in its response.
/// No polling or follow-up read is needed.
///
/// For a host whose enrichment the server leaves to the client, the page is
/// read on this device first and the extracted metadata travels in the enrich
/// request. A failed read sends an empty metadata object, which records the
/// attempt as failed instead of leaving the item pending. Every other host
/// omits the field and keeps server-side extraction.

@ProviderFor(EnrichSavedItem)
final enrichSavedItemProvider = EnrichSavedItemProvider._();

/// Handles one re-read request per explicit user action.
///
/// The state is a boolean indicating whether a request is in flight, not its
/// outcome. Keeping failures out of the provider's build path prevents Riverpod
/// from automatically retrying a write. Feedback is published separately.
///
/// The notifier stays alive while a request is running, even if the screen is
/// closed. The in-flight flag also prevents duplicate requests after rebuilds.
///
/// The flag is set synchronously before the first `await`, so multiple taps in
/// the same frame still produce only one request.
///
/// The endpoint returns the complete result of the attempt in its response.
/// No polling or follow-up read is needed.
///
/// For a host whose enrichment the server leaves to the client, the page is
/// read on this device first and the extracted metadata travels in the enrich
/// request. A failed read sends an empty metadata object, which records the
/// attempt as failed instead of leaving the item pending. Every other host
/// omits the field and keeps server-side extraction.
final class EnrichSavedItemProvider
    extends $NotifierProvider<EnrichSavedItem, bool> {
  /// Handles one re-read request per explicit user action.
  ///
  /// The state is a boolean indicating whether a request is in flight, not its
  /// outcome. Keeping failures out of the provider's build path prevents Riverpod
  /// from automatically retrying a write. Feedback is published separately.
  ///
  /// The notifier stays alive while a request is running, even if the screen is
  /// closed. The in-flight flag also prevents duplicate requests after rebuilds.
  ///
  /// The flag is set synchronously before the first `await`, so multiple taps in
  /// the same frame still produce only one request.
  ///
  /// The endpoint returns the complete result of the attempt in its response.
  /// No polling or follow-up read is needed.
  ///
  /// For a host whose enrichment the server leaves to the client, the page is
  /// read on this device first and the extracted metadata travels in the enrich
  /// request. A failed read sends an empty metadata object, which records the
  /// attempt as failed instead of leaving the item pending. Every other host
  /// omits the field and keeps server-side extraction.
  EnrichSavedItemProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enrichSavedItemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enrichSavedItemHash();

  @$internal
  @override
  EnrichSavedItem create() => EnrichSavedItem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$enrichSavedItemHash() => r'1b16e52b059c8bb5ec8dc0305e299fcdb907074f';

/// Handles one re-read request per explicit user action.
///
/// The state is a boolean indicating whether a request is in flight, not its
/// outcome. Keeping failures out of the provider's build path prevents Riverpod
/// from automatically retrying a write. Feedback is published separately.
///
/// The notifier stays alive while a request is running, even if the screen is
/// closed. The in-flight flag also prevents duplicate requests after rebuilds.
///
/// The flag is set synchronously before the first `await`, so multiple taps in
/// the same frame still produce only one request.
///
/// The endpoint returns the complete result of the attempt in its response.
/// No polling or follow-up read is needed.
///
/// For a host whose enrichment the server leaves to the client, the page is
/// read on this device first and the extracted metadata travels in the enrich
/// request. A failed read sends an empty metadata object, which records the
/// attempt as failed instead of leaving the item pending. Every other host
/// omits the field and keeps server-side extraction.

abstract class _$EnrichSavedItem extends $Notifier<bool> {
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
