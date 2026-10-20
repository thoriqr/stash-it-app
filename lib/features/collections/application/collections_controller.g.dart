// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Collections list controller with cursor pagination.
///
/// Mirrors SavedItemsController pattern.

@ProviderFor(Collections)
final collectionsProvider = CollectionsProvider._();

/// Collections list controller with cursor pagination.
///
/// Mirrors SavedItemsController pattern.
final class CollectionsProvider
    extends $AsyncNotifierProvider<Collections, CollectionsState> {
  /// Collections list controller with cursor pagination.
  ///
  /// Mirrors SavedItemsController pattern.
  CollectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'collectionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionsHash();

  @$internal
  @override
  Collections create() => Collections();
}

String _$collectionsHash() => r'7715a12b11cb0aa14878763ed621d860e5760e8f';

/// Collections list controller with cursor pagination.
///
/// Mirrors SavedItemsController pattern.

abstract class _$Collections extends $AsyncNotifier<CollectionsState> {
  FutureOr<CollectionsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CollectionsState>, CollectionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CollectionsState>, CollectionsState>,
              AsyncValue<CollectionsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
