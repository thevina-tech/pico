// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_league_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller managing Private League creation and joining workflows.

@ProviderFor(PrivateLeagueController)
final privateLeagueControllerProvider = PrivateLeagueControllerProvider._();

/// Controller managing Private League creation and joining workflows.
final class PrivateLeagueControllerProvider
    extends
        $NotifierProvider<PrivateLeagueController, AsyncValue<PrivateLeague?>> {
  /// Controller managing Private League creation and joining workflows.
  PrivateLeagueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privateLeagueControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privateLeagueControllerHash();

  @$internal
  @override
  PrivateLeagueController create() => PrivateLeagueController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<PrivateLeague?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<PrivateLeague?>>(value),
    );
  }
}

String _$privateLeagueControllerHash() =>
    r'1eb5af2da8c45a3d046e46394a54efd6e225091a';

/// Controller managing Private League creation and joining workflows.

abstract class _$PrivateLeagueController
    extends $Notifier<AsyncValue<PrivateLeague?>> {
  AsyncValue<PrivateLeague?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PrivateLeague?>, AsyncValue<PrivateLeague?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PrivateLeague?>,
                AsyncValue<PrivateLeague?>
              >,
              AsyncValue<PrivateLeague?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
