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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            identifier: identifier,
            password: password,
            rememberMe: _rememberMe,
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
            title: Text(l10n.common_login),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l10n.auth_login_title,
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.auth_login_subtitle,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  // Demo quick-fill hint banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tips_and_updates, size: 16, color: AppColors.info),
                            const SizedBox(width: 6),
                            Text(
                              'Demo Credentials Available',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.info,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mobile: 01712345678 (Rahim) or 01812345678 (Karim)\nPassword: password123',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            _identifierController.text = '01712345678';
                            _passwordController.text = 'password123';
                          },
                          child: Text(
                            'Tap to autofill Rahim Ahmed demo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Identifier field
                  AppTextField(
                    label: l10n.auth_identifier_label,
                    hint: l10n.auth_identifier_hint,
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  // Password field
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
                  const SizedBox(height: 12),

                  // Remember me
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _rememberMe = val ?? true;
                          });
                        },
                      ),
                      Text(l10n.auth_remember_me, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  AppButton(
                    text: l10n.common_login,
                    isLoading: isLoading,
                    onPressed: _submitLogin,
                    variant: AppButtonVariant.primary,
                  ),
                  const SizedBox(height: 20),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.auth_create_account_prompt, style: AppTextStyles.bodyMedium),
                      TextButton(
                        onPressed: () {
                          context.pushReplacement(RoutePath.register);
                        },
                        child: Text(
                          l10n.common_register,
                          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  // Continue as guest
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await context.read<SessionCubit>().continueAsGuest();
                        if (!context.mounted) return;
                        context.go(RoutePath.home);
                      },
                      child: Text(
                        l10n.common_guest,
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
