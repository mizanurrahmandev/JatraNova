import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppModal {
  AppModal._();

  /// Shows standard bottom sheet modal with custom body
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),
              child,
            ],
          ),
        );
      },
    );
  }

  /// Shows confirmation alert dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: AppTextStyles.titleMedium),
          content: Text(message, style: AppTextStyles.bodyMedium),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText ?? 'Cancel', style: AppTextStyles.labelLarge),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                minimumSize: const Size(90, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(confirmText, style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }
}
