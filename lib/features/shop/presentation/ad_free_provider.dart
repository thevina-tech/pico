import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider tracking whether the user has purchased the "Remove Ads" lifetime pass.
final adFreeProvider = NotifierProvider<AdFreeNotifier, bool>(() {
  return AdFreeNotifier();
});

class AdFreeNotifier extends Notifier<bool> {
  static const _key = 'pico_ad_free_unlocked';

  @override
  bool build() {
    _loadState();
    return false;
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isUnlocked = prefs.getBool(_key) ?? false;
      if (isUnlocked != state) {
        state = isUnlocked;
      }
    } catch (_) {}
  }

  Future<void> unlockAdFree() async {
    state = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {}
  }

  Future<void> resetAdFree() async {
    state = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, false);
    } catch (_) {}
  }
}
