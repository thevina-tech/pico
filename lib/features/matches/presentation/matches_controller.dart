import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'matches_feed_provider.dart';
import 'matches_view_model.dart';

part 'matches_controller.g.dart';

/// State model representing the Matches feed, filters, and predictions.
@immutable
class MatchesState {
  const MatchesState({
    required this.allMatches,
    required this.filters,
    this.selectedFilterIndex = 0,
    this.predictions = const {},
  });

  final List<PicoMatch> allMatches;
  final List<MatchFilterChipData> filters;
  final int selectedFilterIndex;
  final Map<String, MatchPrediction> predictions;

  List<PicoMatch> get visibleMatches {
    if (filters.isEmpty || selectedFilterIndex >= filters.length) {
      return allMatches;
    }
    final selected = filters[selectedFilterIndex];
    if (selected.competitionName == 'All' && selected.tournament == null) {
      return allMatches;
    }
    if (selected.tournament != null) {
      return allMatches
          .where((m) => matchBelongsToTournament(m, selected.tournament!))
          .toList();
    }
    return allMatches.where((m) {
      if (selected.competitionId != null && selected.competitionId!.isNotEmpty) {
        if (m.competitionId == selected.competitionId) return true;
        if (isSameCompetition(m.competitionId ?? '', selected.competitionId!)) {
          return true;
        }
      }
      if (m.competitionName == selected.competitionName) return true;
      if (m.competitionId == selected.competitionName) return true;
      final matchLower = m.competitionName.toLowerCase().trim();
      final selLower = selected.competitionName.toLowerCase().trim();
      if (matchLower.contains(selLower) || selLower.contains(matchLower)) {
        return true;
      }
      return isSameCompetition(m.competitionId ?? '', selected.competitionName) ||
          isSameCompetitionName(m.competitionName, selected.competitionName);
    }).toList();
  }

  PicoMatch? get heroMatch {
    if (allMatches.isEmpty) return null;
    try {
      return allMatches.firstWhere(
        (m) =>
            m.competitionName.toLowerCase().contains('champions') &&
            m.status == MatchStatus.upcoming,
      );
    } catch (_) {
      return allMatches.first;
    }
  }

  MatchPrediction? getPrediction(String matchId) => predictions[matchId];

  MatchesState copyWith({
    List<PicoMatch>? allMatches,
    List<MatchFilterChipData>? filters,
    int? selectedFilterIndex,
    Map<String, MatchPrediction>? predictions,
  }) {
    return MatchesState(
      allMatches: allMatches ?? this.allMatches,
      filters: filters ?? this.filters,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      predictions: predictions ?? this.predictions,
    );
  }
}

/// Production-grade Riverpod controller managing match state and predictions.
/// Dynamically updates sorting pills and matches based on the user's enrolled tournaments.
@riverpod
class MatchesController extends _$MatchesController {
  @override
  FutureOr<MatchesState> build() async {
    final matches = await ref.watch(matchesFeedProvider.future);
    final enrolled = await ref.watch(enrolledTournamentsProvider.future);
    final filters = _buildFilters(enrolled, matches);

    return MatchesState(
      allMatches: matches,
      filters: filters,
    );
  }

  void selectFilter(int index) {
    state = state.whenData((s) {
      if (index >= 0 && index < s.filters.length && s.selectedFilterIndex != index) {
        return s.copyWith(selectedFilterIndex: index);
      }
      return s;
    });
  }

  void savePrediction(String matchId, int homeScore, int awayScore) {
    state = state.whenData((s) {
      final newPredictions = Map<String, MatchPrediction>.from(s.predictions);
      newPredictions[matchId] =
          MatchPrediction(homeScore: homeScore, awayScore: awayScore);
      return s.copyWith(predictions: newPredictions);
    });
  }

  static List<MatchFilterChipData> _buildFilters(
    List<Tournament> enrolledTournaments,
    List<PicoMatch> matches,
  ) {
    final list = <MatchFilterChipData>[
      MatchFilterChipData(
        label: 'All (${matches.length})',
        competitionName: 'All',
        count: matches.length,
      ),
    ];

    for (final tournament in enrolledTournaments) {
      final count = matches
          .where((m) => matchBelongsToTournament(m, tournament))
          .length;
      list.add(
        MatchFilterChipData(
          label: '${tournament.name} ($count)',
          competitionName: tournament.name,
          count: count,
          tournament: tournament,
          competitionId: tournament.competitionId,
          dotColor: _resolveCompetitionColor(tournament.name),
        ),
      );
    }
    return list;
  }

  static Color _resolveCompetitionColor(String comp) {
    final lower = comp.toLowerCase();
    if (lower.contains('champions')) return const Color(0xFF818CF8);
    if (lower.contains('championship')) return const Color(0xFF38BDF8);
    if (lower.contains('premier')) return const Color(0xFF38BDF8);
    if (lower.contains('liga')) return const Color(0xFFFFD54F);
    if (lower.contains('serie a')) return const Color(0xFF34D399);
    if (lower.contains('bundesliga')) return const Color(0xFFF87171);
    if (lower.contains('ligue 1')) return const Color(0xFF60A5FA);
    return PicoColors.primaryFixed;
  }
}
