import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/features/profile/presentation/user_profile_provider.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/game_exit_dialog.dart';
import 'package:pico/shared/components/pico_app_bar.dart';
import 'package:pico/shared/components/pico_bottom_nav_bar.dart';
import 'package:pico/shared/components/pico_pitch_background.dart';

/// The official Pico Shop screen based on Stitch "Friendly Football World" game aesthetics.
///
/// Features:
/// 1. Top bar with Level/XP, Coins, and Streak.
/// 2. Featured Pico Pro Pass with tactile rewards and perks.
/// 3. Coins Vault with tiered coin packages.
/// 4. Game Boosters (Streak Shields, Private League Expansion).
/// 5. Mascot Wardrobe & Customizations.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({
    super.key,
    this.showBottomNavBar = false,
    this.currentNavIndex = 0,
    this.onNavTap,
  });

  final bool showBottomNavBar;
  final int currentNavIndex;
  final ValueChanged<int>? onNavTap;

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late int _currentNavIndex;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.currentNavIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final userCoins = profileAsync.value?.coins ?? 1450;

    return PicoGameExitScope(
      child: Scaffold(
        backgroundColor: PicoColors.pitchBackground,
        appBar: PicoAppBar(
          onProfileTap: () => context.go('/profile'),
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
                          break;
                        case 1:
                          context.go('/matches');
                          break;
                        case 2:
                          context.go('/home');
                          break;
                        case 3:
                          context.go('/tournaments');
                          break;
                        case 4:
                          context.go('/profile');
                          break;
                      }
                    },
                  ),
                ),
              )
            : null,
        body: PicoPitchBackground(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 32.0),
                  children: [
                    // 1. Header Banner
                    _buildHeader(l10n, userCoins),
                    const SizedBox(height: 16.0),

                    // 2. Featured: Pico VIP Pass
                    _buildVipPassCard(context),
                    const SizedBox(height: 24.0),

                    // 3. Coins Vault
                    _buildSectionTitle(
                      title: 'COINS VAULT',
                      subtitle: 'Use coins to unlock extra private leagues & shields',
                      icon: Icons.monetization_on_rounded,
                      color: PicoColors.gold,
                    ),
                    const SizedBox(height: 12.0),
                    _buildCoinsGrid(context),
                    const SizedBox(height: 24.0),

                    // 4. Game Boosters
                    _buildSectionTitle(
                      title: 'TACTICAL BOOSTERS',
                      subtitle: 'Strengthen your prediction edge',
                      icon: Icons.bolt_rounded,
                      color: PicoColors.electricMint,
                    ),
                    const SizedBox(height: 12.0),
                    _buildBoostersList(context),
                    const SizedBox(height: 24.0),

                    // 5. Mascot Wardrobe Preview
                    _buildSectionTitle(
                      title: 'MASCOT WARDROBE',
                      subtitle: 'Customize Coach Pico on matchday',
                      icon: Icons.checkroom_rounded,
                      color: PicoColors.primaryFixed,
                    ),
                    const SizedBox(height: 12.0),
                    _buildWardrobeSection(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n, int coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x24FFFFFF), width: 1.0),
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
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: PicoColors.primaryDark,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: PicoColors.primaryFixed, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/images/nav_shop.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.storefront_rounded,
                  color: PicoColors.primaryFixed,
                  size: 24.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLUB SHOP',
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Boosts, passes & stadium gear',
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted,
                  ),
                ),
              ],
            ),
          ),
          // Coin balance pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1607),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: PicoColors.gold, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  size: 14.0,
                  color: PicoColors.gold,
                ),
                const SizedBox(width: 5.0),
                Text(
                  '$coins',
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.0, color: color),
            const SizedBox(width: 6.0),
            Text(
              title,
              style: PicoTypography.labelPill.copyWith(
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          subtitle,
          style: PicoTypography.bodySm.copyWith(
            color: PicoColors.textWhiteMuted,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  Widget _buildVipPassCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E240D),
            Color(0xFF171305),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: PicoColors.gold, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Icon(
              Icons.stars_rounded,
              size: 130,
              color: PicoColors.gold.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: PicoColors.gold,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [
                          BoxShadow(
                            color: PicoColors.goldBevel,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'FEATURED PASS',
                        style: PicoTypography.labelPillSm.copyWith(
                          color: const Color(0xFF1B1607),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'PICO PRO',
                      style: PicoTypography.statCounter.copyWith(
                        color: PicoColors.gold,
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  'The Ultimate Football Predictor Pass',
                  style: PicoTypography.headlineMd.copyWith(
                    color: PicoColors.textWhite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10.0),
                _buildPerkRow('Ad-Free Matchday Experience'),
                _buildPerkRow('Unlimited Private Leagues (Beyond 10)'),
                _buildPerkRow('Exclusive Trophy Cabinet Frames'),
                _buildPerkRow('2x XP Multipliers on Big Derbies'),
                const SizedBox(height: 16.0),
                // CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 46.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PicoColors.primary,
                      foregroundColor: PicoColors.textWhite,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pico Pro Pass powered by RevenueCat!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 18.0),
                        const SizedBox(width: 8.0),
                        Text(
                          'GET PICO PRO • \$3.99/mo',
                          style: PicoTypography.labelPill.copyWith(
                            color: PicoColors.textWhite,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

  Widget _buildPerkRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16.0,
            color: PicoColors.electricMint,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: PicoTypography.bodySm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsGrid(BuildContext context) {
    final packs = [
      {'name': 'Scout Bag', 'coins': '500', 'price': '\$0.99', 'popular': false},
      {'name': 'Captain Chest', 'coins': '1,200', 'price': '\$1.99', 'popular': true},
      {'name': 'Champion Safe', 'coins': '3,500', 'price': '\$4.99', 'popular': false},
    ];

    return Row(
      children: packs.map((pack) {
        final bool isPopular = pack['popular'] as bool;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: PicoColors.pitchSurfaceElevated,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isPopular ? PicoColors.gold : const Color(0x24FFFFFF),
                width: isPopular ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                if (isPopular)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: PicoColors.gold,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      'BEST VALUE',
                      style: PicoTypography.labelPillSm.copyWith(
                        color: const Color(0xFF1B1607),
                        fontSize: 8.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                const Icon(
                  Icons.monetization_on_rounded,
                  size: 28.0,
                  color: PicoColors.gold,
                ),
                const SizedBox(height: 6.0),
                Text(
                  '${pack['coins']}',
                  style: PicoTypography.statCounter.copyWith(
                    color: PicoColors.textWhite,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  pack['name'] as String,
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted,
                    fontSize: 10.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  height: 32.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? PicoColors.gold : const Color(0xFF26332B),
                      foregroundColor: isPopular ? const Color(0xFF1B1607) : PicoColors.textWhite,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchased ${pack['name']}!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Text(
                      pack['price'] as String,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: isPopular ? const Color(0xFF1B1607) : PicoColors.textWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBoostersList(BuildContext context) {
    final boosters = [
      {
        'title': 'Streak Shield',
        'desc': 'Preserves your streak if a single match goes wrong',
        'cost': '150 Coins',
        'icon': Icons.shield_rounded,
        'color': PicoColors.electricMint,
      },
      {
        'title': 'Private League Pass',
        'desc': 'Create an extra private league slot beyond your free 10',
        'cost': '250 Coins',
        'icon': Icons.group_add_rounded,
        'color': PicoColors.gold,
      },
      {
        'title': 'Double XP Boost (24h)',
        'desc': 'Earn 2x XP across all submitted and settled matches',
        'cost': '300 Coins',
        'icon': Icons.trending_up_rounded,
        'color': PicoColors.primaryFixed,
      },
    ];

    return Column(
      children: boosters.map((booster) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: PicoColors.pitchSurfaceElevated,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0x1FFFFFFF), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: (booster['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  booster['icon'] as IconData,
                  color: booster['color'] as Color,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booster['title'] as String,
                      style: PicoTypography.labelPill.copyWith(
                        color: PicoColors.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      booster['desc'] as String,
                      style: PicoTypography.bodySm.copyWith(
                        color: PicoColors.textWhiteMuted,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A2B),
                  foregroundColor: PicoColors.primaryFixed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Activated ${booster['title']}!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Text(
                  booster['cost'] as String,
                  style: PicoTypography.labelPillSm.copyWith(
                    color: PicoColors.primaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWardrobeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PicoColors.pitchSurfaceElevated,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x1FFFFFFF), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: PicoColors.primaryDark,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                'assets/images/nav_profile.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.person_rounded,
                  color: PicoColors.primaryFixed,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coach Pico Gear',
                  style: PicoTypography.labelPill.copyWith(
                    color: PicoColors.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Exclusive manager caps, retro shirts & golden whistle customizations arriving in next drop.',
                  style: PicoTypography.bodySm.copyWith(
                    color: PicoColors.textWhiteMuted,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              'SOON',
              style: PicoTypography.labelPillSm.copyWith(
                color: PicoColors.textWhiteMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
