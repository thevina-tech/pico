import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';

part 'matches_feed_provider.g.dart';

/// AsyncNotifier provider fetching matches and filtering them strictly
/// to ONLY those linked to the competition_id of tournaments the user has joined.
@riverpod
class MatchesFeed extends _$MatchesFeed {
  @override
  FutureOr<List<PicoMatch>> build() async {
    final repository = ref.watch(matchRepositoryProvider);
    final allMatches = await repository.getAllMatches();

    final enrolled = await ref.watch(enrolledTournamentsProvider.future);
    if (enrolled.isEmpty) {
      return const [];
    }

    return allMatches.where((match) {
      return enrolled.any((tourn) => matchBelongsToTournament(match, tourn));
    }).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(matchRepositoryProvider);
      final allMatches = await repository.getAllMatches();
      final enrolled = await ref.read(enrolledTournamentsProvider.future);
      if (enrolled.isEmpty) {
        return const [];
      }
      return allMatches.where((match) {
        return enrolled.any((tourn) => matchBelongsToTournament(match, tourn));
      }).toList();
    });
  }
}

/// Helper method determining if a [PicoMatch] is linked to an enrolled [Tournament].
bool matchBelongsToTournament(PicoMatch match, Tournament tournament) {
  // 1. Match by competitionId directly or via known provider aliases
  if (match.competitionId != null && match.competitionId!.isNotEmpty) {
    if (match.competitionId == tournament.competitionId) return true;
    if (isSameCompetition(match.competitionId!, tournament.competitionId)) {
      return true;
    }
  }

  // 2. Match by competitionName directly or via known localized/commercial aliases
  if (match.competitionName.isNotEmpty) {
    if (isSameCompetitionName(match.competitionName, tournament.name)) {
      return true;
    }
  }

  return false;
}

/// Compares competition IDs including known aliases between slugs and provider IDs.
bool isSameCompetition(String id1, String id2) {
  if (id1.isEmpty || id2.isEmpty) return false;
  if (id1 == id2) return true;
  const aliases = [
    {'la_liga', '1'},
    {'premier_league', '10'},
    {'serie_a', '2'},
    {'bundesliga', '3'},
    {'ligue_1', '4'},
    {'champions_league', '6', '70393'},
    {'championship', '67799'},
  ];

  for (final set in aliases) {
    if (set.contains(id1) && set.contains(id2)) return true;
  }
  final s1 = id1.toLowerCase().trim();
  final s2 = id2.toLowerCase().trim();
  return s1 == s2;
}

/// Compares competition names including localized and commercial titles.
bool isSameCompetitionName(String name1, String name2) {
  final n1 = name1.toLowerCase().trim();
  final n2 = name2.toLowerCase().trim();
  if (n1.isEmpty || n2.isEmpty) return false;
  if (n1 == n2) return true;
  if (n1.contains(n2) || n2.contains(n1)) return true;

  const nameAliases = [
    {'la liga', 'laliga', 'primera división', 'primera division', 'la liga ea sports', 'spanish laliga'},
    {'premier league', 'epl', 'english premier league', 'barclays premier league'},
    {'serie a', 'italian serie a', 'serie a tim'},
    {'bundesliga', 'german bundesliga'},
    {'ligue 1', 'french ligue 1', 'ligue 1 mcdonalds', 'ligue 1 uber eats'},
    {'champions league', 'ucl', 'uefa champions league'},
    {'championship', 'efl championship', 'english league championship'},
  ];

  for (final set in nameAliases) {
    if (set.contains(n1) && set.contains(n2)) return true;
  }
  return false;
}
