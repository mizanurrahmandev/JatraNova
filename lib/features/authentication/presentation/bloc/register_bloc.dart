import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_event.dart';
import 'package:jatra_nova/features/authentication/presentation/bloc/register_state.dart';

/// Manages Registration Screen form state, validation, password visibility,
/// and Terms & Conditions agreement.
///
/// Account creation and database persistence remain unimplemented until
/// approved.
@injectable
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterState()) {
    on<RegisterFullNameChanged>(_onFullNameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterPasswordVisibilityToggled>(_onVisibilityToggled);
    on<RegisterTermsToggled>(_onTermsToggled);
    on<RegisterSubmitted>(_onSubmitted);
    on<RegisterNoticeDismissed>(_onNoticeDismissed);
  }

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
  static const int _minPasswordLength = 6;
  static const Duration _submissionDelay = Duration(milliseconds: 250);

  void _onFullNameChanged(
    RegisterFullNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        fullName: event.fullName,
        fullNameError: () => state.showValidationErrors
            ? _validateFullName(event.fullName)
            : null,
        status: RegisterStatus.idle,
      ),
    );
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        emailError: () =>
            state.showValidationErrors ? _validateEmail(event.email) : null,
        status: RegisterStatus.idle,
      ),
    );
  }

  void _onPhoneChanged(
    RegisterPhoneChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        phone: event.phone,
        phoneError: () =>
            state.showValidationErrors ? _validatePhone(event.phone) : null,
        status: RegisterStatus.idle,
      ),
    );
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        passwordError: () => state.showValidationErrors
            ? _validatePassword(event.password)
            : null,
        status: RegisterStatus.idle,
      ),
    );
  }

  void _onVisibilityToggled(
    RegisterPasswordVisibilityToggled event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onTermsToggled(
    RegisterTermsToggled event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        agreedToTerms: event.agreed,
        termsError: () =>
            state.showValidationErrors ? _validateTerms(event.agreed) : null,
        status: RegisterStatus.idle,
      ),
    );
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.isSubmitting) {
      return;
    }

    final fullNameError = _validateFullName(state.fullName);
    final emailError = _validateEmail(state.email);
    final phoneError = _validatePhone(state.phone);
    final passwordError = _validatePassword(state.password);
    final termsError = _validateTerms(state.agreedToTerms);

    if (fullNameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null ||
        termsError != null) {
      emit(
        state.copyWith(
          showValidationErrors: true,
          fullNameError: () => fullNameError,
          emailError: () => emailError,
          phoneError: () => phoneError,
          passwordError: () => passwordError,
          termsError: () => termsError,
          status: RegisterStatus.idle,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        showValidationErrors: true,
        fullNameError: () => null,
        emailError: () => null,
        phoneError: () => null,
        passwordError: () => null,
        termsError: () => null,
        status: RegisterStatus.submitting,
      ),
    );

    await Future<void>.delayed(_submissionDelay);

    emit(state.copyWith(status: RegisterStatus.unimplementedNotice));
  }

  void _onNoticeDismissed(
    RegisterNoticeDismissed event,
    Emitter<RegisterState> emit,
  ) {
    if (state.status == RegisterStatus.unimplementedNotice) {
      emit(state.copyWith(status: RegisterStatus.idle));
    }
  }

  RegisterFullNameError? _validateFullName(String value) {
    if (value.trim().isEmpty) {
      return RegisterFullNameError.required;
    }
    return null;
  }

  RegisterEmailError? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return RegisterEmailError.required;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return RegisterEmailError.invalid;
    }
    return null;
  }

  RegisterPhoneError? _validatePhone(String value) {
    final normalized = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (normalized.isEmpty) {
      return RegisterPhoneError.required;
    }
    if (!_phoneRegex.hasMatch(normalized)) {
      return RegisterPhoneError.invalid;
    }
    return null;
  }

  RegisterPasswordError? _validatePassword(String value) {
    if (value.isEmpty) {
      return RegisterPasswordError.required;
    }
    if (value.length < _minPasswordLength) {
      return RegisterPasswordError.tooShort;
    }
    return null;
  }

  RegisterTermsError? _validateTerms(bool agreed) {
    if (!agreed) {
      return RegisterTermsError.required;
    }
    return null;
  }
}
