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

  @override
  String get onboardingWelcomeTitle => 'Predice Fútbol.\nCompite con Amigos.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Pronostica marcadores, acumula Puntos Pico y compite con amigos en ligas privadas y globales.';

  @override
  String get getStartedButton => 'Empezar';

  @override
  String get setupSpeedHint => 'Se configura en menos de 1 minuto.';

  @override
  String get howPicoWorksTitle => 'Cómo Funciona Pico';

  @override
  String get howPicoWorksSubtitle =>
      'Simple, rápido y hecho para los días de partido.';

  @override
  String get step1Title => 'Pronostica el marcador';

  @override
  String get step1Description =>
      'Elige ganador y marcador exacto antes del inicio';

  @override
  String get step2Title => 'Gana puntos y sube';

  @override
  String get step2Description =>
      'Acierta marcadores cada semana y suma Puntos Pico';

  @override
  String get step3Title => 'Gana trofeos de torneo';

  @override
  String get step3Description =>
      'Supera a tus amigos y domina el ranking mundial';

  @override
  String get nextStepHint => 'Siguiente: Elige tu equipo favorito (15 seg)';

  @override
  String stepIndicator(int current, int total) {
    return 'PASO $current/$total';
  }

  @override
  String get personalizationTitle => 'Elige tus Favoritos';

  @override
  String get personalizationSubtitle =>
      'Elige tu nombre de usuario y sigue tus clubes y ligas favoritas.';

  @override
  String get customizeFeedKicker => 'PERSONALIZA TU FEED';

  @override
  String get usernameLabel => 'Elige un Nombre de Usuario';

  @override
  String get usernamePlaceholder => 'ej. joao_goleador';

  @override
  String get usernameErrorEmpty =>
      'Por favor introduce un nombre de usuario para continuar.';

  @override
  String get usernameErrorTooShort =>
      'El nombre debe tener al menos 3 caracteres';

  @override
  String get topLeaguesTitle => 'Ligas y Copas Principales';

  @override
  String get clubsFollowTitle => 'Clubes que Sigues';

  @override
  String get personalizationHelperNote =>
      'Puedes cambiar tu equipo favorito y unirte a más torneos en cualquier momento.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get skipButton => 'Omitir';

  @override
  String get preferencesSyncHint =>
      'Tus preferencias se sincronizan al instante en la Liga Pico';

  @override
  String get savingPreferences => 'Guardando tu perfil...';

  @override
  String mascotGreeting(String username) {
    return '¡Gran partido esta noche, $username! ⚽';
  }

  @override
  String get upcomingMatchesTitle => 'Próximos Partidos';

  @override
  String get noUpcomingMatches =>
      'No hay próximos partidos en este momento. ¡Vuelve pronto!';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get homeMenuTitle => 'Ajustes y Menú';

  @override
  String get signOutButton => 'Cerrar Sesión';

  @override
  String get exitDialogTitle => '¿Abandonar la Cancha?';

  @override
  String get exitDialogMessage =>
      '¿Seguro que quieres salir de Pico? ¡Hay partidos y pronósticos esperándote!';

  @override
  String get exitDialogStayButton => 'QUEDARSE Y PREDECIR';

  @override
  String get exitDialogLeaveButton => 'Salir del Juego';

  @override
  String get matchOfTheDayTitle => 'Partido del Día';

  @override
  String get viewAllMatches => 'Ver Todos';

  @override
  String moreMatchesAvailable(int count) {
    return '+$count partidos más en Partidos';
  }

  @override
  String get profileTitleKicker => 'Profeta del Partido';

  @override
  String get hitRateLabel => 'Acierto';

  @override
  String get matchesLabel => 'Partidos';

  @override
  String get podiumsLabel => 'Podios';

  @override
  String get clubRankLabel => 'Rango Club';

  @override
  String xpProgressToLevel(int level) {
    return 'Progreso de XP hacia NVL $level';
  }

  @override
  String get tournamentsAccordionTitle => 'Torneos';

  @override
  String get tournamentsAccordionSubtitle => 'Copas activas y ligas semanales';

  @override
  String tournamentsActiveCount(int count) {
    return '$count Activos';
  }

  @override
  String get followingAccordionTitle => 'Siguiendo';

  @override
  String get followingAccordionSubtitle => 'Clubes, ligas y alertas clave';

  @override
  String followingPinnedCount(int count) {
    return '$count Fijados';
  }

  @override
  String get historyAccordionTitle => 'Historial';

  @override
  String get historyAccordionSubtitle => 'Archivo de pronósticos y trofeos';

  @override
  String historySummary(int count, int rate) {
    return '$count Partidos · $rate%';
  }

  @override
  String get recentFormTitle => 'Forma Reciente (Últimos 10 Partidos)';

  @override
  String recentFormSummary(int wins, int exact) {
    return '$wins Victorias · $exact Exactos';
  }

  @override
  String get settingsAccordionTitle => 'Ajustes';

  @override
  String get settingsAccordionSubtitle =>
      'Preferencias, sonido y notificaciones';

  @override
  String get pushNotificationsTitle => 'Notificaciones Push';

  @override
  String get matchdayHapticsTitle => 'Vibración de Partido';

  @override
  String get enabledPill => 'Activado';

  @override
  String get onPill => 'Sí';

  @override
  String get shareMatchdayCard => 'Compartir Ficha del Día';

  @override
  String get shareCardModalTitle => 'Ficha Coleccionable de Partido';

  @override
  String get shareCardPrompt =>
      '¡Comparte tu ficha de Pico y estadísticas con tus amigos!';

  @override
  String get copyProfileSummary => 'Copiar Resumen de Ficha';

  @override
  String get profileSummaryCopied =>
      '¡Resumen de perfil copiado al portapapeles!';

  @override
  String get standingsButton => 'Clasificación';

  @override
  String pointsEarnedBadge(int points) {
    return '+$points Pts';
  }

  @override
  String streakPill(int count) {
    return '$count Racha';
  }

  @override
  String coinsPill(String count) {
    return '$count Monedas';
  }

  @override
  String levelPill(int level) {
    return 'NVL $level';
  }
}
