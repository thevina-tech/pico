import 'dart:io' show Platform, exit;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pico/l10n/app_localizations.dart';
import 'package:pico/shared/components/pico_confirmation_modal.dart';

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

/// Tactile exit confirmation modal dialog faithfully reproducing Stitch screen 4479dd85c5b64355bf6e946dede51811.
/// Displays when user presses the Android system back button.
Future<bool?> showGameExitDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final title = l10n?.exitDialogTitle ?? 'Exit App?';
  final message = l10n?.exitDialogMessage ?? 'Are you sure you want to exit?';
  final stayButtonText = l10n?.exitDialogStayButton ?? 'Stay';
  final leaveButtonText = l10n?.exitDialogLeaveButton ?? 'Exit';

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (BuildContext dialogContext) {
      final dialogL10n = AppLocalizations.of(dialogContext) ?? l10n;
      final dialogTitle = dialogL10n?.exitDialogTitle ?? title;
      final dialogMessage = dialogL10n?.exitDialogMessage ?? message;
      final dialogStayText = dialogL10n?.exitDialogStayButton ?? stayButtonText;
      final dialogLeaveText = dialogL10n?.exitDialogLeaveButton ?? leaveButtonText;

      return PicoConfirmationModal(
        showLogo: false,
        showWatermark: false,
        title: dialogTitle,
        message: dialogMessage,
        cancelText: dialogStayText,
        confirmText: dialogLeaveText,
        cancelStyle: PicoDialogButtonStyle.green,
        confirmStyle: PicoDialogButtonStyle.red,
        cancelKey: const Key('game_exit_dialog_stay_button'),
        confirmKey: const Key('game_exit_dialog_exit_button'),
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
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

