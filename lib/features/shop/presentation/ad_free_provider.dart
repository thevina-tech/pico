import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:pico/core/logging/app_logger.dart';

/// Primary state provider tracking whether the user has the "remove_ads" entitlement active.
final isAdFreeProvider = NotifierProvider<AdFreeNotifier, bool>(() {
  return AdFreeNotifier();
});

/// Backwards compatibility alias for existing consumers and tests
final adFreeProvider = isAdFreeProvider;

class AdFreeNotifier extends Notifier<bool> {
  static const String entitlementId = 'remove_ads';
  bool _listenerRegistered = false;

  @override
  bool build() {
    Future.microtask(_initRevenueCat);
    return false;
  }

  Future<void> _initRevenueCat() async {
    if (_isTestEnvironment) {
      return;
    }

    try {
      // 1. Listen to real-time entitlement updates from RevenueCat
      if (!_listenerRegistered) {
        Purchases.addCustomerInfoUpdateListener((customerInfo) {
          _updateFromCustomerInfo(customerInfo);
        });
        _listenerRegistered = true;
      }

      // 2. Fetch current status on initialization
      final customerInfo = await Purchases.getCustomerInfo();
      _updateFromCustomerInfo(customerInfo);
    } catch (e) {
      AppLogger.warning('RevenueCat getCustomerInfo error: $e');
    }
  }

  void _updateFromCustomerInfo(CustomerInfo customerInfo) {
    final bool isActive =
        customerInfo.entitlements.all[entitlementId]?.isActive == true;
    state = isActive;
    AppLogger.info('isAdFree updated: $isActive');
  }

  /// Manually unlock for testing or offline simulations.
  Future<void> unlockAdFree() async {
    state = true;
  }

  /// Manually reset for testing or offline simulations.
  Future<void> resetAdFree() async {
    state = false;
  }

  bool get _isTestEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }
}
