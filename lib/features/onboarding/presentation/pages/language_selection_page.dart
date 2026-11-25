import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';
import 'package:jatra_nova/core/constants/app_constants.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/localization/locale_bloc.dart';
import 'package:jatra_nova/core/localization/locale_event.dart';
import 'package:jatra_nova/core/localization/locale_state.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Language selection screen recreated from
/// `references/langulage/laguage_screen_demo.png`.
///
/// Allows switching between English (`en`, default) and Bangla (`bn`) via the
/// app-wide [LocaleBloc] without modifying `onboarding_completed`.
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  static const String _backgroundAsset = AppAssets.languageSelectionBackground;

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
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: BlocBuilder<LocaleBloc, LocaleState>(
                            builder: (
                              BuildContext context,
                              LocaleState localeState,
                            ) {
                              final selectedCode =
                                  localeState.locale.languageCode;
                              return Column(
                                children: <Widget>[
                                  const Spacer(flex: 12),
                                  Text(
                                    l10n.chooseLanguageTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.onboardingHeadingNavy,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      height: 1.18,
                                    ),
                                  ),
                                  AppSpacing.verticalSm,
                                  Text(
                                    l10n.chooseLanguageSubtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.onboardingSubtitleSlate,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      height: 1.35,
                                    ),
                                  ),
                                  SizedBox(height: 36.h),
                                  _LanguageOptionCard(
                                    key: const Key('language_option_en'),
                                    label: l10n.languageEnglish,
                                    isSelected: selectedCode ==
                                        AppConstants.defaultLanguageCode,
                                    onTap: () => context
                                        .read<LocaleBloc>()
                                        .add(
                                          const LocaleChanged(
                                            AppConstants.defaultLanguageCode,
                                          ),
                                        ),
                                  ),
                                  AppSpacing.verticalLg,
                                  _LanguageOptionCard(
                                    key: const Key('language_option_bn'),
                                    label: l10n.languageBangla,
                                    isSelected: selectedCode == 'bn',
                                    onTap: () => context
                                        .read<LocaleBloc>()
                                        .add(const LocaleChanged('bn')),
                                  ),
                                  SizedBox(height: 36.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54.h,
                                    child: ElevatedButton(
                                      key: const Key('language_continue_button'),
                                      onPressed: () =>
                                          context.go(RoutePath.welcome),
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
                                            l10n.continueLabel,
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
                                  const Spacer(flex: 24),
                                  AppSpacing.verticalLg,
                                ],
                              );
                            },
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

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14.r);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 68.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.languageCardSelectedFill
                  : AppColors.white,
              borderRadius: borderRadius,
              border: Border.all(
                color: isSelected
                    ? AppColors.languageCardSelectedBorder
                    : AppColors.languageCardUnselectedBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? null
                  : <BoxShadow>[
                      BoxShadow(
                        color: AppColors.onboardingHeadingNavy
                            .withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.language_rounded,
                  size: 26.sp,
                  color: AppColors.onboardingHeadingNavy,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.onboardingHeadingNavy,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                AppSpacing.horizontalMd,
                _LanguageRadioIndicator(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRadioIndicator extends StatelessWidget {
  const _LanguageRadioIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final outerSize = 22.w;
    final innerSize = 11.w;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.onboardingButtonNavy
              : AppColors.languageRadioUnselectedBorder,
          width: isSelected ? 2.0 : 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: innerSize,
                height: innerSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.onboardingButtonNavy,
                ),
              ),
            )
          : null,
    );
  }
}
