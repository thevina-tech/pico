import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import '../data/tournament_repository.dart';
import '../domain/private_league.dart';

part 'private_league_controller.g.dart';

/// Controller managing Private League creation and joining workflows.
@Riverpod(keepAlive: true)
class PrivateLeagueController extends _$PrivateLeagueController {
  @override
  AsyncValue<PrivateLeague?> build() {
    return const AsyncData(null);
  }

  /// Creates a new private league restricted strictly to supported base competitions.
  Future<PrivateLeague> createLeague({
    required String name,
    required String competitionId,
    String description = '',
  }) async {
    state = const AsyncLoading();

    try {
      final authState = ref.read(authProvider);
      final userId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
      if (userId == null) {
        throw Exception('Must be logged in to create a private league');
      }

      final trimmedName = name.trim();
      if (trimmedName.isEmpty) {
        throw Exception('League name cannot be empty');
      }

      // Validate competition exists in database
      final competitions = await ref.read(supportedCompetitionsProvider.future);
      final isValid = competitions.any((c) => c.id == competitionId);
      if (!isValid && competitionId.isNotEmpty) {
        throw Exception('Selected competition is not supported');
      }

      final repo = ref.read(tournamentRepositoryProvider);
      final newLeague = await repo.createPrivateLeague(
        name: trimmedName,
        competitionId: competitionId,
        userId: userId,
        description: description,
      );

      // Invalidate user private leagues list so it reloads
      ref.invalidate(userPrivateLeaguesProvider);

      state = AsyncData(newLeague);
      return newLeague;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Joins an existing private league via a 6-character uppercase alphanumeric code.
  Future<PrivateLeague> joinLeague({
    required String inviteCode,
  }) async {
    state = const AsyncLoading();

    try {
      final authState = ref.read(authProvider);
      final userId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
      if (userId == null) {
        throw Exception('Must be logged in to join a private league');
      }

      final cleanCode = inviteCode.trim().toUpperCase();
      if (cleanCode.length != 6) {
        throw Exception('Invite code must be exactly 6 characters');
      }

      final repo = ref.read(tournamentRepositoryProvider);
      final league = await repo.joinPrivateLeagueByCode(
        inviteCode: cleanCode,
        userId: userId,
      );

      // Invalidate user private leagues list
      ref.invalidate(userPrivateLeaguesProvider);

      state = AsyncData(league);
      return league;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Deletes a private league (Admin / Owner only).
  Future<void> deleteLeague(String leagueId) async {
    final authState = ref.read(authProvider);
    final userId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    if (userId == null) {
      throw Exception('Must be logged in to delete a private league');
    }

    final repo = ref.read(tournamentRepositoryProvider);
    await repo.deletePrivateLeague(leagueId: leagueId, userId: userId);

    ref.invalidate(userPrivateLeaguesProvider);
    ref.invalidate(privateLeagueDetailsProvider(leagueId));
    ref.invalidate(privateLeagueMembersProvider(leagueId));
  }

  /// Removes a member from a private league (Admin / Owner only).
  Future<void> removeMember({
    required String leagueId,
    required String targetUserId,
  }) async {
    final authState = ref.read(authProvider);
    final adminUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    if (adminUserId == null) {
      throw Exception('Must be logged in to remove a member');
    }

    final repo = ref.read(tournamentRepositoryProvider);
    await repo.removeMemberFromPrivateLeague(
      leagueId: leagueId,
      targetUserId: targetUserId,
      adminUserId: adminUserId,
    );

    ref.invalidate(privateLeagueMembersProvider(leagueId));
    ref.invalidate(privateLeagueDetailsProvider(leagueId));
    ref.invalidate(userPrivateLeaguesProvider);
  }

  /// Allows a member to leave a private league.
  Future<void> leaveLeague(String leagueId) async {
    final authState = ref.read(authProvider);
    final userId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    if (userId == null) {
      throw Exception('Must be logged in to leave a private league');
    }

    final repo = ref.read(tournamentRepositoryProvider);
    await repo.leavePrivateLeague(leagueId: leagueId, userId: userId);

    ref.invalidate(userPrivateLeaguesProvider);
    ref.invalidate(privateLeagueDetailsProvider(leagueId));
    ref.invalidate(privateLeagueMembersProvider(leagueId));
  }
}
