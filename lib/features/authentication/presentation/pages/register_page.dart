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
import 'package:jatra_nova/features/authentication/presentation/bloc/register_bloc.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_state.dart';
import 'package:jatra_nova/l10n/app_localizations.dart';

/// Registration screen recreated from
/// `references/authentication/create_account.png`.
///
/// Manages local form input, validation, password visibility, and Terms &
/// Conditions agreement. Real account creation remains unimplemented.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const String _backgroundAsset = AppAssets.generalBackground;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterBloc>(
      create: (_) => getIt<RegisterBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
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

  String? _resolveFullNameError(
    AppLocalizations l10n,
    RegisterFullNameError? error,
  ) {
    switch (error) {
      case RegisterFullNameError.required:
        return l10n.fullNameRequiredError;
      case null:
        return null;
    }
  }

  String? _resolveEmailError(
    AppLocalizations l10n,
    RegisterEmailError? error,
  ) {
    switch (error) {
      case RegisterEmailError.required:
        return l10n.emailRequiredError;
      case RegisterEmailError.invalid:
        return l10n.emailInvalidError;
      case null:
        return null;
    }
  }

  String? _resolvePhoneError(
    AppLocalizations l10n,
    RegisterPhoneError? error,
  ) {
    switch (error) {
      case RegisterPhoneError.required:
        return l10n.phoneRequiredError;
      case RegisterPhoneError.invalid:
        return l10n.phoneInvalidError;
      case null:
        return null;
    }
  }

  String? _resolvePasswordError(
    AppLocalizations l10n,
    RegisterPasswordError? error,
  ) {
    switch (error) {
      case RegisterPasswordError.required:
        return l10n.passwordRequiredError;
      case RegisterPasswordError.tooShort:
        return l10n.passwordMinLengthError;
      case null:
        return null;
    }
  }

  String? _resolveTermsError(
    AppLocalizations l10n,
    RegisterTermsError? error,
  ) {
    switch (error) {
      case RegisterTermsError.required:
        return l10n.termsRequiredError;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<RegisterBloc, RegisterState>(
      listenWhen: (RegisterState prev, RegisterState curr) =>
          prev.status != curr.status &&
          curr.status == RegisterStatus.unimplementedNotice,
      listener: (BuildContext context, RegisterState state) {
        _showNotice(context, l10n.registerNotImplementedNotice);
        context.read<RegisterBloc>().add(const RegisterNoticeDismissed());
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
                RegisterPage._backgroundAsset,
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
                            child: BlocBuilder<RegisterBloc, RegisterState>(
                              builder: (
                                BuildContext context,
                                RegisterState state,
                              ) {
                                final fullNameError = _resolveFullNameError(
                                  l10n,
                                  state.fullNameError,
                                );
                                final emailError = _resolveEmailError(
                                  l10n,
                                  state.emailError,
                                );
                                final phoneError = _resolvePhoneError(
                                  l10n,
                                  state.phoneError,
                                );
                                final passwordError = _resolvePasswordError(
                                  l10n,
                                  state.passwordError,
                                );
                                final termsError = _resolveTermsError(
                                  l10n,
                                  state.termsError,
                                );

                                return Column(
                                  children: <Widget>[
                                    SizedBox(height: 8.h),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        key: const Key('register_back_button'),
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
                                    Text(
                                      l10n.createAccountTitle,
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
                                      l10n.createAccountSubtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            AppColors.onboardingSubtitleSlate,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 28.h),
                                    _RegisterTextField(
                                      fieldKey:
                                          const Key('register_full_name_field'),
                                      controller: _fullNameController,
                                      hintText: l10n.fullNameHint,
                                      prefixIcon: Icons.person_rounded,
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.name,
                                      ],
                                      errorText: fullNameError,
                                      enabled: !state.isSubmitting,
                                      onChanged: (String value) => context
                                          .read<RegisterBloc>()
                                          .add(RegisterFullNameChanged(value)),
                                      onSubmitted: (_) =>
                                          _emailFocusNode.requestFocus(),
                                    ),
                                    AppSpacing.verticalMd,
                                    _RegisterTextField(
                                      fieldKey:
                                          const Key('register_email_field'),
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      hintText: l10n.emailHint,
                                      prefixIcon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.email,
                                      ],
                                      errorText: emailError,
                                      enabled: !state.isSubmitting,
                                      onChanged: (String value) => context
                                          .read<RegisterBloc>()
                                          .add(RegisterEmailChanged(value)),
                                      onSubmitted: (_) =>
                                          _phoneFocusNode.requestFocus(),
                                    ),
                                    AppSpacing.verticalMd,
                                    _RegisterTextField(
                                      fieldKey:
                                          const Key('register_phone_field'),
                                      controller: _phoneController,
                                      focusNode: _phoneFocusNode,
                                      hintText: l10n.phoneHint,
                                      prefixIcon: Icons.phone_rounded,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const <String>[
                                        AutofillHints.telephoneNumber,
                                      ],
                                      errorText: phoneError,
                                      enabled: !state.isSubmitting,
                                      onChanged: (String value) => context
                                          .read<RegisterBloc>()
                                          .add(RegisterPhoneChanged(value)),
                                      onSubmitted: (_) =>
                                          _passwordFocusNode.requestFocus(),
                                    ),
                                    AppSpacing.verticalMd,
                                    _RegisterTextField(
                                      fieldKey:
                                          const Key('register_password_field'),
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      hintText: l10n.passwordHint,
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: state.obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const <String>[
                                        AutofillHints.newPassword,
                                      ],
                                      errorText: passwordError,
                                      enabled: !state.isSubmitting,
                                      onChanged: (String value) => context
                                          .read<RegisterBloc>()
                                          .add(RegisterPasswordChanged(value)),
                                      onSubmitted: (_) => context
                                          .read<RegisterBloc>()
                                          .add(const RegisterSubmitted()),
                                      suffixIcon: IconButton(
                                        key: const Key(
                                          'register_password_visibility_button',
                                        ),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context
                                                .read<RegisterBloc>()
                                                .add(
                                                  const RegisterPasswordVisibilityToggled(),
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
                                    AppSpacing.verticalLg,
                                    InkWell(
                                      key: const Key('register_terms_row'),
                                      onTap: state.isSubmitting
                                          ? null
                                          : () => context
                                              .read<RegisterBloc>()
                                              .add(
                                                RegisterTermsToggled(
                                                  !state.agreedToTerms,
                                                ),
                                              ),
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: AppSpacing.xs,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              width: 24.w,
                                              height: 24.w,
                                              child: Checkbox(
                                                key: const Key(
                                                  'register_terms_checkbox',
                                                ),
                                                value: state.agreedToTerms,
                                                onChanged: state.isSubmitting
                                                    ? null
                                                    : (bool? value) => context
                                                        .read<RegisterBloc>()
                                                        .add(
                                                          RegisterTermsToggled(
                                                            value ?? false,
                                                          ),
                                                        ),
                                                activeColor:
                                                    AppColors.secondary,
                                                checkColor: AppColors.white,
                                                side: BorderSide(
                                                  color: termsError != null
                                                      ? AppColors.error
                                                      : AppColors
                                                          .languageRadioUnselectedBorder,
                                                  width: 1.5,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5.r,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            AppSpacing.horizontalMd,
                                            Expanded(
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .onboardingHeadingNavy,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.3,
                                                  ),
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      text:
                                                          l10n.agreeTermsPrefix,
                                                    ),
                                                    TextSpan(
                                                      text: l10n
                                                          .termsAndConditions,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.secondary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (termsError != null) ...<Widget>[
                                      AppSpacing.verticalXs,
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          termsError,
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 22.h),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54.h,
                                      child: ElevatedButton(
                                        key: const Key(
                                          'register_submit_button',
                                        ),
                                        onPressed: state.isSubmitting
                                            ? null
                                            : () => context
                                                .read<RegisterBloc>()
                                                .add(const RegisterSubmitted()),
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
                                                  'register_loading_indicator',
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
                                                l10n.register,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(height: 18.h),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          l10n.alreadyHaveAccount,
                                          style: TextStyle(
                                            color:
                                                AppColors.onboardingHeadingNavy,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        TextButton(
                                          key: const Key(
                                            'register_login_link_button',
                                          ),
                                          onPressed: state.isSubmitting
                                              ? null
                                              : () =>
                                                  context.go(RoutePath.login),
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
                                            l10n.login,
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

class _RegisterTextField extends StatelessWidget {
  const _RegisterTextField({
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
          vertical: 15.h,
        ),
        prefixIcon: Icon(
          prefixIcon,
          size: 20.sp,
          color: AppColors.primary,
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
