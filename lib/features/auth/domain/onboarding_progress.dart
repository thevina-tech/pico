import 'package:flutter/foundation.dart';

/// Immutable domain model representing in-flight onboarding progress and draft choices.
@immutable
class OnboardingProgress {
  const OnboardingProgress({
    this.step = 0,
    this.username,
    this.selectedTeamId,
    this.selectedLeagueIds = const [],
  });

  /// The active onboarding step index (0 to 4).
  /// - 0: Welcome
  /// - 1: How Pico Works
  /// - 2: Username Selection
  /// - 3: Team Selection
  /// - 4: League Selection
  final int step;

  /// Draft or selected username chosen by the user.
  final String? username;

  /// Draft or selected favorite team ID chosen by the user.
  final String? selectedTeamId;

  /// Draft or selected favorite league IDs chosen by the user.
  final List<String> selectedLeagueIds;

  bool get hasUsername => username != null && username!.trim().isNotEmpty;
  bool get hasTeam => selectedTeamId != null && selectedTeamId!.trim().isNotEmpty;
  bool get hasLeagues => selectedLeagueIds.isNotEmpty;

  OnboardingProgress copyWith({
    int? step,
    String? username,
    String? selectedTeamId,
    List<String>? selectedLeagueIds,
  }) {
    return OnboardingProgress(
      step: step ?? this.step,
      username: username ?? this.username,
      selectedTeamId: selectedTeamId ?? this.selectedTeamId,
      selectedLeagueIds: selectedLeagueIds ?? this.selectedLeagueIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingProgress &&
          runtimeType == other.runtimeType &&
          step == other.step &&
          username == other.username &&
          selectedTeamId == other.selectedTeamId &&
          listEquals(selectedLeagueIds, other.selectedLeagueIds);

  @override
  int get hashCode => Object.hash(
        step,
        username,
        selectedTeamId,
        Object.hashAll(selectedLeagueIds),
      );

  @override
  String toString() =>
      'OnboardingProgress(step: $step, username: $username, selectedTeamId: $selectedTeamId, selectedLeagueIds: $selectedLeagueIds)';
}
