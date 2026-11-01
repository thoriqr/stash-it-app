// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide feedback state.
///
/// Keeps the latest notice available independently of the route that
/// triggered it. Callers provide the feedback content; this controller
/// manages only its visibility.

@ProviderFor(Feedback)
final feedbackProvider = FeedbackProvider._();

/// App-wide feedback state.
///
/// Keeps the latest notice available independently of the route that
/// triggered it. Callers provide the feedback content; this controller
/// manages only its visibility.
final class FeedbackProvider extends $NotifierProvider<Feedback, AppFeedback?> {
  /// App-wide feedback state.
  ///
  /// Keeps the latest notice available independently of the route that
  /// triggered it. Callers provide the feedback content; this controller
  /// manages only its visibility.
  FeedbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackHash();

  @$internal
  @override
  Feedback create() => Feedback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppFeedback? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppFeedback?>(value),
    );
  }
}

String _$feedbackHash() => r'53c5b129b9403e892fdcef821661b8cc121ee35c';

/// App-wide feedback state.
///
/// Keeps the latest notice available independently of the route that
/// triggered it. Callers provide the feedback content; this controller
/// manages only its visibility.

abstract class _$Feedback extends $Notifier<AppFeedback?> {
  AppFeedback? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppFeedback?, AppFeedback?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppFeedback?, AppFeedback?>,
              AppFeedback?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
