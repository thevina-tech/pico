// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Production-grade Riverpod controller managing match state and predictions.
/// Dynamically updates sorting pills and matches based on the user's enrolled tournaments.

@ProviderFor(MatchesController)
final matchesControllerProvider = MatchesControllerProvider._();

/// Production-grade Riverpod controller managing match state and predictions.
/// Dynamically updates sorting pills and matches based on the user's enrolled tournaments.
final class MatchesControllerProvider
    extends $AsyncNotifierProvider<MatchesController, MatchesState> {
  /// Production-grade Riverpod controller managing match state and predictions.
  /// Dynamically updates sorting pills and matches based on the user's enrolled tournaments.
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

String _$matchesControllerHash() => r'087c327e1e8df0eb261a686b87646f8d5575657a';

/// Production-grade Riverpod controller managing match state and predictions.
/// Dynamically updates sorting pills and matches based on the user's enrolled tournaments.

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
