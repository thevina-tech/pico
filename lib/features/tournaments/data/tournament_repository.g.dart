// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [TournamentRepository].

@ProviderFor(tournamentRepository)
final tournamentRepositoryProvider = TournamentRepositoryProvider._();

/// Provider for [TournamentRepository].

final class TournamentRepositoryProvider
    extends
        $FunctionalProvider<
          TournamentRepository,
          TournamentRepository,
          TournamentRepository
        >
    with $Provider<TournamentRepository> {
  /// Provider for [TournamentRepository].
  TournamentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tournamentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tournamentRepositoryHash();

  @$internal
  @override
  $ProviderElement<TournamentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TournamentRepository create(Ref ref) {
    return tournamentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TournamentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TournamentRepository>(value),
    );
  }
}

String _$tournamentRepositoryHash() =>
    r'063ec2e3a4d5770b1b896b211d1636f4ba7ea928';

/// Provider exposing the list of tournaments the active authenticated user has joined.

@ProviderFor(enrolledTournaments)
final enrolledTournamentsProvider = EnrolledTournamentsProvider._();

/// Provider exposing the list of tournaments the active authenticated user has joined.

final class EnrolledTournamentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tournament>>,
          List<Tournament>,
          FutureOr<List<Tournament>>
        >
    with $FutureModifier<List<Tournament>>, $FutureProvider<List<Tournament>> {
  /// Provider exposing the list of tournaments the active authenticated user has joined.
  EnrolledTournamentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enrolledTournamentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enrolledTournamentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Tournament>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tournament>> create(Ref ref) {
    return enrolledTournaments(ref);
  }
}

String _$enrolledTournamentsHash() =>
    r'cf62e31ad8f3b8859620caad8f7644968b11e8cf';
