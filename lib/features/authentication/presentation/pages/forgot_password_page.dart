import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';
import 'package:jatra_nova/core/constants/app_spacing.dart';
import 'package:jatra_nova/core/di/injection.dart';
import 'package:jatra_nova/core/route/route_config.dart';
import 'package:jatra_nova/core/theme/app_colors.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_bloc.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_state.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Forgot Password screen recreated from
/// `references/authentication/reset_password_screen.png`.
///
/// Manages local email input and validation. Password recovery remains
/// unimplemented in this demo.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  static const String _backgroundAsset = AppAssets.resetPasswordBackground;
  static const String _illustrationAsset = AppAssets.emailIllustration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (_) => getIt<ForgotPasswordBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String? _resolveEmailError(
    AppLocalizations l10n,
    ForgotPasswordEmailError? error,
  ) {
    switch (error) {
      case ForgotPasswordEmailError.required:
        return l10n.emailRequiredError;
      case ForgotPasswordEmailError.invalid:
        return l10n.emailInvalidError;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (ForgotPasswordState prev, ForgotPasswordState curr) =>
          prev.status != curr.status &&
          curr.status == ForgotPasswordStatus.unimplementedNotice,
      listener: (BuildContext context, ForgotPasswordState state) {
        _showNotice(context, l10n.forgotPasswordNotImplementedNotice);
        context
            .read<ForgotPasswordBloc>()
            .add(const ForgotPasswordNoticeDismissed());
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.onboardingBackgroundFallback,
          resizeToAvoidBottomInset: true,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                ForgotPasswordPage._backgroundAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 28.w),
                            child: BlocBuilder<ForgotPasswordBloc,
                                ForgotPasswordState>(
                              builder: (
                                BuildContext context,
                                ForgotPasswordState state,
                              ) {
                                final emailError = _resolveEmailError(
                                  l10n,
                                  state.emailError,
                                );
                                final borderRadius = BorderRadius.circular(14.r);

                                return Column(
                                  children: <Widget>[
                                    SizedBox(height: 8.h),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        key: const Key(
                                          'forgot_password_back_button',
                                        ),
                                        onPressed: () =>
                                            context.go(RoutePath.login),
                                        icon: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: 22.sp,
                                          color:
                                              AppColors.onboardingHeadingNavy,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(
                                          minWidth: 40.w,
                                          minHeight: 40.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Image.asset(
                                      ForgotPasswordPage._illustrationAsset,
                                      width: 210.w,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: 20.h),
                                    Text(
                                      l10n.resetPasswordTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.onboardingHeadingNavy,
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        height: 1.18,
                                      ),
                                    ),
                                    AppSpacing.verticalMd,
                                    Text(
                                      l10n.resetPasswordSubtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            AppColors.onboardingSubtitleSlate,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.35,
                                      ),
                                    ),
                                    SizedBox(height: 30.h),
                                    TextField(
                                      key: const Key(
                                        'forgot_password_email_field',
                                      ),
                                      controller: _emailController,
                                      enabled: !state.isSubmitting,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                      ],
                                      onChanged: (String value) => context
                                          .read<ForgotPasswordBloc>()
                                          .add(
                                            ForgotPasswordEmailChanged(value),
                                          ),
                                      onSubmitted: (_) => context
                                          .read<ForgotPasswordBloc>()
                                          .add(
                                            const ForgotPasswordSubmitted(),
                                          ),
                                      style: TextStyle(
                                        color: AppColors.onboardingHeadingNavy,
                                        fontSize: 15.5.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: l10n.emailHint,
                                        hintStyle: TextStyle(
                                          color: AppColors.loginInputIcon,
                                          fontSize: 15.5.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        errorText: emailError,
                                        errorMaxLines: 2,
                                        filled: true,
                                        fillColor: AppColors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 16.h,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.mail_outline_rounded,
                                          size: 20.sp,
                                          color:
                                              AppColors.onboardingHeadingNavy,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: borderRadius,
                                          borderSide: const BorderSide(
                                            color: AppColors
                                                .languageCardUnselectedBorder,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: borderRadius,
                                          borderSide: const BorderSide(
                                            color: AppColors
                                                .languageCardUnselectedBorder,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: borderRadius,
                                          borderSide: const BorderSide(
                                            color: AppColors.secondary,
                                            width: 1.4,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: borderRadius,
                                          borderSide: const BorderSide(
                                            color: AppColors.error,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: borderRadius,
                                          borderSide: const BorderSide(
                                            color: AppColors.error,
                                            width: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54.h,
                                      child: ElevatedButton(
                                        key: const Key(
                                          'forgot_password_submit_button',
                                        ),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context
                                                .read<ForgotPasswordBloc>()
                                                .add(
                                                  const ForgotPasswordSubmitted(),
                                                ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.onboardingButtonNavy,
                                          disabledBackgroundColor: AppColors
                                              .onboardingButtonNavy
                                              .withValues(alpha: 0.72),
                                          foregroundColor: AppColors.white,
                                          elevation: 0,
                                          shape: const StadiumBorder(),
                                        ),
                                        child: state.isSubmitting
                                            ? SizedBox(
                                                key: const Key(
                                                  'forgot_password_loading_indicator',
                                                ),
                                                width: 22.w,
                                                height: 22.w,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    AppColors.white,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                l10n.sendResetLink,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    AppSpacing.verticalXl,
                                    TextButton(
                                      key: const Key(
                                        'forgot_password_back_to_login_button',
                                      ),
                                      onPressed: state.isSubmitting
                                          ? null
                                          : () => context.go(RoutePath.login),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.secondary,
                                        minimumSize: Size(48.w, 44.h),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                      ),
                                      child: Text(
                                        l10n.backToLogin,
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(height: 36.h),
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
      ),
    );
  }
}
