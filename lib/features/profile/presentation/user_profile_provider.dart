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

      // Do not use Google display name, full_name, or email prefix as app username
      return UserProfile(
        id: user.id,
        email: user.email,
        username: null,
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

  /// Adds coins to the current profile state (e.g. from rewarded video ads).
  void addCoins(int amount) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(coins: current.coins + amount));
    }
  }
}
