import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
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
    if (selected.competitionName == 'All') {
      return allMatches;
    }
    return allMatches
        .where((m) => m.competitionName == selected.competitionName)
        .toList();
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
@riverpod
class MatchesController extends _$MatchesController {
  @override
  FutureOr<MatchesState> build() async {
    final repository = ref.watch(matchRepositoryProvider);
    final matches = await repository.getAllMatches();
    final competitions = await repository.getCompetitions();
    final filters = _buildFilters(competitions, matches);

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
    List<String> competitions,
    List<PicoMatch> matches,
  ) {
    final list = <MatchFilterChipData>[
      MatchFilterChipData(
        label: 'All (${matches.length})',
        competitionName: 'All',
        count: matches.length,
      ),
    ];

    for (final comp in competitions) {
      final count = matches.where((m) => m.competitionName == comp).length;
      list.add(
        MatchFilterChipData(
          label: '$comp ($count)',
          competitionName: comp,
          count: count,
          dotColor: _resolveCompetitionColor(comp),
        ),
      );
    }
    return list;
  }

  static Color _resolveCompetitionColor(String comp) {
    final lower = comp.toLowerCase();
    if (lower.contains('champions')) return const Color(0xFF818CF8);
    if (lower.contains('championship')) return const Color(0xFF38BDF8);
    if (lower.contains('argentina')) return const Color(0xFF38BDF8);
    if (lower.contains('chile')) return const Color(0xFFF87171);
    if (lower.contains('colombia')) return const Color(0xFFFBBF24);
    if (lower.contains('amistoso')) return const Color(0xFF34D399);
    return PicoColors.primaryFixed;
  }
}
