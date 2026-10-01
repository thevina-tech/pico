import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/auth/data/onboarding_preferences_repository.dart';
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

/// Primary startup decision-maker widget and Splash screen gateway.
///
/// Holds the UI state while Supabase initializes and checks whether the user has
/// completed onboarding/personalization, preventing any flash of the Onboarding screen
/// for authenticated users while displaying the branded Splash artwork.
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
  int _onboardingStep = 0;
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
      final user = client.auth.currentUser;

      if (user == null) {
        // User not logged in: Show the "Welcome" screen or saved initial step
        final repo = ref.read(onboardingPreferencesRepositoryProvider);
        final progress = await repo.getProgress();
        final resumeStep = progress.step == 1 ? 1 : 0;
        _routeToOnboarding(step: resumeStep);
        return;
      }

      // Check database profile to see if user has completed profile (username exists)
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        final profile = await profileRepo.getProfile(user.id);

        final hasUsername = profile != null &&
            profile.username != null &&
            profile.username!.trim().isNotEmpty &&
            !profile.username!.startsWith('Guest_');

        if (hasUsername) {
          // Returning User with completed profile: Route directly to Main Dashboard
          try {
            await ref.read(onboardingPreferencesRepositoryProvider).clearProgress();
          } catch (_) {}
          ref.read(authProvider.notifier).markPersonalized();
          _routeToHome();
        } else {
          // Incomplete profile: read saved progress to resume at exact step (2 or 3)
          final repo = ref.read(onboardingPreferencesRepositoryProvider);
          final progress = await repo.getProgress();
          final resumeStep = progress.step >= 2 ? progress.step.clamp(2, 3) : 2;
          _routeToOnboarding(step: resumeStep);
        }
      } catch (e, st) {
        AppLogger.error('AuthGate: failed to fetch profile for onboarding check', e, st);
        final repo = ref.read(onboardingPreferencesRepositoryProvider);
        final progress = await repo.getProgress();
        final resumeStep = progress.step >= 2 ? progress.step.clamp(2, 3) : 2;
        _routeToOnboarding(step: resumeStep);
      }
      return;
    }

    // 2. Offline / Hermetic test environment without active Supabase client
    final authState = ref.read(authProvider);
    if (authState is PicoAuthAuthenticated) {
      if (authState.isPersonalized) {
        _routeToHome();
      } else {
        final repo = ref.read(onboardingPreferencesRepositoryProvider);
        final progress = await repo.getProgress();
        final resumeStep = progress.step >= 2 ? progress.step.clamp(2, 3) : 2;
        _routeToOnboarding(step: resumeStep);
      }
    } else {
      final repo = ref.read(onboardingPreferencesRepositoryProvider);
      final progress = await repo.getProgress();
      final resumeStep = progress.step == 1 ? 1 : 0;
      _routeToOnboarding(step: resumeStep);
    }
  }

  void _routeToHome() {
    if (!mounted) return;

    try {
      FlutterNativeSplash.remove();
    } catch (_) {}

    setState(() {
      _isLoading = false;
      _destination = _AuthDestination.home;
    });

    if (GoRouter.maybeOf(context) != null) {
      context.go('/home');
    }
  }

  void _routeToOnboarding({int step = 0}) {
    if (!mounted) return;

    try {
      FlutterNativeSplash.remove();
    } catch (_) {}

    setState(() {
      _isLoading = false;
      _destination = _AuthDestination.onboarding;
      _onboardingStep = step;
    });

    if (GoRouter.maybeOf(context) != null) {
      context.go('/onboarding?step=$step');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        return widget.onboardingWidget ??
            OnboardingScreen(initialPage: _onboardingStep);
      }
    }

    // In GoRouter context, context.go('/home') or context.go('/onboarding')
    // triggers navigation; maintain clean pitch Scaffold with loader during transition.
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
