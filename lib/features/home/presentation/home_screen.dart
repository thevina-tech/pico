import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/profile/presentation/widgets/division_ladder_sheet.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/widgets/ads/banner_ad_widget.dart';

/// The official Pico Home screen modeled directly on Stitch "Pico home image.png".
///
/// Layout structure:
/// 1. Top bar:
///    - Left: Profile card with custom 3D avatar & real username (no Google account avatar).
///    - Center: Division card with 3D heraldic crest & division name.
///    - Right: Tactile hamburger menu button.
/// 2. Special Event card:
///    - Prominent cinematic match card (El Clásico / featured match) with stadium lighting,
///      LALIGA badge, team crests, and tactile "PREDICT NOW" action.
/// 3. How to Play section:
///    - Gamified 3-step walkthrough (Choose a match -> Make your prediction -> Earn points).
/// 4. Bottom navigation bar:
///    - Preserved [PicoBottomNavBar] integration with 4 game tabs.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.heroMatch,
    this.showBottomNavBar = true,
    this.currentNavIndex = 0,
    this.onNavTap,
    this.onNavigateMatches,
    this.onNavigateTournaments,
    this.onNavigateProfile,
    this.onMakePrediction,
    this.onViewLeaderboard,
    this.onMenuTap,
  });

  final PicoMatch? heroMatch;
  final bool showBottomNavBar;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onNavigateMatches;
  final VoidCallback? onNavigateTournaments;
  final VoidCallback? onNavigateProfile;
  final VoidCallback? onMakePrediction;
  final VoidCallback? onViewLeaderboard;
  final VoidCallback? onMenuTap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentNavIndex != widget.currentNavIndex) {
      _currentNavIndex = widget.currentNavIndex;
    }
  }

  void _navigateToMatches() {
    if (widget.onNavigateMatches != null) {
      widget.onNavigateMatches!();
    } else {
      context.go('/matches');
    }
  }

  void _navigateToTournaments() {
    if (widget.onNavigateTournaments != null) {
      widget.onNavigateTournaments!();
    } else {
      context.go('/tournaments');
    }
  }

  void _navigateToProfile() {
    if (widget.onNavigateProfile != null) {
      widget.onNavigateProfile!();
    } else {
      context.go('/profile');
    }
  }

  void _openDetailedPrediction(PicoMatch match) {
    if (widget.onMakePrediction != null) {
      widget.onMakePrediction!();
    } else {
      context.push('/prediction/${match.id}', extra: match);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final profile = profileAsync.value ??
        const UserProfile(
          id: 'guest',
          username: null,
          level: 1,
          xp: 0,
          streak: 0,
          coins: 0,
          totalPoints: 0,
        );

    final matchesAsync = ref.watch(matchesFeedProvider);
    final matches = matchesAsync.value ?? <PicoMatch>[];
    final allMatches = <PicoMatch>[...matches];
    if (widget.heroMatch != null &&
        !allMatches.any((m) => m.id == widget.heroMatch!.id)) {
      allMatches.insert(0, widget.heroMatch!);
    }
    final featuredMatch = allMatches.isNotEmpty ? allMatches.first : null;

    return PicoGameExitScope(
      child: Stack(
        children: [
          // 1. Full-Bleed Sunny Pitch Background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Transform.scale(
                scale: 1.02,
                child: Image.asset(
                  'assets/images/main_background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: PicoColors.pitchBackground,
                  ),
                ),
              ),
            ),
          ),

          // 2. Soft darkening overlay for text legibility
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.16),
              ),
            ),
          ),

          // 3. Subtle pitch contrast vignette
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.25, 0.60, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.30),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Scaffold hosting top bar, body content, and bottom navigation
          Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: widget.showBottomNavBar
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BannerAdWidget(placement: 'dashboard_bottom'),
                      Center(
                        heightFactor: 1.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440.0),
                          child: PicoBottomNavBar(
                            currentIndex: _currentNavIndex,
                            onTap: (idx) {
                              setState(() => _currentNavIndex = idx);
                              widget.onNavTap?.call(idx);
                              switch (idx) {
                                case 0:
                                  // Already Home
                                  break;
                                case 1:
                                  _navigateToMatches();
                                  break;
                                case 2:
                                  _navigateToTournaments();
                                  break;
                                case 3:
                                  _navigateToProfile();
                                  break;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : const BannerAdWidget(placement: 'dashboard_bottom'),
            body: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Greeting Section ("Hey {username}! 👋", "Ready to predict...", 3D Menu Button)
                      _buildGreetingSection(context, profile),

                      // Gap between greeting section and pills
                      const SizedBox(height: 14.0),

                      // 2. Pinned Top Bar: Profile Pill | Division Pill
                      _buildTopBar(context, profile),

                      // Gap between pills and scrollable content
                      const SizedBox(height: 12.0),

                      // 3. Scrollable Content
                      Expanded(
                        child: RefreshIndicator(
                          color: PicoColors.primary,
                          backgroundColor: PicoColors.pitchSurfaceElevated,
                          onRefresh: () async {
                            await ref.read(matchesFeedProvider.notifier).refresh();
                            await ref.read(currentUserProfileProvider.notifier).refresh();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Special Event Card (Cinematic Match Showcase)
                                _buildSpecialEventCard(context, featuredMatch),

                                // How to Play Section (Gamified 3-step loop)
                                _buildHowToPlaySection(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top greeting section: "Hey {username}! 👋", subtitle "Ready to predict...", and 3D Settings Menu Button
  Widget _buildGreetingSection(BuildContext context, UserProfile profile) {
    final l10n = AppLocalizations.of(context);
    final username = profile.username != null && profile.username!.isNotEmpty
        ? profile.username!
        : 'Player';

    final greeting = l10n?.homeGreeting(username) ?? 'Hey $username! 👋';
    final subtitle = l10n?.homeReadyToPredict ?? "Ready to predict today's biggest clash?";

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Headline + Subtitle (White high-contrast text)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 22.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    shadows: [
                      Shadow(
                        color: Color(0x66000000),
                        offset: Offset(0, 1.5),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.92),
                    letterSpacing: 0.1,
                    shadows: const [
                      Shadow(
                        color: Color(0x66000000),
                        offset: Offset(0, 1.0),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),

          // Right: 3D Tactile Menu Button (leads to Settings)
          GestureDetector(
            key: const Key('home_screen_menu_button'),
            onTap: () {
              if (widget.onMenuTap != null) {
                widget.onMenuTap!();
              } else {
                context.push('/settings');
              }
            },
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: const Color(0xFF0F3E26),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: const Color(0x334ADE80),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF061A0F),
                    offset: Offset(0, 3.5),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x26000000),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Top Bar: Profile Section (50% width) & Division Section (50% width)
  /// - Profile Section on Left: exact tactile design as create/join league button
  /// - Division Section on Right: shield icon + translated division title
  Widget _buildTopBar(BuildContext context, UserProfile profile) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Left: User Profile Pill with same 3D design as create/join button
          Expanded(
            child: _TactileProfilePill(
              profile: profile,
              onTap: _navigateToProfile,
              onLongPress: () {
                if (widget.onMenuTap != null) {
                  widget.onMenuTap!();
                } else {
                  context.push('/settings');
                }
              },
            ),
          ),

          const SizedBox(width: 10.0),

          // Right: Division Pill (50% of available width)
          Expanded(
            child: _buildDivisionPill(profile, l10n),
          ),
        ],
      ),
    );
  }

  /// Division Pill: shows only user's division with a shield icon in the division color
  Widget _buildDivisionPill(UserProfile profile, AppLocalizations? l10n) {
    final divisionTitle = l10n != null
        ? profile.division.localizedTitle(l10n)
        : profile.division.defaultTitle;

    return GestureDetector(
      key: const Key('home_screen_division_pill'),
      onTap: () => DivisionLadderSheet.show(context, profile),
      child: Container(
        height: 56.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: const Color(0xFF092013),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: profile.division.borderColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF040E08),
              offset: Offset(0, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Shield showing the division level color
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: const Color(0xFF13281C),
                borderRadius: BorderRadius.circular(11.0),
                border: Border.all(
                  color: profile.division.borderColor.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.shield_rounded,
                  color: profile.division.primaryColor,
                  size: 24.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // User's Division
            Expanded(
              child: Text(
                divisionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Special Event Card modeled on Stitch "Pico home image.png"
  /// - Upper half: Arena floodlights banner, red LALIGA badge, gold "EL CLÁSICO" title & kickoff.
  /// - Lower half: White/cream card face, Real Madrid & Barcelona crests, VS circle, and tactile PREDICT NOW action.
  Widget _buildSpecialEventCard(BuildContext context, PicoMatch? featuredMatch) {
    final homeTeam = featuredMatch?.homeTeamName ?? 'Real Madrid';
    final awayTeam = featuredMatch?.awayTeamName ?? 'Barcelona';
    final competition = featuredMatch != null
        ? featuredMatch.competitionName.toUpperCase()
        : 'LALIGA';
    final kickoff = featuredMatch != null
        ? '📅 ${featuredMatch.kickoffTimeFormatted}'
        : '📅 Sat, 26 Oct • 21:00';

    final predictions = ref.watch(predictionControllerProvider);
    final predictionMap = predictions.value;
    final existing = (featuredMatch != null && predictionMap != null)
        ? predictionMap[featuredMatch.id]
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(color: const Color(0xFF1E432F), width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF040E08),
              offset: Offset(0, 4.0),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upper Half: Stadium Banner with Title & Kickoff
              SizedBox(
                height: 140.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner Image
                    Image.asset(
                      'assets/images/el_clasico_banner.png',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF131B38),
                              Color(0xFF381428),
                              Color(0xFF1E0E1B),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Atmospheric Gradient Overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.68),
                          ],
                        ),
                      ),
                    ),

                    // Text & Badges Overlay
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // League Badge (Red LALIGA badge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE52535),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              competition,
                              style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 10.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Match Title ("EL CLÁSICO")
                          const Text(
                            'EL CLÁSICO',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 25.0,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFF7C85C),
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  offset: Offset(0, 2.0),
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 3.0),

                          // Kickoff / Time Label
                          Text(
                            kickoff,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),

                          const SizedBox(height: 2.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lower Half: Cream Surface with Teams & Predict Button
              Container(
                color: const Color(0xFFF5F3EC),
                padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
                child: Column(
                  children: [
                    // Teams Matchup Row
                    Row(
                      children: [
                        // Home Team
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTeamCrest(
                                badgeUrl: featuredMatch?.homeTeamBadgeUrl,
                                isRealMadrid: homeTeam.contains('Real Madrid'),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                homeTeam,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1C2421),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Center VS Indicator
                        Container(
                          width: 36.0,
                          height: 36.0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE4E1D8),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 13.0,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF284836),
                              ),
                            ),
                          ),
                        ),

                        // Away Team
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTeamCrest(
                                badgeUrl: featuredMatch?.awayTeamBadgeUrl,
                                isBarcelona: awayTeam.contains('Barcelona'),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                awayTeam,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1C2421),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12.0),

                    // Prediction Action Button
                    GestureDetector(
                      onTap: () {
                        if (featuredMatch != null) {
                          _openDetailedPrediction(featuredMatch);
                        } else {
                          _navigateToMatches();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 42.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: const Color(0xFF14532D),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF0F3D1F),
                              offset: Offset(0, 3.0),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sports_soccer_rounded,
                                size: 18.0,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                existing != null
                                    ? 'PREDICTED: ${existing.homeScore} - ${existing.awayScore}'
                                    : 'PREDICT NOW',
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Team crest icon container
  Widget _buildTeamCrest({
    String? badgeUrl,
    bool isRealMadrid = false,
    bool isBarcelona = false,
  }) {
    return Container(
      width: 46.0,
      height: 46.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFDDD9CF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.shield_rounded,
          color: isRealMadrid
              ? const Color(0xFF0C2340)
              : (isBarcelona ? const Color(0xFFA50044) : const Color(0xFF1E3A2B)),
          size: 26.0,
        ),
      ),
    );
  }

  /// 3. How to Play Section modeled on Stitch "Pico home image.png"
  /// - Left: "HOW TO" (neon mint), "PLAY" (golden yellow), "Predict. Compete. Earn."
  /// - Right: 3 step cards (Choose a match -> Make your prediction -> Earn points)
  Widget _buildHowToPlaySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF092013),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: const Color(0xFF1E432F), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF040E08),
              offset: Offset(0, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Title Column
            SizedBox(
              width: 90.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'HOW TO',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF38EF7D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'PLAY',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 24.0,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE5B348),
                      height: 1.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Predict. Compete. Earn.',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E9E80),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4.0),

            // Right Row: 3 Step Cards connected with Chevrons
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Step 1: Choose a Match
                  _buildHowToStepCard(
                    stepNumber: '1',
                    label: 'CHOOSE\nA MATCH',
                    graphic: const Center(
                      child: Text(
                        '⚽',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14.0,
                    color: Color(0xFF285438),
                  ),

                  // Step 2: Make Your Prediction
                  _buildHowToStepCard(
                    stepNumber: '2',
                    label: 'MAKE YOUR\nPREDICTION',
                    graphic: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _ScoreTile('2'),
                        SizedBox(width: 2.0),
                        _ScoreTile('1'),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14.0,
                    color: Color(0xFF285438),
                  ),

                  // Step 3: Earn Points
                  _buildHowToStepCard(
                    stepNumber: '3',
                    label: 'EARN\nPOINTS',
                    graphic: const Center(
                      child: Text(
                        '🏆',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single step card inside "HOW TO PLAY"
  Widget _buildHowToStepCard({
    required String stepNumber,
    required String label,
    required Widget graphic,
  }) {
    return Container(
      width: 60.0,
      padding: const EdgeInsets.fromLTRB(3.0, 6.0, 3.0, 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2B1B),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFF1E4830), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Graphic container
          SizedBox(
            height: 22.0,
            child: Center(child: graphic),
          ),

          const SizedBox(height: 4.0),

          // Number badge
          Container(
            width: 15.0,
            height: 15.0,
            decoration: BoxDecoration(
              color: const Color(0xFF183B25),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E6B44), width: 1.0),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  color: Colors.white,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4.0),

          // Label pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            decoration: BoxDecoration(
              color: const Color(0xFFD6D3C8),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A241E),
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tactile score digit card inside "HOW TO PLAY"
class _ScoreTile extends StatelessWidget {
  const _ScoreTile(this.digit);
  final String digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E5DC),
        borderRadius: BorderRadius.circular(2.5),
        border: Border.all(color: const Color(0xFFB0AC9F), width: 0.8),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E3A2B),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Tactile 2.5D profile pill with the same physical design and press-down dynamics as the create/join button.
class _TactileProfilePill extends StatefulWidget {
  const _TactileProfilePill({
    required this.profile,
    required this.onTap,
    this.onLongPress,
  });

  final UserProfile profile;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_TactileProfilePill> createState() => _TactileProfilePillState();
}

class _TactileProfilePillState extends State<_TactileProfilePill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 3.5;
    final double translationY = _isPressed ? bevel : 0.0;
    final double currentBevel = _isPressed ? 0.5 : bevel;

    final username = widget.profile.username != null && widget.profile.username!.isNotEmpty
        ? widget.profile.username!
        : 'Player';

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: GestureDetector(
        key: const Key('home_screen_profile_pill'),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, translationY, 0.0),
          height: 56.0,
          padding: const EdgeInsets.fromLTRB(10.0, 6.0, 12.0, 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD41D),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFFFF7C2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9E6500),
                offset: Offset(0, currentBevel),
                blurRadius: 0,
              ),
              BoxShadow(
                color: const Color(0x66FFD41D),
                offset: Offset(0, currentBevel + 2),
                blurRadius: 10,
              ),
              const BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 5),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container with exact same translucent tint as create/join button
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF261700).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person_rounded,
                  size: 22.0,
                  color: Color(0xFF261700),
                ),
              ),
              const SizedBox(width: 10.0),

              // Username + Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF261700),
                        letterSpacing: 0.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'LVL ${widget.profile.level}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF261700).withValues(alpha: 0.7),
                        letterSpacing: 0.2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
