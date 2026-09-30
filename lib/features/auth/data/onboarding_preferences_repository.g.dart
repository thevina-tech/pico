// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_preferences_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider providing persistent onboarding progress repository.

@ProviderFor(onboardingPreferencesRepository)
final onboardingPreferencesRepositoryProvider =
    OnboardingPreferencesRepositoryProvider._();

/// Riverpod provider providing persistent onboarding progress repository.

final class OnboardingPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          OnboardingPreferencesRepository,
          OnboardingPreferencesRepository,
          OnboardingPreferencesRepository
        >
    with $Provider<OnboardingPreferencesRepository> {
  /// Riverpod provider providing persistent onboarding progress repository.
  OnboardingPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<OnboardingPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingPreferencesRepository create(Ref ref) {
    return onboardingPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingPreferencesRepository>(
        value,
      ),
    );
  }
}

String _$onboardingPreferencesRepositoryHash() =>
    r'941379a3690249308b9a79c24521adc128134ded';
