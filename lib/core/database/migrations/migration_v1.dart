import 'package:sqflite/sqflite.dart';
import '../db_tables.dart';
import '../seed/seed_data.dart';

class MigrationV1 {
  MigrationV1._();

  static Future<void> execute(Database db) async {
    // 1. Users
    await db.execute('''
      CREATE TABLE ${DbTables.users} (
        ${UserColumns.id} TEXT PRIMARY KEY,
        ${UserColumns.fullName} TEXT NOT NULL,
        ${UserColumns.mobile} TEXT UNIQUE NOT NULL,
        ${UserColumns.email} TEXT UNIQUE NOT NULL,
        ${UserColumns.passwordHash} TEXT NOT NULL,
        ${UserColumns.avatarPath} TEXT,
        ${UserColumns.isActive} INTEGER NOT NULL DEFAULT 1,
        ${UserColumns.createdAt} INTEGER NOT NULL,
        ${UserColumns.updatedAt} INTEGER NOT NULL
      );
    ''');

    // 2. Locations
    await db.execute('''
      CREATE TABLE ${DbTables.locations} (
        ${LocationColumns.id} TEXT PRIMARY KEY,
        ${LocationColumns.nameEn} TEXT NOT NULL,
        ${LocationColumns.nameBn} TEXT NOT NULL,
        ${LocationColumns.code} TEXT UNIQUE NOT NULL,
        ${LocationColumns.isActive} INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // 3. Operators
    await db.execute('''
      CREATE TABLE ${DbTables.operators} (
        ${OperatorColumns.id} TEXT PRIMARY KEY,
        ${OperatorColumns.nameEn} TEXT NOT NULL,
        ${OperatorColumns.nameBn} TEXT NOT NULL,
        ${OperatorColumns.logoAsset} TEXT,
        ${OperatorColumns.isHandoverAllowed} INTEGER NOT NULL DEFAULT 1,
        ${OperatorColumns.handoverCommissionPct} INTEGER NOT NULL DEFAULT 30
      );
    ''');

    // 4. Routes
    await db.execute('''
      CREATE TABLE ${DbTables.routes} (
        ${RouteColumns.id} TEXT PRIMARY KEY,
        ${RouteColumns.originLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${RouteColumns.destinationLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${RouteColumns.distanceKm} INTEGER,
        ${RouteColumns.estimatedDurationMinutes} INTEGER
      );
    ''');

    // 5. Buses
    await db.execute('''
      CREATE TABLE ${DbTables.buses} (
        ${BusColumns.id} TEXT PRIMARY KEY,
        ${BusColumns.operatorId} TEXT NOT NULL REFERENCES ${DbTables.operators}(${OperatorColumns.id}),
        ${BusColumns.busName} TEXT NOT NULL,
        ${BusColumns.busType} TEXT NOT NULL,
        ${BusColumns.seatLayoutCode} TEXT NOT NULL,
        ${BusColumns.acType} TEXT NOT NULL,
        ${BusColumns.facilitiesJson} TEXT,
        ${BusColumns.totalSeats} INTEGER NOT NULL,
        ${BusColumns.isActive} INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // 6. Trips
    await db.execute('''
      CREATE TABLE ${DbTables.trips} (
        ${TripColumns.id} TEXT PRIMARY KEY,
        ${TripColumns.busId} TEXT NOT NULL REFERENCES ${DbTables.buses}(${BusColumns.id}),
        ${TripColumns.operatorId} TEXT NOT NULL REFERENCES ${DbTables.operators}(${OperatorColumns.id}),
        ${TripColumns.routeId} TEXT REFERENCES ${DbTables.routes}(${RouteColumns.id}),
        ${TripColumns.originLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${TripColumns.destinationLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${TripColumns.departureAt} INTEGER NOT NULL,
        ${TripColumns.arrivalAt} INTEGER NOT NULL,
        ${TripColumns.boardingPoint} TEXT NOT NULL,
        ${TripColumns.dropOffPoint} TEXT NOT NULL,
        ${TripColumns.fareAmount} INTEGER NOT NULL,
        ${TripColumns.status} TEXT NOT NULL DEFAULT 'scheduled',
        CONSTRAINT check_trip_times CHECK (${TripColumns.departureAt} < ${TripColumns.arrivalAt})
      );
    ''');

    // 7. Seat Inventory (Composite Primary Key: trip_id + seat_number)
    await db.execute('''
      CREATE TABLE ${DbTables.seatInventory} (
        ${SeatInventoryColumns.tripId} TEXT NOT NULL REFERENCES ${DbTables.trips}(${TripColumns.id}) ON DELETE CASCADE,
        ${SeatInventoryColumns.seatNumber} TEXT NOT NULL,
        ${SeatInventoryColumns.status} TEXT NOT NULL DEFAULT 'available' CHECK (${SeatInventoryColumns.status} IN ('available', 'held', 'booked', 'unavailable')),
        ${SeatInventoryColumns.holdUserId} TEXT REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${SeatInventoryColumns.holdExpiry} INTEGER,
        PRIMARY KEY (${SeatInventoryColumns.tripId}, ${SeatInventoryColumns.seatNumber})
      );
    ''');

    // 8. Bookings (Master Booking)
    await db.execute('''
      CREATE TABLE ${DbTables.bookings} (
        ${BookingColumns.id} TEXT PRIMARY KEY,
        ${BookingColumns.bookingCode} TEXT UNIQUE NOT NULL,
        ${BookingColumns.userId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${BookingColumns.journeyType} TEXT NOT NULL CHECK (${BookingColumns.journeyType} IN ('direct', 'connecting')),
        ${BookingColumns.bookingStatus} TEXT NOT NULL CHECK (${BookingColumns.bookingStatus} IN ('draft', 'payment_pending', 'confirmed', 'payment_failed', 'cancelled', 'completed')),
        ${BookingColumns.paymentStatus} TEXT NOT NULL CHECK (${BookingColumns.paymentStatus} IN ('pending', 'processing', 'success', 'failed', 'cancelled')),
        ${BookingColumns.passengerCount} INTEGER NOT NULL,
        ${BookingColumns.originLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${BookingColumns.destinationLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${BookingColumns.journeyDate} INTEGER NOT NULL,
        ${BookingColumns.subtotalAmount} INTEGER NOT NULL,
        ${BookingColumns.serviceChargeAmount} INTEGER NOT NULL DEFAULT 0,
        ${BookingColumns.discountAmount} INTEGER NOT NULL DEFAULT 0,
        ${BookingColumns.totalAmount} INTEGER NOT NULL,
        ${BookingColumns.createdAt} INTEGER NOT NULL
      );
    ''');

    // 9. Booking Legs
    await db.execute('''
      CREATE TABLE ${DbTables.bookingLegs} (
        ${BookingLegColumns.id} TEXT PRIMARY KEY,
        ${BookingLegColumns.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingColumns.id}) ON DELETE CASCADE,
        ${BookingLegColumns.tripId} TEXT NOT NULL REFERENCES ${DbTables.trips}(${TripColumns.id}),
        ${BookingLegColumns.legOrder} INTEGER NOT NULL CHECK (${BookingLegColumns.legOrder} IN (1, 2)),
        ${BookingLegColumns.transferPoint} TEXT,
        ${BookingLegColumns.waitingMinutes} INTEGER,
        ${BookingLegColumns.legFareAmount} INTEGER NOT NULL,
        UNIQUE (${BookingLegColumns.bookingId}, ${BookingLegColumns.legOrder})
      );
    ''');

    // 10. Passengers
    await db.execute('''
      CREATE TABLE ${DbTables.passengers} (
        ${PassengerColumns.id} TEXT PRIMARY KEY,
        ${PassengerColumns.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingColumns.id}) ON DELETE CASCADE,
        ${PassengerColumns.fullName} TEXT NOT NULL,
        ${PassengerColumns.mobile} TEXT NOT NULL,
        ${PassengerColumns.email} TEXT,
        ${PassengerColumns.passengerOrder} INTEGER NOT NULL,
        UNIQUE (${PassengerColumns.bookingId}, ${PassengerColumns.passengerOrder})
      );
    ''');

    // 11. Tickets
    await db.execute('''
      CREATE TABLE ${DbTables.tickets} (
        ${TicketColumns.id} TEXT PRIMARY KEY,
        ${TicketColumns.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingColumns.id}) ON DELETE CASCADE,
        ${TicketColumns.bookingLegId} TEXT NOT NULL REFERENCES ${DbTables.bookingLegs}(${BookingLegColumns.id}) ON DELETE CASCADE,
        ${TicketColumns.tripId} TEXT NOT NULL REFERENCES ${DbTables.trips}(${TripColumns.id}),
        ${TicketColumns.passengerId} TEXT NOT NULL REFERENCES ${DbTables.passengers}(${PassengerColumns.id}),
        ${TicketColumns.seatNumber} TEXT NOT NULL,
        ${TicketColumns.ownerUserId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${TicketColumns.qrToken} TEXT UNIQUE NOT NULL,
        ${TicketColumns.originalTicketPrice} INTEGER NOT NULL,
        ${TicketColumns.ticketStatus} TEXT NOT NULL CHECK (${TicketColumns.ticketStatus} IN ('confirmed', 'used', 'cancelled', 'handed_over', 'revoked')),
        ${TicketColumns.issuedAt} INTEGER NOT NULL,
        ${TicketColumns.invalidatedAt} INTEGER
      );
    ''');

    // 12. Demo Payments
    await db.execute('''
      CREATE TABLE ${DbTables.demoPayments} (
        ${DemoPaymentColumns.id} TEXT PRIMARY KEY,
        ${DemoPaymentColumns.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingColumns.id}) ON DELETE CASCADE,
        ${DemoPaymentColumns.attemptNumber} INTEGER NOT NULL,
        ${DemoPaymentColumns.paymentMethod} TEXT NOT NULL,
        ${DemoPaymentColumns.status} TEXT NOT NULL CHECK (${DemoPaymentColumns.status} IN ('processing', 'success', 'failed', 'cancelled')),
        ${DemoPaymentColumns.amount} INTEGER NOT NULL,
        ${DemoPaymentColumns.isDemo} INTEGER NOT NULL DEFAULT 1,
        ${DemoPaymentColumns.createdAt} INTEGER NOT NULL,
        ${DemoPaymentColumns.completedAt} INTEGER,
        UNIQUE (${DemoPaymentColumns.bookingId}, ${DemoPaymentColumns.attemptNumber})
      );
    ''');

    // 13. Handover Requests
    await db.execute('''
      CREATE TABLE ${DbTables.handoverRequests} (
        ${HandoverRequestColumns.id} TEXT PRIMARY KEY,
        ${HandoverRequestColumns.ticketId} TEXT NOT NULL REFERENCES ${DbTables.tickets}(${TicketColumns.id}),
        ${HandoverRequestColumns.senderId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${HandoverRequestColumns.receiverId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${HandoverRequestColumns.receiverNameSnapshot} TEXT NOT NULL,
        ${HandoverRequestColumns.receiverMobileSnapshot} TEXT NOT NULL,
        ${HandoverRequestColumns.message} TEXT,
        ${HandoverRequestColumns.status} TEXT NOT NULL CHECK (${HandoverRequestColumns.status} IN ('pending', 'approved', 'rejected', 'cancelled', 'declined', 'completed')),
        ${HandoverRequestColumns.createdAt} INTEGER NOT NULL,
        ${HandoverRequestColumns.updatedAt} INTEGER NOT NULL,
        CONSTRAINT check_handover_sender_not_receiver CHECK (${HandoverRequestColumns.senderId} != ${HandoverRequestColumns.receiverId})
      );
    ''');

    // 14. Handover Records (Immutable audit)
    await db.execute('''
      CREATE TABLE ${DbTables.handoverRecords} (
        ${HandoverRecordColumns.id} TEXT PRIMARY KEY,
        ${HandoverRecordColumns.handoverRequestId} TEXT UNIQUE NOT NULL REFERENCES ${DbTables.handoverRequests}(${HandoverRequestColumns.id}),
        ${HandoverRecordColumns.previousOwnerId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${HandoverRecordColumns.newOwnerId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${HandoverRecordColumns.oldTicketId} TEXT NOT NULL,
        ${HandoverRecordColumns.newTicketId} TEXT NOT NULL,
        ${HandoverRecordColumns.completedAt} INTEGER NOT NULL
      );
    ''');

    // 15. Revenue Splits (30% Operator, 50% Handoverer, 20% JatraNova)
    await db.execute('''
      CREATE TABLE ${DbTables.revenueSplits} (
        ${RevenueSplitColumns.id} TEXT PRIMARY KEY,
        ${RevenueSplitColumns.handoverRecordId} TEXT UNIQUE NOT NULL REFERENCES ${DbTables.handoverRecords}(${HandoverRecordColumns.id}),
        ${RevenueSplitColumns.originalTicketPrice} INTEGER NOT NULL,
        ${RevenueSplitColumns.operatorPercent} INTEGER NOT NULL DEFAULT 30,
        ${RevenueSplitColumns.handovererPercent} INTEGER NOT NULL DEFAULT 50,
        ${RevenueSplitColumns.platformPercent} INTEGER NOT NULL DEFAULT 20,
        ${RevenueSplitColumns.operatorShare} INTEGER NOT NULL,
        ${RevenueSplitColumns.handovererShare} INTEGER NOT NULL,
        ${RevenueSplitColumns.platformShare} INTEGER NOT NULL,
        ${RevenueSplitColumns.createdAt} INTEGER NOT NULL
      );
    ''');

    // 16. Connection Rules
    await db.execute('''
      CREATE TABLE ${DbTables.connectionRules} (
        ${ConnectionRuleColumns.id} TEXT PRIMARY KEY,
        ${ConnectionRuleColumns.operatorId} TEXT NOT NULL REFERENCES ${DbTables.operators}(${OperatorColumns.id}),
        ${ConnectionRuleColumns.transferHubLocationId} TEXT NOT NULL REFERENCES ${DbTables.locations}(${LocationColumns.id}),
        ${ConnectionRuleColumns.minBufferMinutes} INTEGER NOT NULL DEFAULT 45,
        ${ConnectionRuleColumns.maxWaitMinutes} INTEGER NOT NULL DEFAULT 180,
        ${ConnectionRuleColumns.isActive} INTEGER NOT NULL DEFAULT 1
      );
    ''');

    // 17. Cancellation Policies & Rules
    await db.execute('''
      CREATE TABLE ${DbTables.cancellationPolicies} (
        ${CancellationPolicyColumns.id} TEXT PRIMARY KEY,
        ${CancellationPolicyColumns.operatorId} TEXT NOT NULL REFERENCES ${DbTables.operators}(${OperatorColumns.id}),
        ${CancellationPolicyColumns.policyName} TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE ${DbTables.cancellationRules} (
        ${CancellationRuleColumns.id} TEXT PRIMARY KEY,
        ${CancellationRuleColumns.policyId} TEXT NOT NULL REFERENCES ${DbTables.cancellationPolicies}(${CancellationPolicyColumns.id}) ON DELETE CASCADE,
        ${CancellationRuleColumns.minHoursBeforeDeparture} INTEGER NOT NULL,
        ${CancellationRuleColumns.refundPercent} INTEGER NOT NULL CHECK (${CancellationRuleColumns.refundPercent} BETWEEN 0 AND 100)
      );
    ''');

    // 18. Notifications
    await db.execute('''
      CREATE TABLE ${DbTables.notifications} (
        ${NotificationColumns.id} TEXT PRIMARY KEY,
        ${NotificationColumns.userId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${NotificationColumns.title} TEXT NOT NULL,
        ${NotificationColumns.message} TEXT NOT NULL,
        ${NotificationColumns.category} TEXT NOT NULL,
        ${NotificationColumns.relatedType} TEXT,
        ${NotificationColumns.relatedId} TEXT,
        ${NotificationColumns.isRead} INTEGER NOT NULL DEFAULT 0,
        ${NotificationColumns.createdAt} INTEGER NOT NULL
      );
    ''');

    // 19. Saved Passengers
    await db.execute('''
      CREATE TABLE ${DbTables.savedPassengers} (
        ${SavedPassengerColumns.id} TEXT PRIMARY KEY,
        ${SavedPassengerColumns.userId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UserColumns.id}),
        ${SavedPassengerColumns.fullName} TEXT NOT NULL,
        ${SavedPassengerColumns.mobile} TEXT NOT NULL,
        ${SavedPassengerColumns.email} TEXT,
        ${SavedPassengerColumns.gender} TEXT,
        ${SavedPassengerColumns.createdAt} INTEGER NOT NULL,
        ${SavedPassengerColumns.updatedAt} INTEGER NOT NULL
      );
    ''');

    // 20. Critical Performance & Invariant Indexes
    await db.execute('''
      CREATE UNIQUE INDEX ux_one_success_payment_per_booking
      ON ${DbTables.demoPayments} (${DemoPaymentColumns.bookingId})
      WHERE ${DemoPaymentColumns.status} = 'success';
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX ux_one_active_handover_per_ticket
      ON ${DbTables.handoverRequests} (${HandoverRequestColumns.ticketId})
      WHERE ${HandoverRequestColumns.status} IN ('pending', 'approved');
    ''');

    await db.execute('''
      CREATE INDEX ix_trips_search
      ON ${DbTables.trips} (${TripColumns.originLocationId}, ${TripColumns.destinationLocationId}, ${TripColumns.departureAt});
    ''');

    await db.execute('''
      CREATE INDEX ix_tickets_owner_status
      ON ${DbTables.tickets} (${TicketColumns.ownerUserId}, ${TicketColumns.ticketStatus});
    ''');

    await db.execute('''
      CREATE INDEX ix_notifications_user_created
      ON ${DbTables.notifications} (${NotificationColumns.userId}, ${NotificationColumns.createdAt} DESC);
    ''');

    await db.execute('''
      CREATE INDEX ix_bookings_user_created
      ON ${DbTables.bookings} (${BookingColumns.userId}, ${BookingColumns.createdAt} DESC);
    ''');

    // Insert deterministic seed data inside the same creation transaction
    await SeedData.insertSeedData(db);
  }
}
