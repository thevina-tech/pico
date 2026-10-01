// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournaments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller managing the Tournaments tab selection and data refreshes.

@ProviderFor(TournamentsController)
final tournamentsControllerProvider = TournamentsControllerProvider._();

/// Controller managing the Tournaments tab selection and data refreshes.
final class TournamentsControllerProvider
    extends $NotifierProvider<TournamentsController, TournamentsState> {
  /// Controller managing the Tournaments tab selection and data refreshes.
  TournamentsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tournamentsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tournamentsControllerHash();

  @$internal
  @override
  TournamentsController create() => TournamentsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TournamentsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TournamentsState>(value),
    );
  }
}

String _$tournamentsControllerHash() =>
    r'e655e640a03a0ce0cf137089969b900f9127e0fa';

/// Controller managing the Tournaments tab selection and data refreshes.

abstract class _$TournamentsController extends $Notifier<TournamentsState> {
  TournamentsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TournamentsState, TournamentsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TournamentsState, TournamentsState>,
              TournamentsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
