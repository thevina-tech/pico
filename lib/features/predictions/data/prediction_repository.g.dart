// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing the active [PredictionRepository].

@ProviderFor(predictionRepository)
final predictionRepositoryProvider = PredictionRepositoryProvider._();

/// Riverpod provider exposing the active [PredictionRepository].

final class PredictionRepositoryProvider
    extends
        $FunctionalProvider<
          PredictionRepository,
          PredictionRepository,
          PredictionRepository
        >
    with $Provider<PredictionRepository> {
  /// Riverpod provider exposing the active [PredictionRepository].
  PredictionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'predictionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$predictionRepositoryHash();

  @$internal
  @override
  $ProviderElement<PredictionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PredictionRepository create(Ref ref) {
    return predictionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PredictionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PredictionRepository>(value),
    );
  }
}

String _$predictionRepositoryHash() =>
    r'dd84fab7dc6ca818a3d7ab4c30cc96ce1818df66';
