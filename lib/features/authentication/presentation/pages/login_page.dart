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
import 'package:jatra_nova/features/authentication/presentation/bloc/login_bloc.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/login_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/login_state.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Login screen recreated from `references/authentication/login_screen.png`.
///
/// Provides local form interaction, validation, and password visibility toggle.
/// Actual authentication submission remains unimplemented until approved.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String _backgroundAsset = AppAssets.generalBackground;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
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
    LoginEmailError? error,
  ) {
    switch (error) {
      case LoginEmailError.required:
        return l10n.emailRequiredError;
      case LoginEmailError.invalid:
        return l10n.emailInvalidError;
      case null:
        return null;
    }
  }

  String? _resolvePasswordError(
    AppLocalizations l10n,
    LoginPasswordError? error,
  ) {
    switch (error) {
      case LoginPasswordError.required:
        return l10n.passwordRequiredError;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (LoginState prev, LoginState curr) =>
          prev.status != curr.status &&
          curr.status == LoginStatus.unimplementedNotice,
      listener: (BuildContext context, LoginState state) {
        _showNotice(context, l10n.loginNotImplementedNotice);
        context.read<LoginBloc>().add(const LoginNoticeDismissed());
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
                LoginPage._backgroundAsset,
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
                            child: BlocBuilder<LoginBloc, LoginState>(
                              builder: (
                                BuildContext context,
                                LoginState state,
                              ) {
                                final emailErrorText = _resolveEmailError(
                                  l10n,
                                  state.emailError,
                                );
                                final passwordErrorText = _resolvePasswordError(
                                  l10n,
                                  state.passwordError,
                                );

                                return Column(
                                  children: <Widget>[
                                    SizedBox(height: 8.h),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        key: const Key('login_back_button'),
                                        onPressed: () =>
                                            context.go(RoutePath.welcome),
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
                                    SizedBox(height: 18.h),
                                    Text(
                                      l10n.loginTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.onboardingHeadingNavy,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                        height: 1.15,
                                      ),
                                    ),
                                    AppSpacing.verticalSm,
                                    Text(
                                      l10n.loginSubtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            AppColors.onboardingSubtitleSlate,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 32.h),
                                    _LoginTextField(
                                      fieldKey: const Key('login_email_field'),
                                      controller: _emailController,
                                      hintText: l10n.emailHint,
                                      prefixIcon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                      ],
                                      errorText: emailErrorText,
                                      enabled: !state.isSubmitting,
                                      onChanged: (String value) => context
                                          .read<LoginBloc>()
                                          .add(LoginEmailChanged(value)),
                                      onSubmitted: (_) =>
                                          _passwordFocusNode.requestFocus(),
                                    ),
                                    AppSpacing.verticalLg,
                                    _LoginTextField(
                                      fieldKey:
                                          const Key('login_password_field'),
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      hintText: l10n.passwordHint,
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: state.obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.password,
                                      ],
                                      errorText: passwordErrorText,
                                      enabled: !state.isSubmitting,
                                      onChanged: (String value) => context
                                          .read<LoginBloc>()
                                          .add(LoginPasswordChanged(value)),
                                      onSubmitted: (_) => context
                                          .read<LoginBloc>()
                                          .add(const LoginSubmitted()),
                                      suffixIcon: IconButton(
                                        key: const Key(
                                          'login_password_visibility_button',
                                        ),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context
                                                .read<LoginBloc>()
                                                .add(
                                                  const LoginPasswordVisibilityToggled(),
                                                ),
                                        icon: Icon(
                                          state.obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 20.sp,
                                          color: AppColors.loginInputIcon,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        key: const Key(
                                          'login_forgot_password_button',
                                        ),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context.go(
                                                  RoutePath.forgotPassword,
                                                ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.secondary,
                                          minimumSize: Size(48.w, 36.h),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                            vertical: AppSpacing.xs,
                                          ),
                                        ),
                                        child: Text(
                                          l10n.forgotPassword,
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 14.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54.h,
                                      child: ElevatedButton(
                                        key: const Key('login_submit_button'),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context
                                                .read<LoginBloc>()
                                                .add(const LoginSubmitted()),
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
                                                  'login_loading_indicator',
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
                                                l10n.login,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: 22.h),
                                    Row(
                                      children: <Widget>[
                                        const Expanded(
                                          child: Divider(
                                            color: AppColors.welcomeDivider,
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                          ),
                                          child: Text(
                                            l10n.orContinueWith,
                                            style: TextStyle(
                                              color: AppColors
                                                  .onboardingSubtitleSlate,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          child: Divider(
                                            color: AppColors.welcomeDivider,
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 18.h),
                                    _SocialAuthButton(
                                      buttonKey:
                                          const Key('login_google_button'),
                                      label: l10n.continueWithGoogle,
                                      icon: Center(
                                        child: Image.asset(
                                          AppAssets.googleLogo,
                                          key: const Key('login_google_logo'),
                                          width: 22.w,
                                          height: 22.w,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      onPressed: state.isSubmitting
                                          ? null
                                          : () => _showNotice(
                                                context,
                                                l10n.socialLoginUnavailableNotice,
                                              ),
                                    ),
                                    const Spacer(),
                                    SizedBox(height: 20.h),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          l10n.dontHaveAccount,
                                          style: TextStyle(
                                            color:
                                                AppColors.onboardingHeadingNavy,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextButton(
                                          key: const Key(
                                            'login_register_link_button',
                                          ),
                                          onPressed: state.isSubmitting
                                              ? null
                                              : () => context.go(
                                                    RoutePath.register,
                                                  ),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColors.secondary,
                                            minimumSize: Size(0, 36.h),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.xs,
                                            ),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            l10n.register,
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.fieldKey,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
    this.suffixIcon,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14.r);

    return TextField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(
        color: AppColors.onboardingHeadingNavy,
        fontSize: 15.5.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.loginInputIcon,
          fontSize: 15.5.sp,
          fontWeight: FontWeight.w400,
        ),
        errorText: errorText,
        errorMaxLines: 2,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 20.sp,
          color: AppColors.loginInputIcon,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: AppColors.languageCardUnselectedBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(
            color: AppColors.languageCardUnselectedBorder,
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
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  const _SocialAuthButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton(
        key: buttonKey,
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.onboardingHeadingNavy,
          elevation: 0,
          side: const BorderSide(
            color: AppColors.languageCardUnselectedBorder,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            AppSpacing.horizontalMd,
            Text(
              label,
              style: TextStyle(
                color: AppColors.onboardingHeadingNavy,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
