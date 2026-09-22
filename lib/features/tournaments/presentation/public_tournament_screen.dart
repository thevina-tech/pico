import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/matches/presentation/matches_feed_provider.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/l10n/app_localizations.dart';

/// Detail screen for official Public Tournaments.
/// Displays tournament header, live leaderboard standings, and competition match feed.
class PublicTournamentScreen extends ConsumerStatefulWidget {
  const PublicTournamentScreen({
    super.key,
    required this.tournamentId,
    this.initialTournament,
  });

  final String tournamentId;
  final Tournament? initialTournament;

  @override
  ConsumerState<PublicTournamentScreen> createState() =>
      _PublicTournamentScreenState();
}

class _PublicTournamentScreenState
    extends ConsumerState<PublicTournamentScreen> {
  int _selectedTabIndex = 0; // 0: Standings, 1: Matches
  bool _isJoining = false;

  Future<void> _handleJoinTournament(Tournament tournament, AppLocalizations l10n) async {
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

    setState(() => _isJoining = true);
    try {
      final userId = authState.user!.id;
      await ref.read(tournamentRepositoryProvider).enrollInTournament(
            userId: userId,
            tournamentId: tournament.id,
          );
      ref.invalidate(enrolledTournamentsProvider);
      ref.invalidate(tournamentLeaderboardProvider(tournament.id));
      ref.invalidate(matchesFeedProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.joinTournamentSuccessToast(tournament.name)),
            backgroundColor: PicoColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: PicoColors.accentCoral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tournamentAsync = ref.watch(tournamentDetailsProvider(widget.tournamentId));
    final compsMap = ref.watch(competitionsMapProvider).value ?? {};

    final currentTournament = tournamentAsync.value ?? widget.initialTournament;
    final enrolledAsync = ref.watch(enrolledTournamentsProvider);
    final enrolledTournaments = enrolledAsync.value ?? const [];
    final isEnrolled = currentTournament != null &&
        enrolledTournaments.any((t) => t.id == currentTournament.id);

    return Scaffold(
      backgroundColor: PicoColors.pitchBackground,
      appBar: AppBar(
        backgroundColor: PicoColors.pitchBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: PicoColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.tournamentDetailsTitle,
          style: PicoTypography.headlineMd.copyWith(
            color: PicoColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: currentTournament == null
          ? const Center(
              child: CircularProgressIndicator(color: PicoColors.primary),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440.0),
                  child: Column(
                    children: [
                      // Header Card
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: _buildHeaderCard(
                          currentTournament,
                          compsMap[currentTournament.competitionId],
                          l10n,
                        ),
                      ),

                      // Attractive Join CTA Banner (if not enrolled)
                      if (!isEnrolled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                          child: _buildJoinBanner(currentTournament, l10n),
                        ),

                      // Segmented Tab Selector
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildTabSelector(l10n),
                      ),
                      const SizedBox(height: 12.0),

                      // Tab View Content
                      Expanded(
                        child: _selectedTabIndex == 0
                            ? _buildLeaderboardView(currentTournament.id, l10n)
                            : _buildMatchesView(
                                currentTournament,
                                isEnrolled,
                                l10n,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(
    Tournament tournament,
    Competition? comp,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F261A),
            Color(0xFF0B1B13),
            Color(0xFF050D09),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: PicoColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF020604),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Competition Emblem inside solid white container
          _buildCompEmblem(comp),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: PicoColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        'OFFICIAL TOURNAMENT',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.gold,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  tournament.name,
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 17.0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  comp?.name ?? tournament.competitionId,
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompEmblem(Competition? comp) {
    return Container(
      width: 52.0,
      height: 52.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      child: comp?.emblemUrl != null && comp!.emblemUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: comp.emblemUrl!,
                width: 36.0,
                height: 36.0,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Text(
                  comp.flag,
                  style: const TextStyle(fontSize: 24.0),
                ),
              ),
            )
          : Text(
              comp?.flag ?? '🏆',
              style: const TextStyle(fontSize: 24.0),
            ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: l10n.leaderboardTab,
              icon: Icons.leaderboard_rounded,
              isSelected: _selectedTabIndex == 0,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildTabButton(
              title: l10n.matchesTab,
              icon: Icons.sports_soccer_rounded,
              isSelected: _selectedTabIndex == 1,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9.0),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15.0,
              color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
            ),
            const SizedBox(width: 6.0),
            Text(
              title,
              style: PicoTypography.labelPillSm.copyWith(
                color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardView(String tournamentId, AppLocalizations l10n) {
    final leaderboardAsync = ref.watch(tournamentLeaderboardProvider(tournamentId));
    final authState = ref.watch(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;

    return leaderboardAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: PicoColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: PicoColors.accentCoral),
        ),
      ),
      data: (participants) {
        if (participants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off_rounded, size: 48.0, color: PicoColors.textWhiteMuted),
                const SizedBox(height: 12.0),
                Text(
                  l10n.noParticipantsYet,
                  style: PicoTypography.bodyLg.copyWith(color: PicoColors.textWhiteMuted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            final rank = index + 1;
            final isCurrentUser = participant.userId == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(0xFF143322)
                    : PicoColors.darkTray,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: isCurrentUser
                      ? PicoColors.primary
                      : Colors.white.withValues(alpha: 0.06),
                  width: isCurrentUser ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Rank badge
                  _buildRankBadge(rank),
                  const SizedBox(width: 12.0),

                  // Avatar
                  CircleAvatar(
                    radius: 18.0,
                    backgroundColor: const Color(0xFF1B3828),
                    backgroundImage: participant.avatarUrl != null && participant.avatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(participant.avatarUrl!)
                        : null,
                    child: (participant.avatarUrl == null || participant.avatarUrl!.isEmpty)
                        ? Text(
                            (participant.username ?? 'P').characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: PicoColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.0,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12.0),

                  // Username + You pill
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            participant.username ?? 'Player',
                            style: PicoTypography.titleCard.copyWith(
                              color: PicoColors.textWhite,
                              fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 14.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: PicoColors.primary,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                color: PicoColors.pitchBackground,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Points Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B13),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: rank <= 3 ? PicoColors.gold : Colors.white.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '${participant.picoPoints} ${l10n.pointsAbbreviation}',
                      style: PicoTypography.headlineMd.copyWith(
                        color: rank <= 3 ? PicoColors.gold : PicoColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor;

    if (rank == 1) {
      badgeColor = PicoColors.gold;
      textColor = const Color(0xFF261A00);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF1E293B);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32);
      textColor = Colors.white;
    } else {
      badgeColor = const Color(0xFF1E2922);
      textColor = PicoColors.textWhiteMuted;
    }

    return Container(
      width: 28.0,
      height: 28.0,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildJoinBanner(Tournament tournament, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF163E28),
            Color(0xFF0F2B1B),
            Color(0xFF081910),
          ],
        ),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: PicoColors.gold.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: PicoColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                    color: PicoColors.gold.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 13.0, color: PicoColors.gold),
                    const SizedBox(width: 4.0),
                    Text(
                      l10n.joinTournamentBannerBadge,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 10.0,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            l10n.joinTournamentBannerTitle,
            style: PicoTypography.headlineMd.copyWith(
              color: PicoColors.textWhite,
              fontWeight: FontWeight.w900,
              fontSize: 17.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            l10n.joinTournamentBannerSub,
            style: PicoTypography.bodySm.copyWith(
              color: PicoColors.textWhiteMuted,
              fontSize: 12.0,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isJoining ? null : () => _handleJoinTournament(tournament, l10n),
              icon: _isJoining
                  ? const SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: PicoColors.pitchBackground,
                      ),
                    )
                  : const Icon(Icons.sports_soccer_rounded, size: 18.0),
              label: Text(
                _isJoining ? '...' : l10n.joinTournamentAction,
                style: PicoTypography.labelPillSm.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.0,
                  letterSpacing: 0.8,
                  color: PicoColors.pitchBackground,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PicoColors.primary,
                foregroundColor: PicoColors.pitchBackground,
                elevation: 0,
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

  Widget _buildPreviewModeBanner(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.0),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: PicoColors.gold.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_rounded, color: PicoColors.gold, size: 16.0),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              l10n.previewModeBanner,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesView(
    Tournament tournament,
    bool isEnrolled,
    AppLocalizations l10n,
  ) {
    final matchesAsync = ref.watch(competitionMatchesProvider(tournament.competitionId));

    return matchesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: PicoColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: PicoColors.accentCoral),
        ),
      ),
      data: (matches) {
        if (matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_busy_rounded, size: 48.0, color: PicoColors.textWhiteMuted),
                const SizedBox(height: 12.0),
                Text(
                  l10n.noMatchesForCompetition,
                  style: PicoTypography.bodyLg.copyWith(color: PicoColors.textWhiteMuted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
          itemCount: matches.length + (!isEnrolled ? 1 : 0),
          itemBuilder: (context, index) {
            if (!isEnrolled && index == 0) {
              return _buildPreviewModeBanner(l10n);
            }
            final match = matches[!isEnrolled ? index - 1 : index];
            return _buildMatchCard(match, tournament, isEnrolled, l10n);
          },
        );
      },
    );
  }

  Widget _buildMatchCard(
    PicoMatch match,
    Tournament tournament,
    bool isEnrolled,
    AppLocalizations l10n,
  ) {
    final isFinished = match.status == MatchStatus.finished;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: PicoColors.darkTray,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          // Kickoff / Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.kickoffTimeFormatted.toUpperCase(),
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.textWhiteMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: isFinished
                      ? const Color(0xFF334155)
                      : PicoColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  isFinished ? 'FINAL' : match.kickoffTimeFormatted,
                  style: TextStyle(
                    color: isFinished ? Colors.white70 : PicoColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Teams and Score
          Row(
            children: [
              // Home Team
              Expanded(
                child: Row(
                  children: [
                    _buildTeamBadge(match.homeTeamBadgeUrl, match.homeTeamName),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        match.homeTeamName,
                        style: PicoTypography.titleCard.copyWith(
                          color: PicoColors.textWhite,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Score or VS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: isFinished
                    ? Text(
                        '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                        style: PicoTypography.headlineMd.copyWith(
                          color: PicoColors.gold,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                        ),
                      )
                    : Text(
                        'VS',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),

              // Away Team
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        match.awayTeamName,
                        textAlign: TextAlign.end,
                        style: PicoTypography.titleCard.copyWith(
                          color: PicoColors.textWhite,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    _buildTeamBadge(match.awayTeamBadgeUrl, match.awayTeamName),
                  ],
                ),
              ),
            ],
          ),

          // Predict CTA if upcoming
          if (!isFinished) ...[
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isJoining
                    ? null
                    : () async {
                        if (!isEnrolled) {
                          await _handleJoinTournament(tournament, l10n);
                          final refreshedEnrolled = ref.read(enrolledTournamentsProvider).value ?? const [];
                          final nowEnrolled = refreshedEnrolled.any((t) => t.id == tournament.id);
                          if (!nowEnrolled) return;
                        }
                        if (!mounted) return;
                        context.push('/prediction/${match.id}', extra: match);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled ? PicoColors.primary : PicoColors.gold,
                  foregroundColor: const Color(0xFF0F1A13),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isJoining
                    ? const SizedBox(
                        width: 14.0,
                        height: 14.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Color(0xFF0F1A13),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isEnrolled) ...[
                            const Icon(Icons.bolt_rounded, size: 14.0, color: Color(0xFF0F1A13)),
                            const SizedBox(width: 4.0),
                          ],
                          Text(
                            isEnrolled ? l10n.predictAction : l10n.joinAndPredictAction,
                            style: PicoTypography.labelPillSm.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                              letterSpacing: 0.8,
                              color: const Color(0xFF0F1A13),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamBadge(String badgeUrl, String teamName) {
    return Container(
      width: 26.0,
      height: 26.0,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
      ),
      padding: const EdgeInsets.all(2.0),
      alignment: Alignment.center,
      child: badgeUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: badgeUrl,
                width: 22.0,
                height: 22.0,
                fit: BoxFit.contain,
                errorWidget: (ctx, url, err) => Text(
                  teamName.characters.first,
                  style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700),
                ),
              ),
            )
          : Text(
              teamName.characters.first,
              style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w700),
            ),
    );
  }
}
