// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_url_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Save URL mutation: one `POST /saved-items` per explicit user action.
///
/// ## State is "a save is in flight", and that is all
///
/// The *outcome* of a save is deliberately not provider state. A failure
/// published as `AsyncError` would be retried by Riverpod (a failed build is
/// retried up to ten times with backoff unless the provider opts out), and a
/// retried POST is a second insert: the backend has no idempotency key and
/// duplicates are allowed (**D16**), so the duplicate would be silent and real.
/// Publishing the outcome through the app-wide feedback channel avoids the whole
/// question, keeps a failed save out of the widget's build, and matches how the
/// rest of the app reports transient outcomes.
///
/// `bool` is therefore the entire state, and value equality is built in.
///
/// ## `keepAlive`
///
/// A save outlives the screen that started it. The user may switch destination
/// while the POST is in flight; the notifier must still publish the outcome and
/// refresh the listing afterwards, and an auto-disposed notifier could do neither
/// (its `ref` is dead, so the state write would throw).
///
/// ## No retry, at any layer
///
/// The POST is issued **once per tap**. [submit] has no retry, no timer and no
/// "try again" path, and nothing here resubmits after an uncertain outcome
/// (**D15**, **D16**). The `AuthInterceptor`'s one replay is not a retry of this
/// mutation: it happens after a `401` that the bearer guard raised *before* the
/// handler ran, so the first attempt wrote nothing and the replayed request is
/// still the first one that can write.
///
/// A second call while one is in flight is declined rather than queued — see
/// [submit].
///
/// ## No `retry:` override
///
/// [build] is `=> false`: it performs no I/O and cannot fail, so there is no
/// failure for Riverpod's retry policy to see. `SavedItems` needs the override
/// because its *build* reads the network; this one has nothing to guard.

@ProviderFor(SaveUrl)
final saveUrlProvider = SaveUrlProvider._();

/// The Save URL mutation: one `POST /saved-items` per explicit user action.
///
/// ## State is "a save is in flight", and that is all
///
/// The *outcome* of a save is deliberately not provider state. A failure
/// published as `AsyncError` would be retried by Riverpod (a failed build is
/// retried up to ten times with backoff unless the provider opts out), and a
/// retried POST is a second insert: the backend has no idempotency key and
/// duplicates are allowed (**D16**), so the duplicate would be silent and real.
/// Publishing the outcome through the app-wide feedback channel avoids the whole
/// question, keeps a failed save out of the widget's build, and matches how the
/// rest of the app reports transient outcomes.
///
/// `bool` is therefore the entire state, and value equality is built in.
///
/// ## `keepAlive`
///
/// A save outlives the screen that started it. The user may switch destination
/// while the POST is in flight; the notifier must still publish the outcome and
/// refresh the listing afterwards, and an auto-disposed notifier could do neither
/// (its `ref` is dead, so the state write would throw).
///
/// ## No retry, at any layer
///
/// The POST is issued **once per tap**. [submit] has no retry, no timer and no
/// "try again" path, and nothing here resubmits after an uncertain outcome
/// (**D15**, **D16**). The `AuthInterceptor`'s one replay is not a retry of this
/// mutation: it happens after a `401` that the bearer guard raised *before* the
/// handler ran, so the first attempt wrote nothing and the replayed request is
/// still the first one that can write.
///
/// A second call while one is in flight is declined rather than queued — see
/// [submit].
///
/// ## No `retry:` override
///
/// [build] is `=> false`: it performs no I/O and cannot fail, so there is no
/// failure for Riverpod's retry policy to see. `SavedItems` needs the override
/// because its *build* reads the network; this one has nothing to guard.
final class SaveUrlProvider extends $NotifierProvider<SaveUrl, bool> {
  /// The Save URL mutation: one `POST /saved-items` per explicit user action.
  ///
  /// ## State is "a save is in flight", and that is all
  ///
  /// The *outcome* of a save is deliberately not provider state. A failure
  /// published as `AsyncError` would be retried by Riverpod (a failed build is
  /// retried up to ten times with backoff unless the provider opts out), and a
  /// retried POST is a second insert: the backend has no idempotency key and
  /// duplicates are allowed (**D16**), so the duplicate would be silent and real.
  /// Publishing the outcome through the app-wide feedback channel avoids the whole
  /// question, keeps a failed save out of the widget's build, and matches how the
  /// rest of the app reports transient outcomes.
  ///
  /// `bool` is therefore the entire state, and value equality is built in.
  ///
  /// ## `keepAlive`
  ///
  /// A save outlives the screen that started it. The user may switch destination
  /// while the POST is in flight; the notifier must still publish the outcome and
  /// refresh the listing afterwards, and an auto-disposed notifier could do neither
  /// (its `ref` is dead, so the state write would throw).
  ///
  /// ## No retry, at any layer
  ///
  /// The POST is issued **once per tap**. [submit] has no retry, no timer and no
  /// "try again" path, and nothing here resubmits after an uncertain outcome
  /// (**D15**, **D16**). The `AuthInterceptor`'s one replay is not a retry of this
  /// mutation: it happens after a `401` that the bearer guard raised *before* the
  /// handler ran, so the first attempt wrote nothing and the replayed request is
  /// still the first one that can write.
  ///
  /// A second call while one is in flight is declined rather than queued — see
  /// [submit].
  ///
  /// ## No `retry:` override
  ///
  /// [build] is `=> false`: it performs no I/O and cannot fail, so there is no
  /// failure for Riverpod's retry policy to see. `SavedItems` needs the override
  /// because its *build* reads the network; this one has nothing to guard.
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

/// The Save URL mutation: one `POST /saved-items` per explicit user action.
///
/// ## State is "a save is in flight", and that is all
///
/// The *outcome* of a save is deliberately not provider state. A failure
/// published as `AsyncError` would be retried by Riverpod (a failed build is
/// retried up to ten times with backoff unless the provider opts out), and a
/// retried POST is a second insert: the backend has no idempotency key and
/// duplicates are allowed (**D16**), so the duplicate would be silent and real.
/// Publishing the outcome through the app-wide feedback channel avoids the whole
/// question, keeps a failed save out of the widget's build, and matches how the
/// rest of the app reports transient outcomes.
///
/// `bool` is therefore the entire state, and value equality is built in.
///
/// ## `keepAlive`
///
/// A save outlives the screen that started it. The user may switch destination
/// while the POST is in flight; the notifier must still publish the outcome and
/// refresh the listing afterwards, and an auto-disposed notifier could do neither
/// (its `ref` is dead, so the state write would throw).
///
/// ## No retry, at any layer
///
/// The POST is issued **once per tap**. [submit] has no retry, no timer and no
/// "try again" path, and nothing here resubmits after an uncertain outcome
/// (**D15**, **D16**). The `AuthInterceptor`'s one replay is not a retry of this
/// mutation: it happens after a `401` that the bearer guard raised *before* the
/// handler ran, so the first attempt wrote nothing and the replayed request is
/// still the first one that can write.
///
/// A second call while one is in flight is declined rather than queued — see
/// [submit].
///
/// ## No `retry:` override
///
/// [build] is `=> false`: it performs no I/O and cannot fail, so there is no
/// failure for Riverpod's retry policy to see. `SavedItems` needs the override
/// because its *build* reads the network; this one has nothing to guard.

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
