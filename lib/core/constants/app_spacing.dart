import 'package:flutter/widgets.dart';

/// Standard spacing scale for consistent layout gaps across the application.
///
/// Use these constants for `SizedBox` gaps, padding, and margin values that
/// represent standard layout spacing. Do not replace intentional design-
/// specific dimensions (image sizes, button heights, border radii) with these
/// constants — those belong inline or in their own design tokens.
abstract final class AppSpacing {
  // ── Raw values ───────────────────────────────────────────────────────

  /// 4.0 logical pixels.
  static const double xs = 4.0;

  /// 8.0 logical pixels.
  static const double sm = 8.0;

  /// 12.0 logical pixels.
  static const double md = 12.0;

  /// 16.0 logical pixels.
  static const double lg = 16.0;

  /// 24.0 logical pixels.
  static const double xl = 24.0;

  /// 32.0 logical pixels.
  static const double xxl = 32.0;

  /// 48.0 logical pixels.
  static const double xxxl = 48.0;

  // ── Reusable vertical gap widgets ────────────────────────────────────
  //
  // Pre-built `SizedBox` instances for the most common vertical gaps.
  // These avoid repeated `SizedBox(height: ...)` allocations in build methods.

  /// Vertical gap of 4.0 logical pixels.
  static const SizedBox verticalXs = SizedBox(height: xs);

  /// Vertical gap of 8.0 logical pixels.
  static const SizedBox verticalSm = SizedBox(height: sm);

  /// Vertical gap of 12.0 logical pixels.
  static const SizedBox verticalMd = SizedBox(height: md);

  /// Vertical gap of 16.0 logical pixels.
  static const SizedBox verticalLg = SizedBox(height: lg);

  /// Vertical gap of 24.0 logical pixels.
  static const SizedBox verticalXl = SizedBox(height: xl);

  /// Vertical gap of 32.0 logical pixels.
  static const SizedBox verticalXxl = SizedBox(height: xxl);

  /// Vertical gap of 48.0 logical pixels.
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  // ── Reusable horizontal gap widgets ──────────────────────────────────

  /// Horizontal gap of 4.0 logical pixels.
  static const SizedBox horizontalXs = SizedBox(width: xs);

  /// Horizontal gap of 8.0 logical pixels.
  static const SizedBox horizontalSm = SizedBox(width: sm);

  /// Horizontal gap of 12.0 logical pixels.
  static const SizedBox horizontalMd = SizedBox(width: md);

  /// Horizontal gap of 16.0 logical pixels.
  static const SizedBox horizontalLg = SizedBox(width: lg);

  /// Horizontal gap of 24.0 logical pixels.
  static const SizedBox horizontalXl = SizedBox(width: xl);

  /// Horizontal gap of 32.0 logical pixels.
  static const SizedBox horizontalXxl = SizedBox(width: xxl);

  /// Horizontal gap of 48.0 logical pixels.
  static const SizedBox horizontalXxxl = SizedBox(width: xxxl);
}
