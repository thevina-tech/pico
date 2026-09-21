import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';

part 'profile_repository.g.dart';

/// Provider for [ProfileRepository].
@riverpod
ProfileRepository profileRepository(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(supabase);
}

/// Abstract contract for user profile access and updates.
abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);

  Future<void> updatePersonalization({
    required String userId,
    required String username,
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
  Future<void> updatePersonalization({
    required String userId,
    required String username,
    String? favoriteTeamId,
    List<String>? favoriteTeamIds,
    List<String>? favoriteLeagueIds,
  }) async {
    final updates = <String, dynamic>{
      'username': username,
    };
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
      final existing = _mockCache[userId] ?? UserProfile(id: userId);
      final teams = favoriteTeamIds ??
          (favoriteTeamId != null ? [favoriteTeamId] : existing.favoriteTeamIds);
      _mockCache[userId] = existing.copyWith(
        username: username,
        favoriteTeamId: teams.isNotEmpty ? teams.first : null,
        favoriteTeamIds: teams,
        favoriteLeagueIds: favoriteLeagueIds ?? existing.favoriteLeagueIds,
      );
      AppLogger.info('Mock profile updated: username=$username');
      return;
    }

    try {
      await _supabase.from('profiles').update(updates).eq('id', userId);
      AppLogger.info('Profile updated successfully in Supabase for user $userId');
    } catch (e, st) {
      AppLogger.error('Failed to update personalization for user $userId', e, st);
      rethrow;
    }
  }
}
