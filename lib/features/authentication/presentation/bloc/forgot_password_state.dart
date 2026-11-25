import 'package:equatable/equatable.dart';

enum ForgotPasswordEmailError { required, invalid }

enum ForgotPasswordStatus { idle, submitting, unimplementedNotice }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.showValidationError = false,
    this.emailError,
    this.status = ForgotPasswordStatus.idle,
  });

  final String email;
  final bool showValidationError;
  final ForgotPasswordEmailError? emailError;
  final ForgotPasswordStatus status;

  bool get isSubmitting => status == ForgotPasswordStatus.submitting;

  ForgotPasswordState copyWith({
    String? email,
    bool? showValidationError,
    ForgotPasswordEmailError? Function()? emailError,
    ForgotPasswordStatus? status,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      showValidationError: showValidationError ?? this.showValidationError,
      emailError: emailError != null ? emailError() : this.emailError,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        email,
        showValidationError,
        emailError,
        status,
      ];
}
