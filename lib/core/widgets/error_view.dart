import 'package:flutter/material.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../error/failure.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  final Failure? failure;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    this.failure,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayMessage = failure?.toLocalizedMessage(context) ??
        message ??
        l10n?.common_error ??
        'Something went wrong';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.common_error ?? 'Error',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: l10n?.common_retry ?? 'Retry',
                onPressed: onRetry,
                variant: AppButtonVariant.primary,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
