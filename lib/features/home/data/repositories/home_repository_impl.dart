import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/database/db_tables.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/home/data/datasources/home_local_datasource.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';
import 'package:jatra_nova/features/home/domain/repositories/i_home_repository.dart';

@Injectable(as: IHomeRepository)
class HomeRepositoryImpl implements IHomeRepository {
  HomeRepositoryImpl(this._localDataSource);

  final IHomeLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, HomeDataEntity>> loadHomeData({
    required String languageCode,
    String? userId,
  }) async {
    try {
      final snapshot = await _localDataSource.fetchHomeSnapshot(userId: userId);
      final isBangla = languageCode == 'bn';

      final stopsById = <String, StopEntity>{};
      final stops = <StopEntity>[];

      for (final row in snapshot.stops) {
        final stop = StopEntity(
          id: row[StopsCols.id]! as String,
          cityCode: row[StopsCols.cityCode]! as String,
          name: (isBangla ? row[StopsCols.nameBn] : row[StopsCols.nameEn])!
              as String,
          isPopular: (row[StopsCols.isPopular] as int? ?? 0) == 1,
          isTransferHub: (row[StopsCols.isTransferHub] as int? ?? 0) == 1,
        );
        stopsById[stop.id] = stop;
        stops.add(stop);
      }

      final popularRoutes = <PopularRouteEntity>[];
      for (final row in snapshot.popularRoutes) {
        final origin = stopsById[row['origin_stop_id'] as String];
        final dest = stopsById[row['destination_stop_id'] as String];
        if (origin == null || dest == null) {
          continue;
        }
        popularRoutes.add(
          PopularRouteEntity(
            id: row['route_id']! as String,
            originStop: origin,
            destinationStop: dest,
            name: (isBangla ? row['route_name_bn'] : row['route_name_en'])!
                as String,
            minFareMinor: row['min_fare_minor'] as int?,
          ),
        );
      }

      final popularBuses = <PopularBusEntity>[];
      for (final row in snapshot.popularBuses) {
        final departureMs = row['departure_at']! as int;
        popularBuses.add(
          PopularBusEntity(
            tripId: row['trip_id']! as String,
            busName: (isBangla ? row['bus_name_bn'] : row['bus_name_en'])!
                as String,
            operatorName:
                (isBangla ? row['operator_name_bn'] : row['operator_name_en'])!
                    as String,
            originName:
                (isBangla ? row['origin_name_bn'] : row['origin_name_en'])!
                    as String,
            destinationName: (isBangla
                    ? row['destination_name_bn']
                    : row['destination_name_en'])!
                as String,
            departureAt: DateTime.fromMillisecondsSinceEpoch(
              departureMs,
              isUtc: true,
            ).toLocal(),
            fareMinor: row['fare_minor']! as int,
            availableSeats: row['available_seats'] as int? ?? 0,
            busType: row['bus_type']! as String,
          ),
        );
      }

      return Right<Failure, HomeDataEntity>(
        HomeDataEntity(
          stops: stops,
          popularRoutes: popularRoutes,
          popularBuses: popularBuses,
          passengerName: snapshot.userFullName,
        ),
      );
    } catch (e) {
      return Left<Failure, HomeDataEntity>(
        Failure(
          type: FailureType.database,
          debugMessage: e.toString(),
        ),
      );
    }
  }
}
