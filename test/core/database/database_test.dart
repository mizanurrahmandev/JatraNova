import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/database/db_tables.dart';
import 'package:jatra_nova/core/database/migrations/migration_v1.dart';
import 'package:jatra_nova/core/database/seed/seed_data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  setUpAll(() {
    // Initialize FFI for local in-memory SQLite testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Open in-memory database with foreign keys enabled
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
  });

  tearDown(() async {
    await db.close();
  });

  group('Database Foundation & Schema Integrity', () {
    test('enforces PRAGMA foreign_keys = ON', () async {
      final result = await db.rawQuery('PRAGMA foreign_keys;');
      expect(result.first['foreign_keys'], equals(1));
    });

    test('creates all required tables successfully', () async {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';",
      );
      final tableNames = tables.map((row) => row['name'] as String).toSet();

      expect(tableNames, containsAll([
        DbTables.users,
        DbTables.locations,
        DbTables.operators,
        DbTables.routes,
        DbTables.buses,
        DbTables.trips,
        DbTables.seatInventory,
        DbTables.bookings,
        DbTables.bookingLegs,
        DbTables.passengers,
        DbTables.tickets,
        DbTables.demoPayments,
        DbTables.handoverRequests,
        DbTables.handoverRecords,
        DbTables.revenueSplits,
        DbTables.connectionRules,
        DbTables.cancellationPolicies,
        DbTables.cancellationRules,
        DbTables.notifications,
        DbTables.savedPassengers,
      ]));
    });

    test('verifies deterministic seed data initialization', () async {
      // Users seeded
      final users = await db.query(DbTables.users);
      expect(users.length, equals(2));
      final rahim = users.firstWhere((u) => u[UserColumns.id] == 'user_rahim');
      expect(rahim[UserColumns.fullName], equals('Rahim Ahmed'));
      expect(rahim[UserColumns.passwordHash], equals(SeedData.hashPassword('password123')));

      // Locations seeded
      final locations = await db.query(DbTables.locations);
      expect(locations.length, equals(6));

      // Operators seeded
      final operators = await db.query(DbTables.operators);
      expect(operators.length, equals(3));
      final greenLine = operators.firstWhere((o) => o[OperatorColumns.id] == 'op_greenline');
      expect(greenLine[OperatorColumns.isHandoverAllowed], equals(1));
      expect(greenLine[OperatorColumns.handoverCommissionPct], equals(30));

      // Trips seeded for 7 days
      final trips = await db.query(DbTables.trips);
      expect(trips.length, greaterThanOrEqualTo(20));

      // Initial confirmed ticket for Rahim
      final tickets = await db.query(
        DbTables.tickets,
        where: '${TicketColumns.ownerUserId} = ?',
        whereArgs: ['user_rahim'],
      );
      expect(tickets.length, equals(1));
      expect(tickets.first[TicketColumns.ticketStatus], equals('confirmed'));
    });

    test('rejects orphan foreign key insertion', () async {
      // Attempt to insert a trip referencing non-existent operator
      expect(
        () async => await db.insert(DbTables.trips, {
          TripColumns.id: 'trip_invalid',
          TripColumns.busId: 'bus_gl_01',
          TripColumns.operatorId: 'non_existent_operator',
          TripColumns.originLocationId: 'loc_dhaka',
          TripColumns.destinationLocationId: 'loc_chattogram',
          TripColumns.departureAt: 1000000,
          TripColumns.arrivalAt: 2000000,
          TripColumns.boardingPoint: 'Point A',
          TripColumns.dropOffPoint: 'Point B',
          TripColumns.fareAmount: 500,
          TripColumns.status: 'scheduled',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('enforces uniqueness on user mobile and email', () async {
      // Attempt duplicate mobile
      expect(
        () async => await db.insert(DbTables.users, {
          UserColumns.id: 'user_duplicate_mobile',
          UserColumns.fullName: 'Duplicate',
          UserColumns.mobile: '01712345678', // Rahim's mobile
          UserColumns.email: 'unique@demo.com',
          UserColumns.passwordHash: 'hash',
          UserColumns.isActive: 1,
          UserColumns.createdAt: 1000,
          UserColumns.updatedAt: 1000,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('enforces at most one successful payment per booking index', () async {
      const bookingId = 'booking_rahim_demo_01';

      // First successful payment already exists in seed. Attempt second successful payment:
      expect(
        () async => await db.insert(DbTables.demoPayments, {
          DemoPaymentColumns.id: 'payment_duplicate_success',
          DemoPaymentColumns.bookingId: bookingId,
          DemoPaymentColumns.attemptNumber: 2,
          DemoPaymentColumns.paymentMethod: 'Demo Card',
          DemoPaymentColumns.status: 'success', // Conflicts with unique index
          DemoPaymentColumns.amount: 1350,
          DemoPaymentColumns.isDemo: 1,
          DemoPaymentColumns.createdAt: 2000,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('enforces at most one active handover request per ticket', () async {
      const ticketId = 'ticket_rahim_demo_01';

      // Insert first pending handover request
      await db.insert(DbTables.handoverRequests, {
        HandoverRequestColumns.id: 'hr_active_01',
        HandoverRequestColumns.ticketId: ticketId,
        HandoverRequestColumns.senderId: 'user_rahim',
        HandoverRequestColumns.receiverId: 'user_karim',
        HandoverRequestColumns.receiverNameSnapshot: 'Karim Hasan',
        HandoverRequestColumns.receiverMobileSnapshot: '01812345678',
        HandoverRequestColumns.status: 'pending',
        HandoverRequestColumns.createdAt: 1000,
        HandoverRequestColumns.updatedAt: 1000,
      });

      // Attempt second pending handover request on same ticket
      expect(
        () async => await db.insert(DbTables.handoverRequests, {
          HandoverRequestColumns.id: 'hr_active_02',
          HandoverRequestColumns.ticketId: ticketId,
          HandoverRequestColumns.senderId: 'user_rahim',
          HandoverRequestColumns.receiverId: 'user_karim',
          HandoverRequestColumns.receiverNameSnapshot: 'Karim Hasan',
          HandoverRequestColumns.receiverMobileSnapshot: '01812345678',
          HandoverRequestColumns.status: 'pending',
          HandoverRequestColumns.createdAt: 2000,
          HandoverRequestColumns.updatedAt: 2000,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rolls back entire transaction on mid-operation failure', () async {
      const testTripId = 'trip_dac_ctg_gl_0';
      const seatToHold = 'B1';

      try {
        await db.transaction((txn) async {
          // Step 1: Update seat status to held
          await txn.update(
            DbTables.seatInventory,
            {
              SeatInventoryColumns.status: 'held',
              SeatInventoryColumns.holdUserId: 'user_rahim',
              SeatInventoryColumns.holdExpiry: 9999999999,
            },
            where: '${SeatInventoryColumns.tripId} = ? AND ${SeatInventoryColumns.seatNumber} = ?',
            whereArgs: [testTripId, seatToHold],
          );

          // Step 2: Deliberate error (violating foreign key constraint)
          await txn.insert(DbTables.bookings, {
            BookingColumns.id: 'invalid_booking',
            BookingColumns.bookingCode: 'JN-ERR',
            BookingColumns.userId: 'non_existent_user', // FK failure
            BookingColumns.journeyType: 'direct',
            BookingColumns.bookingStatus: 'confirmed',
            BookingColumns.paymentStatus: 'success',
            BookingColumns.passengerCount: 1,
            BookingColumns.originLocationId: 'loc_dhaka',
            BookingColumns.destinationLocationId: 'loc_chattogram',
            BookingColumns.journeyDate: 1000,
            BookingColumns.subtotalAmount: 1000,
            BookingColumns.totalAmount: 1000,
            BookingColumns.createdAt: 1000,
          });
        });
      } catch (_) {
        // Expected rollback
      }

      // Assert that Step 1 was rolled back
      final seat = await db.query(
        DbTables.seatInventory,
        where: '${SeatInventoryColumns.tripId} = ? AND ${SeatInventoryColumns.seatNumber} = ?',
        whereArgs: [testTripId, seatToHold],
      );
      expect(seat.first[SeatInventoryColumns.status], equals('available'));
      expect(seat.first[SeatInventoryColumns.holdUserId], isNull);
    });

    test('validates same-operator connecting journey query logic', () async {
      // Query to pair Leg 1 (Dhaka -> Rajshahi) and Leg 2 (Rajshahi -> Rangpur)
      final connectingLegs = await db.rawQuery('''
        SELECT 
          t1.id AS leg1_trip_id,
          t1.departure_at AS leg1_dep,
          t1.arrival_at AS leg1_arr,
          t2.id AS leg2_trip_id,
          t2.departure_at AS leg2_dep,
          t2.arrival_at AS leg2_arr,
          t1.operator_id AS operator_id,
          ((t2.departure_at - t1.arrival_at) / 60000) AS wait_minutes,
          cr.min_buffer_minutes,
          cr.max_wait_minutes
        FROM ${DbTables.trips} t1
        JOIN ${DbTables.trips} t2 
          ON t1.operator_id = t2.operator_id
          AND t1.destination_location_id = t2.origin_location_id
        JOIN ${DbTables.connectionRules} cr
          ON cr.operator_id = t1.operator_id
          AND cr.transfer_hub_location_id = t1.destination_location_id
        WHERE t1.origin_location_id = 'loc_dhaka'
          AND t2.destination_location_id = 'loc_rangpur'
          AND ((t2.departure_at - t1.arrival_at) / 60000) >= cr.min_buffer_minutes
          AND ((t2.departure_at - t1.arrival_at) / 60000) <= cr.max_wait_minutes
      ''');

      expect(connectingLegs.isNotEmpty, isTrue);
      final connection = connectingLegs.first;
      expect(connection['operator_id'], equals('op_greenline'));
      expect(connection['wait_minutes'], equals(75)); // 1h 15m layover
      expect(connection['wait_minutes'] as int, greaterThanOrEqualTo(45));
      expect(connection['wait_minutes'] as int, lessThanOrEqualTo(180));
    });
  });
}
