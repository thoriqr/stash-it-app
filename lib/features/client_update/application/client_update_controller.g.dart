// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads the release policy at launch and on resume, and when the user asks.
///
/// Every failure is fail-open: the check never blocks the app and an automatic
/// check never shows an error. A manual check publishes a short notice because
/// the user explicitly asked for a result.

@ProviderFor(ClientUpdate)
final clientUpdateProvider = ClientUpdateProvider._();

/// Reads the release policy at launch and on resume, and when the user asks.
///
/// Every failure is fail-open: the check never blocks the app and an automatic
/// check never shows an error. A manual check publishes a short notice because
/// the user explicitly asked for a result.
final class ClientUpdateProvider
    extends $NotifierProvider<ClientUpdate, ClientUpdateState> {
  /// Reads the release policy at launch and on resume, and when the user asks.
  ///
  /// Every failure is fail-open: the check never blocks the app and an automatic
  /// check never shows an error. A manual check publishes a short notice because
  /// the user explicitly asked for a result.
  ClientUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientUpdateHash();

  @$internal
  @override
  ClientUpdate create() => ClientUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientUpdateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientUpdateState>(value),
    );
  }
}

String _$clientUpdateHash() => r'a4cb9913b9fb7152f69aae2a77a612425306a916';

/// Reads the release policy at launch and on resume, and when the user asks.
///
/// Every failure is fail-open: the check never blocks the app and an automatic
/// check never shows an error. A manual check publishes a short notice because
/// the user explicitly asked for a result.

abstract class _$ClientUpdate extends $Notifier<ClientUpdateState> {
  ClientUpdateState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ClientUpdateState, ClientUpdateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientUpdateState, ClientUpdateState>,
              ClientUpdateState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
