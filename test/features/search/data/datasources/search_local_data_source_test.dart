import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/database/migrations/migration_v1.dart';
import 'package:jatra_nova/features/search/data/datasources/search_local_data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late SearchLocalDataSourceImpl dataSource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON;');
        },
        onCreate: (db, version) async {
          await MigrationV1.execute(db);
        },
      ),
    );
    dataSource = SearchLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SearchLocalDataSourceImpl', () {
    test('fetches all active locations', () async {
      final locations = await dataSource.getLocations();
      expect(locations.length, equals(6));
      expect(locations.any((l) => l.code == 'DAC'), isTrue);
      expect(locations.any((l) => l.code == 'CTG'), isTrue);
    });

    test('fetches direct trips between Dhaka and Chattogram with accurate available seats', () async {
      final now = DateTime.now().toUtc();
      final startOfDay = DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch;
      final endOfDay = DateTime.utc(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

      final trips = await dataSource.searchDirectTrips(
        originId: 'loc_dhaka',
        destinationId: 'loc_chattogram',
        startOfDayEpochMs: startOfDay,
        endOfDayEpochMs: endOfDay,
      );

      expect(trips.isNotEmpty, isTrue);
      final firstTrip = trips.first;
      expect(firstTrip.originNameEn, equals('Dhaka'));
      expect(firstTrip.destinationNameEn, equals('Chattogram'));
      expect(firstTrip.availableSeats, greaterThan(0));
      expect(firstTrip.availableSeats, lessThanOrEqualTo(firstTrip.totalSeats));
    });

    test('fetches popular routes summary', () async {
      final routes = await dataSource.getPopularRoutes();
      expect(routes.isNotEmpty, isTrue);
      final firstRoute = routes.first;
      expect(firstRoute.containsKey('starting_fare'), isTrue);
      expect(firstRoute.containsKey('daily_trips'), isTrue);
    });
  });
}
