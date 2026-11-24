import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _handleBootSequence();
  }

  Future<void> _handleBootSequence() async {
    // Artificial small delay for splash branding
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final prefs = getIt<SharedPreferences>();
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

    if (!onboardingDone) {
      context.go(RoutePath.onboarding);
      return;
    }

    final sessionCubit = getIt<SessionCubit>();
    if (sessionCubit.state.isAuthenticated || sessionCubit.state.isGuest) {
      context.go(RoutePath.home);
    } else {
      context.go(RoutePath.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // Brand Logo Emblem
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // App Title
              Text(
                l10n.app_name,
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              Text(
                l10n.tagline,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(flex: 2),
              // Animated Circular Progress Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Version 1.0.0 (Demo)',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
