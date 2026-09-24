import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/auth/domain/auth_state.dart';
import 'package:pico/features/auth/presentation/auth_provider.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/matches/domain/pico_match.dart';
import 'package:pico/features/predictions/presentation/prediction_controller.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/domain/private_league_member.dart';
import 'package:pico/features/tournaments/presentation/private_league_controller.dart';
import 'package:pico/shared/components/match_card.dart';
import 'package:pico/shared/components/prediction_bottom_sheet.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/l10n/app_localizations.dart';

/// Detail screen for Private Leagues.
/// Features invite code sharing, live standings, competition matches,
/// and role-based UI (Owner Admin Controls vs. Member Leave League).
class PrivateTournamentScreen extends ConsumerStatefulWidget {
  const PrivateTournamentScreen({
    super.key,
    required this.leagueId,
    this.initialLeague,
  });

  final String leagueId;
  final PrivateLeague? initialLeague;

  @override
  ConsumerState<PrivateTournamentScreen> createState() =>
      _PrivateTournamentScreenState();
}

class _PrivateTournamentScreenState
    extends ConsumerState<PrivateTournamentScreen> {
  int _selectedTabIndex = 0; // 0: Standings, 1: Matches
  int _selectedMatchCategoryIndex = 0; // 0: Upcoming, 1: Live, 2: Finished
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leagueAsync = ref.watch(privateLeagueDetailsProvider(widget.leagueId));
    final compsMap = ref.watch(competitionsMapProvider).value ?? {};

    final currentLeague = leagueAsync.value ?? widget.initialLeague;

    final authState = ref.watch(authProvider);
    final currentUserId = authState is PicoAuthAuthenticated ? authState.user?.id : null;
    final isOwner = currentLeague != null && currentUserId != null && currentLeague.ownerId == currentUserId;

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
          l10n.privateLeagueDetailsTitle,
          style: PicoTypography.headlineMd.copyWith(
            color: PicoColors.textWhite,
            fontWeight: FontWeight.w700,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
        actions: [
          // Member option: Leave League (only if NOT the owner)
          if (currentLeague != null && !isOwner)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: PicoColors.accentCoral),
              tooltip: l10n.leaveLeagueButton,
              onPressed: () => _confirmLeaveLeague(currentLeague, l10n),
            ),
        ],
      ),
      body: currentLeague == null
          ? const Center(
              child: CircularProgressIndicator(color: PicoColors.primary),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440.0),
                  child: Column(
                    children: [
                      // Scrollable Header Section (Invite Code + Atmosphere + Admin Controls)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
                        child: Column(
                          children: [
                            // 1. Prominent 6-Character Invite Code Banner
                            _buildInviteCodeBanner(currentLeague, l10n),
                            const SizedBox(height: 10.0),

                            // 2. Atmosphere Header Card
                            _buildHeaderCard(
                              currentLeague,
                              compsMap[currentLeague.competitionId],
                              isOwner,
                              l10n,
                            ),

                            // 3. Admin Controls Section (Owner ONLY)
                            if (isOwner) ...[
                              const SizedBox(height: 10.0),
                              _buildAdminControlsCard(currentLeague, l10n),
                            ],
                          ],
                        ),
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
                            ? _buildLeaderboardView(currentLeague, isOwner, currentUserId, l10n)
                            : _buildMatchesView(currentLeague.competitionId ?? '', l10n),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  /// 1. Prominent 6-Character Invite Code Banner with Copy & Native Share
  Widget _buildInviteCodeBanner(PrivateLeague league, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B13),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: PicoColors.gold.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.key_rounded,
                      size: 13.0,
                      color: PicoColors.gold,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      l10n.inviteCodeBannerTitle,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  league.inviteCode,
                  style: const TextStyle(
                    color: PicoColors.gold,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 22.0,
                    letterSpacing: 4.0,
                  ),
                ),
              ],
            ),
          ),

          // Action 1: Copy to clipboard
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: league.inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.codeCopiedToast),
                  backgroundColor: PicoColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, color: PicoColors.gold, size: 20.0),
            tooltip: 'Copy Code',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1F3524),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
          const SizedBox(width: 8.0),

          // Action 2: Native Share Sheet
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: l10n.shareInviteCodeMessage(league.name, league.inviteCode),
                ),
              );
            },
            icon: const Icon(Icons.share_rounded, color: PicoColors.textWhite, size: 20.0),
            tooltip: 'Share Invite',
            style: IconButton.styleFrom(
              backgroundColor: PicoColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Atmosphere Header Card
  Widget _buildHeaderCard(
    PrivateLeague league,
    Competition? comp,
    bool isOwner,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(14.0),
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
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: PicoColors.primary.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          _buildCompEmblem(comp),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: isOwner
                            ? PicoColors.gold.withValues(alpha: 0.2)
                            : PicoColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        isOwner ? l10n.creatorBadge : l10n.memberBadge,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: isOwner ? PicoColors.gold : PicoColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      '· ${league.memberCount} ${league.memberCount == 1 ? "Member" : "Members"}',
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.textWhiteMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3.0),
                Text(
                  league.name,
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  Widget _buildCompEmblem(Competition? comp) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
                width: 32.0,
                height: 32.0,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Text(
                  comp.flag,
                  style: const TextStyle(fontSize: 22.0),
                ),
              ),
            )
          : Text(
              comp?.flag ?? '⚽',
              style: const TextStyle(fontSize: 22.0),
            ),
    );
  }

  /// 3. Admin Controls Card (Only visible to Owner)
  Widget _buildAdminControlsCard(PrivateLeague league, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1315),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: PicoColors.accentCoral.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: PicoColors.accentCoral,
                size: 18.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                l10n.adminControlsTitle,
                style: PicoTypography.labelPillSm.copyWith(
                  color: PicoColors.accentCoral,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _confirmDeleteLeague(league, l10n),
            icon: const Icon(Icons.delete_forever_rounded, size: 14.0),
            label: Text(
              l10n.deleteLeagueButton,
              style: PicoTypography.labelPillSm.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PicoColors.accentCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
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

  Widget _buildLeaderboardView(
    PrivateLeague league,
    bool isOwner,
    String? currentUserId,
    AppLocalizations l10n,
  ) {
    final membersAsync = ref.watch(privateLeagueMembersProvider(league.id));

    return membersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: PicoColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: PicoColors.accentCoral),
        ),
      ),
      data: (members) {
        if (members.isEmpty) {
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
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final rank = index + 1;
            final isCurrentUser = member.userId == currentUserId;
            final isMemberOwner = member.userId == league.ownerId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
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
                    radius: 17.0,
                    backgroundColor: const Color(0xFF1B3828),
                    backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(member.avatarUrl!)
                        : null,
                    child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                        ? Text(
                            (member.username ?? 'P').characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: PicoColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.0,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10.0),

                  // Username + Creator / You tags
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                member.username ?? 'Player',
                                style: PicoTypography.titleCard.copyWith(
                                  color: PicoColors.textWhite,
                                  fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                                  fontSize: 14.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isMemberOwner) ...[
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                                decoration: BoxDecoration(
                                  color: PicoColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  'CREATOR',
                                  style: TextStyle(
                                    color: PicoColors.gold,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                            ] else if (isCurrentUser) ...[
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
                                decoration: BoxDecoration(
                                  color: PicoColors.primary,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(
                                    color: PicoColors.pitchBackground,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Points Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B13),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: rank <= 3 ? PicoColors.gold : Colors.white.withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '${member.picoPoints} ${l10n.pointsAbbreviation}',
                      style: PicoTypography.headlineMd.copyWith(
                        color: rank <= 3 ? PicoColors.gold : PicoColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.0,
                      ),
                    ),
                  ),

                  // Admin Action: Remove Member (only if viewer is owner AND target is not the owner)
                  if (isOwner && !isMemberOwner) ...[
                    const SizedBox(width: 6.0),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: PicoColors.accentCoral, size: 20.0),
                      tooltip: l10n.removeMemberButton,
                      onPressed: _isProcessing ? null : () => _confirmRemoveMember(league.id, member, l10n),
                    ),
                  ],
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
      width: 26.0,
      height: 26.0,
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
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _buildMatchesView(String competitionId, AppLocalizations l10n) {
    final matchesAsync = ref.watch(competitionMatchesProvider(competitionId));
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
                                : () => showPicoPredictionBottomSheet(
                                      context: context,
                                      ref: ref,
                                      match: match,
                                    ),
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

  // ==========================================
  // CONFIRMATION DIALOGS & ACTIONS
  // ==========================================

  Future<void> _confirmDeleteLeague(PrivateLeague league, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PicoColors.darkTray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        title: Text(
          l10n.deleteLeagueConfirmTitle,
          style: const TextStyle(color: PicoColors.accentCoral, fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.deleteLeagueConfirmBody,
          style: const TextStyle(color: PicoColors.textWhiteMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton, style: const TextStyle(color: PicoColors.textWhiteMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PicoColors.accentCoral,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deleteLeagueAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(privateLeagueControllerProvider.notifier).deleteLeague(league.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.leagueDeletedToast),
          backgroundColor: PicoColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: PicoColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmRemoveMember(
    String leagueId,
    PrivateLeagueMember member,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PicoColors.darkTray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        title: Text(
          l10n.removeMemberConfirmTitle,
          style: const TextStyle(color: PicoColors.accentCoral, fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.removeMemberConfirmBody(member.username ?? 'Player'),
          style: const TextStyle(color: PicoColors.textWhiteMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton, style: const TextStyle(color: PicoColors.textWhiteMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PicoColors.accentCoral,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.removeMemberButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(privateLeagueControllerProvider.notifier).removeMember(
        leagueId: leagueId,
        targetUserId: member.userId,
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memberRemovedToast),
          backgroundColor: PicoColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: PicoColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmLeaveLeague(PrivateLeague league, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PicoColors.darkTray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        title: Text(
          l10n.leaveLeagueConfirmTitle,
          style: const TextStyle(color: PicoColors.accentCoral, fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.leaveLeagueConfirmBody(league.name),
          style: const TextStyle(color: PicoColors.textWhiteMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelButton, style: const TextStyle(color: PicoColors.textWhiteMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PicoColors.accentCoral,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.leaveLeagueAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(privateLeagueControllerProvider.notifier).leaveLeague(league.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.leftLeagueToast),
          backgroundColor: PicoColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: PicoColors.accentCoral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
