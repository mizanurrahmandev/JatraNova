import 'package:flutter/material.dart';

/// Explicitly defined brand and semantic color constants from `AGENTS.md`,
/// plus surface/contrast constants verified against approved visual assets.
abstract final class AppColors {
  static const Color primary = Color(0xFF123B70);
  static const Color secondary = Color(0xFF1976D2);
  static const Color accent = Color(0xFF14BBA6);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color white = Color(0xFFFFFFFF);
  static const Color splashBackgroundFallback = Color(0xFF072C62);

  // Reference-verified Onboarding Screen 1 tokens.
  static const Color onboardingBackgroundFallback = Color(0xFFF2F7FD);
  static const Color onboardingHeadingNavy = Color(0xFF0A2246);
  static const Color onboardingSubtitleSlate = Color(0xFF334155);
  static const Color onboardingProgressTrack = Color(0xFFC8DDE9);
  static const Color onboardingDotInactive = Color(0xFFB4C7DC);
  static const Color onboardingButtonNavy = Color(0xFF092854);

  // Reference-verified Language Selection tokens.
  static const Color languageCardSelectedFill = Color(0xFFEAF2FB);
  static const Color languageCardSelectedBorder = Color(0xFF7FA6D6);
  static const Color languageCardUnselectedBorder = Color(0xFFE2E8F0);
  static const Color languageRadioUnselectedBorder = Color(0xFFB8C2CE);

  // Reference-verified Welcome Screen tokens.
  static const Color welcomeDivider = Color(0xFFD5E0EB);

  // Reference-verified Login Screen tokens.
  static const Color loginInputIcon = Color(0xFF94A3B8);

  // Reference-verified Home Screen tokens.
  static const Color homeHeroStart = Color(0xFF0A2E6E);
  static const Color homeHeroEnd = Color(0xFF1976D2);
  static const Color homeIconBgBlue = Color(0xFFE8F1FC);
  static const Color homeIconBgTeal = Color(0xFFE6F7F4);
  static const Color homeDemoBadgeBg = Color(0xFFE0F2FE);
  static const Color homeTextMuted = Color(0xFF64748B);
  static const Color homeSurfaceBorder = Color(0xFFE2E8F0);
  static const Color handoverAccent = Color(0xFFF97316);
  static const Color connectingAccent = Color(0xFF7C3AED);
}
