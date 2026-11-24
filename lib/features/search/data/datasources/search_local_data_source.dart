import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/db_tables.dart';
import '../models/location_model.dart';
import '../models/trip_model.dart';

abstract class ISearchLocalDataSource {
  Future<List<LocationModel>> getLocations();
  Future<List<TripModel>> searchDirectTrips({
    required String originId,
    required String destinationId,
    required int startOfDayEpochMs,
    required int endOfDayEpochMs,
  });
  Future<List<Map<String, dynamic>>> getPopularRoutes();
}

@Injectable(as: ISearchLocalDataSource)
class SearchLocalDataSourceImpl implements ISearchLocalDataSource {
  final Database _db;

  SearchLocalDataSourceImpl(this._db);

  @override
  Future<List<LocationModel>> getLocations() async {
    final rows = await _db.query(
      DbTables.locations,
      where: '${LocationColumns.isActive} = 1',
      orderBy: LocationColumns.nameEn,
    );
    return rows.map((r) => LocationModel.fromMap(r)).toList();
  }

  @override
  Future<List<TripModel>> searchDirectTrips({
    required String originId,
    required String destinationId,
    required int startOfDayEpochMs,
    required int endOfDayEpochMs,
  }) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    final query = '''
      SELECT 
        t.id AS trip_id,
        t.bus_id,
        t.operator_id,
        op.name_en AS operator_name_en,
        op.name_bn AS operator_name_bn,
        op.logo_asset AS operator_logo,
        b.bus_name,
        b.bus_type,
        b.ac_type,
        b.facilities_json,
        b.total_seats,
        t.origin_location_id,
        l1.name_en AS origin_name_en,
        l1.name_bn AS origin_name_bn,
        t.destination_location_id,
        l2.name_en AS destination_name_en,
        l2.name_bn AS destination_name_bn,
        t.departure_at,
        t.arrival_at,
        t.boarding_point,
        t.drop_off_point,
        t.fare_amount,
        (
          SELECT COUNT(*) 
          FROM ${DbTables.seatInventory} s 
          WHERE s.trip_id = t.id 
            AND (s.status = 'available' OR (s.status = 'held' AND s.hold_expiry < ?))
        ) AS available_seats
      FROM ${DbTables.trips} t
      JOIN ${DbTables.operators} op ON t.operator_id = op.id
      JOIN ${DbTables.buses} b ON t.bus_id = b.id
      JOIN ${DbTables.locations} l1 ON t.origin_location_id = l1.id
      JOIN ${DbTables.locations} l2 ON t.destination_location_id = l2.id
      WHERE t.origin_location_id = ?
        AND t.destination_location_id = ?
        AND t.departure_at >= ?
        AND t.departure_at <= ?
        AND t.status = 'scheduled'
      ORDER BY t.departure_at ASC;
    ''';

    final rows = await _db.rawQuery(query, [
      nowMs,
      originId,
      destinationId,
      startOfDayEpochMs,
      endOfDayEpochMs,
    ]);

    return rows.map((r) => TripModel.fromRow(r)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getPopularRoutes() async {
    final query = '''
      SELECT 
        l1.id AS origin_id,
        l1.name_en AS origin_name_en,
        l1.name_bn AS origin_name_bn,
        l2.id AS destination_id,
        l2.name_en AS destination_name_en,
        l2.name_bn AS destination_name_bn,
        MIN(t.fare_amount) AS starting_fare,
        COUNT(t.id) AS daily_trips
      FROM ${DbTables.trips} t
      JOIN ${DbTables.locations} l1 ON t.origin_location_id = l1.id
      JOIN ${DbTables.locations} l2 ON t.destination_location_id = l2.id
      GROUP BY l1.id, l2.id
      ORDER BY daily_trips DESC
      LIMIT 5;
    ''';

    final rows = await _db.rawQuery(query);
    return rows;
  }
}
