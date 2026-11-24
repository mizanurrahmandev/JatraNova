import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.outline || variant == AppButtonVariant.text
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: buttonChild,
        );
        break;
      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: buttonChild,
        );
        break;
    }

    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    return SizedBox(height: height, width: double.infinity, child: button);
  }
}
