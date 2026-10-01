import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/utils/input_sanitizer.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/presentation/matches_controller.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';

part 'personalization_controller.g.dart';

@immutable
class PersonalizationState {
  const PersonalizationState({
    this.username = '',
    this.selectedTeamIds = const {},
    this.selectedLeagueIds = const {},
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String username;
  final Set<String> selectedTeamIds;
  final Set<String> selectedLeagueIds;
  final bool isSubmitting;
  final String? errorMessage;

  /// Returns the primary selected team (if any).
  String? get selectedTeamId =>
      selectedTeamIds.isNotEmpty ? selectedTeamIds.first : null;

  PersonalizationState copyWith({
    String? username,
    Set<String>? selectedTeamIds,
    Set<String>? selectedLeagueIds,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return PersonalizationState(
      username: username ?? this.username,
      selectedTeamIds: selectedTeamIds ?? this.selectedTeamIds,
      selectedLeagueIds: selectedLeagueIds ?? this.selectedLeagueIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class PersonalizationController extends _$PersonalizationController {
  @override
  PersonalizationState build() {
    return const PersonalizationState(
      selectedLeagueIds: {
        'premier_league',
        'la_liga',
      },
      selectedTeamIds: {'arsenal'},
    );
  }

  void setUsername(String value) {
    state = state.copyWith(username: value.trim(), errorMessage: null);
  }

  void toggleLeague(String leagueId) {
    final updated = Set<String>.from(state.selectedLeagueIds);
    if (updated.contains(leagueId)) {
      updated.remove(leagueId);
    } else {
      // Limit selection to a maximum of 2 leagues
      if (updated.length < 2) {
        updated.add(leagueId);
      }
    }
    state = state.copyWith(selectedLeagueIds: updated);
  }

  void toggleTeam(String teamId) {
    // Exactly 1 team (single-select constraint)
    state = state.copyWith(selectedTeamIds: {teamId}, errorMessage: null);
  }

  void selectTeam(String teamId) => toggleTeam(teamId);

  Future<bool> submit() async {
    final username = state.username.trim();
    if (username.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please introduce a username to continue.',
      );
      return false;
    }
    if (username.length < 3) {
      state = state.copyWith(
        errorMessage: 'Username must be at least 3 characters.',
      );
      return false;
    }
    if (!InputSanitizer.isValidUsername(username)) {
      state = state.copyWith(
        errorMessage: 'Username must be 3-20 alphanumeric characters or underscores.',
      );
      return false;
    }

    final cleanUsername = InputSanitizer.sanitizeUsername(username);

    final authState = ref.read(authProvider);
    if (authState is! PicoAuthAuthenticated || authState.user == null) {
      state = state.copyWith(errorMessage: 'Authentication session not found.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updatePersonalization(
        userId: authState.user!.id,
        username: cleanUsername,
        favoriteTeamId: state.selectedTeamId,
        favoriteTeamIds: state.selectedTeamIds.toList(),
        favoriteLeagueIds: state.selectedLeagueIds.toList(),
      );

      // Auto-enroll user into public tournaments corresponding to their selected leagues
      final tournamentRepo = ref.read(tournamentRepositoryProvider);
      await tournamentRepo.enrollInDefaultTournaments(
        userId: authState.user!.id,
        leagueIds: state.selectedLeagueIds.toList(),
      );

      try {
        final updatedProfile = await repo.getProfile(authState.user!.id);
        if (updatedProfile != null) {
          ref.read(currentUserProfileProvider.notifier).setProfile(updatedProfile);
        } else {
          ref.read(currentUserProfileProvider.notifier).setProfile(
            UserProfile(
              id: authState.user!.id,
              username: username,
              favoriteTeamId: state.selectedTeamId,
              favoriteTeamIds: state.selectedTeamIds.toList(),
              favoriteLeagueIds: state.selectedLeagueIds.toList(),
            ),
          );
        }
      } catch (_) {}

      ref.read(authProvider.notifier).markPersonalized();
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(enrolledTournamentsProvider);
      ref.invalidate(matchesFeedProvider);
      ref.invalidate(matchesControllerProvider);
      AppLogger.info('Personalization and tournament auto-enrollment completed for ${authState.user?.id}');
      return true;
    } on supa.PostgrestException catch (e, st) {
      AppLogger.error('Database error updating profile', e, st);
      String userFriendly = 'Could not update profile. Please try again.';
      if (e.code == '23505') {
        userFriendly =
            'This username is already taken. Please choose another one.';
      } else if (e.code == '23503') {
        userFriendly = 'One of the selected items could not be saved.';
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: userFriendly,
      );
      return false;
    } catch (e, st) {
      AppLogger.error('Failed to submit personalization', e, st);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            'Something went wrong. Please check your connection and try again.',
      );
      return false;
    }
  }
}
