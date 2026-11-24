import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.watch<LocaleCubit>().state.languageCode;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<LocaleCubit>().toggleLocale();
            },
            icon: const Icon(Icons.language, size: 18, color: AppColors.primary),
            label: Text(
              currentLocale == 'bn' ? 'English' : 'বাংলা',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Brand visual illustration emblem
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.welcome_title,
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.welcome_subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // Login Button
              AppButton(
                text: l10n.common_login,
                onPressed: () {
                  context.push(RoutePath.login);
                },
                variant: AppButtonVariant.primary,
              ),
              const SizedBox(height: 12),
              // Register Button
              AppButton(
                text: l10n.common_register,
                onPressed: () {
                  context.push(RoutePath.register);
                },
                variant: AppButtonVariant.outline,
              ),
              const SizedBox(height: 16),
              // Continue as Guest
              TextButton(
                onPressed: () async {
                  await context.read<SessionCubit>().continueAsGuest();
                  if (!context.mounted) return;
                  context.go(RoutePath.home);
                },
                child: Text(
                  l10n.common_guest,
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
