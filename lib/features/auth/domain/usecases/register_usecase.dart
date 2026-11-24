import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/i_auth_repository.dart';

abstract class IRegisterUsecase {
  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  });
}

@Injectable(as: IRegisterUsecase)
class RegisterUsecase implements IRegisterUsecase {
  final IAuthRepository _repository;

  RegisterUsecase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    final cleanName = fullName.trim();
    final cleanMobile = mobile.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) {
      return const Left(Failure(type: FailureType.validation, debugMessage: 'Full name is required'));
    }
    if (!Validators.isValidBdMobile(cleanMobile)) {
      return const Left(Failure(type: FailureType.validation, debugMessage: 'Valid BD mobile is required'));
    }
    if (!Validators.isValidEmail(cleanEmail)) {
      return const Left(Failure(type: FailureType.validation, debugMessage: 'Valid email is required'));
    }
    if (!Validators.isValidPassword(password)) {
      return const Left(Failure(type: FailureType.validation, debugMessage: 'Password must be at least 6 characters'));
    }

    final normalizedMobile = Validators.normalizeBdMobile(cleanMobile);
    return _repository.register(
      fullName: cleanName,
      mobile: normalizedMobile,
      email: cleanEmail,
      password: password,
    );
  }
}
