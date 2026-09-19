// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Production-grade Riverpod controller managing match state and predictions.

@ProviderFor(MatchesController)
final matchesControllerProvider = MatchesControllerProvider._();

/// Production-grade Riverpod controller managing match state and predictions.
final class MatchesControllerProvider
    extends $AsyncNotifierProvider<MatchesController, MatchesState> {
  /// Production-grade Riverpod controller managing match state and predictions.
  MatchesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchesControllerHash();

  @$internal
  @override
  MatchesController create() => MatchesController();
}

String _$matchesControllerHash() => r'bd70c6e769ea6bec673487dd2ebf5bc0e3f8f0c0';

/// Production-grade Riverpod controller managing match state and predictions.

abstract class _$MatchesController extends $AsyncNotifier<MatchesState> {
  FutureOr<MatchesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MatchesState>, MatchesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MatchesState>, MatchesState>,
              AsyncValue<MatchesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
