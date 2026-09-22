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
      'No hay partidos próximos ahora. ¡Vuelve pronto!';

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

  @override
  String get predictAction => 'PREDECIR';

  @override
  String get exactScore => 'Marcador exacto';

  @override
  String get exactScoreTitle => 'Pronóstico de Marcador Exacto';

  @override
  String get pickWinner => 'Elige Ganador';

  @override
  String get whoWins => '¿Quién gana?';

  @override
  String get homeOutcome => 'Local';

  @override
  String get drawOutcome => 'Empate';

  @override
  String get awayOutcome => 'Visitante';

  @override
  String get savePredictionCta => 'Guardar Pronóstico (+10 XP)';

  @override
  String get modifyPrediction => 'Modificar Pronóstico';

  @override
  String get predictionLockedTitle => '¡Pronóstico Bloqueado! ⚽';

  @override
  String predictionLockedBanner(String time) {
    return 'Pronóstico bloqueado · Inicio a las $time';
  }

  @override
  String get predictionWindowClosed =>
      'Los pronósticos están cerrados para este partido';

  @override
  String get predictionLockNote =>
      'Los pronósticos se bloquean exactamente 10 minutos antes del inicio.';

  @override
  String get potentialPointsHeader => 'Puntos Pico Potenciales';

  @override
  String get potentialPointsBreakdown =>
      '+5 por marcador exacto · +3 por ganador acertado';

  @override
  String get quickPredict => 'Pronóstico Rápido';

  @override
  String get predictionSavedToast => '¡Pronóstico registrado! Buena suerte.';

  @override
  String get tournamentsTitle => 'Torneos';

  @override
  String get tournamentsSubtitle => 'Compite con amigos · Sin dinero real';

  @override
  String get myLeaguesTab => 'Mis Ligas';

  @override
  String get discoverTab => 'Descubrir';

  @override
  String get createOrJoinAction => '+ Crear / Unirse';

  @override
  String get createPrivateLeagueTitle => 'Crear Liga Privada';

  @override
  String get createPrivateLeagueSubtitle =>
      'Compite con amigos, piques sanos y corona al campeón de tu grupo.';

  @override
  String get joinPrivateLeagueTitle => 'Unirse a Liga Privada';

  @override
  String get joinPrivateLeagueSubtitle =>
      'Introduce el código de 6 caracteres compartido por tu amigo.';

  @override
  String get leagueNameLabel => 'NOMBRE DE LA LIGA';

  @override
  String get leagueNamePlaceholder => 'ej. Los Reyes del Viernes';

  @override
  String get baseTournamentLabel => 'TORNEO BASE / COMPETICIÓN';

  @override
  String get baseTournamentHelper =>
      'Los partidos y la clasificación se vinculan a esta competición.';

  @override
  String get freeSetupBadge => 'Creación Gratuita';

  @override
  String get createLeagueButton => 'Crear Liga Privada';

  @override
  String get joinLeagueButton => 'Unirse a la Liga';

  @override
  String get enterLeagueCodeLabel => 'INTRODUCE CÓDIGO DE 6 CARACTERES';

  @override
  String get pasteCode => 'Pegar';

  @override
  String get codeCopiedToast => '¡Código de invitación copiado!';

  @override
  String shareInviteMessage(String code) {
    return '¡Únete a mi liga privada en Pico! Usa el código: $code';
  }

  @override
  String get inviteCodeLabel => 'CÓDIGO DE INVITACIÓN';

  @override
  String get copyCodeButton => 'Copiar Código';

  @override
  String get shareCodeButton => 'Compartir Invitación';

  @override
  String get emptyPrivateLeaguesTitle => 'Aún no tienes ligas privadas';

  @override
  String get emptyPrivateLeaguesSubtitle =>
      'Crea una liga para tus amigos o únete con un código de invitación.';

  @override
  String get officialTournamentBadge => 'TORNEO OFICIAL';

  @override
  String get leagueCreatedSuccessTitle => '¡Liga Creada! 🎉';

  @override
  String get leagueJoinedSuccessTitle => '¡Estás dentro! ⚽';

  @override
  String leagueJoinedSuccessSubtitle(String leagueName) {
    return 'Te has unido a $leagueName';
  }

  @override
  String get invalidLeagueCodeError =>
      'Código de invitación inválido. Por favor revísalo e inténtalo de nuevo.';

  @override
  String get alreadyMemberOfLeagueError =>
      'Ya eres miembro de esta liga privada.';

  @override
  String get creatorCannotRejoinError =>
      'Tú creaste esta liga y ya eres su administrador.';

  @override
  String get leagueCodeFormatError =>
      'El código debe tener exactamente 6 caracteres (ej. K9X2P1)';

  @override
  String get doneButton => 'Listo';

  @override
  String get privateLeagueSecurityNote =>
      'Solo los jugadores con tu código de invitación podrán unirse';

  @override
  String get officialBaseTournamentNote => 'Torneo Base Oficial';

  @override
  String competitionsAvailableCount(int count) {
    return '$count disponibles';
  }

  @override
  String get friendsAndColleaguesBadge => 'AMIGOS Y COLEGAS';

  @override
  String get privateCommunitySubtitle => 'Comunidad Privada';

  @override
  String selectBaseTournamentSheetTitle(int count) {
    return 'Seleccionar Torneo Base ($count Disponibles)';
  }

  @override
  String get tournamentDetailsTitle => 'Detalles del Torneo';

  @override
  String get privateLeagueDetailsTitle => 'Liga Privada';

  @override
  String get inviteCodeBannerTitle => 'CÓDIGO DE INVITACIÓN';

  @override
  String get inviteCodeBannerSubtitle =>
      'Comparte con amigos para competir juntos';

  @override
  String shareInviteCodeMessage(String leagueName, String code) {
    return '¡Únete a mi liga privada \"$leagueName\" en Pico! Código de invitación: $code';
  }

  @override
  String get adminControlsTitle => 'CONTROLES DE ADMINISTRADOR';

  @override
  String get deleteLeagueButton => 'Eliminar Liga';

  @override
  String get deleteLeagueConfirmTitle => '¿Eliminar Liga Privada?';

  @override
  String get deleteLeagueConfirmBody =>
      'Esta acción es permanente. Se eliminarán todos los miembros y la tabla de posiciones.';

  @override
  String get deleteLeagueAction => 'Eliminar';

  @override
  String get removeMemberButton => 'Expulsar';

  @override
  String get removeMemberConfirmTitle => '¿Expulsar Miembro?';

  @override
  String removeMemberConfirmBody(String username) {
    return '¿Seguro que deseas expulsar a $username de esta liga?';
  }

  @override
  String get leaveLeagueButton => 'Salir de la Liga';

  @override
  String get leaveLeagueConfirmTitle => '¿Salir de la Liga?';

  @override
  String leaveLeagueConfirmBody(String leagueName) {
    return '¿Seguro que deseas salir de $leagueName? Necesitarás el código para volver a unirte.';
  }

  @override
  String get leaveLeagueAction => 'Salir';

  @override
  String get leaderboardTab => 'Clasificación';

  @override
  String get matchesTab => 'Partidos';

  @override
  String get upcomingMatchesSection => 'Próximos Partidos';

  @override
  String get finishedMatchesSection => 'Partidos Finalizados';

  @override
  String get noParticipantsYet => 'Aún no hay participantes';

  @override
  String get noMatchesForCompetition => 'No hay partidos para esta competición';

  @override
  String get leagueDeletedToast => 'Liga eliminada con éxito';

  @override
  String get memberRemovedToast => 'Miembro expulsado';

  @override
  String get leftLeagueToast => 'Has salido de la liga';

  @override
  String get creatorBadge => 'CREADOR';

  @override
  String get memberBadge => 'MIEMBRO';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get pointsAbbreviation => 'PTS';

  @override
  String get rankHeader => 'POS';

  @override
  String get playerHeader => 'JUGADOR';

  @override
  String get feedTabLive => 'En Vivo';

  @override
  String get feedTabUpcoming => 'Próximos';

  @override
  String get feedTabFinished => 'Finalizados';

  @override
  String teaserOpensInDays(int days) {
    return 'Abre en ${days}d';
  }

  @override
  String teaserOpensInHours(int hours) {
    return 'Abre en ${hours}h';
  }

  @override
  String teaserOpensInMinutes(int minutes) {
    return 'Abre en ${minutes}m';
  }

  @override
  String get teaserCountdownSubtext =>
      'La ventana de predicción abre 7 días antes del inicio';

  @override
  String get pointsOutcomeExact => '+5 Puntos';

  @override
  String get pointsOutcomeWinner => '+3 Puntos';

  @override
  String get pointsOutcomeIncorrect => '0 Puntos';

  @override
  String get pointsOutcomeNone => 'Sin Predicción';

  @override
  String get noLiveMatches => 'No hay partidos en vivo ahora';

  @override
  String get noLiveMatchesSub =>
      'Vuelve durante la jornada para ver partidos en tiempo real.';

  @override
  String get feedNoUpcomingMatches =>
      'No hay partidos próximos en los siguientes 14 días';

  @override
  String get noUpcomingMatchesSub =>
      'Los partidos programados aparecerán aquí.';

  @override
  String get noFinishedMatches =>
      'No hay partidos finalizados en los últimos 7 días';

  @override
  String get noFinishedMatchesSub =>
      'Los partidos finalizados recientemente y los puntos se mostrarán aquí.';
}
