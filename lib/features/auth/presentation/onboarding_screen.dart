import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/core/utils/input_sanitizer.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/core/network/supabase_client_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/profile/data/profile_repository.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/personalization_controller.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/pico_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// The official Pico Onboarding Funnel screen.
///
/// Houses a smooth five-step linear onboarding sequence:
/// - Step 1/5: Welcome Screen
/// - Step 2/5: How Pico Works
/// - Step 3/5: Authentication & Username
/// - Step 4/5: Choose Favorite Team (Database Driven)
/// - Step 5/5: Choose 2 Leagues (Database Driven)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.initialPage = 0,
  });

  /// The starting step page index (0 to 4).
  final int initialPage;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  late int _currentPage;
  String _username = '';
  String? _selectedTeamId;
  final Set<String> _selectedLeagueIds = {};
  String? _step3ErrorMessage;
  bool _isGoogleAuthenticating = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);

    // If already authenticated from a previous session:
    // Never show Welcome (0) or How It Works (1) to an authenticated user
    if (authState is PicoAuthAuthenticated) {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile != null &&
          profile.username != null &&
          profile.username!.trim().isNotEmpty &&
          !profile.username!.startsWith('Guest_')) {
        _username = profile.username!;
        if (profile.favoriteTeamId != null) {
          _selectedTeamId = profile.favoriteTeamId;
          _currentPage = 4; // Step 5: Leagues Selection
        } else {
          _currentPage = 3; // Step 4: Team Selection
        }
      } else {
        // Incomplete profile missing username: start at Step B (Unique Username Selection)
        _currentPage = widget.initialPage >= 2 ? widget.initialPage.clamp(2, 4) : 2;
      }
    } else {
      // Unauthenticated user: show the requested initialPage (defaults to 1: How it works)
      _currentPage = widget.initialPage.clamp(0, 4);
    }
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  supa.SupabaseClient? _getSupabaseClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return ref.read(supabaseClientProvider);
    }
  }

  void _goToPage(int page) {
    if (page >= 2 && widget.initialPage < 2) {
      final client = _getSupabaseClient();
      final currentAuth = ref.read(authProvider);
      final l10n = AppLocalizations.of(context);

      if (client != null) {
        final currentUser = client.auth.currentUser;
        if (currentUser == null ||
            currentUser.email == null ||
            currentUser.email!.isEmpty) {
          PicoSnackBar.showError(
            context,
            l10n?.signInWithGooglePrompt ??
                'Please sign in with Google to continue.',
          );
          return;
        }
      } else if (currentAuth is! PicoAuthAuthenticated) {
        PicoSnackBar.showError(
          context,
          l10n?.signInWithGooglePrompt ??
              'Please sign in with Google to continue.',
        );
        return;
      }
    }

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _currentPage = page);
    }
  }

  void _handleBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
      return;
    }
    try {
      if (context.canPop()) {
        context.pop();
        return;
      }
    } catch (_) {}
  }

  Future<void> _handleGoogleSignIn() async {
    final client = _getSupabaseClient();
    final existingUser = client?.auth.currentUser;
    if (existingUser != null &&
        existingUser.email != null &&
        existingUser.email!.isNotEmpty) {
      // User is already authenticated with Google; advance directly
      _goToPage(2);
      return;
    }

    setState(() => _isGoogleAuthenticating = true);
    try {
      final user = await ref.read(authProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        // User cancelled Google sign-in; dismiss loading gracefully
        setState(() => _isGoogleAuthenticating = false);
        return;
      }

      // Query database profile to check if returning user already has a chosen username
      try {
        final profile =
            await ref.read(profileRepositoryProvider).getProfile(user.id);
        if (!mounted) return;
        if (profile != null &&
            profile.username != null &&
            profile.username!.trim().isNotEmpty &&
            !profile.username!.startsWith('Guest_')) {
          // Returning user: bypass onboarding and route directly to /home
          ref.read(authProvider.notifier).markPersonalized();
          context.go('/home');
          return;
        }
      } catch (profileError) {
        AppLogger.warning('Returning user profile check skipped: $profileError');
      }

      // New user without established username: advance to Step 3 (index 2: Username)
      if (mounted) {
        setState(() => _isGoogleAuthenticating = false);
        _goToPage(2);
      }
    } catch (e, st) {
      AppLogger.error('Google sign-in error in onboarding', e, st);
      if (mounted) {
        setState(() => _isGoogleAuthenticating = false);
        PicoSnackBar.showError(
          context,
          'Failed to sign in with Google: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: PicoPitchBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    // Step 1/5: Welcome
                    _OnboardingWelcomeStep(
                      l10n: l10n,
                      onGetStarted: () => _goToPage(1),
                    ),

                    // Step 2/5: How Pico Works (Continue with Google)
                    _OnboardingHowItWorksStep(
                      l10n: l10n,
                      isAuthenticating: _isGoogleAuthenticating,
                      onBack: () => _goToPage(0),
                      onContinue: _handleGoogleSignIn,
                    ),

                    // Step 3/5: Authentication & Username
                    _OnboardingAuthStep(
                      l10n: l10n,
                      username: _username,
                      errorMessage: _step3ErrorMessage,
                      onBack: () => _goToPage(1),
                      onUsernameConfirmed: (username) {
                        setState(() {
                          _username = username;
                          _step3ErrorMessage = null;
                        });
                        _goToPage(3);
                      },
                    ),

                    // Step 4/5: Choose Favorite Team (Database Driven)
                    _OnboardingTeamSelectionStep(
                      l10n: l10n,
                      selectedTeamId: _selectedTeamId,
                      onBack: () => _goToPage(2),
                      onContinue: (teamId) {
                        setState(() => _selectedTeamId = teamId);
                        _goToPage(4);
                      },
                    ),

                    // Step 5/5: Choose 1 or 2 Leagues (Database Driven)
                    _OnboardingLeaguesSelectionStep(
                      l10n: l10n,
                      username: _username,
                      selectedTeamId: _selectedTeamId,
                      selectedLeagueIds: _selectedLeagueIds,
                      onBack: () => _goToPage(3),
                      onLeaguesChanged: (leagues) {
                        setState(() {
                          _selectedLeagueIds.clear();
                          _selectedLeagueIds.addAll(leagues);
                        });
                      },
                      onUsernameConflict: (error) {
                        setState(() {
                          _step3ErrorMessage = error;
                        });
                        PicoSnackBar.showError(context, error);
                        _goToPage(2);
                      },
                      onAuthRequired: () {
                        PicoSnackBar.showError(
                          context,
                          l10n?.signInWithGoogleSetupPrompt ??
                              'Please sign in with Google to complete your account setup.',
                        );
                        _goToPage(1);
                      },
                      onFinished: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Step 1/5: Welcome Screen (Stitch `a710be47910c41288300983d419aac7a`)
class _OnboardingWelcomeStep extends StatelessWidget {
  const _OnboardingWelcomeStep({
    required this.l10n,
    required this.onGetStarted,
  });

  final AppLocalizations? l10n;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Top Section: Step Dots & Brand
                  _buildTopHeader(),

                  const SizedBox(height: 16.0),

                  // 2. Center Hero: Mascot Showcase
                  _buildMascotHero(),

                  const SizedBox(height: 16.0),

                  // 3. Bottom Section: Value Proposition & CTA
                  _buildBottomActionArea(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          // 5-Step Segmented Dots (Dot 1 Active Pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xB3081810),
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Active Pill (Step 1)
                Container(
                  width: 24.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDFA0),
                    borderRadius: BorderRadius.circular(999.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99FFDFA0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6.0),
                _buildDot(),
                const SizedBox(width: 6.0),
                _buildDot(),
                const SizedBox(width: 6.0),
                _buildDot(),
                const SizedBox(width: 6.0),
                _buildDot(),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Brand Emblem + Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFDFA0), Color(0xFFE2C384)],
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF594311),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 20.0,
                  color: Color(0xFF261A00),
                ),
              ),
              const SizedBox(width: 10.0),
              const Text(
                'Pico Football',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFAF9F4),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 6.0,
      height: 6.0,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMascotHero() {
    return SizedBox(
      width: 250.0,
      height: 250.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glowing Ring
          Container(
            width: 240.0,
            height: 240.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  PicoColors.primary.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: const Color(0x4DE2C384),
                width: 1.5,
              ),
            ),
          ),

          // Inner Tactile Sunken Tray
          Container(
            width: 210.0,
            height: 210.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF103021), Color(0xFF0A1F15)],
              ),
              border: Border.all(
                color: const Color(0x80FFDFA0),
                width: 2.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 16.0,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Center(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA1IWeqmX9ae_kCOoMYPk0Vt7LeU5ZGWmErLX-WD3iCrGCGyMlrAiwFxnmtIkMmwZbvI06SZRpOkeJL8_9HZgXLgpqbNGSZkU_cvb1ejOYbOEQRRl9Rwz_vRDzY-sanVkVXaX8c6j5RUEf_sunT4E_N0yvSoGmaWHp0NiTQGeNCDm4yiYH24GzusZS9VyenW8lUsOmVEnlJolGidUPUXrpZeIhkVpXPeSZOg-JacfW4DZQLoSDNrogZPQ',
                  fit: BoxFit.contain,
                  width: 175.0,
                  height: 175.0,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.sports_soccer,
                    size: 80.0,
                    color: PicoColors.gold,
                  ),
                ),
              ),
            ),
          ),

          // Floating Mini Badge Top-Right: "⚽ Kickoff"
          Positioned(
            top: 10.0,
            right: 8.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFDBDAD5),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚽', style: TextStyle(fontSize: 13.0)),
                  SizedBox(width: 4.0),
                  Text(
                    'KICKOFF',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF006A3A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Mini Badge Bottom-Left: "⭐ Ready"
          Positioned(
            bottom: 12.0,
            left: 6.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFDFA0), Color(0xFFE2C384)],
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF775F2A),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 13.0, color: Color(0xFF261A00)),
                  SizedBox(width: 4.0),
                  Text(
                    'READY',
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF261A00),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          // Value Proposition
          Text(
            l10n?.onboardingWelcomeTitle ??
                'Predict Football.\nCompete with Friends.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 28.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFAF9F4),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              l10n?.onboardingWelcomeSubtitle ??
                  'Call match scores, bank Pico Points, and battle your friends on private & global leaderboards.',
              textAlign: TextAlign.center,
              style: PicoTypography.bodyMd.copyWith(
                color: const Color(0xFFE9E8E3).withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Championship Warm Gold Action Button ("Get Started →")
          _TactileGoldButton(
            text: l10n?.getStartedButton ?? 'Get Started',
            onPressed: onGetStarted,
          ),
          const SizedBox(height: 12.0),

          // Setup Speed Assurance Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bolt,
                size: 16.0,
                color: Color(0xFF00E297),
              ),
              const SizedBox(width: 4.0),
              Flexible(
                child: Text(
                  l10n?.setupSpeedHint ?? 'Takes less than 1 minute to set up.',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFBECABE),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Step 2/5: How Pico Works Screen (Stitch `135649edac1d43758bf6b8fd802338ae`)
class _OnboardingHowItWorksStep extends StatelessWidget {
  const _OnboardingHowItWorksStep({
    required this.l10n,
    required this.isAuthenticating,
    required this.onBack,
    required this.onContinue,
  });

  final AppLocalizations? l10n;
  final bool isAuthenticating;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Top Header: Back Button + Step 2/5 Pill (No Skip)
                  _buildHeader(),

                  const SizedBox(height: 12.0),

                  // 2. Center Content: Mascot + Headline + 3 Cards
                  _buildExplainerContent(),

                  const SizedBox(height: 16.0),

                  // 3. Bottom Docked CTA Area
                  _buildBottomActionArea(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return _OnboardingStepHeader(
      currentStep: 2,
      onBack: onBack,
      isBackEnabled: !isAuthenticating,
    );
  }

  Widget _buildExplainerContent() {
    return Column(
      children: [
        // Mascot Emblem Hero with Radial Emerald Aura
        SizedBox(
          width: 80.0,
          height: 80.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x334DFFB2), Colors.transparent],
                  ),
                ),
              ),
              Container(
                width: 72.0,
                height: 72.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F2C1E),
                  border: Border.all(
                    color: const Color(0x80FFDFA0),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuA1IWeqmX9ae_kCOoMYPk0Vt7LeU5ZGWmErLX-WD3iCrGCGyMlrAiwFxnmtIkMmwZbvI06SZRpOkeJL8_9HZgXLgpqbNGSZkU_cvb1ejOYbOEQRRl9Rwz_vRDzY-sanVkVXaX8c6j5RUEf_sunT4E_N0yvSoGmaWHp0NiTQGeNCDm4yiYH24GzusZS9VyenW8lUsOmVEnlJolGidUPUXrpZeIhkVpXPeSZOg-JacfW4DZQLoSDNrogZPQ',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.sports_soccer,
                      size: 36.0,
                      color: PicoColors.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14.0),

        // Headline & Subtitle
        Text(
          l10n?.howPicoWorksTitle ?? 'How Pico Works',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 28.0,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          l10n?.howPicoWorksSubtitle ?? 'Simple, fast, and built for matchdays.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.70),
          ),
        ),
        const SizedBox(height: 24.0),

        // 3 Tactile Explainer Cards (Predict, Compete, Win)
        _ExplainerCard(
          stepNumber: '1',
          badgeColor: const Color(0xFF006A3A),
          badgeShadowColor: const Color(0xFF004726),
          textColor: Colors.white,
          title: l10n?.step1Title ?? 'Predict the score',
          subtitle: l10n?.step1Description ?? 'Quick picks before kickoff',
        ),
        const SizedBox(height: 12.0),
        _ExplainerCard(
          stepNumber: '2',
          badgeColor: const Color(0xFFFFDFA0),
          badgeShadowColor: const Color(0xFFD9B368),
          textColor: const Color(0xFF261A00),
          title: l10n?.step2Title ?? 'Earn points & climb',
          subtitle: l10n?.step2Description ?? 'Score accurate calls each week',
        ),
        const SizedBox(height: 12.0),
        _ExplainerCard(
          stepNumber: '3',
          badgeColor: const Color(0xFF008557),
          badgeShadowColor: const Color(0xFF00593B),
          textColor: Colors.white,
          title: l10n?.step3Title ?? 'Win tournament trophies',
          subtitle: l10n?.step3Description ?? 'Top friends and global ranks',
        ),
      ],
    );
  }

  Widget _buildBottomActionArea() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          // Google Sign-In Action Button ("Continue with Google")
          _TactileGoogleButton(
            text: l10n?.continueWithGoogle ?? 'Continue with Google',
            isLoading: isAuthenticating,
            onPressed: isAuthenticating ? null : onContinue,
          ),
          const SizedBox(height: 10.0),

          // Next Step Microcopy
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 14.0,
                color: Color(0xFFBECABE),
              ),
              const SizedBox(width: 5.0),
              Flexible(
                child: Text(
                  l10n?.nextStepHint ??
                      'Next: Pick your favorite starting team (15 sec)',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xB3FFFFFF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tactile Explainer Card displaying a number badge, title, and descriptive subtitle.
class _ExplainerCard extends StatelessWidget {
  const _ExplainerCard({
    required this.stepNumber,
    required this.badgeColor,
    required this.badgeShadowColor,
    required this.textColor,
    required this.title,
    required this.subtitle,
  });

  final String stepNumber;
  final Color badgeColor;
  final Color badgeShadowColor;
  final Color textColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Number Badge (Tactile 3D Block)
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: badgeShadowColor,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(width: 14.0),

          // Text Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.60),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>''';

/// 3D Tactile Google Sign-in Button with authentic Google logo and Stitch tactile styling.
class _TactileGoogleButton extends StatefulWidget {
  const _TactileGoogleButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_TactileGoogleButton> createState() => _TactileGoogleButtonState();
}

class _TactileGoogleButtonState extends State<_TactileGoogleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevelHeight = 4.0;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        margin: EdgeInsets.only(
          top: _isPressed ? bevelHeight : 0,
          bottom: _isPressed ? 0 : bevelHeight,
        ),
        width: double.infinity,
        height: 56.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFFCBD5E1),
                    offset: Offset(0, bevelHeight),
                  ),
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.string(
                      _googleSvg,
                      width: 22.0,
                      height: 22.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18.0,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// 3D Tactile Warm Gold Button implementing Stitch button-press-offset aesthetics.
class _TactileGoldButton extends StatefulWidget {
  const _TactileGoldButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_TactileGoldButton> createState() => _TactileGoldButtonState();
}

class _TactileGoldButtonState extends State<_TactileGoldButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevelHeight = 4.0;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        margin: EdgeInsets.only(
          top: _isPressed ? bevelHeight : 0,
          bottom: _isPressed ? 0 : bevelHeight,
        ),
        width: double.infinity,
        height: 56.0,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD41D),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFFFF7C2),
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF9E6500),
                    offset: Offset(0, bevelHeight),
                  ),
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF261A00)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF261A00),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.arrow_forward,
                      size: 20.0,
                      color: Color(0xFF261A00),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

