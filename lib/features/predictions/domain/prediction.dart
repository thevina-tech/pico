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

  /// Calculates Pico Points outcome for this prediction against actual score.
  /// Rule 13: Exact score = 5 total, Correct winner = 3 total, Wrong = 0.
  int calculatePoints(int actualHome, int actualAway) {
    if (isExactScore(actualHome, actualAway)) return 5;
    if (isCorrectWinner(actualHome, actualAway)) return 3;
    return 0;
  }
}
