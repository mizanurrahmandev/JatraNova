import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/filter_criteria_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../datasources/search_local_data_source.dart';

@Injectable(as: ISearchRepository)
class SearchRepositoryImpl implements ISearchRepository {
  final ISearchLocalDataSource _dataSource;

  SearchRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    try {
      final locations = await _dataSource.getLocations();
      return Right(locations);
    } on DatabaseException catch (e) {
      return Left(Failure(type: FailureType.database, debugMessage: e.toString()));
    } catch (e) {
      return Left(Failure(type: FailureType.unknown, debugMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripEntity>>> searchTrips({
    required String originId,
    required String destinationId,
    required int dateEpochMs,
    FilterCriteriaEntity? filters,
  }) async {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(dateEpochMs, isUtc: true);
      final startOfDay = DateTime.utc(dateTime.year, dateTime.month, dateTime.day).millisecondsSinceEpoch;
      final endOfDay = DateTime.utc(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999).millisecondsSinceEpoch;

      final trips = await _dataSource.searchDirectTrips(
        originId: originId,
        destinationId: destinationId,
        startOfDayEpochMs: startOfDay,
        endOfDayEpochMs: endOfDay,
      );

      // Apply Filter Criteria in-memory
      var filteredTrips = List<TripEntity>.from(trips);

      if (filters != null) {
        if (filters.onlyAc != null) {
          filteredTrips = filteredTrips.where((t) => t.isAc == filters.onlyAc).toList();
        }
        if (filters.operatorId != null && filters.operatorId!.isNotEmpty) {
          filteredTrips = filteredTrips.where((t) => t.operatorId == filters.operatorId).toList();
        }

        switch (filters.sortBy) {
          case SortOption.lowestFare:
            filteredTrips.sort((a, b) => a.fareAmount.compareTo(b.fareAmount));
            break;
          case SortOption.fastest:
            filteredTrips.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
            break;
          case SortOption.earliestDeparture:
            filteredTrips.sort((a, b) => a.departureAt.compareTo(b.departureAt));
            break;
        }
      }

      return Right(filteredTrips);
    } on DatabaseException catch (e) {
      return Left(Failure(type: FailureType.database, debugMessage: e.toString()));
    } catch (e) {
      return Left(Failure(type: FailureType.unknown, debugMessage: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPopularRoutes() async {
    try {
      final routes = await _dataSource.getPopularRoutes();
      return Right(routes);
    } on DatabaseException catch (e) {
      return Left(Failure(type: FailureType.database, debugMessage: e.toString()));
    } catch (e) {
      return Left(Failure(type: FailureType.unknown, debugMessage: e.toString()));
    }
  }
}
