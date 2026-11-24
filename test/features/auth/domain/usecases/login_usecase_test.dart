import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/auth/domain/entities/user_entity.dart';
import 'package:jatra_nova/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:jatra_nova/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(mockRepository);
  });

  const testUser = UserEntity(
    id: 'user_1',
    fullName: 'Rahim Ahmed',
    mobile: '01712345678',
    email: 'rahim@demo.com',
    createdAt: 1000,
    updatedAt: 1000,
  );

  test('returns validation failure when identifier is empty', () async {
    final result = await usecase(identifier: '  ', password: 'password123');
    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure.type, equals(FailureType.validation)),
      (_) => fail('Should not succeed'),
    );
  });

  test('returns validation failure when password is empty', () async {
    final result = await usecase(identifier: '01712345678', password: '');
    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure.type, equals(FailureType.validation)),
      (_) => fail('Should not succeed'),
    );
  });

  test('delegates to repository when credentials format is valid', () async {
    when(() => mockRepository.login(
          identifier: '01712345678',
          password: 'password123',
        )).thenAnswer((_) async => const Right(testUser));

    final result = await usecase(identifier: '01712345678', password: 'password123');

    expect(result, equals(const Right(testUser)));
    verify(() => mockRepository.login(
          identifier: '01712345678',
          password: 'password123',
        )).called(1);
  });
}
