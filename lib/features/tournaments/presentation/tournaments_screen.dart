import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/features/tournaments/presentation/tournaments_controller.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_confirmation_modal.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// Central Tournaments Screen featuring "My Leagues" and "Discover" tabs.
class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({
    super.key,
    this.onViewLeaderboard,
  });

  final ValueChanged<String>? onViewLeaderboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(tournamentsControllerProvider);
    final selectedTab = state.activeTab;
    final compsMap = ref.watch(competitionsMapProvider).value ?? {};

    return PicoGameExitScope(
      child: PicoPitchBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PicoAppBar(
            onCoinsTap: () => context.go('/shop'),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: RefreshIndicator(
                  color: PicoColors.primary,
                  backgroundColor: PicoColors.darkTray,
                  onRefresh: () =>
                      ref.read(tournamentsControllerProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 28.0),
                    children: [
                      // Header with Quick Action "+ Create / Join"
                      _buildHeader(context, l10n),
                      const SizedBox(height: 16.0),

                      // Segmented Tabs ("My Leagues" / "Discover")
                      _buildTabs(context, ref, selectedTab, l10n),
                      const SizedBox(height: 18.0),

                      // Tab Content
                      if (selectedTab == 0)
                        _buildMyLeaguesTab(context, ref, l10n, compsMap)
                      else
                        _buildDiscoverTab(context, ref, l10n, compsMap),
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

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 6.0),
        Text(
          l10n.tournamentsTitle,
          textAlign: TextAlign.center,
          style: PicoTypography.headlineLgMobile.copyWith(
            color: PicoColors.textWhite,
            fontWeight: FontWeight.w900,
            fontSize: 28.0,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          l10n.tournamentsSubtitle,
          textAlign: TextAlign.center,
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.textWhiteMuted,
            fontSize: 13.0,
          ),
        ),
        const SizedBox(height: 16.0),
        // 3D tactile Clash Royale "Battle" clear yellow button
        PicoBattleButton(
          text: l10n.createOrJoinAction,
          icon: const Icon(
            Icons.add_rounded,
            size: 20.0,
            color: Color(0xFF261700),
          ),
          onPressed: () => _openCreateOrJoinModal(context, l10n),
        ),
      ],
    );
  }

  Widget _buildTabs(
    BuildContext context,
    WidgetRef ref,
    int selectedTab,
    AppLocalizations l10n,
  ) {
    final privateLeaguesAsync = ref.watch(userPrivateLeaguesProvider);
    final count = privateLeaguesAsync.value?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1.0),
      ),
      child: Row(
        children: [
          // Tab 0: My Leagues
          Expanded(
            child: _TabButton(
              label: l10n.myLeaguesTab,
              icon: Icons.shield_rounded,
              badgeCount: count > 0 ? count : null,
              isSelected: selectedTab == 0,
              onTap: () =>
                  ref.read(tournamentsControllerProvider.notifier).setTab(0),
            ),
          ),
          const SizedBox(width: 4.0),
          // Tab 1: Discover
          Expanded(
            child: _TabButton(
              label: l10n.discoverTab,
              icon: Icons.explore_rounded,
              isSelected: selectedTab == 1,
              onTap: () =>
                  ref.read(tournamentsControllerProvider.notifier).setTab(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLeaguesTab(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Map<String, Competition> compsMap,
  ) {
    final enrolledTournamentsAsync = ref.watch(enrolledTournamentsProvider);
    final privateLeaguesAsync = ref.watch(userPrivateLeaguesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Joined Pico Tournaments (Public First)
        Text(
          'PICO TOURNAMENTS',
          style: PicoTypography.labelPillSm.copyWith(
            color: PicoColors.textWhiteMuted,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10.0),

        enrolledTournamentsAsync.when(
          data: (tournaments) {
            if (tournaments.isEmpty) {
              return _buildEmptyEnrolledTournamentsCard(context, ref, l10n);
            }
            return Column(
              children: tournaments.map((t) => _buildOfficialTournamentCard(context, t, l10n, compsMap)).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(color: PicoColors.primary),
            ),
          ),
          error: (err, _) => _buildErrorCard(err.toString()),
        ),

        const SizedBox(height: 24.0),

        // Section 2: Private Leagues
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRIVATE LEAGUES',
              style: PicoTypography.labelPillSm.copyWith(
                color: PicoColors.textWhiteMuted,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            InkWell(
              onTap: () => context.push('/tournaments/create'),
              child: Text(
                '+ New League',
                style: PicoTypography.bodySm.copyWith(
                  color: PicoColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0),

        privateLeaguesAsync.when(
          data: (leagues) {
            if (leagues.isEmpty) {
              return _buildEmptyPrivateLeaguesCard(context, l10n);
            }
            return Column(
              children: leagues.map((l) => _buildPrivateLeagueCard(context, l, l10n, compsMap)).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(color: PicoColors.primary),
            ),
          ),
          error: (err, _) => _buildErrorCard(err.toString()),
        ),
      ],
    );
  }

  Widget _buildDiscoverTab(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Map<String, Competition> compsMap,
  ) {
    final publicTournamentsAsync = ref.watch(publicTournamentsProvider);
    final enrolledAsync = ref.watch(enrolledTournamentsProvider);
    final enrolledIds = enrolledAsync.value?.map((t) => t.id).toSet() ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP-TIER PUBLIC TOURNAMENTS',
          style: PicoTypography.labelPillSm.copyWith(
            color: PicoColors.textWhiteMuted,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10.0),

        publicTournamentsAsync.when(
          data: (tournaments) {
            return Column(
              children: tournaments.map((t) {
                final isEnrolled = enrolledIds.contains(t.id);
                return _buildDiscoverTournamentCard(
                  context,
                  t,
                  l10n,
                  compsMap,
                  isEnrolled,
                  ref,
                );
              }).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(color: PicoColors.primary),
            ),
          ),
          error: (err, _) => _buildErrorCard(err.toString()),
        ),
      ],
    );
  }

  Widget _buildPrivateLeagueCard(
    BuildContext context,
    PrivateLeague league,
    AppLocalizations l10n,
    Map<String, Competition> compsMap,
  ) {
    final comp = compsMap[league.competitionId];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: () {
          if (onViewLeaderboard != null) {
            onViewLeaderboard?.call(league.name);
          } else {
            context.push('/tournaments/private/${league.id}', extra: league);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: PicoColors.darkTray,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: PicoColors.primary.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // League Badge with Solid White Background
                  _buildCompEmblem(comp),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          league.name,
                          style: PicoTypography.titleCard.copyWith(
                            color: PicoColors.textWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          comp != null
                              ? '${comp.name} · ${league.memberCount} ${league.memberCount == 1 ? "Member" : "Members"}'
                              : '${league.memberCount} Members',
                          style: PicoTypography.bodySm.copyWith(
                            color: PicoColors.textWhiteMuted,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Invite Code Pill (tap to copy)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: league.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.codeCopiedToast),
                          backgroundColor: PicoColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1B13),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: PicoColors.gold, width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            league.inviteCode,
                            style: PicoTypography.headlineMd.copyWith(
                              color: PicoColors.gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.0,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          const Icon(
                            Icons.copy_rounded,
                            size: 13.0,
                            color: PicoColors.gold,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // CTA row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: PicoColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'PRIVATE LEAGUE',
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (onViewLeaderboard != null) {
                        onViewLeaderboard?.call(league.name);
                      } else {
                        context.push('/tournaments/private/${league.id}', extra: league);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF152B20),
                      foregroundColor: PicoColors.textWhite,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Standings',
                      style: PicoTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOfficialTournamentCard(
    BuildContext context,
    Tournament tournament,
    AppLocalizations l10n,
    Map<String, Competition> compsMap,
  ) {
    final comp = compsMap[tournament.competitionId];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: () {
          if (onViewLeaderboard != null) {
            onViewLeaderboard?.call(tournament.name);
          } else {
            context.push('/tournaments/public/${tournament.id}', extra: tournament);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: PicoColors.darkTray,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              // Emblem with Solid White Background
              _buildCompEmblem(comp),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152B20),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        l10n.officialTournamentBadge,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      tournament.name,
                      style: PicoTypography.titleCard.copyWith(
                        color: PicoColors.textWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    Text(
                      comp?.name ?? 'Top-Tier Competition',
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.textWhiteMuted,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (onViewLeaderboard != null) {
                    onViewLeaderboard?.call(tournament.name);
                  } else {
                    context.push('/tournaments/public/${tournament.id}', extra: tournament);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PicoColors.primary,
                  foregroundColor: PicoColors.textWhite,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'View Table',
                  style: PicoTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTournamentCard(
    BuildContext context,
    Tournament tournament,
    AppLocalizations l10n,
    Map<String, Competition> compsMap,
    bool isEnrolled,
    WidgetRef ref,
  ) {
    final comp = compsMap[tournament.competitionId];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: () {
          if (onViewLeaderboard != null) {
            onViewLeaderboard?.call(tournament.name);
          } else {
            context.push('/tournaments/public/${tournament.id}', extra: tournament);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: PicoColors.darkTray,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: isEnrolled
                  ? PicoColors.primary.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              // Emblem with Solid White Background
              _buildCompEmblem(comp),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEnrolled) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: PicoColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded, size: 11.0, color: PicoColors.primary),
                            const SizedBox(width: 3.0),
                            Text(
                              l10n.joinedBadge,
                              style: PicoTypography.labelPillSm.copyWith(
                                color: PicoColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3.0),
                    ],
                    Text(
                      tournament.name,
                      style: PicoTypography.titleCard.copyWith(
                        color: PicoColors.textWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.0,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      comp?.name ?? 'Top-Tier Competition',
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.textWhiteMuted,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEnrolled) ...[
                ElevatedButton(
                  onPressed: () async {
                    final authState = ref.read(authProvider);
                    if (authState is! PicoAuthAuthenticated || authState.user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.signInToJoinTournament),
                          backgroundColor: PicoColors.accentCoral,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final confirmed = await showPicoConfirmationModal(
                      context: context,
                      title: 'Join ${tournament.name}?',
                      message: 'Compete against other fans on the official leaderboard and earn Pico Points from every match!',
                      confirmText: 'Join Tournament',
                      cancelText: l10n.cancelButton,
                      confirmStyle: PicoDialogButtonStyle.green,
                      cancelStyle: PicoDialogButtonStyle.red,
                      customIcon: Container(
                        width: 54.0,
                        height: 54.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(
                            color: const Color(0xFF12944B).withValues(alpha: 0.25),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFF12944B),
                          size: 30.0,
                        ),
                      ),
                    );

                    if (confirmed != true || !context.mounted) return;

                    try {
                      await ref.read(tournamentRepositoryProvider).enrollInTournament(
                            userId: authState.user!.id,
                            tournamentId: tournament.id,
                          );
                      ref.invalidate(enrolledTournamentsProvider);
                      ref.invalidate(tournamentLeaderboardProvider(tournament.id));
                      ref.invalidate(matchesFeedProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.joinTournamentSuccessToast(tournament.name)),
                            backgroundColor: PicoColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: PicoColors.accentCoral,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PicoColors.primary,
                    foregroundColor: PicoColors.pitchBackground,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    l10n.joinAction,
                    style: PicoTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.0,
                      color: PicoColors.pitchBackground,
                    ),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    if (onViewLeaderboard != null) {
                      onViewLeaderboard?.call(tournament.name);
                    } else {
                      context.push('/tournaments/public/${tournament.id}', extra: tournament);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26332A),
                    foregroundColor: PicoColors.textWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Text(
                    'View Table',
                    style: PicoTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompEmblem(Competition? comp) {
    return Container(
      width: 44.0,
      height: 44.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: comp != null && comp.emblemUrl != null && comp.emblemUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: comp.emblemUrl!,
                width: 32.0,
                height: 32.0,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Text(
                  comp.flag,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
            )
          : Text(
              comp?.flag ?? '⚽',
              style: const TextStyle(fontSize: 20.0),
            ),
    );
  }

  Widget _buildEmptyPrivateLeaguesCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              color: const Color(0xFF152B20),
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: const Icon(
              Icons.group_add_rounded,
              color: PicoColors.gold,
              size: 26.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            l10n.emptyPrivateLeaguesTitle,
            style: PicoTypography.headlineMd.copyWith(
              color: PicoColors.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            l10n.emptyPrivateLeaguesSubtitle,
            textAlign: TextAlign.center,
            style: PicoTypography.bodySm.copyWith(
              color: PicoColors.textWhiteMuted,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () => context.push('/tournaments/create'),
            icon: const Icon(Icons.add_rounded, size: 18.0),
            label: Text(l10n.createPrivateLeagueTitle),
            style: ElevatedButton.styleFrom(
              backgroundColor: PicoColors.gold,
              foregroundColor: const Color(0xFF261A00),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEnrolledTournamentsCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            'Explore pico tournaments in the Discover tab',
            textAlign: TextAlign.center,
            style: PicoTypography.bodySm.copyWith(
              color: PicoColors.textWhiteMuted,
            ),
          ),
          const SizedBox(height: 10.0),
          OutlinedButton(
            onPressed: () =>
                ref.read(tournamentsControllerProvider.notifier).setTab(1),
            style: OutlinedButton.styleFrom(
              foregroundColor: PicoColors.primary,
              side: BorderSide(color: PicoColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text('Go to Discover'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: PicoColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        error,
        style: PicoTypography.bodySm.copyWith(color: PicoColors.error),
      ),
    );
  }

  void _openCreateOrJoinModal(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F261B),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF143B29), // Rich emerald turf highlight matching prediction bottom bar
                Color(0xFF0B2117), // Deep solid grass ground
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
            border: Border(
              top: BorderSide(
                color: Color(0x664ADE80), // Soft pitch line green
                width: 1.5,
              ),
              left: BorderSide(color: Color(0x334ADE80), width: 1.0),
              right: BorderSide(color: Color(0x334ADE80), width: 1.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x99000000),
                offset: Offset(0, -8),
                blurRadius: 24,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pull pill
                  Container(
                    width: 44.0,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  // Option 1: Create Private League
                  _TactileMenuButton(
                    title: l10n.createPrivateLeagueTitle,
                    subtitle: 'Set up a private group for your friends',
                    icon: Icons.add_circle_rounded,
                    accentColor: PicoColors.gold,
                    gradientColors: const [
                      Color(0xFF235C3A),
                      Color(0xFF174229),
                      Color(0xFF10331F),
                    ],
                    bevelColor: const Color(0xFF07190F),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/tournaments/create');
                    },
                  ),
                  const SizedBox(height: 14.0),

                  // Option 2: Join with Code
                  _TactileMenuButton(
                    title: l10n.joinPrivateLeagueTitle,
                    subtitle: 'Enter a 6-character code from an invite',
                    icon: Icons.vpn_key_rounded,
                    accentColor: PicoColors.electricMint,
                    gradientColors: const [
                      Color(0xFF1C5235),
                      Color(0xFF143D27),
                      Color(0xFF0D2C1B),
                    ],
                    bevelColor: const Color(0xFF06170E),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/tournaments/join');
                    },
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

/// Tactile 2.5D/3D menu card button with physical bevel and press-down dynamics.
class _TactileMenuButton extends StatefulWidget {
  const _TactileMenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.bevelColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final Color bevelColor;
  final VoidCallback onTap;

  @override
  State<_TactileMenuButton> createState() => _TactileMenuButtonState();
}

class _TactileMenuButtonState extends State<_TactileMenuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 4.0;
    final double translationY = _isPressed ? bevel : 0.0;
    final double currentBevel = _isPressed ? 1.0 : bevel;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, translationY, 0.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.gradientColors,
          ),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.bevelColor,
              offset: Offset(0, currentBevel),
              blurRadius: 0,
            ),
            BoxShadow(
              color: const Color(0x40000000),
              offset: Offset(0, currentBevel + 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.accentColor,
                size: 24.0,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: Color(0xFFD1FAE5),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFF00522C),
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17.0,
              color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: PicoTypography.titleCard.copyWith(
                color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PicoColors.gold
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999.0),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: isSelected ? const Color(0xFF261A00) : PicoColors.textWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A tactile, physical 3D push button styled like the iconic Clash Royale
/// "Battle" clear yellow button with mechanical bevel depression.
class PicoBattleButton extends StatefulWidget {
  const PicoBattleButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.height = 54.0,
    this.width,
  });

  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  final double height;
  final double? width;

  @override
  State<PicoBattleButton> createState() => _PicoBattleButtonState();
}

class _PicoBattleButtonState extends State<PicoBattleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 4.0;
    final double translationY = _isPressed ? bevel : 0.0;
    final double currentBevel = _isPressed ? 0.0 : bevel;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, translationY, 0.0),
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD41D),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEA75),
              Color(0xFFFFD41D),
              Color(0xFFFFB800),
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFFFF6B0),
            width: 1.5,
          ),
          boxShadow: [
            if (currentBevel > 0.0) ...[
              const BoxShadow(
                color: Color(0xFF9E6500),
                offset: Offset(0, 4),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              const BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 8),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8.0),
            ],
            Text(
              widget.text,
              style: const TextStyle(
                color: Color(0xFF261700),
                fontWeight: FontWeight.w900,
                fontSize: 16.0,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

