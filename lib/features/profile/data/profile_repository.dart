import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/core/utils/input_sanitizer.dart';
import 'package:pico/features/matches/domain/team.dart';
import 'package:pico/features/profile/domain/user_profile.dart';

part 'profile_repository.g.dart';

/// Provider for [ProfileRepository].
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(supabase);
}

/// Provider exposing the list of teams from public.teams.
@Riverpod(keepAlive: true)
Future<List<Team>> availableTeams(Ref ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getTeams();
}

/// Abstract contract for user profile access and updates.
abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);

  Future<List<Team>> getTeams();

  /// Checks whether a username is available or already in use.
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId});

  Future<void> updatePersonalization({
    required String userId,
    String? username,
    String? favoriteTeamId,
    List<String>? favoriteTeamIds,
    List<String>? favoriteLeagueIds,
  });
}

/// Production Supabase implementation of [ProfileRepository].
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository([this._supabase]);

  final SupabaseClient? _supabase;
  final Map<String, UserProfile> _mockCache = {};

  @override
  Future<UserProfile?> getProfile(String userId) async {
    if (_supabase == null) {
      return _mockCache[userId] ??
          UserProfile(
            id: userId,
            username: 'Guest_${userId.length >= 6 ? userId.substring(0, 6) : userId}',
          );
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e, st) {
      AppLogger.error('Failed to fetch profile from Supabase for $userId', e, st);
      return _mockCache[userId];
    }
  }



  @override
  Future<List<Team>> getTeams() async {
    if (_supabase == null) {
      return const [];
    }
    try {
      final response = await _supabase
          .from('teams')
          .select('id, name, short_name, crest_url')
          .order('name');
      final list = (response as List<dynamic>)
          .map((row) => Team.fromJson(row as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e, st) {
      AppLogger.error('Failed to fetch teams from Supabase: $e', e, st);
      return const [];
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async {
    final clean = InputSanitizer.sanitizeUsername(username);
    if (!InputSanitizer.isValidUsername(clean)) return false;

    if (_supabase == null) {
      final cleanLower = clean.toLowerCase();
      final taken = _mockCache.values.any((p) =>
          (p.username?.toLowerCase() == cleanLower) && p.id != excludeUserId);
      return !taken;
    }

    try {
      final escaped = InputSanitizer.escapeSqlWildcards(clean);
      final response = await _supabase
          .from('profiles')
          .select('id')
          .ilike('username', escaped);
      final list = response as List<dynamic>;
      if (list.isEmpty) return true;
      if (excludeUserId != null && list.length == 1) {
        final row = list.first as Map<String, dynamic>;
        return row['id'] == excludeUserId;
      }
      return false;
    } catch (e) {
      AppLogger.warning('Pre-check username availability failed: $e');
      return true;
    }
  }

  @override
  Future<void> updatePersonalization({
    required String userId,
    String? username,
    String? favoriteTeamId,
    List<String>? favoriteTeamIds,
    List<String>? favoriteLeagueIds,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null && username.isNotEmpty) {
      final cleanUsername = InputSanitizer.sanitizeUsername(username);
      if (cleanUsername.isNotEmpty) {
        updates['username'] = cleanUsername;
      }
    }
    if (favoriteTeamIds != null) {
      updates['favorite_team_ids'] = favoriteTeamIds;
      if (favoriteTeamIds.isNotEmpty) {
        updates['favorite_team_id'] = favoriteTeamIds.first;
      }
    } else if (favoriteTeamId != null) {
      updates['favorite_team_id'] = favoriteTeamId;
      updates['favorite_team_ids'] = [favoriteTeamId];
    }
    if (favoriteLeagueIds != null) {
      updates['favorite_league_ids'] = favoriteLeagueIds;
    }

    if (_supabase == null) {
      final cleanLower = (username ?? '').toLowerCase();
      final collision = _mockCache.values.any((p) =>
          p.id != userId && (p.username?.toLowerCase() == cleanLower));
      if (collision) {
        throw const PostgrestException(
          message: 'duplicate key value violates unique constraint "profiles_username_key"',
          code: '23505',
        );
      }
      final existing = _mockCache[userId] ?? UserProfile(id: userId);
      final teams = favoriteTeamIds ??
          (favoriteTeamId != null ? [favoriteTeamId] : existing.favoriteTeamIds);
      _mockCache[userId] = existing.copyWith(
        username: username ?? existing.username,
        favoriteTeamId: teams.isNotEmpty ? teams.first : null,
        favoriteTeamIds: teams,
        favoriteLeagueIds: favoriteLeagueIds ?? existing.favoriteLeagueIds,
      );
      AppLogger.info('Mock profile updated: username=$username');
      return;
    }

    try {
      if (updates.isNotEmpty) {
        final payload = <String, dynamic>{
          'id': userId,
          ...updates,
        };

        final currentUser = _supabase.auth.currentUser;
        if (currentUser != null && currentUser.id == userId) {
          if (currentUser.email != null) {
            payload['email'] = currentUser.email;
          }
        }

        await _supabase.from('profiles').upsert(payload, onConflict: 'id');
        AppLogger.info('Profile upserted successfully in Supabase for user $userId');
      }
    } catch (e, st) {
      AppLogger.error('Failed to update personalization for user $userId', e, st);
      rethrow;
    }
  }
}
