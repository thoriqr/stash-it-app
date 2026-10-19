// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's one feedback channel: what is showing, if anything.
///
/// A plain notifier, not an `AsyncNotifier` — publishing is a synchronous value
/// assignment, so nothing here can fail and Riverpod's automatic retry has
/// nothing to act on. `keepAlive` because feedback is app-wide and must outlive
/// the route that raised it.
///
/// Deliberately free of any feature concept. A caller decides what to say and
/// hands over an [AppFeedback]; this type only decides what is on screen.

@ProviderFor(Feedback)
final feedbackProvider = FeedbackProvider._();

/// The app's one feedback channel: what is showing, if anything.
///
/// A plain notifier, not an `AsyncNotifier` — publishing is a synchronous value
/// assignment, so nothing here can fail and Riverpod's automatic retry has
/// nothing to act on. `keepAlive` because feedback is app-wide and must outlive
/// the route that raised it.
///
/// Deliberately free of any feature concept. A caller decides what to say and
/// hands over an [AppFeedback]; this type only decides what is on screen.
final class FeedbackProvider extends $NotifierProvider<Feedback, AppFeedback?> {
  /// The app's one feedback channel: what is showing, if anything.
  ///
  /// A plain notifier, not an `AsyncNotifier` — publishing is a synchronous value
  /// assignment, so nothing here can fail and Riverpod's automatic retry has
  /// nothing to act on. `keepAlive` because feedback is app-wide and must outlive
  /// the route that raised it.
  ///
  /// Deliberately free of any feature concept. A caller decides what to say and
  /// hands over an [AppFeedback]; this type only decides what is on screen.
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

/// The app's one feedback channel: what is showing, if anything.
///
/// A plain notifier, not an `AsyncNotifier` — publishing is a synchronous value
/// assignment, so nothing here can fail and Riverpod's automatic retry has
/// nothing to act on. `keepAlive` because feedback is app-wide and must outlive
/// the route that raised it.
///
/// Deliberately free of any feature concept. A caller decides what to say and
/// hands over an [AppFeedback]; this type only decides what is on screen.

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
