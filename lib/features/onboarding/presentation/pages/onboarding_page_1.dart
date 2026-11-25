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
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:jatra_nova/features/onboarding/presentation/widgets/onboarding_dots_indicator.dart';
import 'package:jatra_nova/features/onboarding/presentation/widgets/onboarding_progress_capsule.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  static const String _backgroundAsset = AppAssets.onboardingBackground;
  static const String _illustrationAsset = AppAssets.onboardingIllustration1;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => getIt<OnboardingBloc>(),
      child: const _OnboardingView1(),
    );
  }
}

class _OnboardingView1 extends StatelessWidget {
  const _OnboardingView1();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (BuildContext context, OnboardingState state) {
        if (state is! OnboardingNavigationReady) {
          return;
        }
        switch (state.target) {
          case OnboardingNavigationTarget.nextStep:
            context.go(RoutePath.onboardingStep2);
          case OnboardingNavigationTarget.step3:
            context.go(RoutePath.onboardingStep3);
          case OnboardingNavigationTarget.languageSelection:
            context.go(RoutePath.languageSelection);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.onboardingBackgroundFallback,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                OnboardingPage1._backgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              SafeArea(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 6.h, right: 14.w),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context
                                    .read<OnboardingBloc>()
                                    .add(const OnboardingSkipRequested()),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondary,
                                  minimumSize: Size(48.w, 44.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 8.h,
                                  ),
                                ),
                                child: Text(
                                  l10n.skip,
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.verticalMd,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 40.sp,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.15,
                                  color: AppColors.onboardingHeadingNavy,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(text: l10n.onboarding1TitlePrefix),
                                  TextSpan(
                                    text: l10n.onboarding1TitleHighlight,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.verticalMd,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28.w),
                            child: Text(
                              l10n.onboarding1Subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.onboardingSubtitleSlate,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.35,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          OnboardingProgressCapsule(
                            width: 108.w,
                            height: 5.h,
                            progress: 0.42,
                          ),
                          SizedBox(height: 6.h),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: 160.h),
                              child: Center(
                                child: Image.asset(
                                  OnboardingPage1._illustrationAsset,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          const OnboardingDotsIndicator(
                            totalDots: 3,
                            activeIndex: 0,
                          ),
                          SizedBox(height: 18.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22.w),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54.h,
                              child: ElevatedButton(
                                onPressed: () => context
                                    .read<OnboardingBloc>()
                                    .add(const OnboardingNextRequested()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.onboardingButtonNavy,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  shape: const StadiumBorder(),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      l10n.next,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20.sp,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),
                        ],
                      ),
                    ),
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
