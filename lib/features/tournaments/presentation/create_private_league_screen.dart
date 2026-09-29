import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/core/utils/input_sanitizer.dart';
import 'package:pico/features/matches/domain/competition.dart';
import 'package:pico/features/tournaments/data/tournament_repository.dart';
import 'package:pico/features/tournaments/domain/private_league.dart';
import 'package:pico/features/tournaments/presentation/private_league_controller.dart';
import 'package:pico/shared/components/pico_button.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';
import 'package:pico/shared/components/pico_snackbar.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/services/revenuecat_ad_service.dart';

/// Screen allowing users to create a new Private League.
/// Strictly limited to the 8 curated top-tier base competitions.
class CreatePrivateLeagueScreen extends ConsumerStatefulWidget {
  const CreatePrivateLeagueScreen({super.key});

  @override
  ConsumerState<CreatePrivateLeagueScreen> createState() =>
      _CreatePrivateLeagueScreenState();
}

class _CreatePrivateLeagueScreenState
    extends ConsumerState<CreatePrivateLeagueScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedCompetitionId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Default to the first competition ID (Primera División / La Liga)
    _selectedCompetitionId = '1';
    RevenueCatAdService.instance.preloadInterstitialAd(
      placement: 'private_league_creation',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = InputSanitizer.sanitizeLeagueName(_nameController.text);
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = l10n.leagueNamePlaceholder;
      });
      return;
    }

    if (!InputSanitizer.isValidLeagueName(name)) {
      setState(() {
        _errorMessage = l10n.leagueNameLengthError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Backend Execution: Await the Supabase call to create the private league.
      final newLeague = await ref
          .read(privateLeagueControllerProvider.notifier)
          .createLeague(
            name: name,
            competitionId: _selectedCompetitionId,
            description: _descriptionController.text.trim(),
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 2. Success Confirmation: Immediately display a success Snackbar.
      PicoSnackBar.showSuccess(context, l10n.leagueCreatedSuccessToast);

      // 3. Yield to UI: Add a brief micro-delay so the Flutter framework renders the Snackbar.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // 4. Show Ad & Transition: Call RevenueCatAdService and transition when ad closes or degrades.
      var dialogShown = false;
      void showLeagueSuccess() {
        if (!dialogShown && mounted) {
          dialogShown = true;
          _showSuccessDialog(newLeague);
        }
      }

      try {
        await RevenueCatAdService.instance.showInterstitialAd(
          placement: 'private_league_creation',
          onDismissed: showLeagueSuccess,
        );
      } catch (_) {
        showLeagueSuccess();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showSuccessDialog(PrivateLeague league) {
    final l10n = AppLocalizations.of(context)!;
    final compsMap = ref.read(competitionsMapProvider).value ?? {};
    final comp = compsMap[league.competitionId];

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400.0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22.0, 26.0, 22.0, 26.0),
                decoration: BoxDecoration(
                  color: PicoColors.darkTray,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: PicoColors.gold.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.65),
                      blurRadius: 32.0,
                      offset: const Offset(0, 10),
                    ),
                    const BoxShadow(
                      color: Color(0x3300E297),
                      blurRadius: 24.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy token with golden glow
                    Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF143322),
                        shape: BoxShape.circle,
                        border: Border.all(color: PicoColors.gold, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4DFFDFA0),
                            blurRadius: 16.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: PicoColors.gold,
                        size: 34.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Success Title
                    Text(
                      l10n.leagueCreatedSuccessTitle,
                      textAlign: TextAlign.center,
                      style: PicoTypography.headlineLgMobile.copyWith(
                        color: PicoColors.textWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(height: 6.0),

                    // League Name
                    Text(
                      league.name,
                      textAlign: TextAlign.center,
                      style: PicoTypography.headlineMd.copyWith(
                        color: PicoColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 17.0,
                      ),
                    ),

                    // Competition Badge
                    if (comp != null) ...[
                      const SizedBox(height: 6.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999.0),
                        ),
                        child: Text(
                          comp.name,
                          textAlign: TextAlign.center,
                          style: PicoTypography.bodySm.copyWith(
                            color: PicoColors.textWhiteMuted,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20.0),

                    // 6-character segmented display
                    Text(
                      l10n.inviteCodeLabel,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: PicoColors.textWhiteMuted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    _buildSegmentedCode(league.inviteCode),
                    const SizedBox(height: 24.0),

                    // Actions
                    Row(
                      children: [
                        // Copy Code Button
                        Expanded(
                          child: PicoButton.dark(
                            text: l10n.copyCodeButton,
                            icon: const Icon(Icons.copy_rounded, size: 18.0, color: Colors.white),
                            height: 48.0,
                            borderRadius: 14.0,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: league.inviteCode));
                              PicoSnackBar.showSuccess(context, l10n.codeCopiedToast);
                            },
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        // Done Button
                        Expanded(
                          child: PicoButton.gold(
                            text: l10n.doneButton,
                            height: 48.0,
                            borderRadius: 14.0,
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegmentedCode(String code) {
    final chars = code.padRight(6).split('');
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final itemWidth =
            ((availableWidth - (5 * 7.0)) / 6.0).clamp(32.0, 46.0);
        final itemHeight = (itemWidth * 1.18).clamp(38.0, 54.0);
        final fontSize = (itemWidth * 0.50).clamp(16.0, 22.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < chars.length; i++) ...[
              if (i > 0) const SizedBox(width: 7.0),
              Container(
                width: itemWidth,
                height: itemHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E16),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: PicoColors.primary, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF00522C),
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  chars[i],
                  style: PicoTypography.headlineLgMobile.copyWith(
                    color: PicoColors.textWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compsAsync = ref.watch(supportedCompetitionsProvider);
    final comps = compsAsync.value ?? [];
    final selectedComp = comps
            .where((c) => c.id == _selectedCompetitionId)
            .firstOrNull ??
        (comps.isNotEmpty
            ? comps.first
            : const Competition(
                id: '1',
                name: 'Primera División (La Liga)',
                emblemUrl:
                    'https://t.resfu.com/img_data/competiciones/logo/1.png?size=120x&lossy=1',
              ));

    return PicoPitchBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PicoAppBar(
          title: l10n.createPrivateLeagueTitle,
          isTransparent: true,
          showBackButton: true,
          onBack: () => Navigator.of(context).pop(),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: PicoColors.textWhiteMuted),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440.0),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              children: [
                // Atmosphere Header Hero Card
                _buildHeroHeader(l10n),
                const SizedBox(height: 20.0),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: PicoColors.darkTray,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // League Name Label
                      Text(
                        l10n.leagueNameLabel,
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // League Name Input Tray
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B13),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          key: const Key('league_name_field'),
                          controller: _nameController,
                          inputFormatters: InputSanitizer.leagueNameFormatters,
                          style: PicoTypography.bodyLg.copyWith(
                            color: PicoColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.leagueNamePlaceholder,
                            hintStyle: PicoTypography.bodyMd.copyWith(
                              color: PicoColors.textWhiteMuted.withValues(alpha: 0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.shield_rounded,
                              color: PicoColors.gold,
                              size: 22.0,
                            ),
                            suffixIcon: _nameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.cancel_rounded,
                                      color: PicoColors.textWhiteMuted,
                                      size: 18.0,
                                    ),
                                    onPressed: () {
                                      _nameController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 14.0,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 18.0),

                      // League Description Label
                      Text(
                        'LEAGUE DESCRIPTION (OPTIONAL)',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: PicoColors.textWhiteMuted,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // League Description Input Tray
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B13),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          key: const Key('league_description_field'),
                          controller: _descriptionController,
                          maxLines: 3,
                          minLines: 2,
                          maxLength: 150,
                          style: PicoTypography.bodyMd.copyWith(
                            color: PicoColors.textWhite,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., Compete with friends and crown the champion',
                            hintStyle: PicoTypography.bodyMd.copyWith(
                              color: PicoColors.textWhiteMuted.withValues(alpha: 0.5),
                            ),
                            counterStyle: PicoTypography.bodySm.copyWith(
                              fontSize: 11.0,
                              color: PicoColors.textWhiteMuted.withValues(alpha: 0.5),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 24.0),
                              child: Icon(
                                Icons.notes_rounded,
                                color: PicoColors.primary,
                                size: 20.0,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 12.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Base Tournament / Competition Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n.baseTournamentLabel,
                              style: PicoTypography.labelPillSm.copyWith(
                                color: PicoColors.textWhiteMuted,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            l10n.competitionsAvailableCount(comps.length),
                            style: PicoTypography.bodySm.copyWith(
                              color: PicoColors.primary,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),

                      // Competition Dropdown Display
                      _buildCompetitionSelector(selectedComp, comps),
                      const SizedBox(height: 8.0),

                      // Helper microcopy
                      Text(
                        l10n.baseTournamentHelper,
                        style: PicoTypography.bodySm.copyWith(
                          color: PicoColors.textWhiteMuted.withValues(alpha: 0.7),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Error Message if any
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: PicoColors.errorContainer,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: PicoColors.errorBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: PicoColors.error,
                          size: 18.0,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: PicoTypography.bodySm.copyWith(
                              color: PicoColors.errorText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],

                // Submit CTA Button (2.5D Tactile Game Button)
                _TactileSubmitButton(
                  isLoading: _isLoading,
                  label: l10n.createLeagueButton,
                  onPressed: _handleCreate,
                ),
                const SizedBox(height: 12.0),

                // Helper reassurance
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 14.0,
                      color: PicoColors.primary,
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        l10n.privateLeagueSecurityNote,
                        textAlign: TextAlign.center,
                        style: PicoTypography.bodySm.copyWith(
                          color: PicoColors.textWhiteMuted,
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
      ),
    ),
  );
}

  Widget _buildHeroHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E5238), // Vibrant bright emerald stadium tone
            Color(0xFF153F2B),
            Color(0xFF0F2E1F),
          ],
        ),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0x664ADE80), // Bright pitch line green border
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF071910),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon badge with glowing stadium frame
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68.0,
                height: 68.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2B6B48),
                      Color(0xFF1B4730),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(
                    color: PicoColors.gold,
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF0E281B),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x4DE6C687),
                      offset: Offset(0, 2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: PicoColors.gold,
                  size: 36.0,
                ),
              ),
              Positioned(
                bottom: -4.0,
                right: -4.0,
                child: Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1F14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PicoColors.gold,
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: PicoColors.primary,
                    size: 14.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            l10n.createPrivateLeagueTitle,
            style: PicoTypography.headlineLgMobile.copyWith(
              color: PicoColors.textWhite,
              fontWeight: FontWeight.w800,
              fontSize: 22.0,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            l10n.createPrivateLeagueSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFFD1FAE5), // Bright, readable mint chalk
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF265A3C), Color(0xFF1B432C)],
              ),
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(
                color: PicoColors.gold.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0E281A),
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: PicoColors.gold,
                  size: 14.0,
                ),
                const SizedBox(width: 6.0),
                Text(
                  l10n.freeSetupBadge.toUpperCase(),
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionSelector(
      Competition selectedComp, List<Competition> comps) {
    return InkWell(
      onTap: () => _openCompetitionPicker(context, comps),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B13),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: PicoColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Competition emblem with solid white container
            _buildEmblem(selectedComp),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedComp.name,
                    style: PicoTypography.bodyLg.copyWith(
                      color: PicoColors.textWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.officialBaseTournamentNote,
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhiteMuted,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: PicoColors.textWhite,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmblem(Competition comp, {bool isLightBackground = false}) {
    return Container(
      width: 38.0,
      height: 38.0,
      decoration: BoxDecoration(
        color: Colors.white, // Solid white background so logos are clearly visible
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isLightBackground
              ? const Color(0xFFE2E8F0)
              : Colors.white.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      child: comp.emblemUrl != null && comp.emblemUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: CachedNetworkImage(
                imageUrl: comp.emblemUrl!,
                width: 28.0,
                height: 28.0,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Text(
                  comp.flag,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
            )
          : Text(
              comp.flag,
              style: const TextStyle(fontSize: 20.0),
            ),
    );
  }

  void _openCompetitionPicker(
      BuildContext context, List<Competition> competitions) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, // Solid white background as requested
      elevation: 12.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12.0),
              // Drag handle
              Container(
                width: 44.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999.0),
                ),
              ),
              const SizedBox(height: 16.0),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFD97706),
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        l10n.selectBaseTournamentSheetTitle(competitions.length),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 16.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  itemCount: competitions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    final comp = competitions[index];
                    final isSelected = comp.id == _selectedCompetitionId;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _selectedCompetitionId = comp.id);
                          Navigator.of(ctx).pop();
                        },
                        borderRadius: BorderRadius.circular(14.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 11.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: isSelected
                                  ? PicoColors.primary
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: PicoColors.primary
                                          .withValues(alpha: 0.12),
                                      blurRadius: 6.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              _buildEmblem(comp, isLightBackground: true),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comp.name,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFF0F172A),
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      l10n.officialBaseTournamentNote,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFF64748B),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: PicoColors.primary,
                                  size: 22.0,
                                )
                              else
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 14.0,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }
}

/// Tactile 2.5D submit button with 4px physical bevel and responsive press dynamics.
/// Wraps an [ElevatedButton] to satisfy test harness finders while rendering custom 3D game geometry.
class _TactileSubmitButton extends StatefulWidget {
  const _TactileSubmitButton({
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_TactileSubmitButton> createState() => _TactileSubmitButtonState();
}

class _TactileSubmitButtonState extends State<_TactileSubmitButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevel = 4.0;
    final double translationY = _isPressed ? bevel : 0.0;
    final double currentBevel = _isPressed ? 1.0 : bevel;

    return Listener(
      onPointerDown: (_) {
        if (!widget.isLoading) {
          setState(() => _isPressed = true);
        }
      },
      onPointerUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      onPointerCancel: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
        }
      },
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          minimumSize: const Size(double.infinity, 54.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, translationY, 0.0),
          width: double.infinity,
          height: 54.0,
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
                color: const Color(0x40FFD41D),
                offset: Offset(0, currentBevel + 4),
                blurRadius: 14,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 22.0,
                  width: 22.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF261700)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Rubik',
                          color: Color(0xFF261700),
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20.0,
                      color: Color(0xFF261700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
