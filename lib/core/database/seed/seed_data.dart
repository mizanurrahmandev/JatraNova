import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import '../db_tables.dart';

class SeedData {
  SeedData._();

  static String hashPassword(String password) {
    const salt = 'jatranova_salt_2026';
    final bytes = utf8.encode('$salt$password');
    return sha256.convert(bytes).toString();
  }

  static Future<void> insertSeedData(Database db) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final commonPasswordHash = hashPassword('password123');

    // 1. Users
    await db.insert(DbTables.users, {
      UserColumns.id: 'user_rahim',
      UserColumns.fullName: 'Rahim Ahmed',
      UserColumns.mobile: '01712345678',
      UserColumns.email: 'rahim@demo.com',
      UserColumns.passwordHash: commonPasswordHash,
      UserColumns.avatarPath: null,
      UserColumns.isActive: 1,
      UserColumns.createdAt: nowMs,
      UserColumns.updatedAt: nowMs,
    });

    await db.insert(DbTables.users, {
      UserColumns.id: 'user_karim',
      UserColumns.fullName: 'Karim Hasan',
      UserColumns.mobile: '01812345678',
      UserColumns.email: 'karim@demo.com',
      UserColumns.passwordHash: commonPasswordHash,
      UserColumns.avatarPath: null,
      UserColumns.isActive: 1,
      UserColumns.createdAt: nowMs,
      UserColumns.updatedAt: nowMs,
    });

    // 2. Locations
    final locations = [
      {'id': 'loc_dhaka', 'name_en': 'Dhaka', 'name_bn': 'ঢাকা', 'code': 'DAC'},
      {'id': 'loc_chattogram', 'name_en': 'Chattogram', 'name_bn': 'চট্টগ্রাম', 'code': 'CTG'},
      {'id': 'loc_rajshahi', 'name_en': 'Rajshahi', 'name_bn': 'রাজশাহী', 'code': 'RAJ'},
      {'id': 'loc_rangpur', 'name_en': 'Rangpur', 'name_bn': 'রংপুর', 'code': 'RNG'},
      {'id': 'loc_sylhet', 'name_en': 'Sylhet', 'name_bn': 'সিলেট', 'code': 'SYL'},
      {'id': 'loc_bogura', 'name_en': 'Bogura', 'name_bn': 'বগুড়া', 'code': 'BOG'},
    ];

    for (final loc in locations) {
      await db.insert(DbTables.locations, {
        LocationColumns.id: loc['id'],
        LocationColumns.nameEn: loc['name_en'],
        LocationColumns.nameBn: loc['name_bn'],
        LocationColumns.code: loc['code'],
        LocationColumns.isActive: 1,
      });
    }

    // 3. Bus Operators
    final operators = [
      {
        'id': 'op_greenline',
        'name_en': 'Green Line Paribahan',
        'name_bn': 'গ্রীন লাইন পরিবহন',
        'logo_asset': 'assets/images/operators/greenline.png',
        'is_handover_allowed': 1,
        'handover_commission_pct': 30,
      },
      {
        'id': 'op_shohagh',
        'name_en': 'Shohagh Paribahan',
        'name_bn': 'সোহাগ পরিবহন',
        'logo_asset': 'assets/images/operators/shohagh.png',
        'is_handover_allowed': 1,
        'handover_commission_pct': 30,
      },
      {
        'id': 'op_desh',
        'name_en': 'Desh Travels',
        'name_bn': 'দেশ ট্রাভেলস',
        'logo_asset': 'assets/images/operators/desh.png',
        'is_handover_allowed': 1,
        'handover_commission_pct': 30,
      },
    ];

    for (final op in operators) {
      await db.insert(DbTables.operators, {
        OperatorColumns.id: op['id'],
        OperatorColumns.nameEn: op['name_en'],
        OperatorColumns.nameBn: op['name_bn'],
        OperatorColumns.logoAsset: op['logo_asset'],
        OperatorColumns.isHandoverAllowed: op['is_handover_allowed'],
        OperatorColumns.handoverCommissionPct: op['handover_commission_pct'],
      });
    }

    // 4. Cancellation Policies & Rules
    await db.insert(DbTables.cancellationPolicies, {
      CancellationPolicyColumns.id: 'policy_standard',
      CancellationPolicyColumns.operatorId: 'op_greenline',
      CancellationPolicyColumns.policyName: 'Standard Cancellation Policy',
    });

    await db.insert(DbTables.cancellationRules, {
      CancellationRuleColumns.id: 'rule_1',
      CancellationRuleColumns.policyId: 'policy_standard',
      CancellationRuleColumns.minHoursBeforeDeparture: 6,
      CancellationRuleColumns.refundPercent: 90,
    });

