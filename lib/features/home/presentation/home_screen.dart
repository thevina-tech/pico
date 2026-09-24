import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_companion.dart';

/// The official Pico Home screen based on Stitch "Direction A: Clash Royale Resource Bar & Subheader".
///
/// Features:
/// 1. Reusable global top bar ([PicoAppBar]) displaying Level/XP, Coins, and Streak.
/// 2. Subheader row immediately below the app bar with user's custom username and tactile menu icon.
/// 3. Lazy loaded upcoming matches list consuming [matchesFeedProvider].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.heroMatch,
    this.showBottomNavBar = true,
    this.currentNavIndex = 2,
    this.onNavTap,
    this.onNavigateShop,
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
  final VoidCallback? onNavigateShop;
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

  void _navigateToShop() {
    if (widget.onNavigateShop != null) {
      widget.onNavigateShop!();
    } else {
      context.go('/shop');
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

  final Map<String, (int, int)> _inlineScores = {};

  Future<void> _onQuickPredictMatch(PicoMatch match) async {
    final predictions = ref.read(predictionControllerProvider);
    final existing = predictions.value?[match.id];
    final scores = _inlineScores[match.id] ??
        (existing != null ? (existing.homeScore, existing.awayScore) : (2, 1));
    final homeScore = scores.$1;
    final awayScore = scores.$2;
    final winner = homeScore > awayScore
        ? 'home'
        : (awayScore > homeScore ? 'away' : 'draw');

    final success = await ref
        .read(predictionControllerProvider.notifier)
        .submitPrediction(
          match: match,
          homeScore: homeScore,
          awayScore: awayScore,
          predictedWinner: winner,
        );

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (success) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.predictionSavedToast ?? 'Prediction locked in! Good luck.',
          ),
          backgroundColor: PicoColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.predictionWindowClosed ??
                'Predictions are closed for this match',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          username: 'Alex',
          level: 7,
          xp: 720,
          streak: 4,
          coins: 1450,
        );

    final matchesAsync = ref.watch(matchesFeedProvider);

    return PicoGameExitScope(
      child: Stack(
        children: [
          // 1. Full-Bleed Sunny Pitch Background (Clouds & sky at top, subtly softened)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Transform.scale(
                scale: 1.02, // Subtle scale to prevent edge bleed
                child: Image.asset(
                  'assets/images/home_pitch_background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: PicoColors.pitchBackground,
                  ),
                ),
              ),
            ),
          ),

          // 2. Soft darkening overlay to tone down bright colors
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.18),
              ),
            ),
          ),

          // 3. Subtle pitch contrast vignette over the middle/bottom grass
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.20, 0.50, 1.0],
                    colors: [
                      Colors.transparent, // Sky & clouds remain clean behind Top Bar
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.28),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Transparent Scaffold hosting floating top bar and scrollable content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PicoAppBar(
              onProfileTap: _navigateToProfile,
              onCoinsTap: _navigateToShop,
            ),
            bottomNavigationBar: widget.showBottomNavBar
                ? Center(
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
                              _navigateToShop();
                              break;
                            case 1:
                              _navigateToMatches();
                              break;
                            case 2:
                              // Already Home (center tab)
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
                  )
                : null,
            body: SafeArea(
              top: false,
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Home-Specific Subheader Row (Username on left, Menu on right)
                      _buildSubHeaderRow(context, profile),

                      // 2. Main Content & Matches Feed
                      Expanded(
                        child: RefreshIndicator(
                          color: PicoColors.primary,
                          backgroundColor: PicoColors.pitchSurfaceElevated,
                          onRefresh: () async {
                            await ref.read(matchesFeedProvider.notifier).refresh();
                            await ref.read(currentUserProfileProvider.notifier).refresh();
                          },
                          child: matchesAsync.when(
                            data: (matches) => _buildMatchesList(context, profile, matches),
                            loading: () => _buildLoadingList(context, profile),
                            error: (err, _) => _buildErrorList(context, profile, err),
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

  /// 1. Sub-Header Bar (Direction A: Calm, Functional, Tactile)
  /// User's custom username pill on far left, tactile menu icon on far right.
  Widget _buildSubHeaderRow(BuildContext context, UserProfile profile) {
    final username = profile.username != null && profile.username!.isNotEmpty
        ? profile.username!
        : 'Alex';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Boxed Username Badge (Clean, tactile, generous padding, no green dot)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.5),
            decoration: BoxDecoration(
              color: const Color(0xFF102318),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF1E432F), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF06110A),
                  offset: Offset(0, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              username,
              style: const TextStyle(
                fontFamily: 'Rubik',
                color: Color(0xFFFAF9F4),
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
                height: 1.0,
              ),
            ),
          ),

          // Right: Tactile Menu Button
          GestureDetector(
            key: const Key('home_screen_menu_button'),
            onTap: () {
              if (widget.onMenuTap != null) {
                widget.onMenuTap!();
              } else {
                _showHomeMenuBottomSheet(context, profile);
              }
            },
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: const Color(0xFF102318),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF1E432F), width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF06110A),
                    offset: Offset(0, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.menu_rounded,
                  size: 20.0,
                  color: Color(0xFFFAF9F4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable feed containing the mascot greeting, active tournament,
  /// and exactly one featured match ("Match of the Day") on the Home screen.
  Widget _buildMatchesList(
    BuildContext context,
    UserProfile profile,
    List<PicoMatch> matches,
  ) {
    // If heroMatch was explicitly passed, prepend or use it
    final allMatches = <PicoMatch>[...matches];
    if (widget.heroMatch != null &&
        !allMatches.any((m) => m.id == widget.heroMatch!.id)) {
      allMatches.insert(0, widget.heroMatch!);
    }

    final hasMatches = allMatches.isNotEmpty;
    final hasMultipleMatches = allMatches.length > 1;
    final totalCount = hasMatches ? (hasMultipleMatches ? 5 : 4) : 4;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildMascotGreetingRow(profile.username ?? 'Alex'),
          );
        }
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildActiveTournamentCard(),
          );
        }
        if (index == 2) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildSectionHeader(allMatches.length),
          );
        }

        if (!hasMatches) {
          return _buildEmptyMatchesState();
        }

        // index 3: The single featured match on the Home screen with inline prediction controls
        if (index == 3) {
          final featuredMatch = allMatches.first;
          final predictions = ref.watch(predictionControllerProvider);
          final existing = predictions.value?[featuredMatch.id];
          final currentScores = _inlineScores[featuredMatch.id] ??
              (existing != null
                  ? (existing.homeScore, existing.awayScore)
                  : (2, 1));

          return Padding(
            padding: EdgeInsets.only(bottom: hasMultipleMatches ? 10.0 : 14.0),
            child: MatchCard.fromMatch(
              match: featuredMatch,
              predictedHomeScore: existing?.homeScore,
              predictedAwayScore: existing?.awayScore,
              showInlinePrediction: true,
              inlineHomeScore: currentScores.$1,
              inlineAwayScore: currentScores.$2,
              onInlineHomeScoreChanged: (val) {
                setState(() {
                  _inlineScores[featuredMatch.id] = (val, currentScores.$2);
                });
              },
              onInlineAwayScoreChanged: (val) {
                setState(() {
                  _inlineScores[featuredMatch.id] = (currentScores.$1, val);
                });
              },
              onQuickPredict: () => _onQuickPredictMatch(featuredMatch),
              onCardTap: () => _openDetailedPrediction(featuredMatch),
              onPredictPressed: () => _openDetailedPrediction(featuredMatch),
              onModifyPressed: () => _openDetailedPrediction(featuredMatch),
              onViewPredictionPressed: () => _openDetailedPrediction(featuredMatch),
            ),
          );
        }

        // index 4: Tactile banner navigating to the Matches screen if more matches exist
        final remaining = allMatches.length - 1;
        final l10n = AppLocalizations.of(context);
        final moreText = l10n?.moreMatchesAvailable(remaining) ??
            '+$remaining more fixtures in Matches';

        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: GestureDetector(
            key: const Key('home_screen_explore_matches_banner'),
            onTap: _navigateToMatches,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: PicoColors.pitchSurfaceElevated,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: PicoColors.cardBorder.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sports_soccer_rounded,
                    size: 16.0,
                    color: PicoColors.primaryFixed,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    moreText,
                    style: PicoTypography.labelPillSm.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15.0,
                    color: PicoColors.primaryFixed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Loading state with placeholder skeleton items.
  Widget _buildLoadingList(BuildContext context, UserProfile profile) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildMascotGreetingRow(profile.username ?? 'Alex'),
          );
        }
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildActiveTournamentCard(),
          );
        }
        if (index == 2) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildSectionHeader(1),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: _buildSkeletonMatchCard(),
        );
      },
    );
  }

  /// Tactile skeleton placeholder match card during data loading.
  Widget _buildSkeletonMatchCard() {
    return Container(
      height: 110.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: PicoColors.cardBorder.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF13281C),
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90.0,
                    height: 12.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E432F),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 60.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF13281C),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 70.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: const Color(0xFF13281C),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Error state with retry action.
  Widget _buildErrorList(BuildContext context, UserProfile profile, Object error) {
    final l10n = AppLocalizations.of(context);
    final retryText = l10n?.retryButton ?? 'Retry';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
      children: [
        _buildMascotGreetingRow(profile.username ?? 'Alex'),
        const SizedBox(height: 16.0),
        _buildActiveTournamentCard(),
        const SizedBox(height: 20.0),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: PicoColors.pitchSurfaceElevated,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 36.0),
              const SizedBox(height: 8.0),
              Text(
                'Could not load upcoming matches.',
                style: PicoTypography.bodyMdBold.copyWith(color: PicoColors.textWhite),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14.0),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(matchesFeedProvider.notifier).refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PicoColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18.0),
                label: Text(retryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Empty matches state.
  Widget _buildEmptyMatchesState() {
    final l10n = AppLocalizations.of(context);
    final emptyText =
        l10n?.noUpcomingMatches ?? 'No upcoming matches right now. Check back soon!';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: PicoColors.cardBorder.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_soccer_rounded,
            color: PicoColors.primaryFixedDim,
            size: 40.0,
          ),
          const SizedBox(height: 12.0),
          Text(
            emptyText,
            style: PicoTypography.bodyMd.copyWith(
              color: PicoColors.textWhiteMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Section Header ("MATCH OF THE DAY") with optional "VIEW ALL" button
  Widget _buildSectionHeader(int count) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.matchOfTheDayTitle.toUpperCase() ?? 'MATCH OF THE DAY';
    final viewAllText = l10n?.viewAllMatches.toUpperCase() ?? 'VIEW ALL';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.0,
              height: 14.0,
              decoration: BoxDecoration(
                color: PicoColors.electricMint,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: PicoTypography.labelPillSm.copyWith(
                color: PicoColors.electricMint,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        if (count > 1)
          GestureDetector(
            key: const Key('home_screen_view_all_matches_button'),
            onTap: _navigateToMatches,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  viewAllText,
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.primaryFixed,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.0,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4.0),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11.0,
                  color: PicoColors.primaryFixed,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Mascot Daily Greeting ("Big match tonight, {username}! ⚽")
  Widget _buildMascotGreetingRow(String username) {
    final l10n = AppLocalizations.of(context);
    final greeting = l10n?.mascotGreeting(username) ?? 'Big match tonight, $username! ⚽';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mascot badge avatar with active indicator
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: PicoColors.primary,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: PicoColors.primaryFixed, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF134E2D),
                    offset: Offset(0, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(child: PicoCompanion.avatar(size: 28.0)),
            ),
            Positioned(
              top: -2.0,
              right: -2.0,
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: PicoColors.electricMint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PicoColors.pitchBackground,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10.0),

        // Speech Bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.5,
            ),
            decoration: const BoxDecoration(
              color: PicoColors.cardFace,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.0),
                topRight: Radius.circular(18.0),
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: PicoColors.cardBevelDark,
                  offset: Offset(0, 3.0),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              greeting,
              style: PicoTypography.bodyMdBold.copyWith(
                color: PicoColors.textPitchInk,
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Active Tournament Hub Card (La Liga Season Hub)
  Widget _buildActiveTournamentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: PicoColors.cardBorder.withValues(alpha: 0.15),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Emblem Icon
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: PicoColors.pitchBackground,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: PicoColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: PicoColors.gold,
                  size: 26.0,
                ),
              ),
              const SizedBox(width: 12.0),

              // Title & Rank
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE TOURNAMENT',
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.electricMint,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'La Liga Season Hub',
                      style: PicoTypography.headlineMd.copyWith(
                        color: PicoColors.textWhite,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Rank #12',
                            style: PicoTypography.labelPillSm.copyWith(
                              color: PicoColors.primaryFixed,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' · 42 Pico Points',
                            style: PicoTypography.bodySm.copyWith(
                              color: PicoColors.textWhiteMuted,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Leaderboard Action Pill
              GestureDetector(
                onTap: () {
                  widget.onViewLeaderboard?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: PicoColors.cardFace,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Leaderboard',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textPitchInk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2.0),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: PicoColors.textPitchInk,
                        size: 14.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Divider(color: PicoColors.cardBorder.withValues(alpha: 0.1)),
          const SizedBox(height: 6.0),

          // Ticker Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        color: PicoColors.electricMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        'Round 28 of 38 active',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          fontSize: 10.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '3 FIXTURES TODAY',
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.textWhiteMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Settings and options bottom sheet triggered by the hamburger icon.
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
                      Navigator.of(ctx).pop();
                      await ref.read(authProvider.notifier).signOut();
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
}
