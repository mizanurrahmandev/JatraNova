/// Application-wide constant values for Phase 1 foundation.
abstract final class AppConstants {
  /// Reference viewport width from approved design spec baseline (375 x 812).
  static const double designWidth = 375.0;

  /// Reference viewport height from approved design spec baseline (375 x 812).
  static const double designHeight = 812.0;

  /// Default application language on first launch (English).
  static const String defaultLanguageCode = 'en';

  /// Supported application language codes.
  static const List<String> supportedLanguageCodes = <String>['en', 'bn'];

  /// Minor currency conversion factor (100 poisha = 1 BDT).
  static const int poishaPerTaka = 100;
}