    await db.insert(DbTables.cancellationRules, {
      CancellationRuleColumns.id: 'rule_2',
      CancellationRuleColumns.policyId: 'policy_standard',
      CancellationRuleColumns.minHoursBeforeDeparture: 2,
      CancellationRuleColumns.refundPercent: 70,
    });

    await db.insert(DbTables.cancellationRules, {
      CancellationRuleColumns.id: 'rule_3',
      CancellationRuleColumns.policyId: 'policy_standard',
      CancellationRuleColumns.minHoursBeforeDeparture: 0,
      CancellationRuleColumns.refundPercent: 0,
    });

    // 5. Connection Rules (Same-Operator Hub Rules)
    await db.insert(DbTables.connectionRules, {
      ConnectionRuleColumns.id: 'conn_rule_gl_raj',
      ConnectionRuleColumns.operatorId: 'op_greenline',
      ConnectionRuleColumns.transferHubLocationId: 'loc_rajshahi',
      ConnectionRuleColumns.minBufferMinutes: 45,
      ConnectionRuleColumns.maxWaitMinutes: 180,
      ConnectionRuleColumns.isActive: 1,
    });

    await db.insert(DbTables.connectionRules, {
      ConnectionRuleColumns.id: 'conn_rule_sh_raj',
      ConnectionRuleColumns.operatorId: 'op_shohagh',
      ConnectionRuleColumns.transferHubLocationId: 'loc_rajshahi',
      ConnectionRuleColumns.minBufferMinutes: 45,
      ConnectionRuleColumns.maxWaitMinutes: 180,
      ConnectionRuleColumns.isActive: 1,
    });

    // 6. Buses
    final buses = [
      {
        'id': 'bus_gl_01',
        'operator_id': 'op_greenline',
        'bus_name': 'Green Line Scania Multi-Axle',
        'bus_type': 'Executive Class',
        'seat_layout_code': '2x2',
        'ac_type': 'AC',
        'facilities_json': jsonEncode(['AC', 'WiFi', 'Charging Port', 'Reclining Seat']),
        'total_seats': 36,
      },
      {
        'id': 'bus_gl_02',
        'operator_id': 'op_greenline',
        'bus_name': 'Green Line Comfort Coach',
        'bus_type': 'Business Class',
        'seat_layout_code': '2x2',
        'ac_type': 'AC',
        'facilities_json': jsonEncode(['AC', 'Water', 'Reclining Seat']),
        'total_seats': 36,
      },
      {
        'id': 'bus_sh_01',
        'operator_id': 'op_shohagh',
        'bus_name': 'Shohagh Hyundai Universe',
        'bus_type': 'Premium Coach',
        'seat_layout_code': '2x2',
        'ac_type': 'AC',
        'facilities_json': jsonEncode(['AC', 'WiFi', 'Water']),
        'total_seats': 36,
      },
      {
        'id': 'bus_desh_01',
        'operator_id': 'op_desh',
        'bus_name': 'Desh Travels Classic',
        'bus_type': 'Economy Coach',
        'seat_layout_code': '2x2',
        'ac_type': 'Non-AC',
        'facilities_json': jsonEncode(['Charging Port']),
        'total_seats': 40,
      },
    ];

    for (final bus in buses) {
      await db.insert(DbTables.buses, {
        BusColumns.id: bus['id'],
        BusColumns.operatorId: bus['operator_id'],
        BusColumns.busName: bus['bus_name'],
        BusColumns.busType: bus['bus_type'],
        BusColumns.seatLayoutCode: bus['seat_layout_code'],
        BusColumns.acType: bus['ac_type'],
        BusColumns.facilitiesJson: bus['facilities_json'],
        BusColumns.totalSeats: bus['total_seats'],
        BusColumns.isActive: 1,
      });
    }

    // 7. Dynamic Scheduled Trips for next 7 days
    final baseDate = DateTime.now().toUtc();
    final startOfToday = DateTime.utc(baseDate.year, baseDate.month, baseDate.day);

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final tripDay = startOfToday.add(Duration(days: dayOffset));

      // Trip A: Dhaka -> Chattogram (Green Line AC)
      final depA = tripDay.add(const Duration(hours: 8)).millisecondsSinceEpoch;
      final arrA = tripDay.add(const Duration(hours: 13, minutes: 30)).millisecondsSinceEpoch;
      final tripAId = 'trip_dac_ctg_gl_$dayOffset';
      await _insertTripWithSeats(
        db: db,
        tripId: tripAId,
        busId: 'bus_gl_01',
        operatorId: 'op_greenline',
        originId: 'loc_dhaka',
        destinationId: 'loc_chattogram',
        depMs: depA,
        arrMs: arrA,
        boarding: 'Gulshan Terminal',
        dropOff: 'Dampara Counter',
        fare: 1300,
        totalSeats: 36,
      );

