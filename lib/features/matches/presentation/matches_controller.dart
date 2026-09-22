import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'matches_feed_provider.dart';
import 'matches_view_model.dart';

part 'matches_controller.g.dart';

/// The 3 categorized views for the match feed.
enum MatchTab {
  live,
  upcoming,
  finished,
}

/// State model representing the Matches feed, filters, and predictions.
@immutable
class MatchesState {
  const MatchesState({
    required this.allMatches,
    required this.filters,
    this.selectedTab = MatchTab.upcoming,
    this.selectedFilterIndex = 0,
    this.predictions = const {},
    this.settlementPoints = const {},
  });

  final List<PicoMatch> allMatches;
  final List<MatchFilterChipData> filters;
  final MatchTab selectedTab;
  final int selectedFilterIndex;
  final Map<String, MatchPrediction> predictions;
  final Map<String, int> settlementPoints;

  /// Matches currently live / in-progress.
  List<PicoMatch> get liveMatches =>
      allMatches.where((m) => m.status == MatchStatus.live).toList();

  /// Upcoming matches within the rolling window.
  List<PicoMatch> get upcomingMatches {
    final now = DateTime.now();
    final maxDate14 = now.add(const Duration(days: 14));
    final within14 = allMatches
        .where((m) => m.status == MatchStatus.upcoming && m.kickoffAt.isBefore(maxDate14))
        .toList();
    if (within14.isNotEmpty) {
      return within14;
    }
    // Fallback: If no fixtures are within 14 days (e.g. international break / fixture gap),
    // show next upcoming matchday fixtures (up to 30 days) as teasers so the feed is never empty.
    final maxDate30 = now.add(const Duration(days: 30));
    final list = allMatches
        .where((m) => m.status == MatchStatus.upcoming && m.kickoffAt.isBefore(maxDate30))
        .toList();
    list.sort((a, b) => a.kickoffAt.compareTo(b.kickoffAt));
    return list;
  }

  /// Finished matches within the settlement window.
  List<PicoMatch> get finishedMatches {
    final now = DateTime.now();
    final minDate7 = now.subtract(const Duration(days: 7));
    final within7 = allMatches
        .where((m) => m.status == MatchStatus.finished && m.kickoffAt.isAfter(minDate7))
        .toList();
    final list = within7.isNotEmpty
        ? within7
        : allMatches
            .where((m) => m.status == MatchStatus.finished && m.kickoffAt.isAfter(now.subtract(const Duration(days: 30))))
            .toList();
    list.sort((a, b) => b.kickoffAt.compareTo(a.kickoffAt));
    return list;
  }

  int get liveCount => liveMatches.length;
  int get upcomingCount => upcomingMatches.length;
  int get finishedCount => finishedMatches.length;

  /// Current fixtures scoped to the active tab.
  List<PicoMatch> get currentTabMatches {
    switch (selectedTab) {
      case MatchTab.live:
        return liveMatches;
      case MatchTab.upcoming:
        return upcomingMatches;
      case MatchTab.finished:
        return finishedMatches;
    }
  }

  /// Visible matches filtered by both the active tab and the chosen competition chip.
  List<PicoMatch> get visibleMatches {
    final tabMatches = currentTabMatches;
    if (filters.isEmpty || selectedFilterIndex >= filters.length) {
      return tabMatches;
    }
    final selected = filters[selectedFilterIndex];
    if (selected.competitionName == 'All' && selected.tournament == null) {
      return tabMatches;
    }
    if (selected.tournament != null) {
      return tabMatches
          .where((m) => matchBelongsToTournament(m, selected.tournament!))
          .toList();
    }
    return tabMatches.where((m) {
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
    MatchTab? selectedTab,
    int? selectedFilterIndex,
    Map<String, MatchPrediction>? predictions,
    Map<String, int>? settlementPoints,
  }) {
    return MatchesState(
      allMatches: allMatches ?? this.allMatches,
      filters: filters ?? this.filters,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      predictions: predictions ?? this.predictions,
      settlementPoints: settlementPoints ?? this.settlementPoints,
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
    const initialTab = MatchTab.upcoming;

    final tempState = MatchesState(
      allMatches: matches,
      filters: const [],
      selectedTab: initialTab,
    );

    final currentTabMatches = tempState.currentTabMatches;
    final filters = _buildFilters(enrolled, currentTabMatches);

    return tempState.copyWith(filters: filters);
  }

  void selectTab(MatchTab tab) {
    state = state.whenData((s) {
      if (s.selectedTab != tab) {
        final tempState = s.copyWith(selectedTab: tab, selectedFilterIndex: 0);
        final tabMatches = tempState.currentTabMatches;

        final enrolled = ref.read(enrolledTournamentsProvider).value ?? const [];
        final filters = _buildFilters(enrolled, tabMatches);
        return tempState.copyWith(filters: filters);
      }
      return s;
    });
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
    if (lower.contains('liga') || lower.contains('primera')) return const Color(0xFFFFD54F);
    if (lower.contains('serie a')) return const Color(0xFF34D399);
    if (lower.contains('bundesliga')) return const Color(0xFFF87171);
    if (lower.contains('ligue 1')) return const Color(0xFF60A5FA);
    return PicoColors.primaryFixed;
  }
}
