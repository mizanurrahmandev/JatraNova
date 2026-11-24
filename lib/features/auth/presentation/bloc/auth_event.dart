part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.identifier,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [identifier, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String mobile;
  final String email;
  final String password;
  final String confirmPassword;
  final bool termsAccepted;

  const AuthRegisterRequested({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.termsAccepted,
  });

  @override
  List<Object?> get props => [
        fullName,
        mobile,
        email,
        password,
        confirmPassword,
        termsAccepted,
      ];
}

class AuthResetState extends AuthEvent {}
