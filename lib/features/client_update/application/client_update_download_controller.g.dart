// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_update_download_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Downloads the current release, verifies its checksum, and hands it to the
/// platform installer.
///
/// The controller never installs silently. Android opens the package installer
/// and Windows opens the ZIP; the user finishes the operation.

@ProviderFor(ClientUpdateDownload)
final clientUpdateDownloadProvider = ClientUpdateDownloadProvider._();

/// Downloads the current release, verifies its checksum, and hands it to the
/// platform installer.
///
/// The controller never installs silently. Android opens the package installer
/// and Windows opens the ZIP; the user finishes the operation.
final class ClientUpdateDownloadProvider
    extends $NotifierProvider<ClientUpdateDownload, ClientUpdateDownloadState> {
  /// Downloads the current release, verifies its checksum, and hands it to the
  /// platform installer.
  ///
  /// The controller never installs silently. Android opens the package installer
  /// and Windows opens the ZIP; the user finishes the operation.
  ClientUpdateDownloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientUpdateDownloadProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientUpdateDownloadHash();

  @$internal
  @override
  ClientUpdateDownload create() => ClientUpdateDownload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientUpdateDownloadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientUpdateDownloadState>(value),
    );
  }
}

String _$clientUpdateDownloadHash() =>
    r'452a7e30e8e7e376fe61a98c6615256f64f6d0a3';

/// Downloads the current release, verifies its checksum, and hands it to the
/// platform installer.
///
/// The controller never installs silently. Android opens the package installer
/// and Windows opens the ZIP; the user finishes the operation.

abstract class _$ClientUpdateDownload
    extends $Notifier<ClientUpdateDownloadState> {
  ClientUpdateDownloadState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ClientUpdateDownloadState, ClientUpdateDownloadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientUpdateDownloadState, ClientUpdateDownloadState>,
              ClientUpdateDownloadState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
