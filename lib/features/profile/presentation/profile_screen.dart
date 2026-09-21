import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Profile screen displaying user stats, streak, level, XP progress,
/// expandable accordions (Tournaments, Following, History, Settings), and a
/// floating "Share Matchday Card" CTA.
///
/// Faithfully reproduces Stitch screen `a3e40b273ae34de3ae4633a7de8bf781`:
/// - Minimalist trading card identity hero with 3D tactile elevation.
/// - 80x80 avatar emblem with overlapping `LVL` shield badge.
/// - FIFA-style tactical stats grid (Hit Rate, Matches, Podiums, Club Rank).
/// - Dynamic XP progress bar to the next level.
/// - 4 expandable accordion sections with rotating chevrons.
/// - Floating tactile Share CTA at the bottom.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Accordion expansion states
  bool _tournamentsExpanded = true;
  bool _followingExpanded = true;
  bool _historyExpanded = false;
  bool _settingsExpanded = false;

  // Curated team/league metadata mapping for followed items
  static const Map<String, _FollowedItemData> _metadataMap = {
    'barcelona': _FollowedItemData(
      name: 'FC Barcelona',
      subname: 'La Liga',
      color: Color(0xFFA50044),
      icon: Icons.shield_rounded,
    ),
    'real_madrid': _FollowedItemData(
      name: 'Real Madrid',
      subname: 'La Liga',
      color: Color(0xFF1E2A5A),
      icon: Icons.shield_rounded,
    ),
    'arsenal': _FollowedItemData(
      name: 'Arsenal',
      subname: 'Premier Lg',
      color: Color(0xFFEF0107),
      icon: Icons.shield_rounded,
    ),
    'man_city': _FollowedItemData(
      name: 'Man City',
      subname: 'Premier Lg',
      color: Color(0xFF6CABDD),
      icon: Icons.shield_rounded,
    ),
    'bayern': _FollowedItemData(
      name: 'Bayern',
      subname: 'Bundesliga',
      color: Color(0xFFDC052D),
      icon: Icons.shield_rounded,
    ),
    'psg': _FollowedItemData(
      name: 'PSG',
      subname: 'Ligue 1',
      color: Color(0xFF004170),
      icon: Icons.shield_rounded,
    ),
    'premier_league': _FollowedItemData(
      name: 'Premier League',
      subname: 'England',
      color: Color(0xFF2D8B55),
      icon: Icons.sports_soccer_rounded,
    ),
    'la_liga': _FollowedItemData(
      name: 'La Liga',
      subname: 'Spain',
      color: Color(0xFF735B27),
      icon: Icons.sports_soccer_rounded,
    ),
    'champions_league': _FollowedItemData(
      name: 'Champions Lg',
      subname: 'UEFA',
      color: Color(0xFF006A44),
      icon: Icons.stars_rounded,
    ),
    'serie_a': _FollowedItemData(
      name: 'Serie A',
      subname: 'Italy',
      color: Color(0xFF1E2A5A),
      icon: Icons.sports_soccer_rounded,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return PicoGameExitScope(
      child: Scaffold(
        backgroundColor: PicoColors.pitchBackground,
        body: PicoPitchBackground(
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: profileAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: PicoColors.primary,
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
                              backgroundColor: PicoColors.primary,
                              foregroundColor: PicoColors.textWhite,
                            ),
                            child: Text(l10n?.retryButton ?? 'Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (profile) => Stack(
                    children: [
                      RefreshIndicator(
                        color: PicoColors.primary,
                        backgroundColor: PicoColors.pitchSurfaceElevated,
                        onRefresh: () => ref
                            .read(currentUserProfileProvider.notifier)
                            .refresh(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            14.0,
                            16.0,
                            110.0,
                          ),
                          children: [
                            // 1. DIRECTION 1: MINIMALIST TRADING CARD / IDENTITY BADGE
                            _buildTradingCardHero(profile, l10n),
                            const SizedBox(height: 14.0),

                            // 2. ACCORDION 1: TOURNAMENTS
                            _buildTournamentsAccordion(l10n),
                            const SizedBox(height: 10.0),

                            // 3. ACCORDION 2: FOLLOWING
                            _buildFollowingAccordion(profile, l10n),
                            const SizedBox(height: 10.0),

                            // 4. ACCORDION 3: HISTORY
                            _buildHistoryAccordion(l10n),
                            const SizedBox(height: 10.0),

                            // 5. ACCORDION 4: SETTINGS & ACCOUNT
                            _buildSettingsAccordion(profile, l10n),
                          ],
                        ),
                      ),

                      // FIXED FLOATING CTA: SHARE MATCHDAY CARD
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildFloatingShareButton(profile, l10n),
                      ),
                    ],
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
  // 1. MINIMALIST TRADING CARD HERO SECTION
  // ---------------------------------------------------------------------------
  Widget _buildTradingCardHero(UserProfile profile, AppLocalizations? l10n) {
    final displayName = profile.username ?? 'Alex';
    final kickerTitle = l10n?.profileTitleKicker ?? 'Matchday Prophet';
    const hitRateText = '70%';
    const matchesCountText = '84';
    const podiumsText = '3';
    const clubRankText = '#12';

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F4),
        borderRadius: BorderRadius.circular(26.0),
        border: Border.all(
          color: const Color(0xFFBECABE).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDED9CC),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x2E000000),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Avatar Emblem + Identity Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Player Avatar Emblem with Level Shield
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76.0,
                    height: 76.0,
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF006A3A),
                          Color(0xFF4DFFB2),
                          Color(0xFFFFDFA0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D271B),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.sports_soccer_rounded,
                            color: Color(0xFFFFDFA0),
                            size: 40.0,
                          ),
                          Positioned(
                            top: 4.0,
                            right: 4.0,
                            child: Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF4DFFB2),
                              size: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Level Badge Overlaid on bottom
                  Positioned(
                    bottom: -8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF735B27),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: const Color(0xFFFAF9F4),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF594311),
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        l10n?.levelPill(profile.level) ?? 'LVL ${profile.level}',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.0,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),

              // Identity Name, Title, and Highlights Row
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PicoTypography.headlineLgMobile.copyWith(
                        color: PicoColors.textPitchInk,
                        fontWeight: FontWeight.w900,
                        fontSize: 23.0,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          color: Color(0xFF006A44),
                          size: 15.0,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            kickerTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PicoTypography.bodySm.copyWith(
                              color: const Color(0xFF3F4940),
                              fontWeight: FontWeight.w700,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),

                    // Badges Row: Streak & Coins
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: [
                        // Streak Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDDC9B),
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFE2C384),
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            '🔥 ${l10n?.streakPill(profile.streak) ?? '${profile.streak} Streak'}',
                            style: PicoTypography.labelPillSm.copyWith(
                              color: const Color(0xFF775F2A),
                              fontWeight: FontWeight.w800,
                              fontSize: 10.5,
                            ),
                          ),
                        ),

                        // Coins Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: PicoColors.primaryTintContainer,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFD0E9DA),
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            '🪙 ${l10n?.coinsPill(profile.formattedCoins) ?? '${profile.formattedCoins} Coins'}',
                            style: PicoTypography.labelPillSm.copyWith(
                              color: PicoColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 10.5,
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
          const SizedBox(height: 18.0),

          // Consolidated FIFA-Style Tactical Stats Grid (4 columns)
          Container(
            padding: const EdgeInsets.only(top: 14.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFBECABE).withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTacticalStatCell(
                    label: l10n?.hitRateLabel ?? 'Hit Rate',
                    value: hitRateText,
                    valueColor: const Color(0xFF006A3A),
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: _buildTacticalStatCell(
                    label: l10n?.matchesLabel ?? 'Matches',
                    value: matchesCountText,
                    valueColor: PicoColors.textPitchInk,
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: _buildTacticalStatCell(
                    label: l10n?.podiumsLabel ?? 'Podiums',
                    value: podiumsText,
                    valueColor: const Color(0xFF735B27),
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: _buildTacticalStatCell(
                    label: l10n?.clubRankLabel ?? 'Club Rank',
                    value: clubRankText,
                    valueColor: const Color(0xFF006A44),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),

          // XP Progress to Next Level
          Container(
            padding: const EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFBECABE).withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n?.xpProgressToLevel(profile.level + 1) ??
                            'XP Progress to LVL ${profile.level + 1}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PicoTypography.labelPill.copyWith(
                          color: const Color(0xFF3F4940),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${profile.xpInLevel} ',
                            style: PicoTypography.statCounterSm.copyWith(
                              color: const Color(0xFF006A3A),
                              fontWeight: FontWeight.w900,
                              fontSize: 13.0,
                            ),
                          ),
                          TextSpan(
                            text:
                                '/ ${UserProfileXpX.formatNumberWithCommas(profile.targetXpForLevel)} XP',
                            style: PicoTypography.labelPillSm.copyWith(
                              color: const Color(0xFF6F7A70),
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),

                // XP Progress Bar
                Container(
                  height: 10.0,
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3DE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: profile.xpProgressRatio > 0.0
                        ? profile.xpProgressRatio
                        : 0.02,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF006A3A),
                            Color(0xFF4DFFB2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalStatCell({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F4EF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFEDE8DD),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFEDE8DD),
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PicoTypography.labelPillSm.copyWith(
              color: const Color(0xFF6F7A70),
              fontWeight: FontWeight.w700,
              fontSize: 9.0,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: PicoTypography.statCounter.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 16.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. ACCORDION 1: TOURNAMENTS
  // ---------------------------------------------------------------------------
  Widget _buildTournamentsAccordion(AppLocalizations? l10n) {
    return _buildAccordionContainer(
      isOpen: _tournamentsExpanded,
      onToggle: () => setState(() => _tournamentsExpanded = !_tournamentsExpanded),
      icon: Icons.emoji_events_rounded,
      iconBg: PicoColors.primaryFixed,
      iconColor: PicoColors.primaryDark,
      shadowColor: const Color(0xFF7ED99C),
      title: l10n?.tournamentsAccordionTitle ?? 'Tournaments',
      subtitle: l10n?.tournamentsAccordionSubtitle ?? 'Active cups & weekly leagues',
      badgeText: l10n?.tournamentsActiveCount(2) ?? '2 Active',
      badgeBg: PicoColors.primary.withValues(alpha: 0.1),
      badgeTextColor: PicoColors.primaryDark,
      badgeBorder: PicoColors.primary.withValues(alpha: 0.2),
      content: Column(
        children: [
          // Tournament Card A
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEDE8DD)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3DE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#12',
                    style: PicoTypography.statCounterSm.copyWith(
                      color: PicoColors.primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        runSpacing: 2.0,
                        children: [
                          Text(
                            'La Liga Weekly',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PicoTypography.headlineMd.copyWith(
                              color: PicoColors.textPitchInk,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 1.0,
                            ),
                            decoration: BoxDecoration(
                              color: PicoColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'GW 28',
                              style: PicoTypography.labelPillSm.copyWith(
                                color: PicoColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Top 8% · 284 Pts (+18 today)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PicoTypography.bodySm.copyWith(
                          color: const Color(0xFF6F7A70),
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n?.standingsButton ?? 'Standings',
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.0,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: PicoColors.primaryDark,
                      size: 13.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Tournament Card B
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEDE8DD)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.0,
                  height: 34.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDDC9B),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFE2C384),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#2',
                    style: PicoTypography.statCounterSm.copyWith(
                      color: const Color(0xFF775F2A),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        runSpacing: 2.0,
                        children: [
                          Text(
                            'The Friday Five',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PicoTypography.headlineMd.copyWith(
                              color: PicoColors.textPitchInk,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 1.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDFA0).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              'Podium',
                              style: PicoTypography.labelPillSm.copyWith(
                                color: const Color(0xFF735B27),
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '5/5 Correct Picks · Final Round',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PicoTypography.bodySm.copyWith(
                          color: const Color(0xFF6F7A70),
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n?.standingsButton ?? 'Standings',
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.0,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: PicoColors.primaryDark,
                      size: 13.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ACCORDION 2: FOLLOWING
  // ---------------------------------------------------------------------------
  Widget _buildFollowingAccordion(UserProfile profile, AppLocalizations? l10n) {
    // Combine followed teams & leagues
    final followedIds = <String>[
      ...profile.favoriteTeamIds,
      ...profile.favoriteLeagueIds,
    ];

    // Default fallback followed items if user has none selected yet
    final displayIds = followedIds.isNotEmpty
        ? followedIds
        : const ['barcelona', 'arsenal', 'premier_league', 'champions_league'];

    final pinnedCountText = l10n?.followingPinnedCount(displayIds.length) ??
        '${displayIds.length} Pinned';

    return _buildAccordionContainer(
      isOpen: _followingExpanded,
      onToggle: () => setState(() => _followingExpanded = !_followingExpanded),
      icon: Icons.favorite_rounded,
      iconBg: const Color(0xFFE3E3DE),
      iconColor: PicoColors.textPitchInk,
      shadowColor: const Color(0xFFD8D1C3),
      title: l10n?.followingAccordionTitle ?? 'Following',
      subtitle: l10n?.followingAccordionSubtitle ??
          'Clubs, leagues & priority alerts',
      badgeText: pinnedCountText,
      badgeBg: const Color(0xFFE9E8E3),
      badgeTextColor: const Color(0xFF3F4940),
      badgeBorder: const Color(0xFFBECABE).withValues(alpha: 0.4),
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 2.5,
        ),
        itemCount: displayIds.length,
        itemBuilder: (context, index) {
          final id = displayIds[index];
          final item = _metadataMap[id] ??
              _FollowedItemData(
                name: id.replaceAll('_', ' ').toUpperCase(),
                subname: 'League',
                color: PicoColors.primaryDark,
                icon: Icons.shield_rounded,
              );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: const Color(0xFFBECABE).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 16.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PicoTypography.headlineMd.copyWith(
                          color: PicoColors.textPitchInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        item.subname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PicoTypography.bodySm.copyWith(
                          color: const Color(0xFF6F7A70),
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.push_pin_rounded,
                  color: PicoColors.primaryDark,
                  size: 15.0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. ACCORDION 3: HISTORY
  // ---------------------------------------------------------------------------
  Widget _buildHistoryAccordion(AppLocalizations? l10n) {
    return _buildAccordionContainer(
      isOpen: _historyExpanded,
      onToggle: () => setState(() => _historyExpanded = !_historyExpanded),
      icon: Icons.history_rounded,
      iconBg: const Color(0xFF4DFFB2),
      iconColor: const Color(0xFF002112),
      shadowColor: const Color(0xFF00E297),
      title: l10n?.historyAccordionTitle ?? 'History',
      subtitle: l10n?.historyAccordionSubtitle ??
          'Predictions slip archive & past trophies',
      badgeText: l10n?.historySummary(84, 70) ?? '84 Matches · 70%',
      badgeBg: const Color(0xFF4DFFB2).withValues(alpha: 0.2),
      badgeTextColor: const Color(0xFF006A44),
      badgeBorder: const Color(0xFF006A44).withValues(alpha: 0.2),
      content: Column(
        children: [
          // Recent Form Strip
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEDE8DD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (l10n?.recentFormTitle ??
                                'Recent Form (Last 10 Matches)')
                            .toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: const Color(0xFF6F7A70),
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      l10n?.recentFormSummary(7, 3) ?? '7 Wins · 3 Exact',
                      style: PicoTypography.statCounterSm.copyWith(
                        color: PicoColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFormBadge('W', isWin: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('W', isWin: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('3:1', isExact: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('L', isLoss: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('W', isWin: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('W', isWin: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('2:0', isExact: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('L', isLoss: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('W', isWin: true),
                      const SizedBox(width: 4.0),
                      _buildFormBadge('1:0', isExact: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Past Match Slip Example
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFEDE8DD)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: PicoColors.primaryDark,
                  size: 20.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arsenal vs Chelsea',
                        style: PicoTypography.headlineMd.copyWith(
                          color: PicoColors.textPitchInk,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        'Predicted 2-1 · Final 2-1 (+15 XP)',
                        style: PicoTypography.bodySm.copyWith(
                          color: const Color(0xFF6F7A70),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n?.pointsEarnedBadge(3) ?? '+3 Pts',
                  style: PicoTypography.statCounterSm.copyWith(
                    color: PicoColors.primaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormBadge(
    String text, {
    bool isWin = false,
    bool isExact = false,
    bool isLoss = false,
  }) {
    Color bg = PicoColors.primary;
    if (isExact) bg = const Color(0xFF008557);
    if (isLoss) bg = PicoColors.error;

    return Container(
      width: 25.0,
      height: 25.0,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.0),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: PicoTypography.labelPillSm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: isExact ? 9.5 : 11.0,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. ACCORDION 4: SETTINGS & ACCOUNT
  // ---------------------------------------------------------------------------
  Widget _buildSettingsAccordion(UserProfile profile, AppLocalizations? l10n) {
    return _buildAccordionContainer(
      isOpen: _settingsExpanded,
      onToggle: () => setState(() => _settingsExpanded = !_settingsExpanded),
      icon: Icons.settings_rounded,
      iconBg: const Color(0xFFE3E3DE),
      iconColor: PicoColors.textPitchInk,
      shadowColor: const Color(0xFFD8D1C3),
      title: l10n?.settingsAccordionTitle ?? 'Settings',
      subtitle: l10n?.settingsAccordionSubtitle ??
          'Preferences, sound & notifications',
      badgeText: 'v1.0.0',
      badgeBg: const Color(0xFFE9E8E3),
      badgeTextColor: const Color(0xFF3F4940),
      badgeBorder: const Color(0xFFBECABE).withValues(alpha: 0.4),
      content: Column(
        children: [
          // Push Notifications Setting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFEDE8DD)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_rounded,
                  color: PicoColors.primaryDark,
                  size: 20.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    l10n?.pushNotificationsTitle ?? 'Push Notifications',
                    style: PicoTypography.headlineMd.copyWith(
                      color: PicoColors.textPitchInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: PicoColors.primary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    l10n?.enabledPill ?? 'Enabled',
                    style: PicoTypography.labelPillSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Matchday Haptics Setting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4EF),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFEDE8DD)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.vibration_rounded,
                  color: PicoColors.primaryDark,
                  size: 20.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    l10n?.matchdayHapticsTitle ?? 'Matchday Haptics',
                    style: PicoTypography.headlineMd.copyWith(
                      color: PicoColors.textPitchInk,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3DE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    l10n?.onPill ?? 'On',
                    style: PicoTypography.labelPillSm.copyWith(
                      color: const Color(0xFF3F4940),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),

          // Sign Out Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('profile_sign_out_button'),
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout_rounded, size: 16.0),
              label: Text(l10n?.signOutButton ?? 'Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PicoColors.error,
                side: BorderSide(
                  color: PicoColors.error.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GENERIC ACCORDION CONTAINER HELPER
  // ---------------------------------------------------------------------------
  Widget _buildAccordionContainer({
    required bool isOpen,
    required VoidCallback onToggle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color shadowColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required Color badgeBorder,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F4),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFBECABE).withValues(alpha: 0.4),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDED9CC),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Button
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: iconColor, size: 22.0),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: PicoTypography.headlineMd.copyWith(
                            color: PicoColors.textPitchInk,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: PicoTypography.bodySm.copyWith(
                            color: const Color(0xFF6F7A70),
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: badgeBorder),
                    ),
                    child: Text(
                      badgeText,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF6F7A70),
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Collapsible Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 14.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFBECABE).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
              ),
              child: content,
            ),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. FIXED FLOATING CTA: SHARE MATCHDAY CARD
  // ---------------------------------------------------------------------------
  Widget _buildFloatingShareButton(UserProfile profile, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            PicoColors.pitchBackground,
            PicoColors.pitchBackground.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440.0),
          child: SizedBox(
            width: double.infinity,
            height: 52.0,
            child: ElevatedButton.icon(
              key: const Key('profile_share_card_button'),
              onPressed: () => _showShareCardModal(context, profile, l10n),
              icon: const Icon(Icons.ios_share_rounded, size: 20.0),
              label: Text(
                l10n?.shareMatchdayCard ?? 'Share Matchday Card',
                style: PicoTypography.headlineMd.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.0,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PicoColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: const BorderSide(
                    color: Color(0xFF00522C),
                    width: 1.5,
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
  // 7. SHARE MATCHDAY CARD MODAL SHEET
  // ---------------------------------------------------------------------------
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
            color: Color(0xFFFAF9F4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFBECABE),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 16.0),

              // Title
              Text(
                l10n?.shareCardModalTitle ?? 'Matchday Trading Card',
                style: PicoTypography.headlineMd.copyWith(
                  color: PicoColors.textPitchInk,
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
                  color: const Color(0xFF6F7A70),
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
                  border: Border.all(color: PicoColors.primaryFixed, width: 1.5),
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
                        const Icon(
                          Icons.sports_soccer_rounded,
                          color: PicoColors.mintGlow,
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
                                  color: PicoColors.primaryFixed,
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
                            color: PicoColors.gold,
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
                        backgroundColor: PicoColors.primary,
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
                    backgroundColor: PicoColors.primary,
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

class _FollowedItemData {
  const _FollowedItemData({
    required this.name,
    required this.subname,
    required this.color,
    required this.icon,
  });

  final String name;
  final String subname;
  final Color color;
  final IconData icon;
}

