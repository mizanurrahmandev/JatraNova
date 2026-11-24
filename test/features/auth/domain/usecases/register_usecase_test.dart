import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/auth/domain/entities/user_entity.dart';
import 'package:jatra_nova/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jatra_nova/features/auth/domain/usecases/register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(mockRepository);
  });

  const testUser = UserEntity(
    id: 'user_new',
    fullName: 'Sadia Akter',
    mobile: '01718765432',
    email: 'sadia@demo.com',
    createdAt: 2000,
    updatedAt: 2000,
  );

  test('returns validation failure when mobile is invalid', () async {
    final result = await usecase(
      fullName: 'Sadia Akter',
      mobile: '01212345678', // invalid BD mobile
      email: 'sadia@demo.com',
      password: 'password123',
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure.type, equals(FailureType.validation)),
      (_) => fail('Should fail'),
    );
  });

  test('returns validation failure when email is invalid', () async {
    final result = await usecase(
      fullName: 'Sadia Akter',
      mobile: '01718765432',
      email: 'invalid-email',
      password: 'password123',
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure.type, equals(FailureType.validation)),
      (_) => fail('Should fail'),
    );
  });

  test('returns validation failure when password is too short', () async {
    final result = await usecase(
      fullName: 'Sadia Akter',
      mobile: '01718765432',
      email: 'sadia@demo.com',
      password: '123',
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure.type, equals(FailureType.validation)),
      (_) => fail('Should fail'),
    );
  });

  test('normalizes mobile and calls repository successfully', () async {
    when(() => mockRepository.register(
          fullName: 'Sadia Akter',
          mobile: '01718765432',
          email: 'sadia@demo.com',
          password: 'password123',
        )).thenAnswer((_) async => const Right(testUser));

    final result = await usecase(
      fullName: 'Sadia Akter',
      mobile: '+8801718765432', // should normalize to 01718765432
      email: 'sadia@demo.com',
      password: 'password123',
    );

    expect(result, equals(const Right(testUser)));
    verify(() => mockRepository.register(
          fullName: 'Sadia Akter',
          mobile: '01718765432',
          email: 'sadia@demo.com',
          password: 'password123',
        )).called(1);
  });
}