      // Trip B: Dhaka -> Chattogram (Shohagh AC)
      final depB = tripDay.add(const Duration(hours: 9, minutes: 30)).millisecondsSinceEpoch;
      final arrB = tripDay.add(const Duration(hours: 15)).millisecondsSinceEpoch;
      final tripBId = 'trip_dac_ctg_sh_$dayOffset';
      await _insertTripWithSeats(
        db: db,
        tripId: tripBId,
        busId: 'bus_sh_01',
        operatorId: 'op_shohagh',
        originId: 'loc_dhaka',
        destinationId: 'loc_chattogram',
        depMs: depB,
        arrMs: arrB,
        boarding: 'Mohakhali Terminal',
        dropOff: 'GEC Circle Counter',
        fare: 1250,
        totalSeats: 36,
      );

      // Trip C: Dhaka -> Sylhet (Desh Non-AC)
      final depC = tripDay.add(const Duration(hours: 7)).millisecondsSinceEpoch;
      final arrC = tripDay.add(const Duration(hours: 12, minutes: 30)).millisecondsSinceEpoch;
      final tripCId = 'trip_dac_syl_desh_$dayOffset';
      await _insertTripWithSeats(
        db: db,
        tripId: tripCId,
        busId: 'bus_desh_01',
        operatorId: 'op_desh',
        originId: 'loc_dhaka',
        destinationId: 'loc_sylhet',
        depMs: depC,
        arrMs: arrC,
        boarding: 'Sayedabad Terminal',
        dropOff: 'Kadamtali Terminal',
        fare: 650,
        totalSeats: 40,
      );

      // Connecting Journey Pair on Green Line:
      // Leg 1: Dhaka -> Rajshahi (Departs 08:00, Arrives 11:30)
      final depConn1 = tripDay.add(const Duration(hours: 8)).millisecondsSinceEpoch;
      final arrConn1 = tripDay.add(const Duration(hours: 11, minutes: 30)).millisecondsSinceEpoch;
      final tripConn1Id = 'trip_dac_raj_gl_$dayOffset';
      await _insertTripWithSeats(
        db: db,
        tripId: tripConn1Id,
        busId: 'bus_gl_01',
        operatorId: 'op_greenline',
        originId: 'loc_dhaka',
        destinationId: 'loc_rajshahi',
        depMs: depConn1,
        arrMs: arrConn1,
        boarding: 'Gabtoli Terminal',
        dropOff: 'Rajshahi Bus Terminal',
        fare: 800,
        totalSeats: 36,
      );

