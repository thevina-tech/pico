/// Domain exceptions related to Private Leagues.
sealed class PrivateLeagueException implements Exception {
  final String message;
  const PrivateLeagueException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the provided 6-character invite code does not exist.
class LeagueNotFoundException extends PrivateLeagueException {
  const LeagueNotFoundException([super.message = 'LEAGUE_NOT_FOUND']);
}

/// Thrown when the user is already a participating member in the league.
class LeagueAlreadyMemberException extends PrivateLeagueException {
  const LeagueAlreadyMemberException([super.message = 'ALREADY_MEMBER']);
}

/// Thrown when the user created the league and attempts to rejoin it.
class LeagueCreatorCannotRejoinException extends PrivateLeagueException {
  const LeagueCreatorCannotRejoinException([super.message = 'CREATOR_CANNOT_REJOIN']);
}

/// Thrown when a non-owner attempts an admin-only operation (delete, kick).
class LeagueNotOwnerException extends PrivateLeagueException {
  const LeagueNotOwnerException([super.message = 'NOT_LEAGUE_OWNER']);
}

/// Thrown when the league creator attempts to leave rather than delete their league.
class LeagueOwnerCannotLeaveException extends PrivateLeagueException {
  const LeagueOwnerCannotLeaveException([super.message = 'OWNER_CANNOT_LEAVE']);
}

/// Thrown when an owner attempts to remove themselves via member removal.
class LeagueOwnerCannotBeRemovedException extends PrivateLeagueException {
  const LeagueOwnerCannotBeRemovedException([super.message = 'OWNER_CANNOT_BE_REMOVED']);
}

/// Generic private league exception fallback.
class LeagueGenericException extends PrivateLeagueException {
  const LeagueGenericException(super.message);
}

