import 'package:jatra_nova/core/database/db_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Initial database schema migration (v1) creating the approved 20 tables,
/// foreign keys, composite constraints, CHECK constraints, and indexes.
abstract final class MigrationV1 {
  static Future<void> up(DatabaseExecutor db) async {
    for (final statement in _ddlStatements) {
      await db.execute(statement);
    }
  }

  static final List<String> _ddlStatements = <String>[
    // 1. users
    '''
    CREATE TABLE ${DbTables.users} (
      ${UsersCols.id} TEXT NOT NULL PRIMARY KEY,
      ${UsersCols.fullName} TEXT NOT NULL,
      ${UsersCols.mobile} TEXT NOT NULL UNIQUE,
      ${UsersCols.email} TEXT NULL UNIQUE,
      ${UsersCols.credentialHash} TEXT NOT NULL,
      ${UsersCols.avatarKey} TEXT NOT NULL DEFAULT 'initials',
      ${UsersCols.createdAt} INTEGER NOT NULL,
      ${UsersCols.updatedAt} INTEGER NOT NULL
    )
    ''',

    // 2. saved_passengers
    '''
    CREATE TABLE ${DbTables.savedPassengers} (
      ${SavedPassengersCols.id} TEXT NOT NULL PRIMARY KEY,
      ${SavedPassengersCols.userId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UsersCols.id}) ON DELETE CASCADE,
      ${SavedPassengersCols.displayName} TEXT NOT NULL,
      ${SavedPassengersCols.fullName} TEXT NOT NULL,
      ${SavedPassengersCols.mobile} TEXT NOT NULL,
      ${SavedPassengersCols.email} TEXT NULL,
      ${SavedPassengersCols.relationshipLabel} TEXT NULL,
      ${SavedPassengersCols.createdAt} INTEGER NOT NULL,
      ${SavedPassengersCols.updatedAt} INTEGER NOT NULL
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.savedPassengersUser}
      ON ${DbTables.savedPassengers}(${SavedPassengersCols.userId})
    ''',

    // 3. bus_operators
    '''
    CREATE TABLE ${DbTables.busOperators} (
      ${BusOperatorsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${BusOperatorsCols.nameEn} TEXT NOT NULL,
      ${BusOperatorsCols.nameBn} TEXT NOT NULL,
      ${BusOperatorsCols.logoPath} TEXT NULL,
      ${BusOperatorsCols.isVerified} INTEGER NOT NULL DEFAULT 1 CHECK(${BusOperatorsCols.isVerified} IN (0, 1)),
      ${BusOperatorsCols.allowsExchange} INTEGER NOT NULL DEFAULT 1 CHECK(${BusOperatorsCols.allowsExchange} IN (0, 1)),
      ${BusOperatorsCols.exchangeCutoffMinutes} INTEGER NOT NULL DEFAULT 120 CHECK(${BusOperatorsCols.exchangeCutoffMinutes} >= 0),
      ${BusOperatorsCols.cancellationPolicyJson} TEXT NOT NULL,
      ${BusOperatorsCols.createdAt} INTEGER NOT NULL
    )
    ''',

    // 4. stops
    '''
    CREATE TABLE ${DbTables.stops} (
      ${StopsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${StopsCols.cityCode} TEXT NOT NULL UNIQUE,
      ${StopsCols.nameEn} TEXT NOT NULL,
      ${StopsCols.nameBn} TEXT NOT NULL,
      ${StopsCols.isPopular} INTEGER NOT NULL DEFAULT 0 CHECK(${StopsCols.isPopular} IN (0, 1)),
      ${StopsCols.isTransferHub} INTEGER NOT NULL DEFAULT 0 CHECK(${StopsCols.isTransferHub} IN (0, 1))
    )
    ''',

    // 5. routes
    '''
    CREATE TABLE ${DbTables.routes} (
      ${RoutesCols.id} TEXT NOT NULL PRIMARY KEY,
      ${RoutesCols.originStopId} TEXT NOT NULL REFERENCES ${DbTables.stops}(${StopsCols.id}),
      ${RoutesCols.destinationStopId} TEXT NOT NULL REFERENCES ${DbTables.stops}(${StopsCols.id}),
      ${RoutesCols.nameEn} TEXT NOT NULL,
      ${RoutesCols.nameBn} TEXT NOT NULL,
      ${RoutesCols.isPopular} INTEGER NOT NULL DEFAULT 0 CHECK(${RoutesCols.isPopular} IN (0, 1)),
      UNIQUE(${RoutesCols.originStopId}, ${RoutesCols.destinationStopId}),
      UNIQUE(${RoutesCols.id}, ${RoutesCols.originStopId}, ${RoutesCols.destinationStopId}),
      CHECK(${RoutesCols.originStopId} != ${RoutesCols.destinationStopId})
    )
    ''',

    // 6. trips
    '''
    CREATE TABLE ${DbTables.trips} (
      ${TripsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TripsCols.operatorId} TEXT NOT NULL REFERENCES ${DbTables.busOperators}(${BusOperatorsCols.id}),
      ${TripsCols.routeId} TEXT NOT NULL,
      ${TripsCols.originStopId} TEXT NOT NULL,
      ${TripsCols.destinationStopId} TEXT NOT NULL,
      ${TripsCols.busNameEn} TEXT NOT NULL,
      ${TripsCols.busNameBn} TEXT NOT NULL,
      ${TripsCols.busType} TEXT NOT NULL CHECK(${TripsCols.busType} IN ('ac_business', 'ac_sleeper', 'non_ac')),
      ${TripsCols.departureAt} INTEGER NOT NULL,
      ${TripsCols.arrivalAt} INTEGER NOT NULL,
      ${TripsCols.boardingPointEn} TEXT NOT NULL,
      ${TripsCols.boardingPointBn} TEXT NOT NULL,
      ${TripsCols.dropOffPointEn} TEXT NOT NULL,
      ${TripsCols.dropOffPointBn} TEXT NOT NULL,
      ${TripsCols.facilitiesJson} TEXT NULL,
      ${TripsCols.fareMinor} INTEGER NOT NULL CHECK(${TripsCols.fareMinor} >= 0),
      ${TripsCols.totalSeats} INTEGER NOT NULL CHECK(${TripsCols.totalSeats} > 0),
      ${TripsCols.isPopular} INTEGER NOT NULL DEFAULT 0 CHECK(${TripsCols.isPopular} IN (0, 1)),
      ${TripsCols.isActive} INTEGER NOT NULL DEFAULT 1 CHECK(${TripsCols.isActive} IN (0, 1)),
      CHECK(${TripsCols.arrivalAt} > ${TripsCols.departureAt}),
      FOREIGN KEY (${TripsCols.routeId}, ${TripsCols.originStopId}, ${TripsCols.destinationStopId})
        REFERENCES ${DbTables.routes}(${RoutesCols.id}, ${RoutesCols.originStopId}, ${RoutesCols.destinationStopId})
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.tripsSearch}
      ON ${DbTables.trips}(${TripsCols.originStopId}, ${TripsCols.destinationStopId}, ${TripsCols.departureAt}, ${TripsCols.isActive})
    ''',

    // 7. connection_rules
    '''
    CREATE TABLE ${DbTables.connectionRules} (
      ${ConnectionRulesCols.id} TEXT NOT NULL PRIMARY KEY,
      ${ConnectionRulesCols.hubStopId} TEXT NOT NULL REFERENCES ${DbTables.stops}(${StopsCols.id}),
      ${ConnectionRulesCols.operatorId} TEXT NULL REFERENCES ${DbTables.busOperators}(${BusOperatorsCols.id}),
      ${ConnectionRulesCols.minBufferMinutes} INTEGER NOT NULL DEFAULT 30 CHECK(${ConnectionRulesCols.minBufferMinutes} >= 0),
      ${ConnectionRulesCols.maxBufferMinutes} INTEGER NOT NULL DEFAULT 240 CHECK(${ConnectionRulesCols.maxBufferMinutes} >= ${ConnectionRulesCols.minBufferMinutes}),
      ${ConnectionRulesCols.transferInstructionsEn} TEXT NOT NULL,
      ${ConnectionRulesCols.transferInstructionsBn} TEXT NOT NULL,
      ${ConnectionRulesCols.isActive} INTEGER NOT NULL DEFAULT 1 CHECK(${ConnectionRulesCols.isActive} IN (0, 1))
    )
    ''',

    // 8. bookings (created before trip_seats because trip_seats.booking_id references bookings)
    '''
    CREATE TABLE ${DbTables.bookings} (
      ${BookingsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${BookingsCols.bookingNumber} TEXT NOT NULL UNIQUE,
      ${BookingsCols.userId} TEXT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${BookingsCols.bookingType} TEXT NOT NULL CHECK(${BookingsCols.bookingType} IN ('direct', 'connecting')),
      ${BookingsCols.bookingStatus} TEXT NOT NULL CHECK(${BookingsCols.bookingStatus} IN ('pending_payment', 'payment_failed', 'payment_cancelled', 'confirmed', 'cancelled', 'partially_cancelled')),
      ${BookingsCols.paymentStatus} TEXT NOT NULL CHECK(${BookingsCols.paymentStatus} IN ('pending', 'paid', 'partially_refunded_demo', 'refunded_demo')),
      ${BookingsCols.totalAmountMinor} INTEGER NOT NULL CHECK(${BookingsCols.totalAmountMinor} >= 0),
      ${BookingsCols.createdAt} INTEGER NOT NULL,
      ${BookingsCols.updatedAt} INTEGER NOT NULL
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.bookingsUserCreated}
      ON ${DbTables.bookings}(${BookingsCols.userId}, ${BookingsCols.createdAt} DESC)
    ''',

    // 9. trip_seats
    '''
    CREATE TABLE ${DbTables.tripSeats} (
      ${TripSeatsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TripSeatsCols.tripId} TEXT NOT NULL REFERENCES ${DbTables.trips}(${TripsCols.id}) ON DELETE CASCADE,
      ${TripSeatsCols.seatNumber} TEXT NOT NULL,
      ${TripSeatsCols.seatClass} TEXT NULL,
      ${TripSeatsCols.status} TEXT NOT NULL CHECK(${TripSeatsCols.status} IN ('available', 'held', 'booked', 'blocked')),
      ${TripSeatsCols.holdUserId} TEXT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TripSeatsCols.holdSessionId} TEXT NULL,
      ${TripSeatsCols.holdExpiry} INTEGER NULL,
      ${TripSeatsCols.bookingId} TEXT NULL REFERENCES ${DbTables.bookings}(${BookingsCols.id}),
      UNIQUE(${TripSeatsCols.tripId}, ${TripSeatsCols.seatNumber}),
      UNIQUE(${TripSeatsCols.id}, ${TripSeatsCols.tripId}),
      CHECK(NOT (${TripSeatsCols.holdUserId} IS NOT NULL AND ${TripSeatsCols.holdSessionId} IS NOT NULL)),
      CHECK((${TripSeatsCols.status} != 'available') OR (${TripSeatsCols.holdUserId} IS NULL AND ${TripSeatsCols.holdSessionId} IS NULL AND ${TripSeatsCols.holdExpiry} IS NULL AND ${TripSeatsCols.bookingId} IS NULL)),
      CHECK((${TripSeatsCols.status} != 'held') OR (((${TripSeatsCols.holdUserId} IS NOT NULL AND ${TripSeatsCols.holdSessionId} IS NULL) OR (${TripSeatsCols.holdUserId} IS NULL AND ${TripSeatsCols.holdSessionId} IS NOT NULL)) AND ${TripSeatsCols.holdExpiry} IS NOT NULL AND ${TripSeatsCols.bookingId} IS NULL)),
      CHECK((${TripSeatsCols.status} != 'booked') OR (${TripSeatsCols.bookingId} IS NOT NULL AND ${TripSeatsCols.holdUserId} IS NULL AND ${TripSeatsCols.holdSessionId} IS NULL AND ${TripSeatsCols.holdExpiry} IS NULL)),
      CHECK((${TripSeatsCols.status} != 'blocked') OR (${TripSeatsCols.holdUserId} IS NULL AND ${TripSeatsCols.holdSessionId} IS NULL AND ${TripSeatsCols.holdExpiry} IS NULL AND ${TripSeatsCols.bookingId} IS NULL))
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.tripSeatsTripStatus}
      ON ${DbTables.tripSeats}(${TripSeatsCols.tripId}, ${TripSeatsCols.status}, ${TripSeatsCols.holdExpiry})
    ''',

    // 10. booking_legs
    '''
    CREATE TABLE ${DbTables.bookingLegs} (
      ${BookingLegsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${BookingLegsCols.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingsCols.id}) ON DELETE CASCADE,
      ${BookingLegsCols.tripId} TEXT NOT NULL REFERENCES ${DbTables.trips}(${TripsCols.id}),
      ${BookingLegsCols.legOrder} INTEGER NOT NULL CHECK(${BookingLegsCols.legOrder} IN (1, 2)),
      ${BookingLegsCols.transferPointEn} TEXT NULL,
      ${BookingLegsCols.transferPointBn} TEXT NULL,
      ${BookingLegsCols.bufferMinutes} INTEGER NULL,
      ${BookingLegsCols.demoTrackingStage} TEXT NULL,
      ${BookingLegsCols.demoDelayMinutes} INTEGER NOT NULL DEFAULT 0 CHECK(${BookingLegsCols.demoDelayMinutes} >= 0),
      UNIQUE(${BookingLegsCols.bookingId}, ${BookingLegsCols.legOrder}),
      UNIQUE(${BookingLegsCols.id}, ${BookingLegsCols.bookingId}, ${BookingLegsCols.legOrder}),
      UNIQUE(${BookingLegsCols.id}, ${BookingLegsCols.bookingId}, ${BookingLegsCols.tripId})
    )
    ''',

    // 11. booking_passengers
    '''
    CREATE TABLE ${DbTables.bookingPassengers} (
      ${BookingPassengersCols.id} TEXT NOT NULL PRIMARY KEY,
      ${BookingPassengersCols.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingsCols.id}) ON DELETE CASCADE,
      ${BookingPassengersCols.bookingLegId} TEXT NOT NULL,
      ${BookingPassengersCols.tripId} TEXT NOT NULL,
      ${BookingPassengersCols.savedPassengerId} TEXT NULL REFERENCES ${DbTables.savedPassengers}(${SavedPassengersCols.id}) ON DELETE SET NULL,
      ${BookingPassengersCols.passengerGroupIndex} INTEGER NOT NULL CHECK(${BookingPassengersCols.passengerGroupIndex} BETWEEN 1 AND 4),
      ${BookingPassengersCols.passengerName} TEXT NOT NULL,
      ${BookingPassengersCols.passengerMobile} TEXT NOT NULL,
      ${BookingPassengersCols.passengerEmail} TEXT NULL,
      ${BookingPassengersCols.seatId} TEXT NOT NULL,
      ${BookingPassengersCols.seatNumberSnapshot} TEXT NOT NULL,
      FOREIGN KEY (${BookingPassengersCols.bookingLegId}, ${BookingPassengersCols.bookingId}, ${BookingPassengersCols.tripId})
        REFERENCES ${DbTables.bookingLegs}(${BookingLegsCols.id}, ${BookingLegsCols.bookingId}, ${BookingLegsCols.tripId}) ON DELETE CASCADE,
      FOREIGN KEY (${BookingPassengersCols.seatId}, ${BookingPassengersCols.tripId})
        REFERENCES ${DbTables.tripSeats}(${TripSeatsCols.id}, ${TripSeatsCols.tripId}),
      UNIQUE(${BookingPassengersCols.bookingLegId}, ${BookingPassengersCols.seatId}),
      UNIQUE(${BookingPassengersCols.bookingLegId}, ${BookingPassengersCols.passengerGroupIndex}),
      UNIQUE(${BookingPassengersCols.id}, ${BookingPassengersCols.bookingId}, ${BookingPassengersCols.bookingLegId}, ${BookingPassengersCols.passengerGroupIndex})
    )
    ''',

    // 12. demo_payments
    '''
    CREATE TABLE ${DbTables.demoPayments} (
      ${DemoPaymentsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${DemoPaymentsCols.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingsCols.id}) ON DELETE CASCADE,
      ${DemoPaymentsCols.idempotencyKey} TEXT NOT NULL UNIQUE,
      ${DemoPaymentsCols.method} TEXT NOT NULL CHECK(${DemoPaymentsCols.method} IN ('mobile_banking', 'card', 'cash_demo')),
      ${DemoPaymentsCols.status} TEXT NOT NULL CHECK(${DemoPaymentsCols.status} IN ('pending', 'success', 'failed', 'cancelled')),
      ${DemoPaymentsCols.amountMinor} INTEGER NOT NULL CHECK(${DemoPaymentsCols.amountMinor} >= 0),
      ${DemoPaymentsCols.createdAt} INTEGER NOT NULL,
      ${DemoPaymentsCols.completedAt} INTEGER NULL
    )
    ''',
    '''
    CREATE UNIQUE INDEX ${DbIndexes.demoPaymentsSuccessBooking}
      ON ${DbTables.demoPayments}(${DemoPaymentsCols.bookingId})
      WHERE ${DemoPaymentsCols.status} = 'success'
    ''',

    // 13. tickets
    '''
    CREATE TABLE ${DbTables.tickets} (
      ${TicketsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketsCols.ticketNumber} TEXT NOT NULL UNIQUE,
      ${TicketsCols.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingsCols.id}) ON DELETE CASCADE,
      ${TicketsCols.passengerGroupIndex} INTEGER NOT NULL CHECK(${TicketsCols.passengerGroupIndex} BETWEEN 1 AND 4),
      ${TicketsCols.ownerUserId} TEXT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TicketsCols.holderName} TEXT NOT NULL,
      ${TicketsCols.holderMobile} TEXT NOT NULL,
      ${TicketsCols.holderEmail} TEXT NULL,
      ${TicketsCols.originalTicketPriceMinor} INTEGER NOT NULL CHECK(${TicketsCols.originalTicketPriceMinor} >= 0),
      ${TicketsCols.status} TEXT NOT NULL CHECK(${TicketsCols.status} IN ('issued', 'used', 'partially_used', 'expired', 'revoked_exchanged', 'cancelled', 'invalidated')),
      ${TicketsCols.issuedAt} INTEGER NOT NULL,
      UNIQUE(${TicketsCols.id}, ${TicketsCols.bookingId}),
      UNIQUE(${TicketsCols.id}, ${TicketsCols.bookingId}, ${TicketsCols.passengerGroupIndex})
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.ticketsNumber}
      ON ${DbTables.tickets}(${TicketsCols.ticketNumber})
    ''',
    '''
    CREATE INDEX ${DbIndexes.ticketsOwnerIssued}
      ON ${DbTables.tickets}(${TicketsCols.ownerUserId}, ${TicketsCols.issuedAt} DESC)
    ''',
    '''
    CREATE UNIQUE INDEX ${DbIndexes.activeTicketPerBookingPassenger}
      ON ${DbTables.tickets}(${TicketsCols.bookingId}, ${TicketsCols.passengerGroupIndex})
      WHERE ${TicketsCols.status} IN ('issued', 'used', 'partially_used', 'expired')
    ''',

    // 14. ticket_legs
    '''
    CREATE TABLE ${DbTables.ticketLegs} (
      ${TicketLegsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketLegsCols.ticketId} TEXT NOT NULL,
      ${TicketLegsCols.bookingId} TEXT NOT NULL,
      ${TicketLegsCols.bookingLegId} TEXT NOT NULL,
      ${TicketLegsCols.legOrder} INTEGER NOT NULL CHECK(${TicketLegsCols.legOrder} IN (1, 2)),
      ${TicketLegsCols.bookingPassengerId} TEXT NOT NULL,
      ${TicketLegsCols.passengerGroupIndex} INTEGER NOT NULL CHECK(${TicketLegsCols.passengerGroupIndex} BETWEEN 1 AND 4),
      ${TicketLegsCols.boardingStatus} TEXT NOT NULL DEFAULT 'pending' CHECK(${TicketLegsCols.boardingStatus} IN ('pending', 'boarded', 'missed', 'cancelled', 'invalidated')),
      ${TicketLegsCols.validatedAt} INTEGER NULL,
      ${TicketLegsCols.missedAt} INTEGER NULL,
      ${TicketLegsCols.validatedByDemoContext} TEXT NULL,
      FOREIGN KEY (${TicketLegsCols.ticketId}, ${TicketLegsCols.bookingId}, ${TicketLegsCols.passengerGroupIndex})
        REFERENCES ${DbTables.tickets}(${TicketsCols.id}, ${TicketsCols.bookingId}, ${TicketsCols.passengerGroupIndex}) ON DELETE CASCADE,
      FOREIGN KEY (${TicketLegsCols.bookingLegId}, ${TicketLegsCols.bookingId}, ${TicketLegsCols.legOrder})
        REFERENCES ${DbTables.bookingLegs}(${BookingLegsCols.id}, ${BookingLegsCols.bookingId}, ${BookingLegsCols.legOrder}) ON DELETE CASCADE,
      FOREIGN KEY (${TicketLegsCols.bookingPassengerId}, ${TicketLegsCols.bookingId}, ${TicketLegsCols.bookingLegId}, ${TicketLegsCols.passengerGroupIndex})
        REFERENCES ${DbTables.bookingPassengers}(${BookingPassengersCols.id}, ${BookingPassengersCols.bookingId}, ${BookingPassengersCols.bookingLegId}, ${BookingPassengersCols.passengerGroupIndex}) ON DELETE CASCADE,
      UNIQUE(${TicketLegsCols.ticketId}, ${TicketLegsCols.bookingLegId}),
      UNIQUE(${TicketLegsCols.ticketId}, ${TicketLegsCols.legOrder}),
      CHECK((${TicketLegsCols.boardingStatus} != 'boarded') OR (${TicketLegsCols.validatedAt} IS NOT NULL)),
      CHECK((${TicketLegsCols.boardingStatus} != 'missed') OR (${TicketLegsCols.missedAt} IS NOT NULL)),
      CHECK((${TicketLegsCols.boardingStatus} = 'missed') OR (${TicketLegsCols.missedAt} IS NULL))
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.ticketLegsTicket}
      ON ${DbTables.ticketLegs}(${TicketLegsCols.ticketId}, ${TicketLegsCols.legOrder})
    ''',
    '''
    CREATE INDEX ${DbIndexes.ticketLegsLegStatus}
      ON ${DbTables.ticketLegs}(${TicketLegsCols.bookingLegId}, ${TicketLegsCols.boardingStatus})
    ''',
    '''
    CREATE UNIQUE INDEX ${DbIndexes.activeTicketLegPassenger}
      ON ${DbTables.ticketLegs}(${TicketLegsCols.bookingLegId}, ${TicketLegsCols.bookingPassengerId})
      WHERE ${TicketLegsCols.boardingStatus} != 'invalidated'
    ''',

    // 15. ticket_qr_tokens
    '''
    CREATE TABLE ${DbTables.ticketQrTokens} (
      ${TicketQrTokensCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketQrTokensCols.ticketId} TEXT NOT NULL REFERENCES ${DbTables.tickets}(${TicketsCols.id}) ON DELETE CASCADE,
      ${TicketQrTokensCols.tokenHash} TEXT NOT NULL UNIQUE,
      ${TicketQrTokensCols.status} TEXT NOT NULL CHECK(${TicketQrTokensCols.status} IN ('active', 'revoked')),
      ${TicketQrTokensCols.createdAt} INTEGER NOT NULL,
      ${TicketQrTokensCols.revokedAt} INTEGER NULL
    )
    ''',
    '''
    CREATE UNIQUE INDEX ${DbIndexes.activeQrPerTicket}
      ON ${DbTables.ticketQrTokens}(${TicketQrTokensCols.ticketId})
      WHERE ${TicketQrTokensCols.status} = 'active'
    ''',

    // 16. ticket_cancellations
    '''
    CREATE TABLE ${DbTables.ticketCancellations} (
      ${TicketCancellationsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketCancellationsCols.bookingId} TEXT NOT NULL REFERENCES ${DbTables.bookings}(${BookingsCols.id}) ON DELETE CASCADE,
      ${TicketCancellationsCols.ticketId} TEXT NOT NULL UNIQUE,
      ${TicketCancellationsCols.cancelledByUserId} TEXT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TicketCancellationsCols.reason} TEXT NULL,
      ${TicketCancellationsCols.refundPercentage} INTEGER NOT NULL CHECK(${TicketCancellationsCols.refundPercentage} IN (0, 75, 100)),
      ${TicketCancellationsCols.refundAmountMinor} INTEGER NOT NULL CHECK(${TicketCancellationsCols.refundAmountMinor} >= 0),
      ${TicketCancellationsCols.refundStatus} TEXT NOT NULL CHECK(${TicketCancellationsCols.refundStatus} IN ('refund_pending_demo', 'refund_completed_demo', 'no_refund_applicable')),
      ${TicketCancellationsCols.cancelledAt} INTEGER NOT NULL,
      FOREIGN KEY (${TicketCancellationsCols.ticketId}, ${TicketCancellationsCols.bookingId})
        REFERENCES ${DbTables.tickets}(${TicketsCols.id}, ${TicketsCols.bookingId}) ON DELETE CASCADE
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.ticketCancellationsBooking}
      ON ${DbTables.ticketCancellations}(${TicketCancellationsCols.bookingId}, ${TicketCancellationsCols.cancelledAt} DESC)
    ''',

    // 17. ticket_exchange_requests
    '''
    CREATE TABLE ${DbTables.ticketExchangeRequests} (
      ${TicketExchangeRequestsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketExchangeRequestsCols.ticketId} TEXT NOT NULL REFERENCES ${DbTables.tickets}(${TicketsCols.id}),
      ${TicketExchangeRequestsCols.senderUserId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TicketExchangeRequestsCols.receiverUserId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TicketExchangeRequestsCols.receiverNameSnapshot} TEXT NOT NULL,
      ${TicketExchangeRequestsCols.receiverMobileSnapshot} TEXT NOT NULL,
      ${TicketExchangeRequestsCols.optionalMessage} TEXT NULL,
      ${TicketExchangeRequestsCols.status} TEXT NOT NULL CHECK(${TicketExchangeRequestsCols.status} IN ('pending', 'approved', 'rejected', 'cancelled', 'declined', 'completed')),
      ${TicketExchangeRequestsCols.createdAt} INTEGER NOT NULL,
      ${TicketExchangeRequestsCols.updatedAt} INTEGER NOT NULL,
      CHECK(${TicketExchangeRequestsCols.senderUserId} != ${TicketExchangeRequestsCols.receiverUserId})
    )
    ''',
    '''
    CREATE UNIQUE INDEX ${DbIndexes.activeExchangePerTicket}
      ON ${DbTables.ticketExchangeRequests}(${TicketExchangeRequestsCols.ticketId})
      WHERE ${TicketExchangeRequestsCols.status} IN ('pending', 'approved')
    ''',

    // 18. ticket_exchange_history
    '''
    CREATE TABLE ${DbTables.ticketExchangeHistory} (
      ${TicketExchangeHistoryCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketExchangeHistoryCols.requestId} TEXT NOT NULL UNIQUE REFERENCES ${DbTables.ticketExchangeRequests}(${TicketExchangeRequestsCols.id}),
      ${TicketExchangeHistoryCols.oldTicketId} TEXT NOT NULL UNIQUE REFERENCES ${DbTables.tickets}(${TicketsCols.id}),
      ${TicketExchangeHistoryCols.newTicketId} TEXT NOT NULL UNIQUE REFERENCES ${DbTables.tickets}(${TicketsCols.id}),
      ${TicketExchangeHistoryCols.previousOwnerId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TicketExchangeHistoryCols.newOwnerId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UsersCols.id}),
      ${TicketExchangeHistoryCols.completedAt} INTEGER NOT NULL
    )
    ''',

    // 19. ticket_revenue_splits
    '''
    CREATE TABLE ${DbTables.ticketRevenueSplits} (
      ${TicketRevenueSplitsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${TicketRevenueSplitsCols.requestId} TEXT NOT NULL UNIQUE REFERENCES ${DbTables.ticketExchangeRequests}(${TicketExchangeRequestsCols.id}),
      ${TicketRevenueSplitsCols.originalTicketPriceMinor} INTEGER NOT NULL CHECK(${TicketRevenueSplitsCols.originalTicketPriceMinor} >= 0),
      ${TicketRevenueSplitsCols.operatorShareMinor} INTEGER NOT NULL CHECK(${TicketRevenueSplitsCols.operatorShareMinor} >= 0),
      ${TicketRevenueSplitsCols.exchangerShareMinor} INTEGER NOT NULL CHECK(${TicketRevenueSplitsCols.exchangerShareMinor} >= 0),
      ${TicketRevenueSplitsCols.platformShareMinor} INTEGER NOT NULL CHECK(${TicketRevenueSplitsCols.platformShareMinor} >= 0),
      ${TicketRevenueSplitsCols.createdAt} INTEGER NOT NULL,
      CHECK(${TicketRevenueSplitsCols.operatorShareMinor} + ${TicketRevenueSplitsCols.exchangerShareMinor} + ${TicketRevenueSplitsCols.platformShareMinor} = ${TicketRevenueSplitsCols.originalTicketPriceMinor})
    )
    ''',

    // 20. notifications
    '''
    CREATE TABLE ${DbTables.notifications} (
      ${NotificationsCols.id} TEXT NOT NULL PRIMARY KEY,
      ${NotificationsCols.userId} TEXT NOT NULL REFERENCES ${DbTables.users}(${UsersCols.id}) ON DELETE CASCADE,
      ${NotificationsCols.titleEn} TEXT NOT NULL,
      ${NotificationsCols.titleBn} TEXT NOT NULL,
      ${NotificationsCols.messageEn} TEXT NOT NULL,
      ${NotificationsCols.messageBn} TEXT NOT NULL,
      ${NotificationsCols.category} TEXT NOT NULL CHECK(${NotificationsCols.category} IN ('booking', 'payment', 'reminder', 'delay', 'cancellation', 'exchange')),
      ${NotificationsCols.isRead} INTEGER NOT NULL DEFAULT 0 CHECK(${NotificationsCols.isRead} IN (0, 1)),
      ${NotificationsCols.relatedRecordType} TEXT NULL,
      ${NotificationsCols.relatedRecordId} TEXT NULL,
      ${NotificationsCols.createdAt} INTEGER NOT NULL
    )
    ''',
    '''
    CREATE INDEX ${DbIndexes.notificationsUserReadCreated}
      ON ${DbTables.notifications}(${NotificationsCols.userId}, ${NotificationsCols.isRead}, ${NotificationsCols.createdAt} DESC)
    ''',
  ];
}
