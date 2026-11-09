// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_mutation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One note save or delete at a time.
///
/// The state is a plain `bool` set synchronously before the first `await`, so a
/// double tap cannot issue two writes. It is keep-alive so a request already
/// sent is not abandoned when the editor route closes.
///
/// Feedback is published only by this controller, through the app-wide notice
/// system. On a confirmed mutation, the loaded detail and any loaded listings
/// are patched in place rather than refetched.

@ProviderFor(NoteMutation)
final noteMutationProvider = NoteMutationProvider._();

/// One note save or delete at a time.
///
/// The state is a plain `bool` set synchronously before the first `await`, so a
/// double tap cannot issue two writes. It is keep-alive so a request already
/// sent is not abandoned when the editor route closes.
///
/// Feedback is published only by this controller, through the app-wide notice
/// system. On a confirmed mutation, the loaded detail and any loaded listings
/// are patched in place rather than refetched.
final class NoteMutationProvider extends $NotifierProvider<NoteMutation, bool> {
  /// One note save or delete at a time.
  ///
  /// The state is a plain `bool` set synchronously before the first `await`, so a
  /// double tap cannot issue two writes. It is keep-alive so a request already
  /// sent is not abandoned when the editor route closes.
  ///
  /// Feedback is published only by this controller, through the app-wide notice
  /// system. On a confirmed mutation, the loaded detail and any loaded listings
  /// are patched in place rather than refetched.
  NoteMutationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteMutationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteMutationHash();

  @$internal
  @override
  NoteMutation create() => NoteMutation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$noteMutationHash() => r'9717a3d1ad90ae45d7f6fbdf09c127dc9b599b5c';

/// One note save or delete at a time.
///
/// The state is a plain `bool` set synchronously before the first `await`, so a
/// double tap cannot issue two writes. It is keep-alive so a request already
/// sent is not abandoned when the editor route closes.
///
/// Feedback is published only by this controller, through the app-wide notice
/// system. On a confirmed mutation, the loaded detail and any loaded listings
/// are patched in place rather than refetched.

abstract class _$NoteMutation extends $Notifier<bool> {
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
