import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/profile/data/profile_repository.dart';

part 'auth_provider.g.dart';

/// Stream provider listening to Supabase auth state changes.
@riverpod
Stream<supa.AuthState> authStateChanges(Ref ref) {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase == null) {
    return const Stream.empty();
  }
  return supabase.auth.onAuthStateChange;
}

/// Central Riverpod AuthNotifier managing authentication state,
/// anonymous login, and personalization tracking.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<supa.AuthState>? _subscription;

  @override
  PicoAuthState build() {
    final supabase = ref.watch(supabaseClientProvider);
    if (supabase == null) {
      return const PicoAuthUnauthenticated();
    }

    _subscription?.cancel();
    _subscription = supabase.auth.onAuthStateChange.listen((data) {
      _handleAuthChangeEvent(data);
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    final currentUser = supabase.auth.currentUser;
    if (currentUser != null) {
      _checkPersonalization(currentUser);
      return PicoAuthAuthenticated(user: currentUser);
    }

    return const PicoAuthUnauthenticated();
  }

  void _handleAuthChangeEvent(supa.AuthState data) {
    final user = data.session?.user;
    if (user != null) {
      _checkPersonalization(user);
    } else {
      state = const PicoAuthUnauthenticated();
    }
  }

  Future<void> _checkPersonalization(supa.User user) async {
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = await profileRepo.getProfile(user.id);

      final isPersonalized = profile != null &&
          profile.username != null &&
          !profile.username!.startsWith('Guest_') &&
          profile.favoriteTeamId != null;

      state = PicoAuthAuthenticated(
        user: user,
        isPersonalized: isPersonalized,
      );
    } catch (e) {
      state = PicoAuthAuthenticated(user: user, isPersonalized: false);
    }
  }

  /// Executes anonymous guest authentication through Supabase.
  Future<void> signInAnonymously() async {
    final supabase = ref.read(supabaseClientProvider);
    if (supabase == null) {
      AppLogger.warning('Supabase not initialized; simulating offline guest login');
      const mockUser = supa.User(
        id: 'guest_test_id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );
      state = const PicoAuthAuthenticated(user: mockUser, isPersonalized: false);
      return;
    }

    state = const PicoAuthAuthenticating();
    try {
      final response = await supabase.auth.signInAnonymously();
      final user = response.user;
      if (user != null) {
        AppLogger.info('Anonymous login successful for user ${user.id}');
        state = PicoAuthAuthenticated(user: user, isPersonalized: false);
      } else {
        state = const PicoAuthError('Failed to obtain user session.');
      }
    } on supa.AuthApiException catch (e, st) {
      if (e.code == 'anonymous_provider_disabled') {
        const helpfulMsg =
            'Anonymous sign-ins are disabled in your Supabase project. '
            'Please enable "Anonymous sign-in" in your Supabase Dashboard: '
            'Authentication > Providers > Anonymous sign-in.';
        AppLogger.error(helpfulMsg, e, st);
        state = const PicoAuthError(helpfulMsg);
        throw const supa.AuthApiException(
          helpfulMsg,
          code: 'anonymous_provider_disabled',
          statusCode: '422',
        );
      }
      AppLogger.error('Error signing in anonymously: ${e.message}', e, st);
      state = PicoAuthError(e.message);
      rethrow;
    } catch (e, st) {
      AppLogger.error('Error signing in anonymously', e, st);
      state = PicoAuthError(e.toString());
      rethrow;
    }
  }

  /// Marks the current user as personalized.
  void markPersonalized() {
    final current = state;
    if (current is PicoAuthAuthenticated) {
      state = current.copyWith(isPersonalized: true);
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    final supabase = ref.read(supabaseClientProvider);
    if (supabase != null) {
      await supabase.auth.signOut();
    }
    state = const PicoAuthUnauthenticated();
  }
}
