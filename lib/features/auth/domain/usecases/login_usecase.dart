import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

abstract class ILoginUsecase {
  Future<Either<Failure, UserEntity>> call({
    required String identifier,
    required String password,
  });
}

@Injectable(as: ILoginUsecase)
class LoginUsecase implements ILoginUsecase {
  final IAuthRepository _repository;

  LoginUsecase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call({
    required String identifier,
    required String password,
  }) async {
    final cleanIdentifier = identifier.trim();
    if (cleanIdentifier.isEmpty) {
      return const Left(Failure(type: FailureType.validation, debugMessage: 'Identifier is required'));
    }
    if (password.isEmpty) {
      return const Left(Failure(type: FailureType.validation, debugMessage: 'Password is required'));
    }
    return _repository.login(identifier: cleanIdentifier, password: password);
  }
}
