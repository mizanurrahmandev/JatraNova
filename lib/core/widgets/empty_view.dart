import 'package:flutter/material.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

class EmptyView extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyView({
    super.key,
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayTitle = title ?? l10n?.common_empty ?? 'No data found';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: Icon(icon, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            Text(
              displayTitle,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                variant: AppButtonVariant.outline,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
