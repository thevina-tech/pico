import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pico/core/theme/pico_colors.dart';
import 'package:pico/core/theme/pico_typography.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_companion.dart';

/// Safely and definitely terminates/exits the application.
///
/// 1. Calls [SystemNavigator.pop] to signal Android/iOS to finish the activity
///    and run standard OS teardown animations.
/// 2. If the platform process has not exited after 250ms (e.g. in debug mode,
///    certain OEM Android task managers, or nested Activity stacks), terminates
///    the VM process via [exit(0)].
Future<void> quitGame() async {
  try {
    await SystemNavigator.pop();
  } catch (_) {
    // If SystemNavigator.pop throws or is unavailable, fallback directly
  }

  // Ensure process terminates if SystemNavigator.pop() did not destroy the process
  // (Disabled during widget/unit tests to preserve the test runner).
  if (!kIsWeb && !Platform.environment.containsKey('FLUTTER_TEST')) {
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      exit(0);
    });
  }
}

/// Tactile Clash Royale style exit confirmation modal dialog.
/// Displays when user presses the Android system back button.
Future<bool?> showGameExitDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final title = l10n?.exitDialogTitle ?? 'Leaving the Pitch?';
  final message = l10n?.exitDialogMessage ??
      'Are you sure you want to quit Pico? Upcoming matches and predictions are waiting for you!';
  final stayButtonText = l10n?.exitDialogStayButton ?? 'STAY & PREDICT';
  final leaveButtonText = l10n?.exitDialogLeaveButton ?? 'Leave Game';

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      final dialogL10n = AppLocalizations.of(dialogContext) ?? l10n;
      final dialogTitle = dialogL10n?.exitDialogTitle ?? title;
      final dialogMessage = dialogL10n?.exitDialogMessage ?? message;
      final dialogStayText = dialogL10n?.exitDialogStayButton ?? stayButtonText;
      final dialogLeaveText = dialogL10n?.exitDialogLeaveButton ?? leaveButtonText;

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2417),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: const Color(0xFF1E432F), width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF06110A),
                offset: Offset(0, 6),
                blurRadius: 0,
              ),
              BoxShadow(
                color: Colors.black87,
                offset: Offset(0, 12),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascot Avatar Anchor
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: PicoColors.primary,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: PicoColors.primaryFixed, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF065F46),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: PicoCompanion.avatar(size: 38.0),
                ),
              ),
              const SizedBox(height: 18.0),

              // Title
              Text(
                dialogTitle,
                style: PicoTypography.headlineMd.copyWith(
                  color: PicoColors.textWhite,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),

              // Subtitle
              Text(
                dialogMessage,
                style: PicoTypography.bodySm.copyWith(
                  color: PicoColors.textWhiteMuted,
                  fontSize: 13.0,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // 1. Primary Stay & Predict Button (Green 3D tactile button)
              GestureDetector(
                key: const Key('game_exit_dialog_stay_button'),
                onTap: () => Navigator.of(dialogContext).pop(false),
                child: Container(
                  width: double.infinity,
                  height: 48.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF22C55E),
                        Color(0xFF15803D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF14532D),
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      dialogStayText,
                      style: PicoTypography.labelPillSm.copyWith(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              // 2. Secondary Exit Button ("Leave Game" / "Salir del Juego")
              GestureDetector(
                key: const Key('game_exit_dialog_exit_button'),
                onTap: () => Navigator.of(dialogContext).pop(true),
                child: Container(
                  width: double.infinity,
                  height: 40.0,
                  alignment: Alignment.center,
                  child: Text(
                    dialogLeaveText,
                    style: PicoTypography.bodySm.copyWith(
                      color: PicoColors.textWhiteMuted.withValues(alpha: 0.8),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Reusable wrapper that intercepts Android system back events (gesture or nav button)
/// and displays the [showGameExitDialog] exit confirmation modal.
class PicoGameExitScope extends StatelessWidget {
  const PicoGameExitScope({
    super.key,
    required this.child,
    this.onStay,
  });

  final Widget child;
  final VoidCallback? onStay;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!context.mounted) return;
        final shouldExit = await showGameExitDialog(context);
        if (shouldExit == true) {
          await quitGame();
        } else {
          onStay?.call();
        }
      },
      child: child,
    );
  }
}

