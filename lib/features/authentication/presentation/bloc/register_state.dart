import 'package:equatable/equatable.dart';

enum RegisterFullNameError { required }

enum RegisterEmailError { required, invalid }

enum RegisterPhoneError { required, invalid }

enum RegisterPasswordError { required, tooShort }

enum RegisterTermsError { required }

enum RegisterStatus { idle, submitting, unimplementedNotice }

class RegisterState extends Equatable {
  const RegisterState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.obscurePassword = true,
    this.agreedToTerms = false,
    this.showValidationErrors = false,
    this.fullNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.termsError,
    this.status = RegisterStatus.idle,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final bool obscurePassword;
  final bool agreedToTerms;
  final bool showValidationErrors;
  final RegisterFullNameError? fullNameError;
  final RegisterEmailError? emailError;
  final RegisterPhoneError? phoneError;
  final RegisterPasswordError? passwordError;
  final RegisterTermsError? termsError;
  final RegisterStatus status;

  bool get isSubmitting => status == RegisterStatus.submitting;

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    bool? obscurePassword,
    bool? agreedToTerms,
    bool? showValidationErrors,
    RegisterFullNameError? Function()? fullNameError,
    RegisterEmailError? Function()? emailError,
    RegisterPhoneError? Function()? phoneError,
    RegisterPasswordError? Function()? passwordError,
    RegisterTermsError? Function()? termsError,
    RegisterStatus? status,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      fullNameError:
          fullNameError != null ? fullNameError() : this.fullNameError,
      emailError: emailError != null ? emailError() : this.emailError,
      phoneError: phoneError != null ? phoneError() : this.phoneError,
      passwordError:
          passwordError != null ? passwordError() : this.passwordError,
      termsError: termsError != null ? termsError() : this.termsError,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        fullName,
        email,
        phone,
        password,
        obscurePassword,
        agreedToTerms,
        showValidationErrors,
        fullNameError,
        emailError,
        phoneError,
        passwordError,
        termsError,
        status,
      ];
}
