import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/profile/domain/user_profile.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/features/profile/presentation/widgets/division_ladder_sheet.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/division_badge.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_button.dart';
import 'package:pico/features/profile/presentation/help_support_screen.dart';
import 'package:pico/features/profile/presentation/settings_screen.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/pico_snackbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// The official Profile screen displaying user stats, streak, level, XP progress,
/// tournaments banner, following & history hubs, quick actions (Rate App & Help),
/// and a tactile Share Matchday Card button.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return PicoGameExitScope(
      child: PicoPitchBackground(
        imageAsset: 'assets/images/main_background.png',
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
                          PicoButton.primary(
                            text: l10n?.retryButton ?? 'Retry',
                            isFullWidth: false,
                            height: 42.0,
                            borderRadius: 12.0,
                            onPressed: () {
                              ref
                                  .read(currentUserProfileProvider.notifier)
                                  .refresh();
                            },
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
                        const SizedBox(height: 14.0),

                        // 4. Quick Actions (Rate App, Help/Support & Settings)
                        _buildQuickActionsSection(profile, l10n),
                        const SizedBox(height: 18.0),

                        // 6. Tactile Gold Share Button (Share the App)
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
    final displayName = (profile.username != null && profile.username!.isNotEmpty)
        ? profile.username!
        : 'Player';

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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Division Tier & Progress Bar (Tapping opens DivisionLadderSheet)
          GestureDetector(
            onTap: () => DivisionLadderSheet.show(context, profile),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0x66081A13),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: profile.division.borderColor.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DivisionBadge(
                        tier: profile.division,
                        size: DivisionBadgeSize.small,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          l10n != null ? profile.division.localizedTitle(l10n) : profile.division.defaultTitle,
                          style: PicoTypography.statCounterSm.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.0,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Text(
                        profile.division.nextTier != null
                            ? '${profile.formattedTotalPoints} / ${profile.division.nextTier!.minPoints} PP'
                            : '${profile.formattedTotalPoints} PP',
                        style: PicoTypography.bodySm.copyWith(
                          color: profile.division.accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16.0,
                        color: Color(0xFF6EE7B7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF04120C),
                      borderRadius: BorderRadius.circular(999.0),
                      border: Border.all(
                        color: profile.division.borderColor.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: profile.divisionProgressRatio,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              profile.division.primaryColor,
                              profile.division.accentColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999.0),
                          boxShadow: [
                            BoxShadow(
                              color: profile.division.accentColor.withValues(alpha: 0.5),
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    profile.division.nextTier != null
                        ? (l10n != null
                            ? l10n.pointsToNextDivision(
                                profile.pointsToNextDivision.toString(),
                                profile.division.nextTier!.localizedTitle(l10n),
                              )
                            : '${profile.pointsToNextDivision} pts to ${profile.division.nextTier!.defaultTitle}')
                        : (l10n != null
                            ? l10n.eliteDivisionStatus(profile.formattedTotalPoints)
                            : '${profile.formattedTotalPoints} pts (Elite Division)'),
                    style: PicoTypography.bodySm.copyWith(
                      color: const Color(0xB3A7F3D0),
                      fontWeight: FontWeight.w600,
                      fontSize: 11.0,
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

  // ---------------------------------------------------------------------------
  // 2. QUICK STATS GRID (3 TACTILE CARDS)
  // ---------------------------------------------------------------------------
  Widget _buildQuickStatsGrid(UserProfile profile, AppLocalizations? l10n) {
    final hitRateLabel = l10n?.hitRateLabel ?? 'Hit Rate';
    final matchesLabel = l10n?.matchesLabel ?? 'Matches';
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

        // Card 3: Prediction Points & Division
        Expanded(
          child: _TactileCard(
            onTap: () => DivisionLadderSheet.show(context, profile),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.military_tech_rounded,
                  color: profile.division.accentColor,
                  size: 22.0,
                ),
                const SizedBox(height: 6.0),
                Text(
                  profile.formattedTotalPoints,
                  style: PicoTypography.headlineLg.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19.0,
                  ),
                ),
                Text(
                  l10n?.predictionPointsAbbr ?? 'PP',
                  style: PicoTypography.bodySm.copyWith(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  profile.division.badgeLabel,
                  style: PicoTypography.bodySm.copyWith(
                    color: profile.division.accentColor,
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
  // 5. QUICK ACTIONS SECTION (RATE APP & HELP/SUPPORT)
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsSection(UserProfile profile, AppLocalizations? l10n) {
    return Column(
      children: [
        // Action 1: Rate App
        _TactileCard(
          key: const Key('profile_rate_app_action'),
          onTap: _handleRateApp,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: const Color(0x26F59E0B),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0x4DF59E0B),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFBBF24),
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate App',
                      style: PicoTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Enjoying Pico? Leave us a review on the store',
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

        // Action 2: Help & Support (Navigates to HelpSupportScreen)
        _TactileCard(
          key: const Key('profile_help_action'),
          onTap: () {
            HapticFeedback.lightImpact();
            try {
              context.push('/help-support');
            } catch (_) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const HelpSupportScreen(),
                ),
              );
            }
          },
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
        const SizedBox(height: 10.0),

        // Action 3: Settings (Navigates to SettingsScreen)
        _TactileCard(
          key: const Key('profile_settings_action'),
          onTap: () {
            HapticFeedback.lightImpact();
            try {
              context.push('/settings');
            } catch (_) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            }
          },
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
                      l10n?.settingsTitle ?? 'Settings',
                      style: PicoTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      l10n?.settingsSubtitle ??
                          'Account, sign out & preferences',
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

  Future<void> _handleRateApp() async {
    HapticFeedback.lightImpact();
    // Hardcoded external store link for testing purposes right now.
    // REMINDER: Change this to the official Pico package name before launch!
    const String storeUrl =
        'https://play.google.com/store/apps/details?id=com.devdaumienebi.yonunca';

    final uri = Uri.parse(storeUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        final l10n = AppLocalizations.of(context);
        PicoSnackBar.showError(
          context,
          l10n?.couldNotOpenStoreLink ?? 'Could not open store link.',
        );
      }
    } catch (e) {
      debugPrint('[ProfileScreen] Store link launch error: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        PicoSnackBar.showError(
          context,
          l10n?.couldNotOpenStoreLink ?? 'Could not open store link.',
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 6. SHARE THE APP BUTTON (TACTILE GOLD)
  // ---------------------------------------------------------------------------
  Widget _buildShareButton(UserProfile profile, AppLocalizations? l10n) {
    return _TactileButton(
      key: const Key('profile_share_card_button'),
      onPressed: () => _handleShareApp(l10n),
      color: const Color(0xFFFFD41D),
      shadowColor: const Color(0xFF9E6500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.share_rounded,
            color: Color(0xFF261700),
            size: 18.0,
          ),
          const SizedBox(width: 8.0),
          Text(
            l10n?.shareTheAppButton ?? 'Share the App',
            style: PicoTypography.headlineMd.copyWith(
              color: const Color(0xFF261700),
              fontWeight: FontWeight.w900,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShareApp(AppLocalizations? l10n) async {
    HapticFeedback.lightImpact();
    final message = l10n?.shareAppMessage ??
        'Join me on Pico to predict football matches! https://play.google.com/store/apps/details?id=com.devdaumienebi.yonunca';
    try {
      await SharePlus.instance.share(
        ShareParams(text: message),
      );
    } catch (e) {
      debugPrint('[ProfileScreen] Share error: $e');
    }
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
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

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
          color: const Color(0xE60E271F),
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
    required this.color,
    required this.shadowColor,
  });

  final Widget child;
  final VoidCallback onPressed;
  final Color color;
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
          color: widget.color,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFFFF7C2),
            width: 1.2,
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
