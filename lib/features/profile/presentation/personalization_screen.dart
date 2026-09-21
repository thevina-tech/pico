import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/profile/presentation/personalization_controller.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official "Pico — Personalization" screen.
///
/// Faithfully reproduces Stitch screen `2aa8ffeb3f234bebaadf5d7b898b0cf9`:
/// - Step indicator header ("STEP 2/5") with Back and Skip actions.
/// - Custom Username input well with tactile sunken container.
/// - Top Leagues & Cups horizontal selection chips.
/// - 3-column Bento grid of Clubs You Follow with crest emblems and tactile states.
/// - Championship Gold 3D CTA button updating profile in Supabase.
class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  late final TextEditingController _usernameController;

  static const _availableLeagues = [
    {'id': 'la_liga', 'name': 'La Liga', 'flag': '🇪🇸'},
    {'id': 'premier_league', 'name': 'Premier League', 'flag': '🏴󠁧󠁢󠁥󠁮󠁧󠁿'},
    {'id': 'champions_league', 'name': 'Champions League', 'flag': '⭐'},
    {'id': 'serie_a', 'name': 'Serie A', 'flag': '🇮🇹'},
    {'id': 'bundesliga', 'name': 'Bundesliga', 'flag': '🇩🇪'},
    {'id': 'ligue_1', 'name': 'Ligue 1', 'flag': '🇫🇷'},
  ];

  static const _availableClubs = [
    {
      'id': 'barcelona',
      'name': 'Barcelona',
      'code': 'FCB',
      'bg': Color(0xFFA50044),
      'inner': Color(0xFF004D98),
      'text': Color(0xFFFFD54F),
    },
    {
      'id': 'real_madrid',
      'name': 'Real Madrid',
      'code': 'RMA',
      'bg': Color(0xFFFFFFFF),
      'inner': Color(0xFF1E2A5A),
      'text': Color(0xFFFFFFFF),
    },
    {
      'id': 'arsenal',
      'name': 'Arsenal',
      'code': 'ARS',
      'bg': Color(0xFFEF0107),
      'inner': Color(0xFF063672),
      'text': Color(0xFFFFE082),
    },
    {
      'id': 'man_city',
      'name': 'Man City',
      'code': 'MCI',
      'bg': Color(0xFF6CABDD),
      'inner': Color(0xFF1C2C5B),
      'text': Color(0xFF6CABDD),
    },
    {
      'id': 'bayern',
      'name': 'Bayern',
      'code': 'FCB',
      'bg': Color(0xFFDC052D),
      'inner': Color(0xFF0066B2),
      'text': Color(0xFFFFFFFF),
    },
    {
      'id': 'psg',
      'name': 'PSG',
      'code': 'PSG',
      'bg': Color(0xFF004170),
      'inner': Color(0xFFDA291C),
      'text': Color(0xFFFFFFFF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final success =
        await ref.read(personalizationControllerProvider.notifier).submit();
    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(personalizationControllerProvider).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: PicoColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleSkip() {
    final l10n = AppLocalizations.of(context);
    final currentUsername = _usernameController.text.trim();
    if (currentUsername.isEmpty) {
      ref.read(personalizationControllerProvider.notifier).setUsername('');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.usernameErrorEmpty ??
                'Please introduce a username to continue.',
          ),
          backgroundColor: PicoColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    _handleContinue();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(personalizationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1D14),
      body: PicoPitchBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440.0),
              child: Column(
                children: [
                  // 1. Top Header Bar: Back, Step Pill, Skip
                  _buildHeaderBar(l10n),

                  // 2. Scrollable Selection Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12.0),

                          // Header Zone: Kicker & Titles
                          _buildHeaderZone(l10n),
                          const SizedBox(height: 20.0),

                          // Username Input Container
                          _buildUsernameSection(l10n, state),
                          const SizedBox(height: 24.0),

                          // Section 1: Top Leagues & Cups
                          _buildLeaguesSection(l10n, state),
                          const SizedBox(height: 24.0),

                          // Section 2: Clubs You Follow Bento Grid
                          _buildClubsSection(l10n, state),
                          const SizedBox(height: 16.0),

                          // Profile Info Note
                          _buildInfoNote(),
                          const SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ),

                  // 3. Docked Bottom Action Area
                  _buildBottomActionArea(l10n, state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar(AppLocalizations? l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/onboarding/how-it-works');
              }
            },
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFF143224),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFF254F3B)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF091710),
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF99F6B6),
                size: 20.0,
              ),
            ),
          ),

          // Step Indicator Pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xCC143224),
              borderRadius: BorderRadius.circular(999.0),
              border: Border.all(color: const Color(0xFF254F3B)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4DFFB2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  l10n?.stepIndicator(3, 5) ?? 'STEP 3/5',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFDFA0),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Skip Action
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              l10n?.skipButton ?? 'Skip',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFFBECABE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderZone(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kicker Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0x33FDDC9B),
            borderRadius: BorderRadius.circular(999.0),
            border: Border.all(color: const Color(0x66E2C384)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune, size: 13.0, color: Color(0xFFFFDFA0)),
              const SizedBox(width: 5.0),
              Text(
                l10n?.customizeFeedKicker ?? 'CUSTOMIZE YOUR FEED',
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFDFA0),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),

        // Title
        Text(
          l10n?.personalizationTitle ?? 'Pick Your Favorites',
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 26.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4.0),

        // Subtitle
        Text(
          l10n?.personalizationSubtitle ??
              'Choose your username and follow your favorite clubs & leagues.',
          style: PicoTypography.bodyMd.copyWith(
            color: const Color(0xFFA3B8AD),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameSection(
      AppLocalizations? l10n, PersonalizationState state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10281D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: state.errorMessage != null
              ? PicoColors.error
              : const Color(0xFF234F3A),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 3),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.usernameLabel ?? 'CHOOSE A USERNAME',
            style: const TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFDFA0),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _usernameController,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            cursorColor: const Color(0xFF00E297),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF091710),
              prefixIcon: const Icon(
                Icons.alternate_email,
                color: Color(0xFF00E297),
                size: 20.0,
              ),
              hintText: l10n?.usernamePlaceholder ?? 'e.g. joao_striker',
              hintStyle: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14.0,
                color: Color(0xFF6E8A7C),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF1B3D2C)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF1B3D2C)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(color: Color(0xFF00E297), width: 1.5),
              ),
            ),
            onChanged: (val) {
              ref
                  .read(personalizationControllerProvider.notifier)
                  .setUsername(val);
            },
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8.0),
            Text(
              state.errorMessage!,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12.0,
                color: PicoColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaguesSection(
      AppLocalizations? l10n, PersonalizationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.topLeaguesTitle.toUpperCase() ?? 'TOP LEAGUES & CUPS',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFDFA0),
                letterSpacing: 0.6,
              ),
            ),
            Text(
              '${state.selectedLeagueIds.length} selected',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 11.0,
                color: Color(0xFF728C7F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Horizontal Wrap Chips
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _availableLeagues.map((league) {
            final isSelected = state.selectedLeagueIds.contains(league['id']);
            return _buildLeagueChip(
              id: league['id']!,
              name: league['name']!,
              flag: league['flag']!,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(personalizationControllerProvider.notifier)
                    .toggleLeague(league['id']!);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLeagueChip({
    required String id,
    required String name,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF9F4) : const Color(0xCC132C20),
          borderRadius: BorderRadius.circular(999.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E297) : const Color(0xFF234D38),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFF054028),
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 14.0)),
            const SizedBox(width: 6.0),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1B1C19)
                    : const Color(0xFFC7D9CE),
              ),
            ),
            const SizedBox(width: 6.0),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 16.0,
              color: isSelected
                  ? const Color(0xFF006A3A)
                  : const Color(0xFF4D7360),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubsSection(
      AppLocalizations? l10n, PersonalizationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.clubsFollowTitle.toUpperCase() ?? 'CLUBS YOU FOLLOW',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFDFA0),
                letterSpacing: 0.6,
              ),
            ),
            Text(
              '${state.selectedTeamIds.length} selected',
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 11.0,
                color: Color(0xFF728C7F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // 3-Column Bento Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableClubs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final club = _availableClubs[index];
            final clubId = club['id'] as String;
            final isSelected = state.selectedTeamIds.contains(clubId);

            return _buildClubCard(
              id: clubId,
              name: club['name'] as String,
              code: club['code'] as String,
              bg: club['bg'] as Color,
              inner: club['inner'] as Color,
              textColor: club['text'] as Color,
              isSelected: isSelected,
              onTap: () {
                ref
                    .read(personalizationControllerProvider.notifier)
                    .toggleTeam(clubId);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildClubCard({
    required String id,
    required String name,
    required String code,
    required Color bg,
    required Color inner,
    required Color textColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF9F4) : const Color(0xE6122E20),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E297) : const Color(0xFF234F3A),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFF004726),
                    offset: Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0xFF08170F),
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Top Right Selected/Add Badge
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                size: 16.0,
                color: isSelected
                    ? const Color(0xFF006A3A)
                    : const Color(0xFF4D7561),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 6.0),
                  // Crest Container
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: inner,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        code,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Club Name
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF1B1C19)
                          : const Color(0xFFC7D9CE),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return const Row(
      children: [
        Icon(Icons.info_outline, size: 16.0, color: Color(0xFFFFDFA0)),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            'You can change or add more clubs anytime in your profile.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12.0,
              color: Color(0xFF8BA699),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionArea(
      AppLocalizations? l10n, PersonalizationState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF0B1D14),
        border: Border(
          top: BorderSide(color: Color(0x26FFFFFF), width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // 3D Championship Gold Action Button
          _TactileGoldContinueButton(
            text: l10n?.continueButton ?? 'Continue',
            isLoading: state.isSubmitting,
            onPressed: state.isSubmitting ? null : _handleContinue,
          ),
          const SizedBox(height: 8.0),

          // Preferences Sync Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6.0,
                height: 6.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF4DFFB2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  l10n?.preferencesSyncHint ??
                      'Preferences sync instantly across Pico League',
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 11.0,
                    color: Color(0xFF6E8A7C),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TactileGoldContinueButton extends StatefulWidget {
  const _TactileGoldContinueButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  State<_TactileGoldContinueButton> createState() =>
      _TactileGoldContinueButtonState();
}

class _TactileGoldContinueButtonState
    extends State<_TactileGoldContinueButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const double bevelHeight = 4.0;

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 75),
        margin: EdgeInsets.only(
          top: _isPressed ? bevelHeight : 0,
          bottom: _isPressed ? 0 : bevelHeight,
        ),
        width: double.infinity,
        height: 54.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFDFA0), Color(0xFFF1CB7A), Color(0xFFE2C384)],
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF775F2A),
                    offset: Offset(0, bevelHeight),
                  ),
                  BoxShadow(
                    color: Color(0x59000000),
                    offset: Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Gloss Highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16.0)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            if (widget.isLoading)
              const SizedBox(
                width: 22.0,
                height: 22.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF261A00)),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.text,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 17.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF261A00),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20.0,
                    color: Color(0xFF261A00),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
