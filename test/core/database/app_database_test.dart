import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/database/app_database.dart';
import 'package:jatra_nova/core/database/db_tables.dart';
import 'package:jatra_nova/core/database/seed/seed_data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  const int nowMs = 1795600000000;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    await AppDatabase.configureForTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    db = await AppDatabase.instance.database;
  });

  tearDown(() async {
    await AppDatabase.resetConfiguration();
  });

  Future<void> insertUser(
    Database db, {
    String id = 'user-1',
    String mobile = '01711000001',
    String? email = 'rahim@example.com',
  }) async {
    await db.insert(DbTables.users, <String, Object?>{
      UsersCols.id: id,
      UsersCols.fullName: 'Test User $id',
      UsersCols.mobile: mobile,
      UsersCols.email: email,
      UsersCols.credentialHash: 'demo_hash_value',
      UsersCols.createdAt: nowMs,
      UsersCols.updatedAt: nowMs,
    });
  }

  Future<void> insertBooking(
    Database db, {
    String id = 'booking-1',
    String bookingNumber = 'BK-1001',
    String? userId,
    String bookingType = 'direct',
    String bookingStatus = 'confirmed',
    String paymentStatus = 'paid',
  }) async {
    await db.insert(DbTables.bookings, <String, Object?>{
      BookingsCols.id: id,
      BookingsCols.bookingNumber: bookingNumber,
      BookingsCols.userId: userId,
      BookingsCols.bookingType: bookingType,
      BookingsCols.bookingStatus: bookingStatus,
      BookingsCols.paymentStatus: paymentStatus,
      BookingsCols.totalAmountMinor: 100000,
      BookingsCols.createdAt: nowMs,
      BookingsCols.updatedAt: nowMs,
    });
  }

  Future<String> firstSeedTripId(Database db) async {
    final rows = await db.query(DbTables.trips, limit: 1);
    return rows.first[TripsCols.id]! as String;
  }

  Future<String> firstAvailableSeatId(Database db, String tripId) async {
    final rows = await db.query(
      DbTables.tripSeats,
      where: '${TripSeatsCols.tripId} = ? AND ${TripSeatsCols.status} = ?',
      whereArgs: <Object?>[tripId, 'available'],
      limit: 1,
    );
    return rows.first[TripSeatsCols.id]! as String;
  }

  group('AppDatabase schema & constraints', () {
    test('opens successfully and creates exactly the 20 approved tables',
        () async {
      expect(db.isOpen, isTrue);

      final rows = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
      );
      final tableNames = rows.map((r) => r['name'] as String).toSet();

      expect(tableNames.length, 20);
      expect(tableNames, equals(DbTables.allTables.toSet()));

      for (final obsolete in <String>[
        'app_preferences',
        'route_stops',
        'handover_requests',
        'seat_inventory',
      ]) {
        expect(tableNames.contains(obsolete), isFalse);
      }

      final fkChecks = await db.rawQuery('PRAGMA foreign_key_check');
      expect(fkChecks, isEmpty);
    });

    test('enforces PRAGMA foreign_keys = ON', () async {
      final result = await db.rawQuery('PRAGMA foreign_keys');
      expect(result.first.values.first, 1);
    });

    test('creates all 15 required indexes including partial unique indexes',
        () async {
      final rows = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index'",
      );
      final indexNames = rows.map((r) => r['name'] as String).toSet();

      const expectedIndexes = <String>[
        DbIndexes.savedPassengersUser,
        DbIndexes.tripsSearch,
        DbIndexes.tripSeatsTripStatus,
        DbIndexes.bookingsUserCreated,
        DbIndexes.demoPaymentsSuccessBooking,
        DbIndexes.ticketsNumber,
        DbIndexes.ticketsOwnerIssued,
        DbIndexes.activeTicketPerBookingPassenger,
        DbIndexes.ticketLegsTicket,
        DbIndexes.ticketLegsLegStatus,
        DbIndexes.activeTicketLegPassenger,
        DbIndexes.activeQrPerTicket,
        DbIndexes.ticketCancellationsBooking,
        DbIndexes.activeExchangePerTicket,
        DbIndexes.notificationsUserReadCreated,
      ];

      for (final idx in expectedIndexes) {
        expect(indexNames.contains(idx), isTrue, reason: 'Missing index $idx');
      }
    });

    test('enforces trip_seats status values and hold-owner mutual exclusivity',
        () async {
      await insertUser(db, id: 'u1');
      await insertBooking(db, id: 'b1', userId: 'u1');
      final tripId = await firstSeedTripId(db);

      // Invalid status rejected.
      await expectLater(
        db.insert(DbTables.tripSeats, <String, Object?>{
          TripSeatsCols.id: 'seat-invalid-status',
          TripSeatsCols.tripId: tripId,
          TripSeatsCols.seatNumber: 'Z1',
          TripSeatsCols.status: 'reserved',
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Held seat with BOTH hold_user_id and hold_session_id rejected.
      await expectLater(
        db.insert(DbTables.tripSeats, <String, Object?>{
          TripSeatsCols.id: 'seat-both-owners',
          TripSeatsCols.tripId: tripId,
          TripSeatsCols.seatNumber: 'Z2',
          TripSeatsCols.status: 'held',
          TripSeatsCols.holdUserId: 'u1',
          TripSeatsCols.holdSessionId: 'sess-1',
          TripSeatsCols.holdExpiry: nowMs + 300000,
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Held seat with NO owner or NO hold_expiry rejected.
      await expectLater(
        db.insert(DbTables.tripSeats, <String, Object?>{
          TripSeatsCols.id: 'seat-no-owner',
          TripSeatsCols.tripId: tripId,
          TripSeatsCols.seatNumber: 'Z3',
          TripSeatsCols.status: 'held',
          TripSeatsCols.holdExpiry: nowMs + 300000,
        }),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.insert(DbTables.tripSeats, <String, Object?>{
          TripSeatsCols.id: 'seat-no-expiry',
          TripSeatsCols.tripId: tripId,
          TripSeatsCols.seatNumber: 'Z4',
          TripSeatsCols.status: 'held',
          TripSeatsCols.holdUserId: 'u1',
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Held seat with ONLY hold_user_id + hold_expiry succeeds.
      await db.insert(DbTables.tripSeats, <String, Object?>{
        TripSeatsCols.id: 'seat-held-user',
        TripSeatsCols.tripId: tripId,
        TripSeatsCols.seatNumber: 'Z5',
        TripSeatsCols.status: 'held',
        TripSeatsCols.holdUserId: 'u1',
        TripSeatsCols.holdSessionId: null,
        TripSeatsCols.holdExpiry: nowMs + 300000,
      });

      // Held seat with ONLY hold_session_id + hold_expiry succeeds (guest).
      await db.insert(DbTables.tripSeats, <String, Object?>{
        TripSeatsCols.id: 'seat-held-guest',
        TripSeatsCols.tripId: tripId,
        TripSeatsCols.seatNumber: 'Z6',
        TripSeatsCols.status: 'held',
        TripSeatsCols.holdUserId: null,
        TripSeatsCols.holdSessionId: 'guest-sess-1',
        TripSeatsCols.holdExpiry: nowMs + 300000,
      });

      // Blocked seat with hold owner or expiry or booking_id rejected.
      await expectLater(
        db.insert(DbTables.tripSeats, <String, Object?>{
          TripSeatsCols.id: 'seat-blocked-owner',
          TripSeatsCols.tripId: tripId,
          TripSeatsCols.seatNumber: 'Z7',
          TripSeatsCols.status: 'blocked',
          TripSeatsCols.holdSessionId: 'guest-sess-1',
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Booked seat with hold_expiry rejected; without hold fields accepted.
      await expectLater(
        db.insert(DbTables.tripSeats, <String, Object?>{
          TripSeatsCols.id: 'seat-booked-hold',
          TripSeatsCols.tripId: tripId,
          TripSeatsCols.seatNumber: 'Z8',
          TripSeatsCols.status: 'booked',
          TripSeatsCols.bookingId: 'b1',
          TripSeatsCols.holdExpiry: nowMs + 300000,
        }),
        throwsA(isA<DatabaseException>()),
      );
      await db.insert(DbTables.tripSeats, <String, Object?>{
        TripSeatsCols.id: 'seat-booked-valid',
        TripSeatsCols.tripId: tripId,
        TripSeatsCols.seatNumber: 'Z9',
        TripSeatsCols.status: 'booked',
        TripSeatsCols.bookingId: 'b1',
      });
    });

    test('validates bookings, demo_payments, ticket_legs, and cancellations CHECKs',
        () async {
      // Generic 'failed' rejected on bookings.booking_status.
      await expectLater(
        insertBooking(db, id: 'b-bad-status', bookingStatus: 'failed'),
        throwsA(isA<DatabaseException>()),
      );
      // 'refund_pending_demo' rejected on bookings.payment_status.
      await expectLater(
        insertBooking(
          db,
          id: 'b-bad-pay',
          bookingNumber: 'BK-1002',
          paymentStatus: 'refund_pending_demo',
        ),
        throwsA(isA<DatabaseException>()),
      );

      // Approved payment_failed / payment_cancelled / partially_refunded_demo / refunded_demo accepted.
      await insertBooking(
        db,
        id: 'b-fail',
        bookingNumber: 'BK-1003',
        bookingStatus: 'payment_failed',
        paymentStatus: 'pending',
      );
      await insertBooking(
        db,
        id: 'b-cancel',
        bookingNumber: 'BK-1004',
        bookingStatus: 'payment_cancelled',
        paymentStatus: 'pending',
      );

      // demo_payments allows multiple failed/cancelled attempts, max 1 success.
      await db.insert(DbTables.demoPayments, <String, Object?>{
        DemoPaymentsCols.id: 'pay-1',
        DemoPaymentsCols.bookingId: 'b-fail',
        DemoPaymentsCols.idempotencyKey: 'idem-1',
        DemoPaymentsCols.method: 'mobile_banking',
        DemoPaymentsCols.status: 'failed',
        DemoPaymentsCols.amountMinor: 100000,
        DemoPaymentsCols.createdAt: nowMs,
      });
      await db.insert(DbTables.demoPayments, <String, Object?>{
        DemoPaymentsCols.id: 'pay-2',
        DemoPaymentsCols.bookingId: 'b-fail',
        DemoPaymentsCols.idempotencyKey: 'idem-2',
        DemoPaymentsCols.method: 'mobile_banking',
        DemoPaymentsCols.status: 'success',
        DemoPaymentsCols.amountMinor: 100000,
        DemoPaymentsCols.createdAt: nowMs + 1000,
        DemoPaymentsCols.completedAt: nowMs + 1000,
      });
      await expectLater(
        db.insert(DbTables.demoPayments, <String, Object?>{
          DemoPaymentsCols.id: 'pay-3',
          DemoPaymentsCols.bookingId: 'b-fail',
          DemoPaymentsCols.idempotencyKey: 'idem-3',
          DemoPaymentsCols.method: 'card',
          DemoPaymentsCols.status: 'success',
          DemoPaymentsCols.amountMinor: 100000,
          DemoPaymentsCols.createdAt: nowMs + 2000,
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Invalid refund_percentage (e.g. 50) rejected in ticket_cancellations.
      await db.insert(DbTables.tickets, <String, Object?>{
        TicketsCols.id: 't-cancel-check',
        TicketsCols.ticketNumber: 'TKT-C-1',
        TicketsCols.bookingId: 'b-fail',
        TicketsCols.passengerGroupIndex: 1,
        TicketsCols.holderName: 'Guest',
        TicketsCols.holderMobile: '01711000099',
        TicketsCols.originalTicketPriceMinor: 100000,
        TicketsCols.status: 'cancelled',
        TicketsCols.issuedAt: nowMs,
      });
      await expectLater(
        db.insert(DbTables.ticketCancellations, <String, Object?>{
          TicketCancellationsCols.id: 'tc-bad-pct',
          TicketCancellationsCols.bookingId: 'b-fail',
          TicketCancellationsCols.ticketId: 't-cancel-check',
          TicketCancellationsCols.refundPercentage: 50,
          TicketCancellationsCols.refundAmountMinor: 50000,
          TicketCancellationsCols.refundStatus: 'refund_pending_demo',
          TicketCancellationsCols.cancelledAt: nowMs,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('rejects invalid passenger_group_index (< 1 or > 4)', () async {
      await insertBooking(db, id: 'b1');
      final tripId = await firstSeedTripId(db);
      final seatId = await firstAvailableSeatId(db, tripId);
      await db.insert(DbTables.bookingLegs, <String, Object?>{
        BookingLegsCols.id: 'leg-1',
        BookingLegsCols.bookingId: 'b1',
        BookingLegsCols.tripId: tripId,
        BookingLegsCols.legOrder: 1,
      });

      for (final badIdx in <int>[0, 5]) {
        await expectLater(
          db.insert(DbTables.bookingPassengers, <String, Object?>{
            BookingPassengersCols.id: 'bp-bad-$badIdx',
            BookingPassengersCols.bookingId: 'b1',
            BookingPassengersCols.bookingLegId: 'leg-1',
            BookingPassengersCols.tripId: tripId,
            BookingPassengersCols.passengerGroupIndex: badIdx,
            BookingPassengersCols.passengerName: 'Bad',
            BookingPassengersCols.passengerMobile: '01711111111',
            BookingPassengersCols.seatId: seatId,
            BookingPassengersCols.seatNumberSnapshot: 'A2',
          }),
          throwsA(isA<DatabaseException>()),
        );

        await expectLater(
          db.insert(DbTables.tickets, <String, Object?>{
            TicketsCols.id: 't-bad-$badIdx',
            TicketsCols.ticketNumber: 'TKT-BAD-$badIdx',
            TicketsCols.bookingId: 'b1',
            TicketsCols.passengerGroupIndex: badIdx,
            TicketsCols.holderName: 'Bad',
            TicketsCols.holderMobile: '01711111111',
            TicketsCols.originalTicketPriceMinor: 100000,
            TicketsCols.status: 'issued',
            TicketsCols.issuedAt: nowMs,
          }),
          throwsA(isA<DatabaseException>()),
        );
      }
    });

    test(
        'partial unique ticket index blocks duplicates for issued, used, partially_used, expired and permits replacement after excluded statuses',
        () async {
      await insertBooking(db, id: 'b1');

      // Test all 4 included statuses block a second ticket for (b1, 1).
      const includedStatuses = <String>[
        'issued',
        'used',
        'partially_used',
        'expired',
      ];
      for (var i = 0; i < includedStatuses.length; i++) {
        final status = includedStatuses[i];
        final pIdx = i + 1; // 1..4
        await db.insert(DbTables.tickets, <String, Object?>{
          TicketsCols.id: 't-inc-$status',
          TicketsCols.ticketNumber: 'TKT-INC-$pIdx',
          TicketsCols.bookingId: 'b1',
          TicketsCols.passengerGroupIndex: pIdx,
          TicketsCols.holderName: 'Holder $pIdx',
          TicketsCols.holderMobile: '0171100001$pIdx',
          TicketsCols.originalTicketPriceMinor: 100000,
          TicketsCols.status: status,
          TicketsCols.issuedAt: nowMs,
        });

        await expectLater(
          db.insert(DbTables.tickets, <String, Object?>{
            TicketsCols.id: 't-dup-$status',
            TicketsCols.ticketNumber: 'TKT-DUP-$pIdx',
            TicketsCols.bookingId: 'b1',
            TicketsCols.passengerGroupIndex: pIdx,
            TicketsCols.holderName: 'Dup',
            TicketsCols.holderMobile: '0171100002$pIdx',
            TicketsCols.originalTicketPriceMinor: 100000,
            TicketsCols.status: 'issued',
            TicketsCols.issuedAt: nowMs + 1,
          }),
          throwsA(isA<DatabaseException>()),
        );
      }

      // Test all 3 excluded statuses allow an eligible replacement ticket.
      await insertBooking(db, id: 'b2', bookingNumber: 'BK-2001');
      const excludedStatuses = <String>[
        'revoked_exchanged',
        'cancelled',
        'invalidated',
      ];
      for (var i = 0; i < excludedStatuses.length; i++) {
        final status = excludedStatuses[i];
        final pIdx = i + 1;
        await db.insert(DbTables.tickets, <String, Object?>{
          TicketsCols.id: 't-old-$status',
          TicketsCols.ticketNumber: 'TKT-OLD-$pIdx',
          TicketsCols.bookingId: 'b2',
          TicketsCols.passengerGroupIndex: pIdx,
          TicketsCols.holderName: 'Old Owner',
          TicketsCols.holderMobile: '0171100003$pIdx',
          TicketsCols.originalTicketPriceMinor: 100000,
          TicketsCols.status: status,
          TicketsCols.issuedAt: nowMs,
        });

        await db.insert(DbTables.tickets, <String, Object?>{
          TicketsCols.id: 't-new-$status',
          TicketsCols.ticketNumber: 'TKT-NEW-$pIdx',
          TicketsCols.bookingId: 'b2',
          TicketsCols.passengerGroupIndex: pIdx,
          TicketsCols.holderName: 'New Owner',
          TicketsCols.holderMobile: '0171100004$pIdx',
          TicketsCols.originalTicketPriceMinor: 100000,
          TicketsCols.status: 'issued',
          TicketsCols.issuedAt: nowMs + 500,
        });
      }
    });

    test('rejects single and composite foreign-key violations', () async {
      await insertBooking(db, id: 'b1', bookingNumber: 'BK-1');
      await insertBooking(db, id: 'b2', bookingNumber: 'BK-2');
      final tripId = await firstSeedTripId(db);
      final seatId = await firstAvailableSeatId(db, tripId);

      // Non-existent booking on booking_legs rejected.
      await expectLater(
        db.insert(DbTables.bookingLegs, <String, Object?>{
          BookingLegsCols.id: 'leg-orphan',
          BookingLegsCols.bookingId: 'missing-booking',
          BookingLegsCols.tripId: tripId,
          BookingLegsCols.legOrder: 1,
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Composite FK: ticket_cancellations cannot pair b1's ticket with b2.
      await db.insert(DbTables.tickets, <String, Object?>{
        TicketsCols.id: 't-b1',
        TicketsCols.ticketNumber: 'TKT-FK-1',
        TicketsCols.bookingId: 'b1',
        TicketsCols.passengerGroupIndex: 1,
        TicketsCols.holderName: 'User',
        TicketsCols.holderMobile: '01711000001',
        TicketsCols.originalTicketPriceMinor: 100000,
        TicketsCols.status: 'issued',
        TicketsCols.issuedAt: nowMs,
      });
      await expectLater(
        db.insert(DbTables.ticketCancellations, <String, Object?>{
          TicketCancellationsCols.id: 'tc-cross-booking',
          TicketCancellationsCols.bookingId: 'b2',
          TicketCancellationsCols.ticketId: 't-b1',
          TicketCancellationsCols.refundPercentage: 100,
          TicketCancellationsCols.refundAmountMinor: 100000,
          TicketCancellationsCols.refundStatus: 'refund_pending_demo',
          TicketCancellationsCols.cancelledAt: nowMs,
        }),
        throwsA(isA<DatabaseException>()),
      );

      // Composite FK: ticket_legs enforces missed_at <-> boarding_status & matching booking_id.
      await db.insert(DbTables.bookingLegs, <String, Object?>{
        BookingLegsCols.id: 'leg-b1',
        BookingLegsCols.bookingId: 'b1',
        BookingLegsCols.tripId: tripId,
        BookingLegsCols.legOrder: 1,
      });
      await db.insert(DbTables.bookingPassengers, <String, Object?>{
        BookingPassengersCols.id: 'bp-b1',
        BookingPassengersCols.bookingId: 'b1',
        BookingPassengersCols.bookingLegId: 'leg-b1',
        BookingPassengersCols.tripId: tripId,
        BookingPassengersCols.passengerGroupIndex: 1,
        BookingPassengersCols.passengerName: 'Passenger 1',
        BookingPassengersCols.passengerMobile: '01711000001',
        BookingPassengersCols.seatId: seatId,
        BookingPassengersCols.seatNumberSnapshot: 'A2',
      });
      await expectLater(
        db.insert(DbTables.ticketLegs, <String, Object?>{
          TicketLegsCols.id: 'tl-bad-missed',
          TicketLegsCols.ticketId: 't-b1',
          TicketLegsCols.bookingId: 'b1',
          TicketLegsCols.bookingLegId: 'leg-b1',
          TicketLegsCols.legOrder: 1,
          TicketLegsCols.bookingPassengerId: 'bp-b1',
          TicketLegsCols.passengerGroupIndex: 1,
          TicketLegsCols.boardingStatus: 'missed',
          TicketLegsCols.missedAt: null,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('repeated initialization and reseeding preserve existing data',
        () async {
      final secondDb = await AppDatabase.instance.database;
      expect(identical(db, secondDb), isTrue);

      await insertUser(db, id: 'user-persist', mobile: '01811000001');
      final initialTrips = await db.query(DbTables.trips);
      final initialStops = await db.query(DbTables.stops);

      await SeedData.seedInTransaction(db, nowUtcMs: nowMs + 86400000);

      final afterTrips = await db.query(DbTables.trips);
      final afterStops = await db.query(DbTables.stops);
      final users = await db.query(
        DbTables.users,
        where: '${UsersCols.id} = ?',
        whereArgs: <Object?>['user-persist'],
      );

      expect(afterTrips.length, initialTrips.length);
      expect(afterStops.length, initialStops.length);
      expect(users.length, 1);
    });
  });
}
