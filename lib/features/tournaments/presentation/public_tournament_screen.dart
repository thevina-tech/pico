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
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/tournament.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/prediction_bottom_sheet.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
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
  int _selectedMatchCategoryIndex = 0; // 0: Upcoming, 1: Live, 2: Finished
  bool _isJoining = false;

  Future<bool> _handleJoinTournament(Tournament tournament, AppLocalizations l10n) async {
    final authState = ref.read(authProvider);
    if (authState is! PicoAuthAuthenticated || authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.signInToJoinTournament),
          backgroundColor: PicoColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
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
      return true;
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
      return false;
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _handleEnrollAndPredict(
    PicoMatch match,
    Tournament tournament,
    AppLocalizations l10n,
  ) async {
    final joined = await _handleJoinTournament(tournament, l10n);
    if (joined && mounted) {
      showPicoPredictionBottomSheet(
        context: context,
        ref: ref,
        match: match,
      );
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

    return PicoPitchBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                                  child: _buildJoinBanner(currentTournament, l10n),
                                ),
                            ],
                          ),
                        ),

                        // Pinned Segmented Tab Selector
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _TabSelectorHeaderDelegate(
                            height: 52.0,
                            child: Container(
                              color: PicoColors.pitchBackground,
                              padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 6.0),
                              child: _buildTabSelector(l10n),
                            ),
                          ),
                        ),
                      ];
                    },
                    body: _selectedTabIndex == 0
                        ? _buildLeaderboardView(currentTournament.id, l10n)
                        : _buildMatchesView(
                            currentTournament,
                            isEnrolled,
                            l10n,
                          ),
                  ),
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
                        'PICO TOURNAMENT',
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
    final predictionsAsync = ref.watch(predictionControllerProvider);

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
      data: (allMatches) {
        if (allMatches.isEmpty) {
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

        final matches = allMatches.whereType<PicoMatch>().toList();
        final liveMatches = matches.where((m) => m.status == MatchStatus.live).toList();
        final upcomingMatches = matches.where((m) => m.status == MatchStatus.upcoming).toList()
          ..sort((a, b) => a.kickoffAt.compareTo(b.kickoffAt));
        final finishedMatches = matches.where((m) => m.status == MatchStatus.finished).toList()
          ..sort((a, b) => b.kickoffAt.compareTo(a.kickoffAt));

        final List<PicoMatch> currentCategoryMatches;
        if (_selectedMatchCategoryIndex == 0) {
          currentCategoryMatches = upcomingMatches;
        } else if (_selectedMatchCategoryIndex == 1) {
          currentCategoryMatches = liveMatches;
        } else {
          currentCategoryMatches = finishedMatches;
        }

        return Column(
          children: [
            // Preview Mode Banner if not enrolled
            if (!isEnrolled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                child: _buildPreviewModeBanner(l10n),
              ),

            // Match Status Tabs (Upcoming, Live, Finished)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildMatchStatusTabs(
                upcomingCount: upcomingMatches.length,
                liveCount: liveMatches.length,
                finishedCount: finishedMatches.length,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 12.0),

            // Matches List or Empty State
            Expanded(
              child: currentCategoryMatches.isEmpty
                  ? _buildCategoryEmptyState(_selectedMatchCategoryIndex, l10n)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                      itemCount: currentCategoryMatches.length,
                      itemBuilder: (context, index) {
                        final match = currentCategoryMatches[index];
                        final userPred = predictionsAsync.value?[match.id];
                        final predictedHomeScore = userPred?.homeScore;
                        final predictedAwayScore = userPred?.awayScore;
                        final points = match.calculateSettlementPoints(
                          predictedHomeScore,
                          predictedAwayScore,
                        );

                        String? outcomeLabel;
                        if (match.status == MatchStatus.finished) {
                          if (userPred != null) {
                            if (points != null && points == 5) {
                              outcomeLabel = l10n.pointsOutcomeExact;
                            } else if (points != null && points == 3) {
                              outcomeLabel = l10n.pointsOutcomeWinner;
                            } else {
                              outcomeLabel = l10n.pointsOutcomeIncorrect;
                            }
                          } else {
                            outcomeLabel = l10n.pointsOutcomeNone;
                          }
                        }

                        String? teaserLabel;
                        if (match.isTeaser) {
                          final countdown = match.teaserCountdown;
                          if (countdown.inDays >= 1) {
                            teaserLabel = l10n.teaserOpensInDays(countdown.inDays);
                          } else if (countdown.inHours >= 1) {
                            teaserLabel = l10n.teaserOpensInHours(countdown.inHours);
                          } else {
                            teaserLabel = l10n.teaserOpensInMinutes(countdown.inMinutes.clamp(1, 60));
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MatchCard.fromMatch(
                            match: match,
                            predictedHomeScore: predictedHomeScore,
                            predictedAwayScore: predictedAwayScore,
                            awardedPoints: points,
                            settlementOutcomeLabel: outcomeLabel,
                            teaserCountdownLabel: teaserLabel,
                            teaserSubtext: l10n.teaserCountdownSubtext,
                            onCardTap: match.isTeaser
                                ? null
                                : () {
                                    if (match.status == MatchStatus.finished || match.isLocked) {
                                      context.push('/prediction/${match.id}', extra: match);
                                    } else if (!isEnrolled) {
                                      _handleEnrollAndPredict(match, tournament, l10n);
                                    } else {
                                      showPicoPredictionBottomSheet(
                                        context: context,
                                        ref: ref,
                                        match: match,
                                      );
                                    }
                                  },
                            onPredictPressed: match.isTeaser
                                ? null
                                : () {
                                    if (!isEnrolled) {
                                      _handleEnrollAndPredict(match, tournament, l10n);
                                    } else {
                                      showPicoPredictionBottomSheet(
                                        context: context,
                                        ref: ref,
                                        match: match,
                                      );
                                    }
                                  },
                            onModifyPressed: () => showPicoPredictionBottomSheet(
                              context: context,
                              ref: ref,
                              match: match,
                            ),
                            onViewPredictionPressed: () =>
                                context.push('/prediction/${match.id}', extra: match),
                            onTapResult: () =>
                                context.push('/prediction/${match.id}', extra: match),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchStatusTabs({
    required int upcomingCount,
    required int liveCount,
    required int finishedCount,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2117),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSubTabItem(
              title: l10n.feedTabUpcoming,
              count: upcomingCount,
              isSelected: _selectedMatchCategoryIndex == 0,
              onTap: () => setState(() => _selectedMatchCategoryIndex = 0),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildSubTabItem(
              title: l10n.feedTabLive,
              count: liveCount,
              isSelected: _selectedMatchCategoryIndex == 1,
              isLive: true,
              onTap: () => setState(() => _selectedMatchCategoryIndex = 1),
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildSubTabItem(
              title: l10n.feedTabFinished,
              count: finishedCount,
              isSelected: _selectedMatchCategoryIndex == 2,
              onTap: () => setState(() => _selectedMatchCategoryIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabItem({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? PicoColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLive && count > 0) ...[
              Container(
                width: 6.0,
                height: 6.0,
                margin: const EdgeInsets.only(right: 5.0),
                decoration: const BoxDecoration(
                  color: PicoColors.accentCoral,
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Text(
              title,
              style: PicoTypography.labelPillSm.copyWith(
                color: isSelected ? PicoColors.textWhite : PicoColors.textWhiteMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(width: 4.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999.0),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : PicoColors.textWhiteMuted,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryEmptyState(int categoryIndex, AppLocalizations l10n) {
    final String title;
    final String subtitle;
    final IconData icon;

    if (categoryIndex == 1) {
      title = l10n.noLiveMatches;
      subtitle = l10n.noLiveMatchesSub;
      icon = Icons.sensors_off_rounded;
    } else if (categoryIndex == 0) {
      title = l10n.feedNoUpcomingMatches;
      subtitle = l10n.noUpcomingMatchesSub;
      icon = Icons.event_busy_rounded;
    } else {
      title = l10n.noFinishedMatches;
      subtitle = l10n.noFinishedMatchesSub;
      icon = Icons.history_toggle_off_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44.0, color: PicoColors.textWhiteMuted.withValues(alpha: 0.6)),
            const SizedBox(height: 12.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: PicoTypography.headlineMd.copyWith(
                color: PicoColors.textWhite,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSelectorHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabSelectorHeaderDelegate({
    required this.child,
    required this.height,
  });

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _TabSelectorHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