String? _cleanUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  return url.split('?').first;
}

/// Reusable top step header with back action, 5-dot segmented progress capsule, and step counter.
class _OnboardingStepHeader extends StatelessWidget {
  const _OnboardingStepHeader({
    required this.currentStep,
    required this.onBack,
    this.isBackEnabled = true,
  });

  final int currentStep;
  final VoidCallback onBack;
  final bool isBackEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Action Button
          GestureDetector(
            onTap: isBackEnabled ? onBack : null,
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4.0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20.0,
              ),
            ),
          ),

          // 5-Step Segmented Capsule
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0x4D000000),
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 1; i <= 5; i++) ...[
                  if (i == currentStep)
                    Container(
                      width: 24.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDFA0),
                        borderRadius: BorderRadius.circular(999.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99FFDFA0),
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                    )
                  else if (i < currentStep)
                    Container(
                      width: 12.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: const Color(0x8099F6B6),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                    )
                  else
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (i < 5) const SizedBox(width: 6.0),
                ],
                const SizedBox(width: 8.0),
                Text(
                  '$currentStep/5',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xE6FFFFFF),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Right side: empty balancing box
          const SizedBox(width: 40.0),
        ],
      ),
    );
  }
}

/// Step 3/5: Authentication & Username Step.
class _OnboardingAuthStep extends ConsumerStatefulWidget {
  const _OnboardingAuthStep({
    required this.l10n,
    required this.username,
    required this.errorMessage,
    required this.onBack,
    required this.onUsernameConfirmed,
  });

