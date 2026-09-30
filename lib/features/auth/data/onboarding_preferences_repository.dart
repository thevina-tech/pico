import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pico/core/logging/app_logger.dart';
import 'package:pico/features/auth/domain/onboarding_progress.dart';

part 'onboarding_preferences_repository.g.dart';

/// Riverpod provider providing persistent onboarding progress repository.
@Riverpod(keepAlive: true)
OnboardingPreferencesRepository onboardingPreferencesRepository(Ref ref) {
  return SharedPrefsOnboardingPreferencesRepository();
}

/// Repository contract for reading and saving onboarding progression and draft selections.
abstract class OnboardingPreferencesRepository {
  /// Retrieves the saved onboarding progress.
  Future<OnboardingProgress> getProgress();

  /// Saves the current step index (0 to 4).
  Future<void> saveStep(int step);

  /// Saves draft username entered by user.
  Future<void> saveUsername(String username);

  /// Saves draft favorite team ID selected by user.
  Future<void> saveTeamId(String teamId);

  /// Saves draft selected league IDs.
  Future<void> saveLeagueIds(List<String> leagueIds);

  /// Clears all saved onboarding progress (upon completing onboarding or sign-out).
  Future<void> clearProgress();
}

/// SharedPreferences-backed implementation of [OnboardingPreferencesRepository].
class SharedPrefsOnboardingPreferencesRepository
    implements OnboardingPreferencesRepository {
  SharedPrefsOnboardingPreferencesRepository([this._prefs]);

  final SharedPreferences? _prefs;
  SharedPreferences? _cachedPrefs;
  final Map<String, dynamic> _fallbackMemory = {};

  static const String _keyStep = 'pico_onboarding_step';
  static const String _keyUsername = 'pico_onboarding_username';
  static const String _keyTeamId = 'pico_onboarding_team_id';
  static const String _keyLeagueIds = 'pico_onboarding_league_ids';

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    if (_cachedPrefs != null) return _cachedPrefs;
    try {
      _cachedPrefs = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 300),
      );
      return _cachedPrefs;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<OnboardingProgress> getProgress() async {
    try {
      final prefs = await _getPrefs();
      final step = prefs != null
          ? (prefs.getInt(_keyStep) ?? 0)
          : (_fallbackMemory[_keyStep] as int? ?? 0);
      final username = prefs != null
          ? prefs.getString(_keyUsername)
          : (_fallbackMemory[_keyUsername] as String?);
      final teamId = prefs != null
          ? prefs.getString(_keyTeamId)
          : (_fallbackMemory[_keyTeamId] as String?);
      final leagueIds = prefs != null
          ? (prefs.getStringList(_keyLeagueIds) ?? const <String>[])
          : (_fallbackMemory[_keyLeagueIds] as List<String>? ?? const <String>[]);

      return OnboardingProgress(
        step: step,
        username: username,
        selectedTeamId: teamId,
        selectedLeagueIds: leagueIds,
      );
    } catch (e) {
      AppLogger.warning('Failed to read onboarding progress: $e');
      return const OnboardingProgress();
    }
  }

  @override
  Future<void> saveStep(int step) async {
    _fallbackMemory[_keyStep] = step;
    try {
      final prefs = await _getPrefs();
      await prefs?.setInt(_keyStep, step);
    } catch (e) {
      AppLogger.warning('Failed to save onboarding step: $e');
    }
  }

  @override
  Future<void> saveUsername(String username) async {
    _fallbackMemory[_keyUsername] = username;
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_keyUsername, username);
    } catch (e) {
      AppLogger.warning('Failed to save onboarding username: $e');
    }
  }

  @override
  Future<void> saveTeamId(String teamId) async {
    _fallbackMemory[_keyTeamId] = teamId;
    try {
      final prefs = await _getPrefs();
      await prefs?.setString(_keyTeamId, teamId);
    } catch (e) {
      AppLogger.warning('Failed to save onboarding teamId: $e');
    }
  }

  @override
  Future<void> saveLeagueIds(List<String> leagueIds) async {
    _fallbackMemory[_keyLeagueIds] = List<String>.from(leagueIds);
    try {
      final prefs = await _getPrefs();
      await prefs?.setStringList(_keyLeagueIds, leagueIds);
    } catch (e) {
      AppLogger.warning('Failed to save onboarding leagueIds: $e');
    }
  }

  @override
  Future<void> clearProgress() async {
    _fallbackMemory.clear();
    try {
      final prefs = await _getPrefs();
      await prefs?.remove(_keyStep);
      await prefs?.remove(_keyUsername);
      await prefs?.remove(_keyTeamId);
      await prefs?.remove(_keyLeagueIds);
    } catch (e) {
      AppLogger.warning('Failed to clear onboarding progress: $e');
    }
  }
}
