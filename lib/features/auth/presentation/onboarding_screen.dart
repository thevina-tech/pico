import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

/// The official Pico Onboarding Funnel screen.
///
/// Houses a smooth two-step onboarding sequence matching Stitch:
/// - Step 1/5: "Pico — Onboarding Welcome" (`a710be47910c41288300983d419aac7a`)
/// - Step 2/5: "Pico — How Pico Works" (`135649edac1d43758bf6b8fd802338ae`)
///
/// Tapping "Continue" on Step 2 completes anonymous authentication and
/// proceeds to Step 3/5: Personalization (`/personalization`).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    this.initialPage = 0,
  });

  /// The starting step page index: 0 for Welcome (1/5), 1 for How Pico Works (2/5).
  final int initialPage;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  late int _currentPage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(0, 1);
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToHowItWorks() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _currentPage = 1);
    }
  }

  void _goToWelcome() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _currentPage = 0);
    }
  }

  void _handleBack() {
    if (_pageController.hasClients && _currentPage > 0) {
      _goToWelcome();
      return;
    }
    try {
      if (context.canPop()) {
        context.pop();
        return;
      }
    } catch (_) {}
  }

  Future<void> _handleContinueToPersonalization() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signInAnonymously();
      if (mounted) {
        context.go('/personalization');
      }
    } catch (e) {
      if (mounted) {
        final message =
            e is supa.AuthApiException ? e.message : 'Failed to sign in: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: PicoColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isAuthenticating = _isLoading || authState is PicoAuthAuthenticating;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentPage > 0) {
          _goToWelcome();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1B13),
        body: PicoPitchBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    // Step 1/5: Welcome
                    _OnboardingWelcomeStep(
                      l10n: l10n,
                      onGetStarted: _goToHowItWorks,
                    ),

                    // Step 2/5: How Pico Works
                    _OnboardingHowItWorksStep(
                      l10n: l10n,
                      isAuthenticating: isAuthenticating,
                      onBack: _handleBack,
                      onSkip: _handleContinueToPersonalization,
                      onContinue: _handleContinueToPersonalization,
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
    required this.onSkip,
    required this.onContinue,
  });

  final AppLocalizations? l10n;
  final bool isAuthenticating;
  final VoidCallback onBack;
  final VoidCallback onSkip;
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
                  // 1. Top Header: Back Button + Step 2/5 Pill + Skip Action
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
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Action Button
          GestureDetector(
            onTap: isAuthenticating ? null : onBack,
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

          // 5-Step Segmented Pill (Step 2/5 Active Glowing Gold)
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
                // Dot 1 (Completed / Visited)
                Container(
                  width: 12.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: const Color(0x8099F6B6),
                    borderRadius: BorderRadius.circular(999.0),
                  ),
                ),
                const SizedBox(width: 6.0),

                // Dot 2 (Active Pill Glowing Gold)
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

                // Dot 3
                _buildDot(),
                const SizedBox(width: 6.0),

                // Dot 4
                _buildDot(),
                const SizedBox(width: 6.0),

                // Dot 5
                _buildDot(),
                const SizedBox(width: 8.0),

                // Step Counter Text
                const Text(
                  '2/5',
                  style: TextStyle(
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

          // Skip Action
          TextButton(
            onPressed: isAuthenticating ? null : onSkip,
            child: Text(
              l10n?.skipButton ?? 'Skip',
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
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
        color: Colors.white.withValues(alpha: 0.20),
        shape: BoxShape.circle,
      ),
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
          // Championship Warm Gold Action Button ("Continue →")
          _TactileGoldButton(
            text: l10n?.continueButton ?? 'Continue',
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
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFDFA0), Color(0xFFF1CB7A), Color(0xFFE2C384)],
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF775F2A),
                    offset: Offset(0, bevelHeight),
                  ),
                  BoxShadow(
                    color: Color(0x59000000),
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Gloss Reflective Stripe
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 24.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16.0)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            if (widget.isLoading)
              const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF261A00)),
                ),
              )
            else
              Row(
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
          ],
        ),
      ),
    );
  }
}
