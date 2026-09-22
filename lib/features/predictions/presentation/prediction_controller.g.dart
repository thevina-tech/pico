// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller managing user predictions across Home and Matches feeds.

@ProviderFor(PredictionController)
final predictionControllerProvider = PredictionControllerProvider._();

/// Riverpod controller managing user predictions across Home and Matches feeds.
final class PredictionControllerProvider
    extends
        $AsyncNotifierProvider<PredictionController, Map<String, Prediction>> {
  /// Riverpod controller managing user predictions across Home and Matches feeds.
  PredictionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'predictionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$predictionControllerHash();

  @$internal
  @override
  PredictionController create() => PredictionController();
}

String _$predictionControllerHash() =>
    r'5ce032c7eab59fef233dc77207f09a3166eba6b4';

/// Riverpod controller managing user predictions across Home and Matches feeds.

abstract class _$PredictionController
    extends $AsyncNotifier<Map<String, Prediction>> {
  FutureOr<Map<String, Prediction>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, Prediction>>,
              Map<String, Prediction>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, Prediction>>,
                Map<String, Prediction>
              >,
              AsyncValue<Map<String, Prediction>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
