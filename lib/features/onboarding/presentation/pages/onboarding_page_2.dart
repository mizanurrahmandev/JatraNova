import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:jatra_nova/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:jatra_nova/features/onboarding/presentation/widgets/onboarding_dots_indicator.dart';
import 'package:jatra_nova/features/onboarding/presentation/widgets/onboarding_progress_capsule.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Second onboarding screen highlighting safety, 24/7 support, and secure
/// payments, recreated from `references/onboarding/screen_2.jpg`.
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  static const String _backgroundAsset = AppAssets.onboardingBackground;
  static const String _illustrationAsset = AppAssets.onboardingIllustration2;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (_) => getIt<OnboardingBloc>(),
      child: const _OnboardingView2(),
    );
  }
}

class _OnboardingView2 extends StatelessWidget {
  const _OnboardingView2();

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
                OnboardingPage2._backgroundAsset,
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
                              SizedBox(height: 6.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.12,
                                      color: AppColors.onboardingHeadingNavy,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(
                                        text: l10n.onboarding2TitlePrefix,
                                      ),
                                      TextSpan(
                                        text: l10n.onboarding2TitleHighlight,
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
                                  l10n.onboarding2Subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.onboardingSubtitleSlate,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.32,
                                  ),
                                ),
                              ),
                              SizedBox(height: 14.h),
                              OnboardingProgressCapsule(
                                width: 108.w,
                                height: 5.h,
                                progress: 0.42,
                              ),
                              SizedBox(height: 8.h),
                              Expanded(
                                child: SizedBox(
                                  height: (constraints.maxHeight * 0.36)
                                      .clamp(150.h, 280.h),
                                  child: Center(
                                    child: Image.asset(
                                      OnboardingPage2._illustrationAsset,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22.w),
                                child: _OnboardingTrustCardsRow(
                                  items: <_TrustCardData>[
                                    _TrustCardData(
                                      icon: Icons.verified_user_rounded,
                                      label: l10n.onboarding2TrustPlatform,
                                    ),
                                    _TrustCardData(
                                      icon: Icons.headset_mic_rounded,
                                      label: l10n.onboarding2TrustSupport,
                                    ),
                                    _TrustCardData(
                                      icon: Icons.lock_rounded,
                                      label: l10n.onboarding2TrustPayments,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 14.h),
                              const OnboardingDotsIndicator(
                                totalDots: 3,
                                activeIndex: 1,
                              ),
                              SizedBox(height: 14.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22.w),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 54.h,
                                  child: ElevatedButton(
                                    onPressed: () => context
                                        .read<OnboardingBloc>()
                                        .add(
                                          const OnboardingNextRequested(
                                            step: 2,
                                          ),
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.onboardingButtonNavy,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: const StadiumBorder(),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustCardData {
  const _TrustCardData({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}

class _OnboardingTrustCardsRow extends StatelessWidget {
  const _OnboardingTrustCardsRow({required this.items});

  final List<_TrustCardData> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(
          Container(
            width: 1.w,
            height: 44.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            color: AppColors.onboardingProgressTrack,
          ),
        );
      }
      children.add(
        Expanded(
          child: _OnboardingTrustCard(data: items[i]),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _OnboardingTrustCard extends StatelessWidget {
  const _OnboardingTrustCard({required this.data});

  final _TrustCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.onboardingHeadingNavy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            data.icon,
            size: 26.sp,
            color: AppColors.onboardingButtonNavy,
          ),
          SizedBox(height: 6.h),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onboardingHeadingNavy,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
