import 'package:freezed_annotation/freezed_annotation.dart';
import 'division.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Normalized domain model for the `profiles` table in Supabase.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? email,
    String? username,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @Default(1) int level,
    @Default(0) int xp,
    @Default(0) int streak,
    @Default(0) int coins,
    @JsonKey(name: 'total_points') @Default(0) int totalPoints,
    @JsonKey(name: 'current_division_key') String? currentDivisionKey,
    @JsonKey(name: 'private_leagues_created')
    @Default(0)
    int privateLeaguesCreated,
    @JsonKey(name: 'favorite_team_id') String? favoriteTeamId,
    @JsonKey(name: 'favorite_team_ids')
    @Default(<String>[])
    List<String> favoriteTeamIds,
    @JsonKey(name: 'favorite_league_ids')
    @Default(<String>[])
    List<String> favoriteLeagueIds,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Extension providing XP progress calculations and string formatting for user profiles.
extension UserProfileXpX on UserProfile {
  /// Target XP required to advance to the next level.
  int get targetXpForLevel => 1000;

  /// Amount of XP accumulated in the current level tier.
  int get xpInLevel => xp % targetXpForLevel;

  /// Normalized progress ratio between 0.0 and 1.0.
  double get xpProgressRatio =>
      targetXpForLevel > 0 ? (xpInLevel / targetXpForLevel).clamp(0.0, 1.0) : 0.0;

  /// Formatted XP label (e.g., '720/1,000').
  String get xpDisplayLabel =>
      '${formatNumberWithCommas(xpInLevel)}/${formatNumberWithCommas(targetXpForLevel)}';

  /// Formatted coins string with thousands separators (e.g., '1,450').
  String get formattedCoins => formatNumberWithCommas(coins);

  /// Helper to format integer values with comma thousands separators.
  static String formatNumberWithCommas(int value) {
    final str = value.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }
}

extension UserProfileDivisionX on UserProfile {
  /// The user's current division tier calculated from their division key or total points.
  DivisionTier get division =>
      currentDivisionKey != null
          ? DivisionTier.fromKey(currentDivisionKey)
          : DivisionTier.fromPoints(totalPoints);

  /// Progress ratio (0.0 to 1.0) towards the next division.
  double get divisionProgressRatio => division.progressRatio(totalPoints);

  /// Prediction points needed to reach the next division tier.
  int get pointsToNextDivision => division.pointsToNext(totalPoints);

  /// Formatted total prediction points with thousands separator (e.g. "1,250").
  String get formattedTotalPoints =>
      UserProfileXpX.formatNumberWithCommas(totalPoints);
}
