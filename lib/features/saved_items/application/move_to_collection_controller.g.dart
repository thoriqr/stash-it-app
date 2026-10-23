// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_to_collection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Move to collection mutation: **one `PUT` per explicit user action**.
///
/// The state is a plain `bool` — "a move is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried PUT is a
/// second write. Publishing outcomes through the app-wide feedback channel keeps
/// the mutation out of the provider's error path. `keepAlive` makes the notifier
/// outlive the sheet, so a request already sent is not abandoned when the modal
/// closes, and the duplicate guard survives a rebuild of the sheet.
///
/// **The in-flight flag is set synchronously before the first await.** Two taps
/// in the same frame therefore produce one request, not two.

@ProviderFor(MoveToCollection)
final moveToCollectionProvider = MoveToCollectionProvider._();

/// The Move to collection mutation: **one `PUT` per explicit user action**.
///
/// The state is a plain `bool` — "a move is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried PUT is a
/// second write. Publishing outcomes through the app-wide feedback channel keeps
/// the mutation out of the provider's error path. `keepAlive` makes the notifier
/// outlive the sheet, so a request already sent is not abandoned when the modal
/// closes, and the duplicate guard survives a rebuild of the sheet.
///
/// **The in-flight flag is set synchronously before the first await.** Two taps
/// in the same frame therefore produce one request, not two.
final class MoveToCollectionProvider
    extends $NotifierProvider<MoveToCollection, bool> {
  /// The Move to collection mutation: **one `PUT` per explicit user action**.
  ///
  /// The state is a plain `bool` — "a move is in flight" — not the outcome. A
  /// failed provider build would be retried by Riverpod, and a retried PUT is a
  /// second write. Publishing outcomes through the app-wide feedback channel keeps
  /// the mutation out of the provider's error path. `keepAlive` makes the notifier
  /// outlive the sheet, so a request already sent is not abandoned when the modal
  /// closes, and the duplicate guard survives a rebuild of the sheet.
  ///
  /// **The in-flight flag is set synchronously before the first await.** Two taps
  /// in the same frame therefore produce one request, not two.
  MoveToCollectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moveToCollectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moveToCollectionHash();

  @$internal
  @override
  MoveToCollection create() => MoveToCollection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$moveToCollectionHash() => r'e1ef8c6ccb4e19b90824f1f69d408f5ac75d7bc9';

/// The Move to collection mutation: **one `PUT` per explicit user action**.
///
/// The state is a plain `bool` — "a move is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried PUT is a
/// second write. Publishing outcomes through the app-wide feedback channel keeps
/// the mutation out of the provider's error path. `keepAlive` makes the notifier
/// outlive the sheet, so a request already sent is not abandoned when the modal
/// closes, and the duplicate guard survives a rebuild of the sheet.
///
/// **The in-flight flag is set synchronously before the first await.** Two taps
/// in the same frame therefore produce one request, not two.

abstract class _$MoveToCollection extends $Notifier<bool> {
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
