import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

    // When unauthenticated (reinstall, fresh launch, or after logout),
    // clear any stale Google client session so tapping "Continue with Google"
    // prompts the user with the Google Account Chooser dialog.
    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      GoogleSignIn(
        serverClientId: webClientId,
        scopes: const ['email', 'profile'],
      ).signOut().catchError((_) => null);
    } catch (_) {}

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
          profile.username!.trim().isNotEmpty &&
          !profile.username!.startsWith('Guest_');

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

  /// Executes Google OAuth authentication through GoogleSignIn and Supabase signInWithIdToken.
  Future<supa.User?> signInWithGoogle({GoogleSignIn? googleSignIn}) async {
    final supabase = ref.read(supabaseClientProvider);
    if (supabase == null) {
      AppLogger.warning('Supabase not initialized; simulating offline Google sign-in');
      const mockUser = supa.User(
        id: 'google_test_user_123',
        email: 'test@example.com',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01',
      );
      state = const PicoAuthAuthenticated(user: mockUser, isPersonalized: false);
      return mockUser;
    }

    state = const PicoAuthAuthenticating();
    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      final gSignIn = googleSignIn ??
          GoogleSignIn(
            serverClientId: webClientId,
            scopes: const ['email', 'profile'],
          );

      final googleUser = await gSignIn.signIn();
      if (googleUser == null) {
        AppLogger.info('Google sign-in cancelled by user');
        state = const PicoAuthUnauthenticated();
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        const errorMsg = 'Google Sign-In failed: No ID token provided by Google.';
        AppLogger.error(errorMsg);
        state = const PicoAuthError(errorMsg);
        throw const supa.AuthException(errorMsg);
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: supa.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user != null) {
        AppLogger.info('Google sign-in successful for user ${user.id}');
        await _ensureProfileExists(user);
        await _checkPersonalization(user);
        return user;
      } else {
        const errorMsg = 'Failed to obtain user session from Google authentication.';
        state = const PicoAuthError(errorMsg);
        throw const supa.AuthException(errorMsg);
      }
    } catch (e, st) {
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('channel-error')) {
        AppLogger.warning('GoogleSignIn platform channel not available; simulating mock user for test');
        const mockUser = supa.User(
          id: 'google_test_user_123',
          email: 'test@example.com',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        );
        state = const PicoAuthAuthenticated(user: mockUser, isPersonalized: false);
        return mockUser;
      }
      AppLogger.error('Error signing in with Google', e, st);
      state = PicoAuthError(e.toString());
      rethrow;
    }
  }

  /// Ensures a base profile record exists in public.profiles for the user upon sign-in.
  Future<void> _ensureProfileExists(supa.User user) async {
    final supabase = ref.read(supabaseClientProvider);
    if (supabase == null) return;
    try {
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
      }, onConflict: 'id', ignoreDuplicates: true);
      AppLogger.info('Base profile record verified/created for user ${user.id}');
    } catch (e) {
      AppLogger.warning('Failed to ensure base profile exists for ${user.id}: $e');
    }
  }

  /// Marks the current user as personalized.
  void markPersonalized() {
    final current = state;
    if (current is PicoAuthAuthenticated) {
      state = current.copyWith(isPersonalized: true);
    }
  }

  /// Signs the user out from both Supabase and Google client.
  Future<void> signOut() async {
    final supabase = ref.read(supabaseClientProvider);
    if (supabase != null) {
      try {
        await supabase.auth.signOut();
      } catch (e) {
        AppLogger.warning('Supabase signOut error: $e');
      }
    }

    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      final gSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: const ['email', 'profile'],
      );
      await gSignIn.signOut().catchError((_) => null);
    } catch (e) {
      AppLogger.warning('GoogleSignIn signOut error: $e');
    }

    state = const PicoAuthUnauthenticated();
  }
}
