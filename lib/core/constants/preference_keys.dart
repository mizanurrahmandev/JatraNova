/// Keys persisted in [SharedPreferences].
///
/// Passwords and credential hashes must never be stored in SharedPreferences.
abstract final class PreferenceKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String selectedLanguage = 'selected_language';
  static const String banglaNumeralsEnabled = 'bangla_numerals_enabled';
  static const String sessionUserId = 'session_user_id';
  static const String rememberMe = 'remember_me';
}
