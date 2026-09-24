import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Profile screen displaying user stats, streak, level, XP progress,
/// tournaments banner, following & history hubs, achievements showcase,
/// quick actions (Settings & Help), and a tactile Share Matchday Card button.
///
/// Faithfully reproduces Stitch screen `aac8792902f14a659466c52c586d920d`
/// (Dark Stadium Gamer Hub).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Local preferences for settings sheet
  bool _pushNotifications = true;
  bool _matchdayHaptics = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return PicoGameExitScope(
      child: PicoPitchBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: profileAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF10B981),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: PicoColors.error,
                            size: 48.0,
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: PicoTypography.bodyMd.copyWith(
                              color: PicoColors.textWhiteMuted,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(currentUserProfileProvider.notifier)
                                  .refresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: PicoColors.textWhite,
                            ),
                            child: Text(l10n?.retryButton ?? 'Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (profile) => RefreshIndicator(
                    color: const Color(0xFF10B981),
                    backgroundColor: const Color(0xFF0E271F),
                    onRefresh: () => ref
                        .read(currentUserProfileProvider.notifier)
                        .refresh(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        14.0,
                        16.0,
                        32.0,
                      ),
                      children: [
                        // 1. Header Section (Avatar, Name, Level & XP Bar)
                        _buildHeaderSection(profile, l10n),
                        const SizedBox(height: 14.0),

                        // 2. Quick Stats Grid (Hit Rate, Matches, Streak)
                        _buildQuickStatsGrid(profile, l10n),
                        const SizedBox(height: 14.0),

                        // 3. Spotlight Tournament Card (Navigation -> /tournaments)
                        _buildSpotlightTournamentCard(l10n),
                        const SizedBox(height: 12.0),

                        // 4. Hub Paired Cards (Following & History)
                        _buildHubPairedCards(profile, l10n),
                        const SizedBox(height: 16.0),

                        // 5. Achievements Showcase (4 Hexagon Badges)
                        _buildAchievementsSection(profile, l10n),
                        const SizedBox(height: 16.0),

                        // 6. Quick Actions (Settings & Help/Support)
                        _buildQuickActionsSection(profile, l10n),
                        const SizedBox(height: 20.0),

                        // 7. Tactile Gold Share Button
                        _buildShareButton(profile, l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. HEADER SECTION
  // ---------------------------------------------------------------------------
  Widget _buildHeaderSection(UserProfile profile, AppLocalizations? l10n) {
    final displayName = profile.username ?? 'Alex';
    final kickerTitle = l10n?.profileTitleKicker ?? 'Matchday Prophet';
    final levelText = l10n?.levelPill(profile.level) ?? 'LVL ${profile.level}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Profile Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Crest Avatar with Gear Level Indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64.0,
                    height: 64.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF059669),
                          Color(0xFF0C2219),
                          Color(0xFF05130D),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF020B06),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF071D15),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Golden soccer ball icon
                          const Icon(
                            Icons.sports_soccer_rounded,
                            color: Color(0xFFFBBF24),
                            size: 34.0,
                            shadows: [
                              Shadow(
                                color: Color(0x66FBBF24),
                                offset: Offset(0, 2),
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                          // Subtle internal shine
                          Positioned(
                            top: 2.0,
                            right: 2.0,
                            child: Container(
                              width: 14.0,
                              height: 14.0,
                              decoration: const BoxDecoration(
                                color: Color(0x2634D399),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Small Settings Gear Button Pip on Avatar
                  Positioned(
                    top: -4.0,
                    right: -4.0,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showSettingsModal(context, profile, l10n),
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          width: 22.0,
                          height: 22.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2C20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0x8034D399),
                              width: 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF020B06),
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            size: 13.0,
                            color: Color(0xFF6EE7B7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14.0),

              // Name and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PicoTypography.headlineLgMobile.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22.0,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFBBF24),
                          size: 15.0,
                        ),
                        const SizedBox(width: 5.0),
                        Expanded(
                          child: Text(
                            kickerTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PicoTypography.bodySm.copyWith(
                              color: const Color(0xFF6EE7B7),
                              fontWeight: FontWeight.w600,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Level & XP Indicator Bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                levelText,
                style: PicoTypography.statCounterSm.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.0,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Container(
                  height: 8.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF081A13),
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: const Color(0x3310B981),
                      width: 1.0,
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: profile.xpProgressRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF34D399),
                            Color(0xFF5EEAD4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x8014B8A6),
                            blurRadius: 8.0,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                '${UserProfileXpX.formatNumberWithCommas(profile.xpInLevel)} / ${UserProfileXpX.formatNumberWithCommas(profile.targetXpForLevel)} XP',
                style: PicoTypography.bodySm.copyWith(
                  color: const Color(0xB3A7F3D0),
                  fontWeight: FontWeight.w600,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. QUICK STATS GRID (3 TACTILE CARDS)
  // ---------------------------------------------------------------------------
  Widget _buildQuickStatsGrid(UserProfile profile, AppLocalizations? l10n) {
    final hitRateLabel = l10n?.hitRateLabel ?? 'Hit Rate';
    final matchesLabel = l10n?.matchesLabel ?? 'Matches';
    final streakText = profile.streak.toString();
    final bestStreakLabel = l10n?.bestStreak(profile.streak > 0 ? profile.streak : 6) ??
        'Best: ${profile.streak > 0 ? profile.streak : 6}';
    final totalSub = l10n?.matchesTotalSub ?? 'Total';
    final trendText = l10n?.hitRateTrendUp(4) ?? '↑ +4%';

    return Row(
      children: [
        // Card 1: Hit Rate
        Expanded(
          child: _TactileCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.track_changes_rounded,
                  color: Color(0xFF34D399),
                  size: 22.0,
                ),
                const SizedBox(height: 6.0),
                Text(
                  '70%',
                  style: PicoTypography.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19.0,
                  ),
                ),
                Text(
                  hitRateLabel,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  trendText,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFF34D399),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8.0),

        // Card 2: Matches
        Expanded(
          child: _TactileCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF22D3EE),
                  size: 22.0,
                ),
                const SizedBox(height: 6.0),
                Text(
                  '84',
                  style: PicoTypography.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19.0,
                  ),
                ),
                Text(
                  matchesLabel,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  totalSub,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8.0),

        // Card 3: Streak
        Expanded(
          child: _TactileCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 20.0,
                    shadows: [
                      Shadow(
                        color: Color(0x80F97316),
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  streakText,
                  style: PicoTypography.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19.0,
                  ),
                ),
                Text(
                  l10n?.streakPill(profile.streak).split(' ').last ?? 'Streak',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  bestStreakLabel,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFFBBF24),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. SPOTLIGHT TOURNAMENT BANNER
  // ---------------------------------------------------------------------------
  Widget _buildSpotlightTournamentCard(AppLocalizations? l10n) {
    final title = l10n?.tournamentsAccordionTitle ?? 'Tournaments';
    final subtitle =
        l10n?.tournamentsAccordionSubtitle ?? 'Active cups & weekly leagues';
    final activePill = l10n?.tournamentsActiveCount(2) ?? '2 Active';

    return _TactileCard(
      key: const Key('profile_tournaments_card'),
      onTap: () => context.go('/tournaments'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF0D2A20),
          Color(0xFF0E2C21),
          Color(0xFF081F18),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle soccer ball watermark on the right
          Positioned(
            right: 28.0,
            bottom: -22.0,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                Icons.sports_soccer_rounded,
                size: 96.0,
                color: const Color(0xFF6EE7B7).withValues(alpha: 0.6),
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Trophy Icon in emerald badge
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0x2610B981),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0x4D34D399),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFF34D399),
                  size: 24.0,
                ),
              ),
              const SizedBox(width: 12.0),

              // Title, Subtitle, Active Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PicoTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x3310B981),
                        borderRadius: BorderRadius.circular(999.0),
                        border: Border.all(
                          color: const Color(0x4D34D399),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        activePill,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: const Color(0xFF6EE7B7),
                          fontWeight: FontWeight.w700,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Arrow
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 24.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. HUB PAIRED CARDS (FOLLOWING & HISTORY)
  // ---------------------------------------------------------------------------
  Widget _buildHubPairedCards(UserProfile profile, AppLocalizations? l10n) {
    final followingCount = profile.favoriteTeamIds.length +
        profile.favoriteLeagueIds.length;
    final followingPill = l10n?.followingPinnedCount(
          followingCount > 0 ? followingCount : 4,
        ) ??
        '${followingCount > 0 ? followingCount : 4} Pinned';
    final historyPill =
        l10n?.historySummary(84, 70) ?? '84 Matches · 70%';

    return Row(
      children: [
        // Hub Card 1: Following (Navigation -> /personalization)
        Expanded(
          child: _TactileCard(
            key: const Key('profile_following_card'),
            onTap: () => context.push('/personalization'),
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 34.0,
                      height: 34.0,
                      decoration: BoxDecoration(
                        color: const Color(0x26F43F5E),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color(0x4DF43F5E),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFB7185),
                        size: 18.0,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20.0,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n?.followingAccordionTitle ?? 'Following',
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  l10n?.followingAccordionSubtitle ?? 'Clubs, leagues & alerts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x4D881337),
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: const Color(0x4DF43F5E),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    followingPill,
                    style: PicoTypography.labelPillSm.copyWith(
                      color: const Color(0xFFFDA4AF),
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Hub Card 2: History (Tap -> Opens History modal)
        Expanded(
          child: _TactileCard(
            key: const Key('profile_history_card'),
            onTap: () => _showHistoryModal(context, profile, l10n),
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 34.0,
                      height: 34.0,
                      decoration: BoxDecoration(
                        color: const Color(0x26F59E0B),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: const Color(0x4DF59E0B),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFFFBBF24),
                        size: 20.0,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20.0,
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  l10n?.historyAccordionTitle ?? 'History',
                  style: PicoTypography.headlineMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  l10n?.historyAccordionSubtitle ?? 'Predictions, archive & past trophies',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x4D78350F),
                    borderRadius: BorderRadius.circular(999.0),
                    border: Border.all(
                      color: const Color(0x4DF59E0B),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    historyPill,
                    style: PicoTypography.labelPillSm.copyWith(
                      color: const Color(0xFFFDE68A),
                      fontWeight: FontWeight.w700,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. ACHIEVEMENTS SECTION (4 HEXAGON BADGES)
  // ---------------------------------------------------------------------------
  Widget _buildAchievementsSection(UserProfile profile, AppLocalizations? l10n) {
    final title = l10n?.achievementsTitle ?? 'Achievements';
    final seeAllLabel = l10n?.seeAll ?? 'See all';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: PicoTypography.headlineMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15.0,
              ),
            ),
            TextButton(
              onPressed: () => _showAchievementsModal(context, profile, l10n),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                seeAllLabel,
                style: PicoTypography.bodySm.copyWith(
                  color: const Color(0xFF34D399),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        Row(
          children: [
            // Badge 1: On Fire
            Expanded(
              child: _HexagonBadgeCard(
                onTap: () => _showAchievementsModal(context, profile, l10n),
                borderGradient: const [
                  Color(0x80FBBF24),
                  Color(0x66F97316),
                ],
                innerColor: const Color(0xFF161F14),
                title: l10n?.achievementOnFireTitle ?? 'On Fire',
                subtitle: l10n?.achievementOnFireDesc(
                      profile.streak > 0 ? profile.streak : 4,
                    ) ??
                    '${profile.streak > 0 ? profile.streak : 4} streak',
                child: const Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 20.0,
                    shadows: [
                      Shadow(
                        color: Color(0x99F97316),
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Badge 2: Sharpshooter
            Expanded(
              child: _HexagonBadgeCard(
                onTap: () => _showAchievementsModal(context, profile, l10n),
                borderGradient: const [
                  Color(0x8038BDF8),
                  Color(0x6606B6D4),
                ],
                innerColor: const Color(0xFF0A1F26),
                title: l10n?.achievementSharpshooterTitle ?? 'Sharpshooter',
                subtitle:
                    l10n?.achievementSharpshooterDesc(70) ?? '70% hit rate',
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Color(0xFF22D3EE),
                  size: 20.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Badge 3: Podium
            Expanded(
              child: _HexagonBadgeCard(
                onTap: () => _showAchievementsModal(context, profile, l10n),
                borderGradient: const [
                  Color(0x80FDE047),
                  Color(0x66CA8A04),
                ],
                innerColor: const Color(0xFF1B1C10),
                title: l10n?.achievementPodiumTitle ?? 'Podium',
                subtitle: l10n?.achievementPodiumDesc(3) ?? '3 podiums',
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFFBBF24),
                  size: 20.0,
                ),
              ),
            ),
            const SizedBox(width: 8.0),

            // Badge 4: 10 Streak (Locked)
            Expanded(
              child: _HexagonBadgeCard(
                onTap: () => _showAchievementsModal(context, profile, l10n),
                borderGradient: const [
                  Color(0x4D64748B),
                  Color(0x33475569),
                ],
                innerColor: const Color(0xFF111915),
                isLocked: true,
                title: l10n?.achievementStreak10Title ?? '10 Streak',
                subtitle: l10n?.achievementLockedLabel ?? 'Locked',
                child: const Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF94A3B8),
                  size: 19.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. QUICK ACTIONS SECTION (SETTINGS & HELP)
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsSection(UserProfile profile, AppLocalizations? l10n) {
    return Column(
      children: [
        // Action 1: Settings
        _TactileCard(
          key: const Key('profile_settings_action'),
          onTap: () => _showSettingsModal(context, profile, l10n),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.settingsAccordionTitle ?? 'Settings',
                      style: PicoTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      l10n?.settingsAccordionSubtitle ??
                          'Preferences, sound & notifications',
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 22.0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),

        // Action 2: Help & Support
        _TactileCard(
          key: const Key('profile_help_action'),
          onTap: () => _showHelpAndSupportModal(context, l10n),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.helpAndSupportTitle ?? 'Help & Support',
                      style: PicoTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      l10n?.helpAndSupportSubtitle ??
                          'Rules, scoring guide & contact',
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
                size: 22.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. SHARE BUTTON (TACTILE GOLD)
  // ---------------------------------------------------------------------------
  Widget _buildShareButton(UserProfile profile, AppLocalizations? l10n) {
    return _TactileButton(
      key: const Key('profile_share_card_button'),
      onPressed: () => _showShareCardModal(context, profile, l10n),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEDB137),
          Color(0xFFD8971F),
        ],
      ),
      shadowColor: const Color(0xFF8B5E08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.share_rounded,
            color: Color(0xFF0E1D15),
            size: 18.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            l10n?.shareMatchdayCard ?? 'Share Matchday Card',
            style: PicoTypography.headlineMd.copyWith(
              color: const Color(0xFF0E1D15),
              fontWeight: FontWeight.w900,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MODALS & BOTTOM SHEETS
  // ---------------------------------------------------------------------------

  /// Settings bottom sheet
  void _showSettingsModal(
    BuildContext context,
    UserProfile profile,
    AppLocalizations? l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF091F17),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
                border: Border(
                  top: BorderSide(color: Color(0x3310B981), width: 1.0),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  Text(
                    l10n?.settingsAccordionTitle ?? 'Settings',
                    style: PicoTypography.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    profile.email ?? profile.username ?? 'Account Settings',
                    style: PicoTypography.bodySm.copyWith(
                      color: const Color(0xFF6EE7B7),
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Push Notifications toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFF34D399),
                    activeTrackColor: const Color(0xFF065F46),
                    inactiveThumbColor: const Color(0xFF94A3B8),
                    inactiveTrackColor: const Color(0xFF1E293B),
                    title: Text(
                      l10n?.pushNotificationsTitle ?? 'Push Notifications',
                      style: PicoTypography.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Match kickoff & score alerts',
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.0,
                      ),
                    ),
                    value: _pushNotifications,
                    onChanged: (val) {
                      setModalState(() => _pushNotifications = val);
                      setState(() => _pushNotifications = val);
                    },
                  ),

                  // Matchday Haptics toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: const Color(0xFF34D399),
                    activeTrackColor: const Color(0xFF065F46),
                    inactiveThumbColor: const Color(0xFF94A3B8),
                    inactiveTrackColor: const Color(0xFF1E293B),
                    title: Text(
                      l10n?.matchdayHapticsTitle ?? 'Matchday Haptics',
                      style: PicoTypography.bodyMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Tactile vibrations on predictions & locks',
                      style: PicoTypography.bodySm.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11.0,
                      ),
                    ),
                    value: _matchdayHaptics,
                    onChanged: (val) {
                      setModalState(() => _matchdayHaptics = val);
                      setState(() => _matchdayHaptics = val);
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Sign Out Button
                  ElevatedButton.icon(
                    key: const Key('profile_sign_out_button'),
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await ref.read(authProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18.0),
                    label: Text(
                      l10n?.signOutButton ?? 'Sign Out',
                      style: PicoTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F1D1D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
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
    );
  }

  /// Help & Support / Rules modal
  void _showHelpAndSupportModal(BuildContext context, AppLocalizations? l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF091F17),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border(
              top: BorderSide(color: Color(0x3310B981), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              Text(
                l10n?.picoRulesTitle ?? 'Game Rules & Scoring',
                style: PicoTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                l10n?.picoRulesSubtitle ??
                    'Fair play, server-side locks & transparent scoring',
                style: PicoTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 20.0),

              // Rule 1: Scoring breakdown
              _buildRuleTile(
                icon: Icons.sports_score_rounded,
                title: 'Scoring Pico Points',
                description:
                    '• Exact score: +5 Total Points\n• Correct winner or draw: +3 Points\n• Incorrect call: 0 Points',
              ),
              const SizedBox(height: 12.0),

              // Rule 2: Server-side Lock
              _buildRuleTile(
                icon: Icons.timer_outlined,
                title: 'Prediction Lock Window',
                description:
                    'Predictions lock exactly 10 minutes before scheduled kickoff. No edits are allowed after lock.',
              ),
              const SizedBox(height: 12.0),

              // Rule 3: XP & Progression
              _buildRuleTile(
                icon: Icons.bolt_rounded,
                title: 'XP Progression',
                description:
                    '+10 XP per prediction submitted, +5 XP per match finished, +5 XP for winner, +10 XP for exact score (+30 XP total).',
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                child: Text(
                  l10n?.doneButton ?? 'Done',
                  style: PicoTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRuleTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0E271F),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0x3310B981),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF34D399), size: 22.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PicoTypography.bodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// History modal
  void _showHistoryModal(
    BuildContext context,
    UserProfile profile,
    AppLocalizations? l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF091F17),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border(
              top: BorderSide(color: Color(0x3310B981), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              Text(
                l10n?.historyAccordionTitle ?? 'History',
                style: PicoTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                l10n?.recentFormTitle ?? 'Recent Form (Last 10 Matches)',
                style: PicoTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 16.0),

              // Recent form strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFormChip('W', const Color(0xFF10B981)),
                  _buildFormChip('E', const Color(0xFFFBBF24)),
                  _buildFormChip('W', const Color(0xFF10B981)),
                  _buildFormChip('W', const Color(0xFF10B981)),
                  _buildFormChip('L', const Color(0xFFEF4444)),
                  _buildFormChip('W', const Color(0xFF10B981)),
                  _buildFormChip('E', const Color(0xFFFBBF24)),
                  _buildFormChip('W', const Color(0xFF10B981)),
                  _buildFormChip('W', const Color(0xFF10B981)),
                  _buildFormChip('E', const Color(0xFFFBBF24)),
                ],
              ),
              const SizedBox(height: 14.0),

              Center(
                child: Text(
                  l10n?.recentFormSummary(7, 3) ?? '7 Wins · 3 Exact',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFF6EE7B7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                child: Text(
                  l10n?.doneButton ?? 'Done',
                  style: PicoTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormChip(String label, Color color) {
    return Container(
      width: 28.0,
      height: 28.0,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: PicoTypography.labelPillSm.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11.0,
        ),
      ),
    );
  }

  /// Achievements modal
  void _showAchievementsModal(
    BuildContext context,
    UserProfile profile,
    AppLocalizations? l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF091F17),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border(
              top: BorderSide(color: Color(0x3310B981), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              Text(
                l10n?.achievementsTitle ?? 'Achievements',
                style: PicoTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 16.0),

              _buildAchievementDetailRow(
                iconEmoji: '🔥',
                title: 'On Fire',
                subtitle: 'Achieve a 4-match winning streak',
                unlocked: true,
              ),
              const SizedBox(height: 10.0),
              _buildAchievementDetailRow(
                iconData: Icons.track_changes_rounded,
                iconColor: const Color(0xFF22D3EE),
                title: 'Sharpshooter',
                subtitle: 'Maintain a 70% or higher hit rate',
                unlocked: true,
              ),
              const SizedBox(height: 10.0),
              _buildAchievementDetailRow(
                iconData: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFBBF24),
                title: 'Podium Finisher',
                subtitle: 'Finish in the top 3 in 3 tournaments',
                unlocked: true,
              ),
              const SizedBox(height: 10.0),
              _buildAchievementDetailRow(
                iconData: Icons.lock_rounded,
                iconColor: const Color(0xFF94A3B8),
                title: '10 Streak Champion',
                subtitle: 'Reach a streak of 10 correct calls',
                unlocked: false,
              ),
              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                child: Text(
                  l10n?.doneButton ?? 'Done',
                  style: PicoTypography.headlineMd.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementDetailRow({
    String? iconEmoji,
    IconData? iconData,
    Color? iconColor,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0E271F),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: unlocked ? const Color(0x3310B981) : const Color(0x2664748B),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: unlocked ? const Color(0x2610B981) : const Color(0x1A64748B),
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: iconEmoji != null
                ? Text(iconEmoji, style: const TextStyle(fontSize: 20.0))
                : Icon(iconData, color: iconColor, size: 22.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PicoTypography.bodyMd.copyWith(
                    color: unlocked ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w800,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: unlocked ? const Color(0xFF10B981) : const Color(0xFF64748B),
            size: 20.0,
          ),
        ],
      ),
    );
  }

  /// Share Matchday Card bottom sheet
  void _showShareCardModal(
    BuildContext context,
    UserProfile profile,
    AppLocalizations? l10n,
  ) {
    final displayName = profile.username ?? 'Alex';
    final cardSummary =
        '⚽ Pico Football Trading Card:\n'
        'Player: $displayName\n'
        'Level: ${profile.level}\n'
        'Streak: ${profile.streak} 🔥\n'
        'Coins: ${profile.formattedCoins} 🪙\n'
        'Hit Rate: 70%\n'
        'Can you beat my score? Download Pico Football!';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF091F17),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
            border: Border(
              top: BorderSide(color: Color(0x3310B981), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 16.0),

              Text(
                l10n?.shareCardModalTitle ?? 'Matchday Trading Card',
                style: PicoTypography.headlineMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                l10n?.shareCardPrompt ??
                    'Share your Pico profile card and stats with friends!',
                textAlign: TextAlign.center,
                style: PicoTypography.bodySm.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 12.0,
                ),
              ),
              const SizedBox(height: 20.0),

              // Card Mini Preview
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF08140E),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: const Color(0xFF34D399),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sports_soccer_rounded,
                      color: Color(0xFF34D399),
                      size: 32.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: PicoTypography.headlineMd.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            'Level ${profile.level} · ${profile.streak} Streak 🔥',
                            style: PicoTypography.bodySm.copyWith(
                              color: const Color(0xFF6EE7B7),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        '70% HIT',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: const Color(0xFF594311),
                          fontWeight: FontWeight.w900,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Action Button: Copy Summary
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton.icon(
                  key: const Key('copy_card_summary_button'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: cardSummary));
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.profileSummaryCopied ??
                              'Profile summary copied to clipboard!',
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18.0),
                  label: Text(
                    l10n?.copyProfileSummary ?? 'Copy Card Summary',
                    style: PicoTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// REUSABLE HELPER WIDGETS
// =============================================================================


/// Tactile Card with 3D bottom bevel shadow and press depression feedback.
class _TactileCard extends StatefulWidget {
  const _TactileCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(12.0),
    this.gradient,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  State<_TactileCard> createState() => _TactileCardState();
}

class _TactileCardState extends State<_TactileCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;

    return GestureDetector(
      onTapDown: isClickable ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isClickable ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isClickable ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.gradient == null ? const Color(0xE60E271F) : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0x4010B981),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF030E08),
              offset: Offset(0, _isPressed ? 2.0 : 4.0),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Tactile Button with 3D bottom shelf and press animation.
class _TactileButton extends StatefulWidget {
  const _TactileButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.gradient,
    required this.shadowColor,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Gradient gradient;
  final Color shadowColor;

  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16.0),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _isPressed ? 1.0 : 4.0),
              blurRadius: 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Hexagon badge card matching the Stitch design
class _HexagonBadgeCard extends StatelessWidget {
  const _HexagonBadgeCard({
    required this.child,
    required this.title,
    required this.subtitle,
    required this.borderGradient,
    required this.innerColor,
    this.isLocked = false,
    this.onTap,
  });

  final Widget child;
  final String title;
  final String subtitle;
  final List<Color> borderGradient;
  final Color innerColor;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TactileCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Opacity(
        opacity: isLocked ? 0.75 : 1.0,
        child: Column(
          children: [
            // Hexagon icon wrapper
            SizedBox(
              width: 44.0,
              height: 44.0,
              child: ClipPath(
                clipper: const _HexagonClipper(),
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: borderGradient,
                    ),
                  ),
                  child: ClipPath(
                    clipper: const _HexagonClipper(),
                    child: Container(
                      color: innerColor,
                      alignment: Alignment.center,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: PicoTypography.labelPillSm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 1.5),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: PicoTypography.bodySm.copyWith(
                color: isLocked
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                fontSize: 9.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hexagon polygon clipper matching:
/// clip-path: polygon(50% 0%, 93% 25%, 93% 75%, 50% 100%, 7% 75%, 7% 25%);
class _HexagonClipper extends CustomClipper<Path> {
  const _HexagonClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.50, 0.0)
      ..lineTo(w * 0.93, h * 0.25)
      ..lineTo(w * 0.93, h * 0.75)
      ..lineTo(w * 0.50, h * 1.00)
      ..lineTo(w * 0.07, h * 0.75)
      ..lineTo(w * 0.07, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