      // Leg 2: Rajshahi -> Rangpur (Departs 12:45, Arrives 15:45)
      // Layover wait = 1 hour 15 minutes (75 minutes -> within 45-180m window!)
      final depConn2 = tripDay.add(const Duration(hours: 12, minutes: 45)).millisecondsSinceEpoch;
      final arrConn2 = tripDay.add(const Duration(hours: 15, minutes: 45)).millisecondsSinceEpoch;
      final tripConn2Id = 'trip_raj_rng_gl_$dayOffset';
      await _insertTripWithSeats(
        db: db,
        tripId: tripConn2Id,
        busId: 'bus_gl_02',
        operatorId: 'op_greenline',
        originId: 'loc_rajshahi',
        destinationId: 'loc_rangpur',
        depMs: depConn2,
        arrMs: arrConn2,
        boarding: 'Rajshahi Bus Terminal',
        dropOff: 'Rangpur Kamarpara Terminal',
        fare: 650,
        totalSeats: 36,
      );
    }

    // 8. Seed 1 confirmed booking and active ticket for Rahim on Day 2
    // So Rahim has an active ticket immediately eligible for Ticket Handover testing!
    final day2Dep = startOfToday.add(const Duration(days: 2, hours: 8)).millisecondsSinceEpoch;
    const testBookingId = 'booking_rahim_demo_01';
    const testTripId = 'trip_dac_ctg_gl_2';

    await db.insert(DbTables.bookings, {
      BookingColumns.id: testBookingId,
      BookingColumns.bookingCode: 'JN-2026-DEMO-01',
      BookingColumns.userId: 'user_rahim',
      BookingColumns.journeyType: 'direct',
      BookingColumns.bookingStatus: 'confirmed',
      BookingColumns.paymentStatus: 'success',
      BookingColumns.passengerCount: 1,
      BookingColumns.originLocationId: 'loc_dhaka',
      BookingColumns.destinationLocationId: 'loc_chattogram',
      BookingColumns.journeyDate: day2Dep,
      BookingColumns.subtotalAmount: 1300,
      BookingColumns.serviceChargeAmount: 50,
      BookingColumns.discountAmount: 0,
      BookingColumns.totalAmount: 1350,
      BookingColumns.createdAt: nowMs,
    });

    const testLegId = 'leg_rahim_demo_01';
    await db.insert(DbTables.bookingLegs, {
      BookingLegColumns.id: testLegId,
      BookingLegColumns.bookingId: testBookingId,
      BookingLegColumns.tripId: testTripId,
      BookingLegColumns.legOrder: 1,
      BookingLegColumns.transferPoint: null,
      BookingLegColumns.waitingMinutes: null,
      BookingLegColumns.legFareAmount: 1300,
    });

    const testPassengerId = 'pax_rahim_01';
    await db.insert(DbTables.passengers, {
      PassengerColumns.id: testPassengerId,
      PassengerColumns.bookingId: testBookingId,
      PassengerColumns.fullName: 'Rahim Ahmed',
      PassengerColumns.mobile: '01712345678',
      PassengerColumns.email: 'rahim@demo.com',
      PassengerColumns.passengerOrder: 1,
    });

    // Mark seat 7 as booked on trip_dac_ctg_gl_2
    await db.update(
      DbTables.seatInventory,
      {
        SeatInventoryColumns.status: 'booked',
        SeatInventoryColumns.holdUserId: null,
        SeatInventoryColumns.holdExpiry: null,
      },
      where: '${SeatInventoryColumns.tripId} = ? AND ${SeatInventoryColumns.seatNumber} = ?',
      whereArgs: [testTripId, 'A1'],
    );

    // Create active confirmed ticket for Rahim
    await db.insert(DbTables.tickets, {
      TicketColumns.id: 'ticket_rahim_demo_01',
      TicketColumns.bookingId: testBookingId,
      TicketColumns.bookingLegId: testLegId,
      TicketColumns.tripId: testTripId,
      TicketColumns.passengerId: testPassengerId,
      TicketColumns.seatNumber: 'A1',
      TicketColumns.ownerUserId: 'user_rahim',
      TicketColumns.qrToken: 'JN-TOKEN-RAHIM-DEMO-01',
      TicketColumns.originalTicketPrice: 1300,
      TicketColumns.ticketStatus: 'confirmed',
      TicketColumns.issuedAt: nowMs,
      TicketColumns.invalidatedAt: null,
    });

    // Record demo payment
    await db.insert(DbTables.demoPayments, {
      DemoPaymentColumns.id: 'payment_rahim_01',
      DemoPaymentColumns.bookingId: testBookingId,
      DemoPaymentColumns.attemptNumber: 1,
      DemoPaymentColumns.paymentMethod: 'Demo Wallet',
      DemoPaymentColumns.status: 'success',
      DemoPaymentColumns.amount: 1350,
      DemoPaymentColumns.isDemo: 1,
      DemoPaymentColumns.createdAt: nowMs,
      DemoPaymentColumns.completedAt: nowMs,
    });

    // Initial notification for Rahim
    await db.insert(DbTables.notifications, {
      NotificationColumns.id: 'notif_rahim_01',
      NotificationColumns.userId: 'user_rahim',
      NotificationColumns.title: 'Booking Confirmed!',
      NotificationColumns.message: 'Your ticket for Dhaka to Chattogram (Seat A1) is confirmed.',
      NotificationColumns.category: 'booking',
      NotificationColumns.relatedType: 'ticket',
      NotificationColumns.relatedId: 'ticket_rahim_demo_01',
      NotificationColumns.isRead: 0,
      NotificationColumns.createdAt: nowMs,
    });
  }

  static Future<void> _insertTripWithSeats({
    required Database db,
    required String tripId,
    required String busId,
    required String operatorId,
    required String originId,
    required String destinationId,
    required int depMs,
    required int arrMs,
    required String boarding,
    required String dropOff,
    required int fare,
    required int totalSeats,
  }) async {
    await db.insert(DbTables.trips, {
      TripColumns.id: tripId,
      TripColumns.busId: busId,
      TripColumns.operatorId: operatorId,
      TripColumns.routeId: null,
      TripColumns.originLocationId: originId,
      TripColumns.destinationLocationId: destinationId,
      TripColumns.departureAt: depMs,
      TripColumns.arrivalAt: arrMs,
      TripColumns.boardingPoint: boarding,
      TripColumns.dropOffPoint: dropOff,
      TripColumns.fareAmount: fare,
      TripColumns.status: 'scheduled',
    });

    // Generate seats e.g. A1, A2, A3, A4, B1, B2...
    final rowLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    int seatCount = 0;

    for (final row in rowLetters) {
      for (int col = 1; col <= 4; col++) {
        if (seatCount >= totalSeats) break;
        final seatNum = '$row$col';
        await db.insert(DbTables.seatInventory, {
          SeatInventoryColumns.tripId: tripId,
          SeatInventoryColumns.seatNumber: seatNum,
          SeatInventoryColumns.status: 'available',
          SeatInventoryColumns.holdUserId: null,
          SeatInventoryColumns.holdExpiry: null,
        });
        seatCount++;
      }
      if (seatCount >= totalSeats) break;
    }
  }
}
