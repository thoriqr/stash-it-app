// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_urls_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device-local fallback list.
///
/// **Not user-scoped.** This provider deliberately depends on no session or
/// account provider and is not cleared by `SessionBoundary`: the entries belong
/// to the installation, not to a signed-in user.
///
/// The two mutations below are local reconciliation only. They never call the
/// API, never require a session, and never change the list's ownership.

@ProviderFor(PendingUrls)
final pendingUrlsProvider = PendingUrlsProvider._();

/// The device-local fallback list.
///
/// **Not user-scoped.** This provider deliberately depends on no session or
/// account provider and is not cleared by `SessionBoundary`: the entries belong
/// to the installation, not to a signed-in user.
///
/// The two mutations below are local reconciliation only. They never call the
/// API, never require a session, and never change the list's ownership.
final class PendingUrlsProvider
    extends $AsyncNotifierProvider<PendingUrls, PendingUrlSnapshot> {
  /// The device-local fallback list.
  ///
  /// **Not user-scoped.** This provider deliberately depends on no session or
  /// account provider and is not cleared by `SessionBoundary`: the entries belong
  /// to the installation, not to a signed-in user.
  ///
  /// The two mutations below are local reconciliation only. They never call the
  /// API, never require a session, and never change the list's ownership.
  PendingUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingUrlsHash();

  @$internal
  @override
  PendingUrls create() => PendingUrls();
}

String _$pendingUrlsHash() => r'1cda85ed1107f8cd4e4acafbcb988468cf062460';

/// The device-local fallback list.
///
/// **Not user-scoped.** This provider deliberately depends on no session or
/// account provider and is not cleared by `SessionBoundary`: the entries belong
/// to the installation, not to a signed-in user.
///
/// The two mutations below are local reconciliation only. They never call the
/// API, never require a session, and never change the list's ownership.

abstract class _$PendingUrls extends $AsyncNotifier<PendingUrlSnapshot> {
  FutureOr<PendingUrlSnapshot> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PendingUrlSnapshot>, PendingUrlSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PendingUrlSnapshot>, PendingUrlSnapshot>,
              AsyncValue<PendingUrlSnapshot>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
