import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';

/// Capsule progress indicator displayed beneath onboarding copy.
class OnboardingProgressCapsule extends StatelessWidget {
  const OnboardingProgressCapsule({
    required this.width,
    required this.height,
    required this.progress,
    super.key,
  });

  final double width;
  final double height;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.onboardingProgressTrack,
        borderRadius: BorderRadius.circular(999.r),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
      ),
    );
  }
}
