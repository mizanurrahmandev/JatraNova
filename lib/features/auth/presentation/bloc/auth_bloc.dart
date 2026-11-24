import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ILoginUsecase _loginUsecase;
  final IRegisterUsecase _registerUsecase;

  AuthBloc({
    required ILoginUsecase loginUsecase,
    required IRegisterUsecase registerUsecase,
  })  : _loginUsecase = loginUsecase,
        _registerUsecase = registerUsecase,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthResetState>(_onResetState);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUsecase(
      identifier: event.identifier,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!event.termsAccepted) {
      emit(const AuthFailureState(
        Failure(type: FailureType.validation, debugMessage: 'Terms must be accepted'),
      ));
      return;
    }

    if (event.password != event.confirmPassword) {
      emit(const AuthFailureState(
        Failure(type: FailureType.validation, debugMessage: 'Passwords mismatch'),
      ));
      return;
    }

    emit(AuthLoading());
    final result = await _registerUsecase(
      fullName: event.fullName,
      mobile: event.mobile,
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFailureState(failure)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onResetState(
    AuthResetState event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}
