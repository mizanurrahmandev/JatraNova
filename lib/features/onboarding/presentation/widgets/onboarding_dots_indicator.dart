import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';

/// Page indicator dots displayed above the primary onboarding CTA button.
class OnboardingDotsIndicator extends StatelessWidget {
  const OnboardingDotsIndicator({
    required this.totalDots,
    required this.activeIndex,
    super.key,
  });

  final int totalDots;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(totalDots, (int index) {
        final isActive = index == activeIndex;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.onboardingButtonNavy
                  : AppColors.onboardingDotInactive,
            ),
          ),
        );
      }),
    );
  }
}
