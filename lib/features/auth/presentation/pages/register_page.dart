import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/route/route_config.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = true;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            fullName: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            termsAccepted: _termsAccepted,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          await context.read<SessionCubit>().login(
                userId: state.user.id,
                userName: state.user.fullName,
                userMobile: state.user.mobile,
              );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account successfully created!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(RoutePath.home);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.toLocalizedMessage(context)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(l10n.common_register),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l10n.auth_register_title,
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.auth_register_subtitle,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  AppTextField(
                    label: l10n.auth_full_name_label,
                    hint: l10n.auth_full_name_hint,
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Mobile Number
                  AppTextField(
                    label: l10n.auth_mobile_label,
                    hint: l10n.auth_mobile_hint,
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  AppTextField(
                    label: l10n.auth_email_label,
                    hint: l10n.auth_email_hint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  AppTextField(
                    label: l10n.auth_password_label,
                    hint: l10n.auth_password_hint,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  AppTextField(
                    label: l10n.auth_confirm_password_label,
                    hint: l10n.auth_confirm_password_hint,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms and conditions checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _termsAccepted = val ?? true;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          l10n.auth_terms_agree,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  AppButton(
                    text: l10n.common_register,
                    isLoading: isLoading,
                    onPressed: _submitRegister,
                    variant: AppButtonVariant.primary,
                  ),
                  const SizedBox(height: 20),

                  // Already have account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.auth_already_have_account, style: AppTextStyles.bodyMedium),
                      TextButton(
                        onPressed: () {
                          context.pushReplacement(RoutePath.login);
                        },
                        child: Text(
                          l10n.common_login,
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
