import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/database/db_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Raw SQLite query results for the Home Screen.
class HomeLocalSnapshot {
  const HomeLocalSnapshot({
    required this.stops,
    required this.popularRoutes,
    required this.popularBuses,
    this.userFullName,
  });

  final List<Map<String, Object?>> stops;
  final List<Map<String, Object?>> popularRoutes;
  final List<Map<String, Object?>> popularBuses;
  final String? userFullName;
}

abstract class IHomeLocalDataSource {
  Future<HomeLocalSnapshot> fetchHomeSnapshot({String? userId});
}

@Injectable(as: IHomeLocalDataSource)
class HomeLocalDataSourceImpl implements IHomeLocalDataSource {
  HomeLocalDataSourceImpl(this._database);

  final Database _database;

  @override
  Future<HomeLocalSnapshot> fetchHomeSnapshot({String? userId}) async {
    final nowUtcMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    final stops = await _database.query(
      DbTables.stops,
      orderBy: '${StopsCols.isPopular} DESC, ${StopsCols.nameEn} ASC',
    );

    final popularRoutes = await _database.rawQuery(
      '''
      SELECT
        r.${RoutesCols.id} AS route_id,
        r.${RoutesCols.originStopId} AS origin_stop_id,
        r.${RoutesCols.destinationStopId} AS destination_stop_id,
        r.${RoutesCols.nameEn} AS route_name_en,
        r.${RoutesCols.nameBn} AS route_name_bn,
        MIN(t.${TripsCols.fareMinor}) AS min_fare_minor
      FROM ${DbTables.routes} r
      LEFT JOIN ${DbTables.trips} t
        ON t.${TripsCols.routeId} = r.${RoutesCols.id}
        AND t.${TripsCols.isActive} = 1
      WHERE r.${RoutesCols.isPopular} = 1
      GROUP BY r.${RoutesCols.id}
      ORDER BY r.${RoutesCols.nameEn} ASC
      ''',
    );

    final popularBuses = await _database.rawQuery(
      '''
      SELECT
        t.${TripsCols.id} AS trip_id,
        t.${TripsCols.busNameEn} AS bus_name_en,
        t.${TripsCols.busNameBn} AS bus_name_bn,
        t.${TripsCols.busType} AS bus_type,
        t.${TripsCols.departureAt} AS departure_at,
        t.${TripsCols.fareMinor} AS fare_minor,
        o.${BusOperatorsCols.nameEn} AS operator_name_en,
        o.${BusOperatorsCols.nameBn} AS operator_name_bn,
        orig.${StopsCols.nameEn} AS origin_name_en,
        orig.${StopsCols.nameBn} AS origin_name_bn,
        dest.${StopsCols.nameEn} AS destination_name_en,
        dest.${StopsCols.nameBn} AS destination_name_bn,
        COUNT(
          CASE
            WHEN ts.${TripSeatsCols.status} = 'available'
              OR (ts.${TripSeatsCols.status} = 'held' AND ts.${TripSeatsCols.holdExpiry} < ?)
            THEN 1
          END
        ) AS available_seats
      FROM ${DbTables.trips} t
      INNER JOIN ${DbTables.busOperators} o
        ON o.${BusOperatorsCols.id} = t.${TripsCols.operatorId}
      INNER JOIN ${DbTables.stops} orig
        ON orig.${StopsCols.id} = t.${TripsCols.originStopId}
      INNER JOIN ${DbTables.stops} dest
        ON dest.${StopsCols.id} = t.${TripsCols.destinationStopId}
      LEFT JOIN ${DbTables.tripSeats} ts
        ON ts.${TripSeatsCols.tripId} = t.${TripsCols.id}
      WHERE t.${TripsCols.isActive} = 1
        AND t.${TripsCols.isPopular} = 1
        AND t.${TripsCols.departureAt} >= ?
      GROUP BY t.${TripsCols.id}
      ORDER BY t.${TripsCols.departureAt} ASC
      LIMIT 6
      ''',
      <Object?>[nowUtcMs, nowUtcMs],
    );

    String? userFullName;
    if (userId != null && userId.isNotEmpty) {
      final userRows = await _database.query(
        DbTables.users,
        columns: <String>[UsersCols.fullName],
        where: '${UsersCols.id} = ?',
        whereArgs: <Object?>[userId],
        limit: 1,
      );
      if (userRows.isNotEmpty) {
        userFullName = userRows.first[UsersCols.fullName] as String?;
      }
    }

    return HomeLocalSnapshot(
      stops: stops,
      popularRoutes: popularRoutes,
      popularBuses: popularBuses,
      userFullName: userFullName,
    );
  }
}
