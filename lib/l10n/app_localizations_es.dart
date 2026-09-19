// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pico';

  @override
  String get predictButton => 'Predecir';

  @override
  String get navHome => 'Inicio';

  @override
  String get navMatches => 'Partidos';

  @override
  String get navTournaments => 'Torneos';

  @override
  String get navProfile => 'Perfil';

  @override
  String predictBy(String time) {
    return 'Predecir antes de $time';
  }
}
