import 'package:flutter/material.dart';
import 'package:pico/features/profile/domain/division.dart';

/// Display size variants for [DivisionBadge].
enum DivisionBadgeSize {
  small(height: 22.0, fontSize: 10.0, horizontalPadding: 6.0, radius: 6.0),
  medium(height: 30.0, fontSize: 12.0, horizontalPadding: 9.0, radius: 8.0),
  large(height: 38.0, fontSize: 14.0, horizontalPadding: 12.0, radius: 10.0);

  const DivisionBadgeSize({
    required this.height,
    required this.fontSize,
    required this.horizontalPadding,
    required this.radius,
  });

  final double height;
  final double fontSize;
  final double horizontalPadding;
  final double radius;
}

/// A tactile 3D gamified badge displaying a user's [DivisionTier].
/// Styled with tier-specific metallic gradients, neon borders, and beveled glass reflection.
class DivisionBadge extends StatelessWidget {
  const DivisionBadge({
    super.key,
    required this.tier,
    this.size = DivisionBadgeSize.medium,
    this.onTap,
  });

  /// Factory constructor to resolve the tier directly from [points].
  factory DivisionBadge.fromPoints({
    Key? key,
    required int points,
    DivisionBadgeSize size = DivisionBadgeSize.medium,
    VoidCallback? onTap,
  }) {
    return DivisionBadge(
      key: key,
      tier: DivisionTier.fromPoints(points),
      size: size,
      onTap: onTap,
    );
  }

  final DivisionTier tier;
  final DivisionBadgeSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      height: size.height,
      padding: EdgeInsets.symmetric(horizontal: size.horizontalPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: tier.gradientColors,
        ),
        borderRadius: BorderRadius.circular(size.radius),
        border: Border.all(
          color: tier.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.borderColor.withValues(alpha: 0.35),
            offset: const Offset(0, 2),
            blurRadius: 3.0,
          ),
          const BoxShadow(
            color: Color(0x60000000),
            offset: Offset(0, 2),
            blurRadius: 2.0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top bevel highlight / shine
          Positioned(
            top: 1.0,
            left: 1.0,
            right: 1.0,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                color: tier.accentColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tier == DivisionTier.elite) ...[
                  Icon(
                    Icons.stars_rounded,
                    color: tier.accentColor,
                    size: size.fontSize + 2.0,
                  ),
                  const SizedBox(width: 3.0),
                ],
                Text(
                  tier.badgeLabel,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: size.fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: tier.accentColor,
                    shadows: const [
                      Shadow(
                        color: Color(0xCC000000),
                        offset: Offset(0, 1.5),
                        blurRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: badge,
      );
    }

    return badge;
  }
}
