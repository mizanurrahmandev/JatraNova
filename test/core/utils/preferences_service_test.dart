import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/constants/preference_keys.dart';
import 'package:jatra_nova/core/utils/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late PreferencesServiceImpl service;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    service = PreferencesServiceImpl(prefs);
  });

  group('PreferencesServiceImpl', () {
    test('returns expected defaults when unset', () {
      expect(service.onboardingCompleted, isFalse);
      expect(service.selectedLanguage, AppConstants.defaultLanguageCode);
      expect(service.banglaNumeralsEnabled, isFalse);
      expect(service.sessionUserId, isNull);
      expect(service.rememberMe, isFalse);
    });

    test('persists onboarding, language, and bangla numerals keys', () async {
      await service.setOnboardingCompleted(true);
      await service.setSelectedLanguage('bn');
      await service.setBanglaNumeralsEnabled(true);

      expect(prefs.getBool(PreferenceKeys.onboardingCompleted), isTrue);
      expect(prefs.getString(PreferenceKeys.selectedLanguage), 'bn');
      expect(prefs.getBool(PreferenceKeys.banglaNumeralsEnabled), isTrue);
      expect(service.selectedLanguage, 'bn');
    });

    test('falls back to default language when unsupported code is passed',
        () async {
      await service.setSelectedLanguage('fr');
      expect(service.selectedLanguage, 'en');
    });

    test('saves and clears persistent session pointer', () async {
      await service.savePersistentSession(userId: 'user-123');
      expect(service.rememberMe, isTrue);
      expect(service.sessionUserId, 'user-123');

      await service.clearSession();
      expect(service.rememberMe, isFalse);
      expect(service.sessionUserId, isNull);
    });
  });
}
