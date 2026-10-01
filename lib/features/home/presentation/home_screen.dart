import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/profile/presentation/widgets/division_ladder_sheet.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/features/shop/presentation/ad_free_provider.dart';
import 'package:pico/shared/components/game_button.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/how_to_play_card.dart';
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
    this.currentNavIndex = 2,
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
                      Consumer(
                        builder: (context, ref, _) {
                          final isAdFree = ref.watch(isAdFreeProvider);
                          if (isAdFree) return const SizedBox.shrink();
                          return const BannerAdWidget(placement: 'dashboard_bottom');
                        },
                      ),
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
                                  context.go('/shop');
                                  break;
                                case 1:
                                  _navigateToMatches();
                                  break;
                                case 2:
                                  // Already Home
                                  break;
                                case 3:
                                  _navigateToTournaments();
                                  break;
                                case 4:
                                  _navigateToProfile();
                                  break;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Consumer(
                    builder: (context, ref, _) {
                      final isAdFree = ref.watch(isAdFreeProvider);
                      if (isAdFree) return const SizedBox.shrink();
                      return const BannerAdWidget(placement: 'dashboard_bottom');
                    },
                  ),
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
                                // Special Event Card (El Clásico Teaser)
                                _buildSpecialEventCard(context),

                                // How to Play Section
                                const HowToPlayCard(),
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
          GameButton.cream(
            key: const Key('home_screen_menu_button'),
            width: 48.0,
            height: 48.0,
            borderRadius: 14.0,
            extrusionHeight: 4.0,
            pressedExtrusionHeight: 1.5,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (widget.onMenuTap != null) {
                widget.onMenuTap!();
              } else {
                context.push('/settings');
              }
            },
            child: const Center(
              child: Icon(
                Icons.menu_rounded,
                color: Color(0xFF13211B),
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 1. Top Bar: Profile Section (50% width) & Division Section (50% width)
  /// - Profile Section on Left: GameButton.gold with avatar icon, username, and level
  /// - Division Section on Right: GameButton.green with shield icon and translated division title
  Widget _buildTopBar(BuildContext context, UserProfile profile) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Left: User Profile Game Button (50% of available width)
          Expanded(
            child: _buildProfileGameButton(context, profile),
          ),

          const SizedBox(width: 10.0),

          // Right: Division Game Button (50% of available width)
          Expanded(
            child: _buildDivisionGameButton(context, profile, l10n),
          ),
        ],
      ),
    );
  }

  /// Profile button using tactile 3D GameButton.gold with avatar, username, and level
  Widget _buildProfileGameButton(BuildContext context, UserProfile profile) {
    final username = profile.username != null && profile.username!.isNotEmpty
        ? profile.username!
        : 'Player';

    return GameButton.gold(
      key: const Key('home_screen_profile_pill'),
      onPressed: _navigateToProfile,
      onLongPress: () {
        if (widget.onMenuTap != null) {
          widget.onMenuTap!();
        } else {
          _showHomeMenuBottomSheet(context, profile);
        }
      },
      width: double.infinity,
      height: 52.0,
      borderRadius: 16.0,
      extrusionHeight: 4.5,
      pressedExtrusionHeight: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Row(
        children: [
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
          const SizedBox(width: 8.0),
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
                    fontSize: 14.0,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF261700),
                    letterSpacing: 0.2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'LVL ${profile.level}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF261700).withValues(alpha: 0.75),
                    letterSpacing: 0.2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Division button using tactile 3D GameButton.green with heraldic shield and translated division title
  Widget _buildDivisionGameButton(
    BuildContext context,
    UserProfile profile,
    AppLocalizations? l10n,
  ) {
    final divisionTitle = l10n != null
        ? profile.division.localizedTitle(l10n)
        : profile.division.defaultTitle;

    return GameButton.green(
      key: const Key('home_screen_division_pill'),
      onPressed: () => DivisionLadderSheet.show(context, profile),
      width: double.infinity,
      height: 52.0,
      borderRadius: 16.0,
      extrusionHeight: 4.5,
      pressedExtrusionHeight: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: profile.division.borderColor.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.shield_rounded,
              color: profile.division.primaryColor,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              divisionTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.1,
                shadows: [
                  Shadow(
                    color: Color(0x660B2416),
                    offset: Offset(0, 1.2),
                    blurRadius: 2.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Settings and options bottom sheet.
  void _showHomeMenuBottomSheet(BuildContext context, UserProfile profile) {
    final l10n = AppLocalizations.of(context);
    final menuTitle = l10n?.homeMenuTitle ?? 'Settings & Menu';
    final signOutText = l10n?.signOutButton ?? 'Sign Out';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 28.0),
          decoration: const BoxDecoration(
            color: Color(0xFF0F2417),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border(
              top: BorderSide(color: Color(0xFF1E432F), width: 2.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, -4),
                blurRadius: 16,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: PicoColors.textWhiteMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: PicoColors.electricMint,
                      size: 22.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      menuTitle,
                      style: PicoTypography.headlineMd.copyWith(
                        color: PicoColors.textWhite,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13281C),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFF224B33), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38.0,
                        height: 38.0,
                        decoration: BoxDecoration(
                          color: PicoColors.primary,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 22.0),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.username ?? 'Alex',
                              style: PicoTypography.headlineMd.copyWith(
                                color: PicoColors.textWhite,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'LVL ${profile.level} · ${profile.formattedCoins} Coins · ${profile.streak} Streak',
                              style: PicoTypography.labelPillSm.copyWith(
                                color: PicoColors.primaryFixed,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14.0),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: Text(
                      signOutText,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () async {
                      final authNotifier = ref.read(authProvider.notifier);
                      Navigator.of(ctx).pop();
                      await authNotifier.signOut();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 2. Special Event Card: Static teaser for "El Clásico" prediction feature
  /// - Upper half: assets/images/elclasico.png background (BoxFit.cover) with centered "El Clásico" and match date.
  /// - Lower half: Cream card face, solid blue circle for Barcelona, solid white circle for Real Madrid, and disabled "Coming soon" button.
  Widget _buildSpecialEventCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final comingSoonText = l10n?.comingSoon ?? 'Coming soon';

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
              // Upper Half: Stadium Banner with Centered Title & Match Date
              SizedBox(
                height: 140.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image: assets/images/elclasico.png with BoxFit.cover
                    Image.asset(
                      'assets/images/elclasico.png',
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

                    // Atmospheric Gradient Overlay for text readability
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

                    // Horizontally and vertically centered texts: "El Clásico" & match date
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'El Clásico',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 26.0,
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
                            const SizedBox(height: 4.0),
                            Text(
                              '📅 Sat, 26 Oct • 21:00',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.95),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(0, 1.5),
                                    blurRadius: 4.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lower Half: Cream Surface with Teams & Disabled Action Button
              Container(
                color: const Color(0xFFF5F3EC),
                padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 14.0),
                child: Column(
                  children: [
                    // Teams Matchup Row (Barcelona vs Real Madrid with solid colored circles)
                    Row(
                      children: [
                        // Home Team: Barcelona (Solid Blue circle)
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 46.0,
                                height: 46.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF004D98), // Solid Blue
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFDDD9CF),
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x18000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              const Text(
                                'Barcelona',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
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

                        // Away Team: Real Madrid (Solid White circle)
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 46.0,
                                height: 46.0,
                                decoration: BoxDecoration(
                                  color: Colors.white, // Solid White
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFDDD9CF),
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x18000000),
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              const Text(
                                'Real Madrid',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
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

                    const SizedBox(height: 14.0),

                    // Main Action Button: Inactive/disabled "Coming soon" button
                    GameButton.green(
                      key: const Key('special_event_action_button'),
                      text: comingSoonText,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w800,
                      icon: const Icon(
                        Icons.sports_soccer_rounded,
                        size: 20.0,
                        color: Colors.white70,
                      ),
                      onPressed: null, // Inactive/disabled
                      width: double.infinity,
                      height: 48.0,
                      borderRadius: 14.0,
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

