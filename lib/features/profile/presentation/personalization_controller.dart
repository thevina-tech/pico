import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';

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
        'champions_league',
        'ligue_1',
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
      updated.add(leagueId);
    }
    state = state.copyWith(selectedLeagueIds: updated);
  }

  void toggleTeam(String teamId) {
    final updated = Set<String>.from(state.selectedTeamIds);
    if (updated.contains(teamId)) {
      updated.remove(teamId);
    } else {
      updated.add(teamId);
    }
    state = state.copyWith(selectedTeamIds: updated, errorMessage: null);
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
        username: username,
        favoriteTeamId: state.selectedTeamId,
        favoriteTeamIds: state.selectedTeamIds.toList(),
        favoriteLeagueIds: state.selectedLeagueIds.toList(),
      );

      ref.read(authProvider.notifier).markPersonalized();
      ref.invalidate(currentUserProfileProvider);
      AppLogger.info('Personalization saved for ${authState.user?.id}');
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
