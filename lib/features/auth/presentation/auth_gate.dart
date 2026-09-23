import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/auth/presentation/onboarding_screen.dart';
import 'package:pico/features/home/presentation/home_screen.dart';
import 'package:pico/features/profile/data/profile_repository.dart';

/// Extension providing [authStateChanges] alias on [supa.GoTrueClient]
/// to mirror the expected stream listener interface.
extension AuthGateSupabaseAuthExtension on supa.GoTrueClient {
  Stream<supa.AuthState> get authStateChanges => onAuthStateChange;
}

enum _AuthDestination {
  loading,
  home,
  onboarding,
}

/// Primary startup decision-maker widget.
///
/// Holds the UI state while Supabase initializes and checks whether the user has
/// completed onboarding/personalization, preventing any flash of the Onboarding screen
/// for authenticated users.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({
    super.key,
    this.homeWidget,
    this.onboardingWidget,
    this.loadingWidget,
  });

  /// Optional fallback home widget when rendered outside of GoRouter.
  final Widget? homeWidget;

  /// Optional fallback onboarding widget when rendered outside of GoRouter.
  final Widget? onboardingWidget;

  /// Optional custom loading widget.
  final Widget? loadingWidget;

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  StreamSubscription<supa.AuthState>? _authSubscription;
  _AuthDestination _destination = _AuthDestination.loading;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _subscribeToAuthChanges();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateAuthState();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  supa.SupabaseClient? _getSupabaseClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return ref.read(supabaseClientProvider);
    }
  }

  void _subscribeToAuthChanges() {
    final client = _getSupabaseClient();
    if (client != null) {
      try {
        _authSubscription = client.auth.authStateChanges.listen((data) {
          _evaluateAuthState();
        });
      } catch (e) {
        AppLogger.warning('AuthGate: failed to listen to authStateChanges: $e');
      }
    }
  }

  Future<void> _evaluateAuthState() async {
    if (!mounted) return;

    final client = _getSupabaseClient();

    // 1. Production / initialized Supabase client
    if (client != null) {
      final session = client.auth.currentSession;
      final user = session?.user ?? client.auth.currentUser;

      if (session == null || user == null) {
        _routeTo(_AuthDestination.onboarding);
        return;
      }

      // Check database profile to see if user has finished the onboarding flow
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        final profile = await profileRepo.getProfile(user.id);

        final isCompleted = profile != null &&
            profile.username != null &&
            !profile.username!.startsWith('Guest_') &&
            profile.favoriteTeamId != null;

        _routeTo(isCompleted ? _AuthDestination.home : _AuthDestination.onboarding);
      } catch (e, st) {
        AppLogger.error('AuthGate: failed to fetch profile for onboarding check', e, st);
        _routeTo(_AuthDestination.onboarding);
      }
      return;
    }

    // 2. Offline / Hermetic test environment without active Supabase client
    final authState = ref.read(authProvider);
    if (authState is PicoAuthAuthenticated) {
      if (authState.isPersonalized) {
        _routeTo(_AuthDestination.home);
      } else {
        _routeTo(_AuthDestination.onboarding);
      }
    } else {
      _routeTo(_AuthDestination.onboarding);
    }
  }

  void _routeTo(_AuthDestination dest) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _destination = dest;
    });

    if (GoRouter.maybeOf(context) != null) {
      if (dest == _AuthDestination.home) {
        context.go('/home');
      } else if (dest == _AuthDestination.onboarding) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // While the auth state is unknown/loading, return a blank pitch Scaffold
    // containing a centered CircularProgressIndicator. Do not render any interactive screens.
    if (_isLoading) {
      return widget.loadingWidget ??
          const Scaffold(
            backgroundColor: PicoColors.pitchBackground,
            body: Center(
              child: CircularProgressIndicator(
                color: PicoColors.primary,
              ),
            ),
          );
    }

    // If rendered outside GoRouter (e.g. standalone widget tests):
    if (GoRouter.maybeOf(context) == null) {
      if (_destination == _AuthDestination.home) {
        return widget.homeWidget ?? const HomeScreen();
      } else if (_destination == _AuthDestination.onboarding) {
        return widget.onboardingWidget ?? const OnboardingScreen();
      }
    }

    // In GoRouter context, context.go('/home') or context.go('/onboarding')
    // triggers navigation; maintain pitch Scaffold with loader during transition.
    return widget.loadingWidget ??
        const Scaffold(
          backgroundColor: PicoColors.pitchBackground,
          body: Center(
            child: CircularProgressIndicator(
              color: PicoColors.primary,
            ),
          ),
        );
  }
}
