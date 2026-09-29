import 'package:flutter/material.dart';

/// Reusable global top app bar implementing [PreferredSizeWidget],
/// featuring a high-impact, energetic game-like aesthetic.
///
/// Features:
/// - Stylized, vibrant game-themed background with a rich stadium turf multi-stop gradient,
///   stadium floodlight radial glow, and neon green pitch line bottom border.
/// - Prominently centered screen title in a bold, clean, game-like font with depth shadows.
/// - Tactile 3D back button on the left when [showBackButton] is true or [Navigator.canPop] is true.
/// - Preserves native navigation and optional [actions] on the right.
class PicoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PicoAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton,
    this.onBackPressed,
    this.onBack,
    this.actions,
    this.backgroundColor,
    // Legacy callbacks kept optional for backwards compatibility
    this.onProfileTap,
    this.onPointsTap,
    this.onCoinsTap,
    this.onStreakTap,
  });

  /// The text string for the centered screen title.
  final String? title;

  /// Optional custom title widget if a custom layout is preferred over [title].
  final Widget? titleWidget;

  /// Explicit flag to control back button visibility.
  /// If null, falls back to [Navigator.canPop].
  final bool? showBackButton;

  /// Callback executed when the back button is pressed.
  final VoidCallback? onBackPressed;

  /// Alias for [onBackPressed].
  final VoidCallback? onBack;

  /// Optional trailing action widgets on the right.
  final List<Widget>? actions;

  /// Optional override for the background color.
  final Color? backgroundColor;

  /// Legacy callback kept for backwards compatibility.
  final VoidCallback? onProfileTap;

  /// Legacy callback kept for backwards compatibility.
  final VoidCallback? onPointsTap;

  /// Legacy callback kept for backwards compatibility.
  final VoidCallback? onCoinsTap;

  /// Legacy callback kept for backwards compatibility.
  final VoidCallback? onStreakTap;

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final bool canPop = showBackButton ?? Navigator.of(context).canPop();

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xF20F3A30), // Rich stadium turf dark emerald
                  Color(0xF208241D),
                  Color(0xFA041410), // Deep ground base
                ],
              )
            : null,
        border: const Border(
          bottom: BorderSide(
            color: Color(0x5534D399), // Neon stadium turf line
            width: 1.5,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color(0x1A10B981), // Ambient neon stadium glow
            offset: Offset(0, 2),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Subtle Stadium Floodlight Center Glow
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          const Color(0x2E10B981), // Center turf glow
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Top Rim Subtle 3D Bevel Line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1.0,
                child: Container(
                  color: const Color(0x2634D399),
                ),
              ),

              // 3. Centered Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56.0),
                  child: titleWidget ??
                      (title != null && title!.isNotEmpty
                          ? Text(
                              title!,
                              key: const Key('pico_app_bar_title'),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 19.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.4,
                                shadows: [
                                  Shadow(
                                    color: Color(0xB3000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 4.0,
                                  ),
                                  Shadow(
                                    color: Color(0x4034D399),
                                    offset: Offset(0, 0),
                                    blurRadius: 8.0,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                ),
              ),

              // 4. Left: Tactile 3D Back Button (When pop is supported)
              if (canPop)
                Positioned(
                  left: 12.0,
                  child: _buildBackButton(context),
                ),

              // 5. Right: Custom Actions
              if (actions != null && actions!.isNotEmpty)
                Positioned(
                  right: 12.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tactile 3D Back button with stadium green depth, bevel border, and shadow.
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      key: const Key('pico_app_bar_back_button'),
      onTap: () {
        final callback = onBack ?? onBackPressed;
        if (callback != null) {
          callback();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF144D3F),
              Color(0xFF0A2E25),
            ],
          ),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: const Color(0xFF34D399).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