  final AppLocalizations? l10n;
  final String username;
  final String? errorMessage;
  final VoidCallback onBack;
  final ValueChanged<String> onUsernameConfirmed;

  @override
  ConsumerState<_OnboardingAuthStep> createState() => _OnboardingAuthStepState();
}

class _OnboardingAuthStepState extends ConsumerState<_OnboardingAuthStep> {
  late final TextEditingController _usernameController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _errorMessage = widget.errorMessage;
  }

  @override
  void didUpdateWidget(covariant _OnboardingAuthStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.username != oldWidget.username &&
        widget.username != _usernameController.text) {
      _usernameController.text = widget.username;
    }
    if (widget.errorMessage != oldWidget.errorMessage &&
        widget.errorMessage != null) {
      setState(() => _errorMessage = widget.errorMessage);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final l10n = widget.l10n;
    final raw = _usernameController.text;
    final username = raw.trim();

    if (username.isEmpty) {
      setState(() {
        _errorMessage =
            l10n?.usernameErrorEmpty ?? 'Please introduce a username to continue.';
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _errorMessage =
            l10n?.usernameErrorTooShort ?? 'Username must be at least 3 characters';
      });
      return;
    }

    if (raw.contains(' ') || !InputSanitizer.isValidUsername(username)) {
      setState(() {
        _errorMessage = l10n?.usernameAlphanumericError ??
            'Username must be alphanumeric with no spaces';
      });
      return;
    }

    final cleanUsername = InputSanitizer.sanitizeUsername(username);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(profileRepositoryProvider);
      final authState = ref.read(authProvider);
      String? currentUserId;
      if (authState is PicoAuthAuthenticated && authState.user != null) {
        currentUserId = authState.user!.id;
      }

      // Pre-check if username is already taken by another user before advancing
      final isAvailable = await repo.isUsernameAvailable(
        cleanUsername,
        excludeUserId: currentUserId,
      );
      if (!isAvailable) {
        if (mounted) {
          setState(() {
            _errorMessage = l10n?.usernameTakenError ??
                'This username is already taken. Please choose another one.';
            _isLoading = false;
          });
        }
        return;
      }

      // Update personalization controller in-memory
      ref.read(personalizationControllerProvider.notifier).setUsername(cleanUsername);

      if (mounted) {
        widget.onUsernameConfirmed(cleanUsername);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header
                      _OnboardingStepHeader(
                        currentStep: 3,
                        onBack: widget.onBack,
                        isBackEnabled: !_isLoading,
                      ),
                      const SizedBox(height: 28.0),

                      // Shield / Identity Emblem
                      Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF142B20),
                          border: Border.all(
                            color: const Color(0xFFFFDFA0).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3300E297),
                              blurRadius: 18.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_pin_rounded,
                            size: 38.0,
                            color: Color(0xFFFFDFA0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Title
                      Text(
                        l10n?.step3AuthTitle ?? 'What Should We Call You?',
                        textAlign: TextAlign.center,
                        style: PicoTypography.headlineLgMobile.copyWith(
                          color: PicoColors.textWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 24.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Subtitle
                      Text(
                        l10n?.step3AuthSubtitle ??
                            'Pick a username for leaderboards and friend leagues.',
                        textAlign: TextAlign.center,
                        style: PicoTypography.bodyMd.copyWith(
                          color: const Color(0xFFBECABE),
                          fontSize: 14.0,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // Username Input Well
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF07140D),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: _errorMessage != null
                                ? PicoColors.error
                                : const Color(0xFF1E382B),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D000000),
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '@',
                              style: TextStyle(
                                color: Color(0xFFFFDFA0),
                                fontSize: 20.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: TextField(
                                controller: _usernameController,
                                enabled: !_isLoading,
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      l10n?.usernamePlaceholder ?? 'e.g. striker99',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleContinue(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: PicoColors.error,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Bottom Docked CTA Area
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 24.0),
                    child: _TactileGoldButton(
                      text: l10n?.continueButton ?? 'Continue',
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleContinue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Step 4/5: Choose Favorite Team (Database Driven from public.teams).
class _OnboardingTeamSelectionStep extends ConsumerStatefulWidget {
  const _OnboardingTeamSelectionStep({
    required this.l10n,
    required this.selectedTeamId,
    required this.onBack,
    required this.onContinue,
  });

  final AppLocalizations? l10n;
  final String? selectedTeamId;
  final VoidCallback onBack;
  final ValueChanged<String> onContinue;

  @override
  ConsumerState<_OnboardingTeamSelectionStep> createState() =>
      _OnboardingTeamSelectionStepState();
}

class _OnboardingTeamSelectionStepState
    extends ConsumerState<_OnboardingTeamSelectionStep> {
  String? _selectedTeamId;
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selectedTeamId = widget.selectedTeamId;
    _searchController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _OnboardingTeamSelectionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTeamId != oldWidget.selectedTeamId) {
      setState(() => _selectedTeamId = widget.selectedTeamId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_selectedTeamId != null) {
      ref
          .read(personalizationControllerProvider.notifier)
          .selectTeam(_selectedTeamId!);
      widget.onContinue(_selectedTeamId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final teamsAsync = ref.watch(availableTeamsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _OnboardingStepHeader(
            currentStep: 4,
            onBack: widget.onBack,
          ),
          const SizedBox(height: 16.0),

          // Title
          Text(
            l10n?.chooseFavoriteTeamTitle ?? 'Choose Favorite Team',
            style: PicoTypography.headlineLgMobile.copyWith(
              color: PicoColors.textWhite,
              fontWeight: FontWeight.w800,
              fontSize: 22.0,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4.0),

          // Subtitle
          Text(
            l10n?.chooseFavoriteTeamSubtitle ??
                'Select your club to personalize your feed and upcoming matches.',
            style: PicoTypography.bodySm.copyWith(
              color: const Color(0xFFBECABE),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 14.0),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: const Color(0xFF07140D),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 20.0,
                  color: Color(0xFF8AA695),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    inputFormatters: InputSanitizer.searchFormatters,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          l10n?.searchTeamsPlaceholder ?? 'Search clubs...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery =
                          InputSanitizer.sanitizeSearchQuery(val).toLowerCase());
                    },
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18.0,
                      color: Colors.white60,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Expanded Grid of Teams (Internally scrollable, keeping Continue button sticky!)
          Expanded(
            child: teamsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: PicoColors.gold),
              ),
              error: (err, _) => Center(
                child: Text(
                  widget.l10n?.failedToLoadTeams(err.toString()) ??
                      'Failed to load teams: $err',
                  style: const TextStyle(
                    color: PicoColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              data: (allTeams) {
                final filtered = _searchQuery.isEmpty
                    ? allTeams
                    : allTeams.where((t) {
                        final name = t.name.toLowerCase();
                        final code = (t.shortName ?? '').toLowerCase();
                        return name.contains(_searchQuery) ||
                            code.contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Text(
                        widget.l10n?.noClubsFound(_searchQuery) ??
                            'No clubs found matching "$_searchQuery"',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  itemCount: filtered.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final team = filtered[index];
                    final isSelected = _selectedTeamId == team.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedTeamId = team.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF142B20)
                              : const Color(0xFF0F2218),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: isSelected
                                ? PicoColors.gold
                                : Colors.white.withValues(alpha: 0.08),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x33FFDFA0),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl:
                                        _cleanUrl(team.crestUrl) ?? '',
                                    width: 44.0,
                                    height: 44.0,
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Container(
                                      width: 44.0,
                                      height: 44.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF152A1E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.shield_outlined,
                                        size: 24.0,
                                        color: Color(0xFF4C7B5D),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 44.0,
                                      height: 44.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF152A1E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.shield_outlined,
                                        size: 24.0,
                                        color: Color(0xFF4C7B5D),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    team.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFE0E0DC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: const BoxDecoration(
                                    color: PicoColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 13.0,
                                    color: Color(0xFF0B1B13),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Docked Sticky CTA Area (Visible at all times!)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _selectedTeamId != null
                            ? const Color(0x33FFDFA0)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                      child: Text(
                        _selectedTeamId != null
                            ? (l10n?.selectedTeamBadge ?? '1/1 Selected')
                            : '0/1 Selected',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _selectedTeamId != null
                              ? const Color(0xFFFFDFA0)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                _TactileGoldButton(
                  text: l10n?.continueButton ?? 'Continue',
                  isLoading: false,
                  onPressed: _selectedTeamId == null ? null : _handleContinue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Step 5/5: Choose 1 or 2 Leagues (Database Driven from public.competitions).
class _OnboardingLeaguesSelectionStep extends ConsumerStatefulWidget {
  const _OnboardingLeaguesSelectionStep({
    required this.l10n,
    required this.username,
    required this.selectedTeamId,
    required this.selectedLeagueIds,
    required this.onBack,
    required this.onLeaguesChanged,
    required this.onUsernameConflict,
    required this.onAuthRequired,
    required this.onFinished,
  });

  final AppLocalizations? l10n;
  final String username;
  final String? selectedTeamId;
  final Set<String> selectedLeagueIds;
  final VoidCallback onBack;
  final ValueChanged<Set<String>> onLeaguesChanged;
  final ValueChanged<String> onUsernameConflict;
  final VoidCallback onAuthRequired;
  final VoidCallback onFinished;

  @override
  ConsumerState<_OnboardingLeaguesSelectionStep> createState() =>
      _OnboardingLeaguesSelectionStepState();
}

class _OnboardingLeaguesSelectionStepState
    extends ConsumerState<_OnboardingLeaguesSelectionStep> {
  final Set<String> _selectedLeagueIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedLeagueIds.addAll(widget.selectedLeagueIds);
  }

  @override
  void didUpdateWidget(covariant _OnboardingLeaguesSelectionStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLeagueIds != oldWidget.selectedLeagueIds) {
      _selectedLeagueIds.clear();
      _selectedLeagueIds.addAll(widget.selectedLeagueIds);
    }
  }

  Future<void> _handleFinish() async {
    final l10n = widget.l10n;

    // Validate 1 or 2 leagues
    if (_selectedLeagueIds.isEmpty ||
        _selectedLeagueIds.length > 2 ||
        _isSubmitting) {
      if (_selectedLeagueIds.isEmpty && mounted) {
        PicoSnackBar.showError(
          context,
          l10n?.twoLeaguesRequired ??
              'Please select 1 or 2 leagues to continue.',
        );
      }
      return;
    }

    // Validate username is present
    final trimmedUsername = widget.username.trim();
    if (trimmedUsername.length < 3) {
      widget.onUsernameConflict(
        l10n?.usernameErrorTooShort ?? 'Username must be at least 3 characters',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(profileRepositoryProvider);

      // 1. Verify username availability before creating/saving account
      final isAvailable = await repo.isUsernameAvailable(trimmedUsername);
      if (!isAvailable) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          widget.onUsernameConflict(
            l10n?.usernameTakenError ??
                'This username is already taken. Please choose another one.',
          );
        }
        return;
      }

      // 2. Verify authenticated Google session (never create anonymous users)
      final currentAuth = ref.read(authProvider);
      supa.SupabaseClient? client;
      try {
        client = supa.Supabase.instance.client;
      } catch (_) {
        client = ref.read(supabaseClientProvider);
      }

      final String userId;
      if (client != null) {
        final currentUser = client.auth.currentUser;
        if (currentUser == null ||
            currentUser.email == null ||
            currentUser.email!.isEmpty) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            widget.onAuthRequired();
          }
          return;
        }
        userId = currentUser.id;
      } else if (currentAuth is PicoAuthAuthenticated && currentAuth.user != null) {
        userId = currentAuth.user!.id;
      } else {
        // Fallback for isolated widget tests without active Supabase client
        userId = 'test_user_id';
      }

      // 3. Atomically update user personalization with all gathered onboarding data
      await repo.updatePersonalization(
        userId: userId,
        username: trimmedUsername,
        favoriteTeamId: widget.selectedTeamId,
        favoriteTeamIds:
            widget.selectedTeamId != null ? [widget.selectedTeamId!] : null,
        favoriteLeagueIds: _selectedLeagueIds.toList(),
      );

      // 4. Auto-enroll user into default tournaments for their selected leagues
      final tournamentRepo = ref.read(tournamentRepositoryProvider);
      await tournamentRepo.enrollInDefaultTournaments(
        userId: userId,
        leagueIds: _selectedLeagueIds.toList(),
      );

      // 5. Update cached profile eagerly & mark as personalized in Auth state
      try {
        final updatedProfile = await repo.getProfile(userId);
        if (updatedProfile != null) {
          ref.read(currentUserProfileProvider.notifier).setProfile(updatedProfile);
        } else {
          ref.read(currentUserProfileProvider.notifier).setProfile(
            UserProfile(
              id: userId,
              username: trimmedUsername,
              favoriteTeamId: widget.selectedTeamId,
              favoriteTeamIds: widget.selectedTeamId != null ? [widget.selectedTeamId!] : const [],
              favoriteLeagueIds: _selectedLeagueIds.toList(),
            ),
          );
        }
      } catch (_) {}

      ref.read(authProvider.notifier).markPersonalized();
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(enrolledTournamentsProvider);
      ref.invalidate(matchesFeedProvider);

      if (mounted) {
        widget.onFinished();
      }
    } on supa.PostgrestException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (e.code == '23505' ||
            e.message.contains('profiles_username_key') ||
            e.message.contains('unique constraint')) {
          widget.onUsernameConflict(
            l10n?.usernameTakenError ??
                'This username is already taken. Please choose another one.',
          );
        } else {
          PicoSnackBar.showError(
            context,
            'Database error: ${e.message}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (e.toString().contains('23505') ||
            e.toString().contains('profiles_username_key') ||
            e.toString().toLowerCase().contains('taken') ||
            e.toString().toLowerCase().contains('unique constraint')) {
          widget.onUsernameConflict(
            l10n?.usernameTakenError ??
                'This username is already taken. Please choose another one.',
          );
          return;
        }
        PicoSnackBar.showError(
          context,
          'Failed to complete onboarding: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final compsAsync = ref.watch(supportedCompetitionsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _OnboardingStepHeader(
            currentStep: 5,
            onBack: widget.onBack,
            isBackEnabled: !_isSubmitting,
          ),
          const SizedBox(height: 16.0),

          // Title
          Text(
            l10n?.chooseLeaguesTitle ?? 'Choose Leagues',
            style: PicoTypography.headlineLgMobile.copyWith(
              color: PicoColors.textWhite,
              fontWeight: FontWeight.w800,
              fontSize: 22.0,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4.0),

          // Subtitle
          Text(
            l10n?.chooseLeaguesSubtitle ??
                'Select 1 or 2 competitions to follow and compete in.',
            style: PicoTypography.bodySm.copyWith(
              color: const Color(0xFFBECABE),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 16.0),

          // Expanded Grid of Competitions (Cards styled identically to team cards)
          Expanded(
            child: compsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: PicoColors.gold),
              ),
              error: (err, _) => Center(
                child: Text(
                  l10n?.failedToLoadCompetitions(err.toString()) ??
                      'Failed to load competitions: $err',
                  style: const TextStyle(
                    color: PicoColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              data: (competitions) {
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  itemCount: competitions.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final comp = competitions[index];
                    final isSelected =
                        _selectedLeagueIds.contains(comp.id);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedLeagueIds.remove(comp.id);
                          } else {
                            if (_selectedLeagueIds.length < 2) {
                              _selectedLeagueIds.add(comp.id);
                            } else {
                              PicoSnackBar.showInfo(
                                context,
                                l10n?.maxLeaguesReached ??
                                    'You can select up to 2 leagues.',
                                duration: const Duration(seconds: 2),
                              );
                            }
                          }
                        });
                        widget.onLeaguesChanged(_selectedLeagueIds);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF142B20)
                              : const Color(0xFF0F2218),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: isSelected
                                ? PicoColors.gold
                                : Colors.white.withValues(alpha: 0.08),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x33FFDFA0),
                                    blurRadius: 10.0,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Emblem or Flag matching team card 44x44
                                  if (comp.emblemUrl != null &&
                                      comp.emblemUrl!.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl:
                                          _cleanUrl(comp.emblemUrl) ?? '',
                                      width: 44.0,
                                      height: 44.0,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Container(
                                        width: 44.0,
                                        height: 44.0,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF152A1E),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          comp.displayFlag,
                                          style: const TextStyle(fontSize: 26.0),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 44.0,
                                        height: 44.0,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF152A1E),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          comp.displayFlag,
                                          style: const TextStyle(fontSize: 26.0),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 44.0,
                                      height: 44.0,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF152A1E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        comp.displayFlag,
                                        style: const TextStyle(fontSize: 26.0),
                                      ),
                                    ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    comp.displayName,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 12.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFE0E0DC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  decoration: const BoxDecoration(
                                    color: PicoColors.gold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 13.0,
                                    color: Color(0xFF0B1B13),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Docked Sticky CTA Area (Visible at all times!)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: (_selectedLeagueIds.isNotEmpty &&
                                _selectedLeagueIds.length <= 2)
                            ? const Color(0x33FFDFA0)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999.0),
                      ),
                      child: Text(
                        l10n?.leaguesSelectedBadge(_selectedLeagueIds.length) ??
                            '${_selectedLeagueIds.length}/2 Selected',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: (_selectedLeagueIds.isNotEmpty &&
                                  _selectedLeagueIds.length <= 2)
                              ? const Color(0xFFFFDFA0)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                _TactileGoldButton(
                  text: l10n?.finishButton ?? 'Finish',
                  isLoading: _isSubmitting,
                  onPressed: (_selectedLeagueIds.isNotEmpty &&
                          _selectedLeagueIds.length <= 2 &&
                          !_isSubmitting)
                      ? _handleFinish
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

