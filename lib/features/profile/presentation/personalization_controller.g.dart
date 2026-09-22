// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalization_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PersonalizationController)
final personalizationControllerProvider = PersonalizationControllerProvider._();

final class PersonalizationControllerProvider
    extends $NotifierProvider<PersonalizationController, PersonalizationState> {
  PersonalizationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personalizationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personalizationControllerHash();

  @$internal
  @override
  PersonalizationController create() => PersonalizationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PersonalizationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PersonalizationState>(value),
    );
  }
}

String _$personalizationControllerHash() =>
    r'b218fef99adeadc426be0d1cd2d2d068298b514c';

abstract class _$PersonalizationController
    extends $Notifier<PersonalizationState> {
  PersonalizationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PersonalizationState, PersonalizationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PersonalizationState, PersonalizationState>,
              PersonalizationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
