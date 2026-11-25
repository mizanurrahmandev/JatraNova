import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/constants/preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction over `SharedPreferences` as the sole store for app preferences
/// and persistent demo session pointers.
abstract class IPreferencesService {
  bool get onboardingCompleted;
  Future<bool> setOnboardingCompleted(bool value);

  String get selectedLanguage;
  Future<bool> setSelectedLanguage(String languageCode);

  bool get banglaNumeralsEnabled;
  Future<bool> setBanglaNumeralsEnabled(bool value);

  String? get sessionUserId;
  bool get rememberMe;

  /// Persists the signed-in session user identifier when Remember Me is active.
  Future<void> savePersistentSession({required String userId});

  /// Clears any persisted session pointer and disables Remember Me.
  Future<void> clearSession();
}

@LazySingleton(as: IPreferencesService)
class PreferencesServiceImpl implements IPreferencesService {
  PreferencesServiceImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  bool get onboardingCompleted =>
      _preferences.getBool(PreferenceKeys.onboardingCompleted) ?? false;

  @override
  Future<bool> setOnboardingCompleted(bool value) =>
      _preferences.setBool(PreferenceKeys.onboardingCompleted, value);

  @override
  String get selectedLanguage {
    final stored = _preferences.getString(PreferenceKeys.selectedLanguage);
    if (stored != null &&
        AppConstants.supportedLanguageCodes.contains(stored)) {
      return stored;
    }
    return AppConstants.defaultLanguageCode;
  }

  @override
  Future<bool> setSelectedLanguage(String languageCode) {
    final normalized =
        AppConstants.supportedLanguageCodes.contains(languageCode)
            ? languageCode
            : AppConstants.defaultLanguageCode;
    return _preferences.setString(PreferenceKeys.selectedLanguage, normalized);
  }

  @override
  bool get banglaNumeralsEnabled =>
      _preferences.getBool(PreferenceKeys.banglaNumeralsEnabled) ?? false;

  @override
  Future<bool> setBanglaNumeralsEnabled(bool value) =>
      _preferences.setBool(PreferenceKeys.banglaNumeralsEnabled, value);

  @override
  String? get sessionUserId =>
      _preferences.getString(PreferenceKeys.sessionUserId);

  @override
  bool get rememberMe =>
      _preferences.getBool(PreferenceKeys.rememberMe) ?? false;

  @override
  Future<void> savePersistentSession({required String userId}) async {
    await _preferences.setBool(PreferenceKeys.rememberMe, true);
    await _preferences.setString(PreferenceKeys.sessionUserId, userId);
  }

  @override
  Future<void> clearSession() async {
    await _preferences.remove(PreferenceKeys.sessionUserId);
    await _preferences.setBool(PreferenceKeys.rememberMe, false);
  }
}
