import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/login_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/login_state.dart';

/// Manages Login Screen form state, input validation, and password visibility.
///
/// Authentication submission is intentionally unimplemented until the
/// authentication architecture is approved.
@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginNoticeDismissed>(_onNoticeDismissed);
  }

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const Duration _submissionDelay = Duration(milliseconds: 250);

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        emailError: () =>
            state.showValidationErrors ? _validateEmail(event.email) : null,
        status: LoginStatus.idle,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        passwordError: () => state.showValidationErrors
            ? _validatePassword(event.password)
            : null,
        status: LoginStatus.idle,
      ),
    );
  }

  void _onVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.isSubmitting) {
      return;
    }

    final emailError = _validateEmail(state.email);
    final passwordError = _validatePassword(state.password);

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          showValidationErrors: true,
          emailError: () => emailError,
          passwordError: () => passwordError,
          status: LoginStatus.idle,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        showValidationErrors: true,
        emailError: () => null,
        passwordError: () => null,
        status: LoginStatus.submitting,
      ),
    );

    await Future<void>.delayed(_submissionDelay);

    emit(state.copyWith(status: LoginStatus.unimplementedNotice));
  }

  void _onNoticeDismissed(
    LoginNoticeDismissed event,
    Emitter<LoginState> emit,
  ) {
    if (state.status == LoginStatus.unimplementedNotice) {
      emit(state.copyWith(status: LoginStatus.idle));
    }
  }

  LoginEmailError? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return LoginEmailError.required;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return LoginEmailError.invalid;
    }
    return null;
  }

  LoginPasswordError? _validatePassword(String value) {
    if (value.isEmpty) {
      return LoginPasswordError.required;
    }
    return null;
  }
}
