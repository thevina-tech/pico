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

/// Provider exposing supported competitions dynamically loaded from Supabase database.

@ProviderFor(supportedCompetitions)
final supportedCompetitionsProvider = SupportedCompetitionsProvider._();

/// Provider exposing supported competitions dynamically loaded from Supabase database.

final class SupportedCompetitionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Competition>>,
          List<Competition>,
          FutureOr<List<Competition>>
        >
    with
        $FutureModifier<List<Competition>>,
        $FutureProvider<List<Competition>> {
  /// Provider exposing supported competitions dynamically loaded from Supabase database.
  SupportedCompetitionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportedCompetitionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportedCompetitionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Competition>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Competition>> create(Ref ref) {
    return supportedCompetitions(ref);
  }
}

String _$supportedCompetitionsHash() =>
    r'9df1c11cd07b17d1028e766d83098e1a0c7a7453';

/// Provider exposing a map of competitions by ID for fast lookup.

@ProviderFor(competitionsMap)
final competitionsMapProvider = CompetitionsMapProvider._();

/// Provider exposing a map of competitions by ID for fast lookup.

final class CompetitionsMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, Competition>>,
          Map<String, Competition>,
          FutureOr<Map<String, Competition>>
        >
    with
        $FutureModifier<Map<String, Competition>>,
        $FutureProvider<Map<String, Competition>> {
  /// Provider exposing a map of competitions by ID for fast lookup.
  CompetitionsMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'competitionsMapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$competitionsMapHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, Competition>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, Competition>> create(Ref ref) {
    return competitionsMap(ref);
  }
}

String _$competitionsMapHash() => r'4d32153b420f58d20c81ca996cd591fa7e0756f8';

/// Provider exposing the list of public tournaments.

@ProviderFor(publicTournaments)
final publicTournamentsProvider = PublicTournamentsProvider._();

/// Provider exposing the list of public tournaments.

final class PublicTournamentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tournament>>,
          List<Tournament>,
          FutureOr<List<Tournament>>
        >
    with $FutureModifier<List<Tournament>>, $FutureProvider<List<Tournament>> {
  /// Provider exposing the list of public tournaments.
  PublicTournamentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicTournamentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicTournamentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Tournament>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tournament>> create(Ref ref) {
    return publicTournaments(ref);
  }
}

String _$publicTournamentsHash() => r'05c8e3b9c4a887aeeb3c783b6faaa00b440b8cab';

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

/// Provider exposing the list of private leagues the active authenticated user has joined or owns.

@ProviderFor(userPrivateLeagues)
final userPrivateLeaguesProvider = UserPrivateLeaguesProvider._();

/// Provider exposing the list of private leagues the active authenticated user has joined or owns.

final class UserPrivateLeaguesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PrivateLeague>>,
          List<PrivateLeague>,
          FutureOr<List<PrivateLeague>>
        >
    with
        $FutureModifier<List<PrivateLeague>>,
        $FutureProvider<List<PrivateLeague>> {
  /// Provider exposing the list of private leagues the active authenticated user has joined or owns.
  UserPrivateLeaguesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPrivateLeaguesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPrivateLeaguesHash();

  @$internal
  @override
  $FutureProviderElement<List<PrivateLeague>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PrivateLeague>> create(Ref ref) {
    return userPrivateLeagues(ref);
  }
}

String _$userPrivateLeaguesHash() =>
    r'6f0d75051df0153f1fdc65c131afe14feabe2ba2';

/// Provider for public tournament details by ID.

@ProviderFor(tournamentDetails)
final tournamentDetailsProvider = TournamentDetailsFamily._();

/// Provider for public tournament details by ID.

