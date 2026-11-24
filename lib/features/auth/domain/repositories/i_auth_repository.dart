import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getUserById(String userId);
}
