import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Welcome screen recreated from `references/welcome/welcome_screen.png`.
///
/// Presents brand identity, welcome copy, and entry actions for Login,
/// Register, and Continue as Guest.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const String _backgroundAsset = AppAssets.generalBackground;
  static const String _logoAsset = AppAssets.busLogo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.onboardingBackgroundFallback,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              _backgroundAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 28.w),
                          child: Column(
                            children: <Widget>[
                              const Spacer(flex: 10),
                              Image.asset(
                                _logoAsset,
                                width: 120.w,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: 6.h),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 34.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: l10n.appNameFirst,
                                      style: const TextStyle(
                                        color: AppColors.onboardingHeadingNavy,
                                      ),
                                    ),
                                    TextSpan(
                                      text: l10n.appNameSecond,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.verticalXs,
                              Text(
                                l10n.appTagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.onboardingHeadingNavy,
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 36.h),
                              Text(
                                l10n.welcomeTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.onboardingHeadingNavy,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                  height: 1.15,
                                ),
                              ),
                              AppSpacing.verticalMd,
                              Text(
                                l10n.welcomeSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.onboardingSubtitleSlate,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              SizedBox(
                                width: double.infinity,
                                height: 54.h,
                                child: ElevatedButton(
                                  key: const Key('welcome_login_button'),
                                  onPressed: () => context.go(RoutePath.login),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        AppColors.onboardingButtonNavy,
                                    foregroundColor: AppColors.white,
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(
                                    l10n.login,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              AppSpacing.verticalLg,
                              SizedBox(
                                width: double.infinity,
                                height: 54.h,
                                child: OutlinedButton(
                                  key: const Key('welcome_register_button'),
                                  onPressed: () =>
                                      context.go(RoutePath.register),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                    foregroundColor:
                                        AppColors.onboardingHeadingNavy,
                                    elevation: 0,
                                    side: const BorderSide(
                                      color: AppColors.onboardingHeadingNavy,
                                      width: 1.4,
                                    ),
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(
                                    l10n.register,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 22.h),
                              Row(
                                children: <Widget>[
                                  const Expanded(
                                    child: Divider(
                                      color: AppColors.welcomeDivider,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                    ),
                                    child: Text(
                                      l10n.orDivider,
                                      style: TextStyle(
                                        color:
                                            AppColors.onboardingSubtitleSlate,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: AppColors.welcomeDivider,
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              TextButton(
                                key: const Key('welcome_guest_button'),
                                onPressed: () =>
                                    context.go(RoutePath.guestHome),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      AppColors.onboardingHeadingNavy,
                                  minimumSize: Size(48.w, 44.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                                child: Text(
                                  l10n.continueAsGuest,
                                  style: TextStyle(
                                    color: AppColors.onboardingHeadingNavy,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(flex: 12),
                              AppSpacing.verticalLg,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
