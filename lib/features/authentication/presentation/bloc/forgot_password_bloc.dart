import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/forgot_password_state.dart';

/// Manages Forgot Password Screen email input, validation, and submission
/// feedback.
///
/// Actual password recovery remains unimplemented in this demo.
@injectable
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
    on<ForgotPasswordNoticeDismissed>(_onNoticeDismissed);
  }

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const Duration _submissionDelay = Duration(milliseconds: 250);

  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        emailError: () =>
            state.showValidationError ? _validateEmail(event.email) : null,
        status: ForgotPasswordStatus.idle,
      ),
    );
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (state.isSubmitting) {
      return;
    }

    final emailError = _validateEmail(state.email);
    if (emailError != null) {
      emit(
        state.copyWith(
          showValidationError: true,
          emailError: () => emailError,
          status: ForgotPasswordStatus.idle,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        showValidationError: true,
        emailError: () => null,
        status: ForgotPasswordStatus.submitting,
      ),
    );

    await Future<void>.delayed(_submissionDelay);

    emit(state.copyWith(status: ForgotPasswordStatus.unimplementedNotice));
  }

  void _onNoticeDismissed(
    ForgotPasswordNoticeDismissed event,
    Emitter<ForgotPasswordState> emit,
  ) {
    if (state.status == ForgotPasswordStatus.unimplementedNotice) {
      emit(state.copyWith(status: ForgotPasswordStatus.idle));
    }
  }

  ForgotPasswordEmailError? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ForgotPasswordEmailError.required;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return ForgotPasswordEmailError.invalid;
    }
    return null;
  }
}
