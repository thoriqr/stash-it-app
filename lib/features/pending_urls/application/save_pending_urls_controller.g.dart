// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_pending_urls_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The explicit, user-initiated bulk save of the device-local URL list.
///
/// ## One run at a time, one request at a time
///
/// [saveAll] walks the snapshot it was given in order and awaits each
/// `POST /saved-items` before starting the next. It never issues concurrent
/// requests and never retries a URL. A second call while a run is in progress
/// returns immediately; the screen also disables its button while [isRunning].
///
/// ## Why a sync [Notifier]
///
/// The outcome is not provider build state. Publishing a failed save as
/// `AsyncError` would let Riverpod retry the build, and a retried POST is a
/// second insert — the backend has no idempotency key. The run reports through
/// its own state instead, exactly as `SaveUrl` does for a single save.
///
/// ## Reuse
///
/// The repository is `SavedItemsRepository.create`, so this path shares the
/// existing `appDio` + `AuthInterceptor`, request/response DTOs, and typed
/// [ApiFailure] mapping. No API client or batch endpoint is introduced.
///
/// ## What is kept
///
/// An entry is removed only after a confirmed create, and only by its exact URL
/// (`PendingUrls.removeConfirmed`). A rejected entry stays; an ambiguous outcome
/// stays and is marked uncertain without refreshing its seven-day timestamp.
/// Confirmed entries are never submitted again by a later run because they are
/// gone from the snapshot that run reads.
///
/// ## `keepAlive`
///
/// The run outlives the screen that started it. The user can switch destination
/// while the requests are in flight; the notifier must still reconcile the local
/// list and leave the summary available when the screen is opened again.

@ProviderFor(SavePendingUrls)
final savePendingUrlsProvider = SavePendingUrlsProvider._();

/// The explicit, user-initiated bulk save of the device-local URL list.
///
/// ## One run at a time, one request at a time
///
/// [saveAll] walks the snapshot it was given in order and awaits each
/// `POST /saved-items` before starting the next. It never issues concurrent
/// requests and never retries a URL. A second call while a run is in progress
/// returns immediately; the screen also disables its button while [isRunning].
///
/// ## Why a sync [Notifier]
///
/// The outcome is not provider build state. Publishing a failed save as
/// `AsyncError` would let Riverpod retry the build, and a retried POST is a
/// second insert — the backend has no idempotency key. The run reports through
/// its own state instead, exactly as `SaveUrl` does for a single save.
///
/// ## Reuse
///
/// The repository is `SavedItemsRepository.create`, so this path shares the
/// existing `appDio` + `AuthInterceptor`, request/response DTOs, and typed
/// [ApiFailure] mapping. No API client or batch endpoint is introduced.
///
/// ## What is kept
///
/// An entry is removed only after a confirmed create, and only by its exact URL
/// (`PendingUrls.removeConfirmed`). A rejected entry stays; an ambiguous outcome
/// stays and is marked uncertain without refreshing its seven-day timestamp.
/// Confirmed entries are never submitted again by a later run because they are
/// gone from the snapshot that run reads.
///
/// ## `keepAlive`
///
/// The run outlives the screen that started it. The user can switch destination
/// while the requests are in flight; the notifier must still reconcile the local
/// list and leave the summary available when the screen is opened again.
final class SavePendingUrlsProvider
    extends $NotifierProvider<SavePendingUrls, PendingUrlSaveState> {
  /// The explicit, user-initiated bulk save of the device-local URL list.
  ///
  /// ## One run at a time, one request at a time
  ///
  /// [saveAll] walks the snapshot it was given in order and awaits each
  /// `POST /saved-items` before starting the next. It never issues concurrent
  /// requests and never retries a URL. A second call while a run is in progress
  /// returns immediately; the screen also disables its button while [isRunning].
  ///
  /// ## Why a sync [Notifier]
  ///
  /// The outcome is not provider build state. Publishing a failed save as
  /// `AsyncError` would let Riverpod retry the build, and a retried POST is a
  /// second insert — the backend has no idempotency key. The run reports through
  /// its own state instead, exactly as `SaveUrl` does for a single save.
  ///
  /// ## Reuse
  ///
  /// The repository is `SavedItemsRepository.create`, so this path shares the
  /// existing `appDio` + `AuthInterceptor`, request/response DTOs, and typed
  /// [ApiFailure] mapping. No API client or batch endpoint is introduced.
  ///
  /// ## What is kept
  ///
  /// An entry is removed only after a confirmed create, and only by its exact URL
  /// (`PendingUrls.removeConfirmed`). A rejected entry stays; an ambiguous outcome
  /// stays and is marked uncertain without refreshing its seven-day timestamp.
  /// Confirmed entries are never submitted again by a later run because they are
  /// gone from the snapshot that run reads.
  ///
  /// ## `keepAlive`
  ///
  /// The run outlives the screen that started it. The user can switch destination
  /// while the requests are in flight; the notifier must still reconcile the local
  /// list and leave the summary available when the screen is opened again.
  SavePendingUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savePendingUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savePendingUrlsHash();

  @$internal
  @override
  SavePendingUrls create() => SavePendingUrls();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingUrlSaveState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingUrlSaveState>(value),
    );
  }
}

String _$savePendingUrlsHash() => r'33ccd434d2ed47825dc8778ce77b6c619c5eb25b';

/// The explicit, user-initiated bulk save of the device-local URL list.
///
/// ## One run at a time, one request at a time
///
/// [saveAll] walks the snapshot it was given in order and awaits each
/// `POST /saved-items` before starting the next. It never issues concurrent
/// requests and never retries a URL. A second call while a run is in progress
/// returns immediately; the screen also disables its button while [isRunning].
///
/// ## Why a sync [Notifier]
///
/// The outcome is not provider build state. Publishing a failed save as
/// `AsyncError` would let Riverpod retry the build, and a retried POST is a
/// second insert — the backend has no idempotency key. The run reports through
/// its own state instead, exactly as `SaveUrl` does for a single save.
///
/// ## Reuse
///
/// The repository is `SavedItemsRepository.create`, so this path shares the
/// existing `appDio` + `AuthInterceptor`, request/response DTOs, and typed
/// [ApiFailure] mapping. No API client or batch endpoint is introduced.
///
/// ## What is kept
///
/// An entry is removed only after a confirmed create, and only by its exact URL
/// (`PendingUrls.removeConfirmed`). A rejected entry stays; an ambiguous outcome
/// stays and is marked uncertain without refreshing its seven-day timestamp.
/// Confirmed entries are never submitted again by a later run because they are
/// gone from the snapshot that run reads.
///
/// ## `keepAlive`
///
/// The run outlives the screen that started it. The user can switch destination
/// while the requests are in flight; the notifier must still reconcile the local
/// list and leave the summary available when the screen is opened again.

abstract class _$SavePendingUrls extends $Notifier<PendingUrlSaveState> {
  PendingUrlSaveState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PendingUrlSaveState, PendingUrlSaveState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PendingUrlSaveState, PendingUrlSaveState>,
              PendingUrlSaveState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
