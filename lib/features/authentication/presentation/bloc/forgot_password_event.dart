import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ForgotPasswordEmailChanged extends ForgotPasswordEvent {
  const ForgotPasswordEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordSubmitted();
}

class ForgotPasswordNoticeDismissed extends ForgotPasswordEvent {
  const ForgotPasswordNoticeDismissed();
}
