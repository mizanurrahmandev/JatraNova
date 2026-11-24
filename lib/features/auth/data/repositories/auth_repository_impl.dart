import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

@Injectable(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthLocalDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final isValid = await _dataSource.verifyCredentials(
        identifier: identifier,
        password: password,
      );

      if (!isValid) {
        return const Left(Failure(
          type: FailureType.unauthorized,
          debugMessage: 'Invalid mobile/email or password',
        ));
      }

      final user = await _dataSource.findByIdentifier(identifier);
      if (user == null) {
        return const Left(Failure(
          type: FailureType.notFound,
          debugMessage: 'User profile not found',
        ));
      }

      return Right(user);
    } on DatabaseException catch (e) {
      return Left(Failure(
        type: FailureType.database,
        debugMessage: e.toString(),
      ));
    } catch (e) {
      return Left(Failure(
        type: FailureType.unknown,
        debugMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      // Check if email or mobile already exists
      final existingUser = await _dataSource.findByIdentifier(mobile);
      if (existingUser != null) {
        return const Left(Failure(
          type: FailureType.conflict,
          debugMessage: 'Mobile already registered',
        ));
      }

      final existingEmail = await _dataSource.findByIdentifier(email);
      if (existingEmail != null) {
        return const Left(Failure(
          type: FailureType.conflict,
          debugMessage: 'Email already registered',
        ));
      }

      final createdUser = await _dataSource.createUser(
        fullName: fullName,
        mobile: mobile,
        email: email,
        password: password,
      );

      return Right(createdUser);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return const Left(Failure(
          type: FailureType.conflict,
          debugMessage: 'Unique constraint error on registration',
        ));
      }
      return Left(Failure(
        type: FailureType.database,
        debugMessage: e.toString(),
      ));
    } catch (e) {
      return Left(Failure(
        type: FailureType.unknown,
        debugMessage: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    try {
      final user = await _dataSource.findById(userId);
      if (user == null) {
        return const Left(Failure(
          type: FailureType.notFound,
          debugMessage: 'User not found',
        ));
      }
      return Right(user);
    } on DatabaseException catch (e) {
      return Left(Failure(
        type: FailureType.database,
        debugMessage: e.toString(),
      ));
    } catch (e) {
      return Left(Failure(
        type: FailureType.unknown,
        debugMessage: e.toString(),
      ));
    }
  }
}
