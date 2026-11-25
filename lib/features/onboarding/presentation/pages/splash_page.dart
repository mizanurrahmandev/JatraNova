import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_bloc.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/splash_state.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const String _backgroundAsset = AppAssets.splashBackground;
  static const String _logoAsset = AppAssets.busLogo;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      create: (_) => getIt<SplashBloc>()..add(const SplashStarted()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SplashBloc, SplashState>(
      listener: (BuildContext context, SplashState state) {
        if (state is! SplashNavigationReady) {
          return;
        }
        switch (state.destination) {
          case SplashDestination.onboarding:
            context.go(RoutePath.onboarding);
          case SplashDestination.languageSelection:
            context.go(RoutePath.languageSelection);
          case SplashDestination.guestHome:
            context.go(RoutePath.guestHome);
          case SplashDestination.signedInHome:
            context.go(RoutePath.home);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.splashBackgroundFallback,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                SplashPage._backgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              SafeArea(
                child: Column(
                  children: <Widget>[
                    const Spacer(flex: 32),
                    Image.asset(
                      SplashPage._logoAsset,
                      width: 215.w,
                      fit: BoxFit.contain,
                    ),
                    AppSpacing.verticalMd,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 42.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            height: 1.12,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: l10n.appNameFirst,
                              style: const TextStyle(color: AppColors.white),
                            ),
                            TextSpan(
                              text: l10n.appNameSecond,
                              style: const TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        l10n.appTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.92),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const Spacer(flex: 35),
                    SizedBox(
                      width: 34.w,
                      height: 34.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.w,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                        backgroundColor:
                            AppColors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      l10n.loading,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.72),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 52.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