final class TournamentDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Tournament?>,
          Tournament?,
          FutureOr<Tournament?>
        >
    with $FutureModifier<Tournament?>, $FutureProvider<Tournament?> {
  /// Provider for public tournament details by ID.
  TournamentDetailsProvider._({
    required TournamentDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tournamentDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentDetailsHash();

  @override
  String toString() {
    return r'tournamentDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Tournament?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Tournament?> create(Ref ref) {
    final argument = this.argument as String;
    return tournamentDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentDetailsHash() => r'211d5f0f3b82f7d2497b6c47f4f05617b3eb688d';

/// Provider for public tournament details by ID.

final class TournamentDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Tournament?>, String> {
  TournamentDetailsFamily._()
    : super(
        retry: null,
        name: r'tournamentDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for public tournament details by ID.

  TournamentDetailsProvider call(String id) =>
      TournamentDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'tournamentDetailsProvider';
}

/// Provider for a tournament's public leaderboard.

@ProviderFor(tournamentLeaderboard)
final tournamentLeaderboardProvider = TournamentLeaderboardFamily._();

/// Provider for a tournament's public leaderboard.

final class TournamentLeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TournamentParticipant>>,
          List<TournamentParticipant>,
          FutureOr<List<TournamentParticipant>>
        >
    with
        $FutureModifier<List<TournamentParticipant>>,
        $FutureProvider<List<TournamentParticipant>> {
  /// Provider for a tournament's public leaderboard.
  TournamentLeaderboardProvider._({
    required TournamentLeaderboardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tournamentLeaderboardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentLeaderboardHash();

  @override
  String toString() {
    return r'tournamentLeaderboardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TournamentParticipant>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TournamentParticipant>> create(Ref ref) {
    final argument = this.argument as String;
    return tournamentLeaderboard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentLeaderboardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentLeaderboardHash() =>
    r'b250c03dd130dc9abba3f77ca8acdd3e9a4898ae';

/// Provider for a tournament's public leaderboard.

final class TournamentLeaderboardFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<TournamentParticipant>>,
          String
        > {
  TournamentLeaderboardFamily._()
    : super(
        retry: null,
        name: r'tournamentLeaderboardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a tournament's public leaderboard.

  TournamentLeaderboardProvider call(String tournamentId) =>
      TournamentLeaderboardProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'tournamentLeaderboardProvider';
}

/// Provider for a private league's details by ID.

@ProviderFor(privateLeagueDetails)
final privateLeagueDetailsProvider = PrivateLeagueDetailsFamily._();

/// Provider for a private league's details by ID.

final class PrivateLeagueDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrivateLeague?>,
          PrivateLeague?,
          FutureOr<PrivateLeague?>
        >
    with $FutureModifier<PrivateLeague?>, $FutureProvider<PrivateLeague?> {
  /// Provider for a private league's details by ID.
  PrivateLeagueDetailsProvider._({
    required PrivateLeagueDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'privateLeagueDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$privateLeagueDetailsHash();

  @override
  String toString() {
    return r'privateLeagueDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PrivateLeague?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrivateLeague?> create(Ref ref) {
    final argument = this.argument as String;
    return privateLeagueDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PrivateLeagueDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$privateLeagueDetailsHash() =>
    r'aa5bc7cfd5d7ced20b34e25316b7b617fc52806f';

/// Provider for a private league's details by ID.

final class PrivateLeagueDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PrivateLeague?>, String> {
  PrivateLeagueDetailsFamily._()
    : super(
        retry: null,
        name: r'privateLeagueDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a private league's details by ID.

  PrivateLeagueDetailsProvider call(String id) =>
      PrivateLeagueDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'privateLeagueDetailsProvider';
}

/// Provider for a private league's member leaderboard.

@ProviderFor(privateLeagueMembers)
final privateLeagueMembersProvider = PrivateLeagueMembersFamily._();

/// Provider for a private league's member leaderboard.

final class PrivateLeagueMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PrivateLeagueMember>>,
          List<PrivateLeagueMember>,
          FutureOr<List<PrivateLeagueMember>>
        >
    with
        $FutureModifier<List<PrivateLeagueMember>>,
        $FutureProvider<List<PrivateLeagueMember>> {
  /// Provider for a private league's member leaderboard.
  PrivateLeagueMembersProvider._({
    required PrivateLeagueMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'privateLeagueMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$privateLeagueMembersHash();

  @override
  String toString() {
    return r'privateLeagueMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PrivateLeagueMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PrivateLeagueMember>> create(Ref ref) {
    final argument = this.argument as String;
    return privateLeagueMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PrivateLeagueMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$privateLeagueMembersHash() =>
    r'bb24bbb5dee139b1d978fd708a063a80b67d5206';

/// Provider for a private league's member leaderboard.

final class PrivateLeagueMembersFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<PrivateLeagueMember>>, String> {
  PrivateLeagueMembersFamily._()
    : super(
        retry: null,
        name: r'privateLeagueMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a private league's member leaderboard.

  PrivateLeagueMembersProvider call(String leagueId) =>
      PrivateLeagueMembersProvider._(argument: leagueId, from: this);

  @override
  String toString() => r'privateLeagueMembersProvider';
}

/// Provider for a private league's message feed.

@ProviderFor(leagueMessages)
final leagueMessagesProvider = LeagueMessagesFamily._();

/// Provider for a private league's message feed.

final class LeagueMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LeagueMessage>>,
          List<LeagueMessage>,
          FutureOr<List<LeagueMessage>>
        >
    with
        $FutureModifier<List<LeagueMessage>>,
        $FutureProvider<List<LeagueMessage>> {
  /// Provider for a private league's message feed.
  LeagueMessagesProvider._({
    required LeagueMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leagueMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leagueMessagesHash();

  @override
  String toString() {
    return r'leagueMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LeagueMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LeagueMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return leagueMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeagueMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leagueMessagesHash() => r'38c776cfbe7305881f900e28e9296c643d1da73c';

/// Provider for a private league's message feed.

final class LeagueMessagesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LeagueMessage>>, String> {
  LeagueMessagesFamily._()
    : super(
        retry: null,
        name: r'leagueMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for a private league's message feed.

  LeagueMessagesProvider call(String leagueId) =>
      LeagueMessagesProvider._(argument: leagueId, from: this);

  @override
  String toString() => r'leagueMessagesProvider';
}

/// Provider for matches filtered by competition ID.

@ProviderFor(competitionMatches)
final competitionMatchesProvider = CompetitionMatchesFamily._();

/// Provider for matches filtered by competition ID.

final class CompetitionMatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PicoMatch>>,
          List<PicoMatch>,
          FutureOr<List<PicoMatch>>
        >
    with $FutureModifier<List<PicoMatch>>, $FutureProvider<List<PicoMatch>> {
  /// Provider for matches filtered by competition ID.
  CompetitionMatchesProvider._({
    required CompetitionMatchesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'competitionMatchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$competitionMatchesHash();

  @override
  String toString() {
    return r'competitionMatchesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PicoMatch>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PicoMatch>> create(Ref ref) {
    final argument = this.argument as String;
    return competitionMatches(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompetitionMatchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$competitionMatchesHash() =>
    r'89f9ab328abdc3460fad9f24c075036713d5f6c0';

/// Provider for matches filtered by competition ID.

final class CompetitionMatchesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PicoMatch>>, String> {
  CompetitionMatchesFamily._()
    : super(
        retry: null,
        name: r'competitionMatchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for matches filtered by competition ID.

  CompetitionMatchesProvider call(String competitionId) =>
      CompetitionMatchesProvider._(argument: competitionId, from: this);

  @override
  String toString() => r'competitionMatchesProvider';
}
