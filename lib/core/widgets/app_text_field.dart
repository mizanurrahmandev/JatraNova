import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
