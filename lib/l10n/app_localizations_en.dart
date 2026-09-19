// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pico';

  @override
  String get predictButton => 'Predict';

  @override
  String get navHome => 'Home';

  @override
  String get navMatches => 'Matches';

  @override
  String get navTournaments => 'Tournaments';

  @override
  String get navProfile => 'Profile';

  @override
  String predictBy(String time) {
    return 'Predict by $time';
  }
}
