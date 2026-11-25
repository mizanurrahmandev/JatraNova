import 'package:dartz/dartz.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';

/// Domain repository contract for loading Passenger Home Screen data.
abstract class IHomeRepository {
  Future<Either<Failure, HomeDataEntity>> loadHomeData({
    required String languageCode,
    String? userId,
  });
}
