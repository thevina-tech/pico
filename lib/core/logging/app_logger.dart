import 'package:talker_flutter/talker_flutter.dart';

/// Centralized logger for Pico application using [Talker].
///
/// Ensures consistent logging across repositories, controllers, and services,
/// preventing unformatted raw print() calls in production.
class AppLogger {
  AppLogger._();

  static final Talker instance = TalkerFlutter.init(
    settings: TalkerSettings(
      useHistory: true,
      maxHistoryItems: 200,
    ),
  );

  static void info(String message) => instance.info(message);
  static void debug(String message) => instance.debug(message);
  static void warning(String message) => instance.warning(message);
  static void error(String message, [Object? exception, StackTrace? stackTrace]) {
    instance.error(message, exception, stackTrace);
  }
}
