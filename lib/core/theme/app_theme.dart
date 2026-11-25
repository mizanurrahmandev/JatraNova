import 'package:flutter/material.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';

/// Minimal light-theme foundation.
///
/// Detailed typography, spacing, and component themes await approved UI
/// design specifications.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
      );
}
