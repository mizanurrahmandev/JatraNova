import 'package:dartz/dartz.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';

abstract class IGetHomeDataUsecase {
  Future<Either<Failure, HomeDataEntity>> call({
    required String languageCode,
    String? userId,
  });
}
