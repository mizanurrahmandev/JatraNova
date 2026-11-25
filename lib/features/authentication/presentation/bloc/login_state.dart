import 'package:equatable/equatable.dart';

enum LoginEmailError { required, invalid }

enum LoginPasswordError { required }

enum LoginStatus { idle, submitting, unimplementedNotice }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.showValidationErrors = false,
    this.emailError,
    this.passwordError,
    this.status = LoginStatus.idle,
  });

  final String email;
  final String password;
  final bool obscurePassword;
  final bool showValidationErrors;
  final LoginEmailError? emailError;
  final LoginPasswordError? passwordError;
  final LoginStatus status;

  bool get isSubmitting => status == LoginStatus.submitting;

  LoginState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? showValidationErrors,
    LoginEmailError? Function()? emailError,
    LoginPasswordError? Function()? passwordError,
    LoginStatus? status,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      showValidationErrors: showValidationErrors ?? this.showValidationErrors,
      emailError: emailError != null ? emailError() : this.emailError,
      passwordError:
          passwordError != null ? passwordError() : this.passwordError,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        email,
        password,
        obscurePassword,
        showValidationErrors,
        emailError,
        passwordError,
        status,
      ];
}
