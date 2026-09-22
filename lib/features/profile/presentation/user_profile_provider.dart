import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';

part 'user_profile_provider.g.dart';

/// Riverpod provider for the current user's profile.
/// Watches [authProvider] and queries [profileRepositoryProvider].
@Riverpod(keepAlive: true)
class CurrentUserProfile extends _$CurrentUserProfile {
  @override
  FutureOr<UserProfile> build() async {
    final authState = ref.watch(authProvider);

    if (authState is PicoAuthAuthenticated && authState.user != null) {
      final user = authState.user!;
      final repo = ref.watch(profileRepositoryProvider);
      final profile = await repo.getProfile(user.id);
      if (profile != null) {
        return profile;
      }

      final fallbackUsername = user.userMetadata?['full_name'] as String? ??
          (user.email != null && user.email!.isNotEmpty
              ? user.email!.split('@').first
              : 'Guest_${user.id.length >= 6 ? user.id.substring(0, 6) : user.id}');

      return UserProfile(
        id: user.id,
        email: user.email,
        username: fallbackUsername,
        level: 1,
        xp: 0,
        streak: 0,
        coins: 0,
      );
    }

    // Default fallback profile for unauthenticated / preview states
    return const UserProfile(
      id: 'guest',
      username: 'Guest',
      level: 1,
      xp: 0,
      streak: 0,
      coins: 0,
    );
  }

  /// Manually refreshes the profile data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authProvider);
      if (authState is PicoAuthAuthenticated && authState.user != null) {
        final repo = ref.read(profileRepositoryProvider);
        final profile = await repo.getProfile(authState.user!.id);
        if (profile != null) return profile;
      }
      return state.value ??
          const UserProfile(
            id: 'guest',
            username: 'Guest',
            level: 1,
            xp: 0,
            streak: 0,
            coins: 0,
          );
    });
  }
}
