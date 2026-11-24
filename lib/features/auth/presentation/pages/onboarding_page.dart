import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    context.go(RoutePath.languageSelection);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final slides = [
      _OnboardingSlide(
        icon: Icons.directions_bus_rounded,
        title: l10n.onboarding_1_title,
        description: l10n.onboarding_1_desc,
        badgeText: 'Smart Booking',
        badgeColor: AppColors.secondary,
      ),
      _OnboardingSlide(
        icon: Icons.verified_user_rounded,
        title: l10n.onboarding_2_title,
        description: l10n.onboarding_2_desc,
        badgeText: 'Nationwide Trust',
        badgeColor: AppColors.accent,
      ),
      _OnboardingSlide(
        icon: Icons.swap_horizontal_circle_rounded,
        title: l10n.onboarding_3_title,
        description: l10n.onboarding_3_desc,
        badgeText: 'Ticket Handover',
        badgeColor: AppColors.handoverOrange,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              l10n.common_skip,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: slide.badgeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 72,
                            color: slide.badgeColor,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: slide.badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide.badgeText,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: slide.badgeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.title,
                          style: AppTextStyles.titleLarge.copyWith(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation indicator dots & action buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    text: _currentPage == slides.length - 1
                        ? l10n.common_get_started
                        : l10n.common_next,
                    onPressed: () {
                      if (_currentPage < slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
  });
}
