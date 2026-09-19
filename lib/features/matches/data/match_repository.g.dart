// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(matchRepository)
final matchRepositoryProvider = MatchRepositoryProvider._();

final class MatchRepositoryProvider
    extends
        $FunctionalProvider<MatchRepository, MatchRepository, MatchRepository>
    with $Provider<MatchRepository> {
  MatchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchRepositoryHash();

  @$internal
  @override
  $ProviderElement<MatchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchRepository create(Ref ref) {
    return matchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchRepository>(value),
    );
  }
}

String _$matchRepositoryHash() => r'd1db834c67e89cad16935f5917f333d16fb33ae1';
