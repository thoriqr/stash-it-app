// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrich_saved_item_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The re-read mutation: **one synchronous `POST` per explicit user action**.
///
/// The state is a plain `bool` — "a re-read is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried POST is a
/// second page fetch and a second write. Publishing the outcome through the
/// app-wide feedback channel keeps the mutation out of the provider's error path.
/// `keepAlive` makes the notifier outlive the route, so a request already sent is
/// not abandoned when the screen is popped, and the duplicate guard survives a
/// rebuild.
///
/// **The in-flight flag is set synchronously before the first `await`.** Two taps
/// in the same frame therefore produce one request, not two.
///
/// **There is nothing to poll.** The endpoint is synchronous: its `200` is the
/// complete post-attempt item, whether extraction succeeded or failed. This
/// controller applies that answer directly and issues no follow-up read.

@ProviderFor(EnrichSavedItem)
final enrichSavedItemProvider = EnrichSavedItemProvider._();

/// The re-read mutation: **one synchronous `POST` per explicit user action**.
///
/// The state is a plain `bool` — "a re-read is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried POST is a
/// second page fetch and a second write. Publishing the outcome through the
/// app-wide feedback channel keeps the mutation out of the provider's error path.
/// `keepAlive` makes the notifier outlive the route, so a request already sent is
/// not abandoned when the screen is popped, and the duplicate guard survives a
/// rebuild.
///
/// **The in-flight flag is set synchronously before the first `await`.** Two taps
/// in the same frame therefore produce one request, not two.
///
/// **There is nothing to poll.** The endpoint is synchronous: its `200` is the
/// complete post-attempt item, whether extraction succeeded or failed. This
/// controller applies that answer directly and issues no follow-up read.
final class EnrichSavedItemProvider
    extends $NotifierProvider<EnrichSavedItem, bool> {
  /// The re-read mutation: **one synchronous `POST` per explicit user action**.
  ///
  /// The state is a plain `bool` — "a re-read is in flight" — not the outcome. A
  /// failed provider build would be retried by Riverpod, and a retried POST is a
  /// second page fetch and a second write. Publishing the outcome through the
  /// app-wide feedback channel keeps the mutation out of the provider's error path.
  /// `keepAlive` makes the notifier outlive the route, so a request already sent is
  /// not abandoned when the screen is popped, and the duplicate guard survives a
  /// rebuild.
  ///
  /// **The in-flight flag is set synchronously before the first `await`.** Two taps
  /// in the same frame therefore produce one request, not two.
  ///
  /// **There is nothing to poll.** The endpoint is synchronous: its `200` is the
  /// complete post-attempt item, whether extraction succeeded or failed. This
  /// controller applies that answer directly and issues no follow-up read.
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

String _$enrichSavedItemHash() => r'29801a2894e129b85940627db75481eb7d89aeaa';

/// The re-read mutation: **one synchronous `POST` per explicit user action**.
///
/// The state is a plain `bool` — "a re-read is in flight" — not the outcome. A
/// failed provider build would be retried by Riverpod, and a retried POST is a
/// second page fetch and a second write. Publishing the outcome through the
/// app-wide feedback channel keeps the mutation out of the provider's error path.
/// `keepAlive` makes the notifier outlive the route, so a request already sent is
/// not abandoned when the screen is popped, and the duplicate guard survives a
/// rebuild.
///
/// **The in-flight flag is set synchronously before the first `await`.** Two taps
/// in the same frame therefore produce one request, not two.
///
/// **There is nothing to poll.** The endpoint is synchronous: its `200` is the
/// complete post-attempt item, whether extraction succeeded or failed. This
/// controller applies that answer directly and issues no follow-up read.

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
