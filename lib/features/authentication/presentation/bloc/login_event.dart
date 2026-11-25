import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => <Object?>[password];
}

class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class LoginNoticeDismissed extends LoginEvent {
  const LoginNoticeDismissed();
}
