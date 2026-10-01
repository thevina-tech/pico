import 'package:freezed_annotation/freezed_annotation.dart';

part 'prediction.freezed.dart';
part 'prediction.g.dart';

/// Normalized domain model for the `predictions` table in Supabase.
@freezed
abstract class Prediction with _$Prediction {
  const factory Prediction({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'match_id') required String matchId,
    @JsonKey(name: 'home_score') required int homeScore,
    @JsonKey(name: 'away_score') required int awayScore,
    @JsonKey(name: 'predicted_winner') required String predictedWinner,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Prediction;

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      _$PredictionFromJson(json);
}

/// Helper extension on [Prediction] for settlement evaluation.
extension PredictionSettlement on Prediction {
  /// Returns true if the prediction matches the exact score.
  bool isExactScore(int actualHome, int actualAway) =>
      homeScore == actualHome && awayScore == actualAway;

  /// Returns true if the prediction picked the correct match winner/outcome.
  bool isCorrectWinner(int actualHome, int actualAway) {
    if (actualHome > actualAway && predictedWinner == 'home') return true;
    if (actualAway > actualHome && predictedWinner == 'away') return true;
    if (actualHome == actualAway && predictedWinner == 'draw') return true;
    return false;
  }

  /// Returns true if the predicted goal difference matches the actual goal difference.
  bool isCorrectGoalDifference(int actualHome, int actualAway) =>
      (homeScore - awayScore) == (actualHome - actualAway);

  /// Calculates Prediction Points (PP) outcome for this prediction against actual score.
  /// Sprint 7 Tiered Division System rules:
  /// - Exact score: 5 PP
  /// - Correct outcome + correct goal difference: 3 PP
  /// - Correct outcome only: 1 PP
  /// - Miss: 0 PP
  int calculatePoints(int actualHome, int actualAway) {
    if (isExactScore(actualHome, actualAway)) return 5;
    final winnerMatches = isCorrectWinner(actualHome, actualAway);
    if (winnerMatches && isCorrectGoalDifference(actualHome, actualAway)) {
      return 3;
    }
    if (winnerMatches) return 1;
    return 0;
  }
}
