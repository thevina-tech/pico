import 'package:flutter/material.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/utils/safe_change_notifier.dart';
import 'package:pico/features/matches/data/match_repository.dart';
import 'package:pico/features/matches/domain/pico_match.dart';


import 'package:pico/features/tournaments/domain/tournament.dart';

/// Presentation model representing a filter chip in the Matches screen.
@immutable
class MatchFilterChipData {
  const MatchFilterChipData({
    required this.label,
    required this.competitionName,
    required this.count,
    this.tournament,
    this.competitionId,
    this.dotColor,
    this.isStar = false,
  });

  final String label;
  final String competitionName;
  final int count;
  final Tournament? tournament;
  final String? competitionId;
  final Color? dotColor;
  final bool isStar;
}

/// Simple model for user score prediction
@immutable
class MatchPrediction {
  const MatchPrediction({required this.homeScore, required this.awayScore});

  final int homeScore;
  final int awayScore;
}

/// Production-grade ViewModel for the Matches feature.
/// Encapsulates all data fetching, competition filtering, and prediction state.
///
/// Strictly adheres to Pico guidelines:
/// - Extends [SafeChangeNotifier]
/// - Keeps all state and dependencies private
/// - Exposes public unmodifiable getters
/// - Keeps all business logic outside the screens
class MatchesViewModel extends SafeChangeNotifier {
  MatchesViewModel(this._repository);

  final MatchRepository _repository;

  List<PicoMatch> _allMatches = [];
  int _selectedFilterIndex = 0;
  List<MatchFilterChipData> _filters = const [];
  bool _isLoading = false;
  String? _errorMessage;

  /// User in-memory predictions: { matchId: MatchPrediction }
  final Map<String, MatchPrediction> _predictions = {};

  // Public unmodifiable getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalCount => _allMatches.length;
  int get selectedFilterIndex => _selectedFilterIndex;
  List<MatchFilterChipData> get filters => List.unmodifiable(_filters);

  List<PicoMatch> get visibleMatches {
    if (_filters.isEmpty || _selectedFilterIndex >= _filters.length) {
      return List.unmodifiable(_allMatches);
    }
    final selected = _filters[_selectedFilterIndex];
    if (selected.competitionName == 'All') {
      return List.unmodifiable(_allMatches);
    }
    return List.unmodifiable(
      _allMatches.where((m) => m.competitionName == selected.competitionName),
    );
  }

  MatchPrediction? getPrediction(String matchId) => _predictions[matchId];

  PicoMatch? get heroMatch {
    if (_allMatches.isEmpty) return null;
    try {
      return _allMatches.firstWhere(
        (m) =>
            m.competitionName.toLowerCase().contains('champions') &&
            m.status == MatchStatus.upcoming,
      );
    } catch (_) {
      return _allMatches.first;
    }
  }

  Future<void> loadMatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final matches = await _repository.getAllMatches();
      final competitions = await _repository.getCompetitions();

      _allMatches = matches;
      _buildFilters(competitions, matches);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load matches: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectFilter(int index) {
    if (index >= 0 && index < _filters.length && _selectedFilterIndex != index) {
      _selectedFilterIndex = index;
      notifyListeners();
    }
  }

  void savePrediction(String matchId, int homeScore, int awayScore) {
    _predictions[matchId] = MatchPrediction(homeScore: homeScore, awayScore: awayScore);
    notifyListeners();
  }

  void _buildFilters(List<String> competitions, List<PicoMatch> matches) {
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

    _filters = list;
    if (_selectedFilterIndex >= _filters.length) {
      _selectedFilterIndex = 0;
    }
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
