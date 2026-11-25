import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class RegisterFullNameChanged extends RegisterEvent {
  const RegisterFullNameChanged(this.fullName);

  final String fullName;

  @override
  List<Object?> get props => <Object?>[fullName];
}

class RegisterEmailChanged extends RegisterEvent {
  const RegisterEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

class RegisterPhoneChanged extends RegisterEvent {
  const RegisterPhoneChanged(this.phone);

  final String phone;

  @override
  List<Object?> get props => <Object?>[phone];
}

class RegisterPasswordChanged extends RegisterEvent {
  const RegisterPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => <Object?>[password];
}

class RegisterPasswordVisibilityToggled extends RegisterEvent {
  const RegisterPasswordVisibilityToggled();
}

class RegisterTermsToggled extends RegisterEvent {
  const RegisterTermsToggled(this.agreed);

  final bool agreed;

  @override
  List<Object?> get props => <Object?>[agreed];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}

class RegisterNoticeDismissed extends RegisterEvent {
  const RegisterNoticeDismissed();
}
