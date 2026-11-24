import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/filter_criteria_entity.dart';
import '../entities/location_entity.dart';
import '../entities/trip_entity.dart';

abstract class ISearchRepository {
  Future<Either<Failure, List<LocationEntity>>> getLocations();

  Future<Either<Failure, List<TripEntity>>> searchTrips({
    required String originId,
    required String destinationId,
    required int dateEpochMs,
    FilterCriteriaEntity? filters,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getPopularRoutes();
}
