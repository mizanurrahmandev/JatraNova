import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = context.watch<LocaleCubit>().state.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.language_title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.language_subtitle,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              // Bangla Option Card
              _LanguageCard(
                title: 'বাংলা',
                subtitle: 'ডিফল্ট ভাষা (বাংলাদেশ)',
                code: 'bn',
                isSelected: currentCode == 'bn',
                onTap: () {
                  context.read<LocaleCubit>().setLocale('bn');
                },
              ),
              const SizedBox(height: 12),
              // English Option Card
              _LanguageCard(
                title: 'English',
                subtitle: 'International language',
                code: 'en',
                isSelected: currentCode == 'en',
                onTap: () {
                  context.read<LocaleCubit>().setLocale('en');
                },
              ),
              const Spacer(),
              AppButton(
                text: l10n.common_continue,
                onPressed: () {
                  context.go(RoutePath.welcome);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: isSelected ? AppColors.primary : AppColors.divider,
      backgroundColor: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                code.toUpperCase(),
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
