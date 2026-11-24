import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/auth/domain/entities/user_entity.dart';
import 'package:jatra_nova/features/auth/domain/usecases/login_usecase.dart';
import 'package:jatra_nova/features/auth/domain/usecases/register_usecase.dart';
import 'package:jatra_nova/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements ILoginUsecase {}

class MockRegisterUsecase extends Mock implements IRegisterUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
  });

  const testUser = UserEntity(
    id: 'user_rahim',
    fullName: 'Rahim Ahmed',
    mobile: '01712345678',
    email: 'rahim@demo.com',
    createdAt: 1000,
    updatedAt: 1000,
  );

  group('AuthBloc - Login', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(() => mockLoginUsecase(
              identifier: '01712345678',
              password: 'password123',
            )).thenAnswer((_) async => const Right(testUser));
        return AuthBloc(
          loginUsecase: mockLoginUsecase,
          registerUsecase: mockRegisterUsecase,
        );
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        identifier: '01712345678',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const AuthSuccess(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when login fails',
      build: () {
        when(() => mockLoginUsecase(
              identifier: '01712345678',
              password: 'wrong_password',
            )).thenAnswer((_) async => const Left(Failure(
              type: FailureType.unauthorized,
              debugMessage: 'Invalid credentials',
            )));
        return AuthBloc(
          loginUsecase: mockLoginUsecase,
          registerUsecase: mockRegisterUsecase,
        );
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        identifier: '01712345678',
        password: 'wrong_password',
      )),
      expect: () => [
        AuthLoading(),
        const AuthFailureState(Failure(
          type: FailureType.unauthorized,
          debugMessage: 'Invalid credentials',
        )),
      ],
    );
  });

  group('AuthBloc - Register', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthFailureState] immediately if terms are not accepted',
      build: () => AuthBloc(
        loginUsecase: mockLoginUsecase,
        registerUsecase: mockRegisterUsecase,
      ),
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        fullName: 'Test User',
        mobile: '01711223344',
        email: 'test@demo.com',
        password: 'password123',
        confirmPassword: 'password123',
        termsAccepted: false,
      )),
      expect: () => [
        const AuthFailureState(Failure(
          type: FailureType.validation,
          debugMessage: 'Terms must be accepted',
        )),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthFailureState] immediately if passwords do not match',
      build: () => AuthBloc(
        loginUsecase: mockLoginUsecase,
        registerUsecase: mockRegisterUsecase,
      ),
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        fullName: 'Test User',
        mobile: '01711223344',
        email: 'test@demo.com',
        password: 'password123',
        confirmPassword: 'different_password',
        termsAccepted: true,
      )),
      expect: () => [
        const AuthFailureState(Failure(
          type: FailureType.validation,
          debugMessage: 'Passwords mismatch',
        )),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when registration succeeds',
      build: () {
        when(() => mockRegisterUsecase(
              fullName: 'Test User',
              mobile: '01711223344',
              email: 'test@demo.com',
              password: 'password123',
            )).thenAnswer((_) async => const Right(testUser));
        return AuthBloc(
          loginUsecase: mockLoginUsecase,
          registerUsecase: mockRegisterUsecase,
        );
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        fullName: 'Test User',
        mobile: '01711223344',
        email: 'test@demo.com',
        password: 'password123',
        confirmPassword: 'password123',
        termsAccepted: true,
      )),
      expect: () => [
        AuthLoading(),
        const AuthSuccess(testUser),
      ],
    );
  });
}
