import 'package:jatra_nova/core/database/db_tables.dart';
import 'package:sqflite/sqflite.dart';

/// Idempotent database seed helper for deterministic local reference data.
///
/// Essential reference data (`stops`, `routes`, `connection_rules`) is kept
/// strictly separated from optional demo catalog data (`bus_operators`, `trips`,
/// `trip_seats`). User accounts (`users`, pending Phase 3 `PD-T06` credential
/// hashing), bookings, payments, tickets, QR tokens, and exchange records are
/// intentionally omitted in Phase 2.
abstract final class SeedData {
  /// Seeds essential reference data and optional demo catalog data on an active
  /// [DatabaseExecutor] (for example inside `onCreate` or an explicit
  /// transaction).
  static Future<void> seed(
    DatabaseExecutor executor, {
    int? nowUtcMs,
    bool includeDemoCatalog = true,
  }) async {
    final anchorUtcMs =
        nowUtcMs ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    await seedReferenceData(executor);
    if (includeDemoCatalog) {
      await seedDemoCatalog(executor, nowUtcMs: anchorUtcMs);
    }
  }

  /// Transactional entrypoint for re-running idempotent seeding outside
  /// `onCreate`.
  static Future<void> seedInTransaction(
    Database db, {
    int? nowUtcMs,
    bool includeDemoCatalog = true,
  }) {
    return db.transaction(
      (txn) => seed(
        txn,
        nowUtcMs: nowUtcMs,
        includeDemoCatalog: includeDemoCatalog,
      ),
    );
  }

  /// Essential reference data: normalized Bangladesh stops, point-to-point
  /// routes, and Rangpur connecting transfer rules from `AGENTS.md`.
  static Future<void> seedReferenceData(DatabaseExecutor db) async {
    for (final stop in _referenceStops) {
      await db.insert(
        DbTables.stops,
        stop,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final route in _referenceRoutes) {
      await db.insert(
        DbTables.routes,
        route,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    for (final rule in _referenceConnectionRules) {
      await db.insert(
        DbTables.connectionRules,
        rule,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// Optional clearly labelled demo catalog data (`bus_operators`, 7-day
  /// relative `trips`, and matching `trip_seats` inventory).
  static Future<void> seedDemoCatalog(
    DatabaseExecutor db, {
    required int nowUtcMs,
  }) async {
    for (final op in _demoOperators(nowUtcMs)) {
      await db.insert(
        DbTables.busOperators,
        op,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    final existingTrips = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM ${DbTables.trips}',
    );
    final tripCount = Sqflite.firstIntValue(existingTrips) ?? 0;
    if (tripCount > 0) {
      return;
    }

    final baseDayStart = _utcStartOfNextDayMs(nowUtcMs);
    const int seatsPerTrip = 16;

    for (var day = 0; day < 7; day++) {
      final dayMs = baseDayStart + Duration(days: day).inMilliseconds;
      final dayTrips = _buildDemoTripsForDay(day: day, dayStartUtcMs: dayMs, totalSeats: seatsPerTrip);
      for (final trip in dayTrips) {
        await db.insert(
          DbTables.trips,
          trip,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        final tripId = trip[TripsCols.id]! as String;
        for (var seatIndex = 0; seatIndex < seatsPerTrip; seatIndex++) {
          final seatCode = _seatCodeForIndex(seatIndex);
          final isBlockedSeat = seatIndex == 0;
          await db.insert(
            DbTables.tripSeats,
            <String, Object?>{
              TripSeatsCols.id: '${tripId}_seat_$seatCode',
              TripSeatsCols.tripId: tripId,
              TripSeatsCols.seatNumber: seatCode,
              TripSeatsCols.seatClass: 'standard',
              TripSeatsCols.status: isBlockedSeat ? 'blocked' : 'available',
              TripSeatsCols.holdUserId: null,
              TripSeatsCols.holdSessionId: null,
              TripSeatsCols.holdExpiry: null,
              TripSeatsCols.bookingId: null,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
  }

  static int _utcStartOfNextDayMs(int nowUtcMs) {
    final now = DateTime.fromMillisecondsSinceEpoch(nowUtcMs, isUtc: true);
    final nextDay = DateTime.utc(now.year, now.month, now.day + 1);
    return nextDay.millisecondsSinceEpoch;
  }

  static String _seatCodeForIndex(int index) {
    const columns = <String>['A', 'B', 'C', 'D'];
    final row = (index ~/ 4) + 1;
    final col = columns[index % 4];
    return '$col$row';
  }

  static const String _opDemoExpressId = 'op_demo_jatranova';
  static const String _opDemoPadmaId = 'op_demo_padma';

  static const String _stopDhaka = 'stop_dac';
  static const String _stopRajshahi = 'stop_rjh';
  static const String _stopSylhet = 'stop_zyl';
  static const String _stopChattogram = 'stop_cgp';
  static const String _stopRangpur = 'stop_rnp';
  static const String _stopBogura = 'stop_bgr';

  static const String _routeDacRjh = 'route_dac_rjh';
  static const String _routeDacZyl = 'route_dac_zyl';
  static const String _routeDacCgp = 'route_dac_cgp';
  static const String _routeDacRnp = 'route_dac_rnp';
  static const String _routeRnpBgr = 'route_rnp_bgr';

  static const List<Map<String, Object?>> _referenceStops =
      <Map<String, Object?>>[
    <String, Object?>{
      StopsCols.id: _stopDhaka,
      StopsCols.cityCode: 'DAC',
      StopsCols.nameEn: 'Dhaka',
      StopsCols.nameBn: 'ঢাকা',
      StopsCols.isPopular: 1,
      StopsCols.isTransferHub: 0,
    },
    <String, Object?>{
      StopsCols.id: _stopRajshahi,
      StopsCols.cityCode: 'RJH',
      StopsCols.nameEn: 'Rajshahi',
      StopsCols.nameBn: 'রাজশাহী',
      StopsCols.isPopular: 1,
      StopsCols.isTransferHub: 0,
    },
    <String, Object?>{
      StopsCols.id: _stopSylhet,
      StopsCols.cityCode: 'ZYL',
      StopsCols.nameEn: 'Sylhet',
      StopsCols.nameBn: 'সিলেট',
      StopsCols.isPopular: 1,
      StopsCols.isTransferHub: 0,
    },
    <String, Object?>{
      StopsCols.id: _stopChattogram,
      StopsCols.cityCode: 'CGP',
      StopsCols.nameEn: 'Chattogram',
      StopsCols.nameBn: 'চট্টগ্রাম',
      StopsCols.isPopular: 1,
      StopsCols.isTransferHub: 0,
    },
    <String, Object?>{
      StopsCols.id: _stopRangpur,
      StopsCols.cityCode: 'RNP',
      StopsCols.nameEn: 'Rangpur',
      StopsCols.nameBn: 'রংপুর',
      StopsCols.isPopular: 0,
      StopsCols.isTransferHub: 1,
    },
    <String, Object?>{
      StopsCols.id: _stopBogura,
      StopsCols.cityCode: 'BGR',
      StopsCols.nameEn: 'Bogura',
      StopsCols.nameBn: 'বগুড়া',
      StopsCols.isPopular: 0,
      StopsCols.isTransferHub: 0,
    },
  ];

  static const List<Map<String, Object?>> _referenceRoutes =
      <Map<String, Object?>>[
    <String, Object?>{
      RoutesCols.id: _routeDacRjh,
      RoutesCols.originStopId: _stopDhaka,
      RoutesCols.destinationStopId: _stopRajshahi,
      RoutesCols.nameEn: 'Dhaka - Rajshahi',
      RoutesCols.nameBn: 'ঢাকা - রাজশাহী',
      RoutesCols.isPopular: 1,
    },
    <String, Object?>{
      RoutesCols.id: _routeDacZyl,
      RoutesCols.originStopId: _stopDhaka,
      RoutesCols.destinationStopId: _stopSylhet,
      RoutesCols.nameEn: 'Dhaka - Sylhet',
      RoutesCols.nameBn: 'ঢাকা - সিলেট',
      RoutesCols.isPopular: 1,
    },
    <String, Object?>{
      RoutesCols.id: _routeDacCgp,
      RoutesCols.originStopId: _stopDhaka,
      RoutesCols.destinationStopId: _stopChattogram,
      RoutesCols.nameEn: 'Dhaka - Chattogram',
      RoutesCols.nameBn: 'ঢাকা - চট্টগ্রাম',
      RoutesCols.isPopular: 1,
    },
    <String, Object?>{
      RoutesCols.id: _routeDacRnp,
      RoutesCols.originStopId: _stopDhaka,
      RoutesCols.destinationStopId: _stopRangpur,
      RoutesCols.nameEn: 'Dhaka - Rangpur',
      RoutesCols.nameBn: 'ঢাকা - রংপুর',
      RoutesCols.isPopular: 0,
    },
    <String, Object?>{
      RoutesCols.id: _routeRnpBgr,
      RoutesCols.originStopId: _stopRangpur,
      RoutesCols.destinationStopId: _stopBogura,
      RoutesCols.nameEn: 'Rangpur - Bogura',
      RoutesCols.nameBn: 'রংপুর - বগুড়া',
      RoutesCols.isPopular: 0,
    },
  ];

  static const List<Map<String, Object?>> _referenceConnectionRules =
      <Map<String, Object?>>[
    <String, Object?>{
      ConnectionRulesCols.id: 'rule_rnp_default',
      ConnectionRulesCols.hubStopId: _stopRangpur,
      ConnectionRulesCols.operatorId: null,
      ConnectionRulesCols.minBufferMinutes: 30,
      ConnectionRulesCols.maxBufferMinutes: 240,
      ConnectionRulesCols.transferInstructionsEn:
          'Disembark at Rangpur Demo Hub Terminal and board your connecting same-operator coach at Bay 2.',
      ConnectionRulesCols.transferInstructionsBn:
          'রংপুর ডেমো হাব টার্মিনালে নেমে একই অপারেটরের সংযোগ বাসে বে-২ থেকে উঠুন।',
      ConnectionRulesCols.isActive: 1,
    },
  ];

  static List<Map<String, Object?>> _demoOperators(int nowUtcMs) =>
      <Map<String, Object?>>[
        <String, Object?>{
          BusOperatorsCols.id: _opDemoExpressId,
          BusOperatorsCols.nameEn: 'JatraNova Demo Coach',
          BusOperatorsCols.nameBn: 'যাত্রানোভা ডেমো কোচ',
          BusOperatorsCols.logoPath: null,
          BusOperatorsCols.isVerified: 1,
          BusOperatorsCols.allowsExchange: 1,
          BusOperatorsCols.exchangeCutoffMinutes: 120,
          BusOperatorsCols.cancellationPolicyJson:
              '{"gte_24h":100,"gte_6h":75,"lt_6h":0}',
          BusOperatorsCols.createdAt: nowUtcMs,
        },
        <String, Object?>{
          BusOperatorsCols.id: _opDemoPadmaId,
          BusOperatorsCols.nameEn: 'Padma Demo Line',
          BusOperatorsCols.nameBn: 'পদ্মা ডেমো লাইন',
          BusOperatorsCols.logoPath: null,
          BusOperatorsCols.isVerified: 1,
          BusOperatorsCols.allowsExchange: 1,
          BusOperatorsCols.exchangeCutoffMinutes: 120,
          BusOperatorsCols.cancellationPolicyJson:
              '{"gte_24h":100,"gte_6h":75,"lt_6h":0}',
          BusOperatorsCols.createdAt: nowUtcMs,
        },
      ];

  static List<Map<String, Object?>> _buildDemoTripsForDay({
    required int day,
    required int dayStartUtcMs,
    required int totalSeats,
  }) {
    int atHour(int h, [int m = 0]) =>
        dayStartUtcMs + Duration(hours: h, minutes: m).inMilliseconds;

    return <Map<String, Object?>>[
      <String, Object?>{
        TripsCols.id: 'trip_dac_rjh_d$day',
        TripsCols.operatorId: _opDemoExpressId,
        TripsCols.routeId: _routeDacRjh,
        TripsCols.originStopId: _stopDhaka,
        TripsCols.destinationStopId: _stopRajshahi,
        TripsCols.busNameEn: 'Demo Express AC',
        TripsCols.busNameBn: 'ডেমো এক্সপ্রেস এসি',
        TripsCols.busType: 'ac_business',
        TripsCols.departureAt: atHour(8, 0),
        TripsCols.arrivalAt: atHour(14, 0),
        TripsCols.boardingPointEn: 'Gabtoli Demo Counter',
        TripsCols.boardingPointBn: 'গাবতলী ডেমো কাউন্টার',
        TripsCols.dropOffPointEn: 'Rajshahi Shiroil Demo Stand',
        TripsCols.dropOffPointBn: 'রাজশাহী শিরোইল ডেমো স্ট্যান্ড',
        TripsCols.facilitiesJson: '["ac","charging_point","water","reclining_seat"]',
        TripsCols.fareMinor: 100000,
        TripsCols.totalSeats: totalSeats,
        TripsCols.isPopular: 1,
        TripsCols.isActive: 1,
      },
      <String, Object?>{
        TripsCols.id: 'trip_dac_zyl_d$day',
        TripsCols.operatorId: _opDemoPadmaId,
        TripsCols.routeId: _routeDacZyl,
        TripsCols.originStopId: _stopDhaka,
        TripsCols.destinationStopId: _stopSylhet,
        TripsCols.busNameEn: 'Demo Sylhet Sleeper',
        TripsCols.busNameBn: 'ডেমো সিলেট স্লিপার',
        TripsCols.busType: 'ac_sleeper',
        TripsCols.departureAt: atHour(9, 0),
        TripsCols.arrivalAt: atHour(15, 0),
        TripsCols.boardingPointEn: 'Sayedabad Demo Counter',
        TripsCols.boardingPointBn: 'সায়েদাবাদ ডেমো কাউন্টার',
        TripsCols.dropOffPointEn: 'Kadamtali Demo Terminal',
        TripsCols.dropOffPointBn: 'কদমতলী ডেমো টার্মিনাল',
        TripsCols.facilitiesJson: '["ac","wifi","charging_point","reclining_seat"]',
        TripsCols.fareMinor: 120000,
        TripsCols.totalSeats: totalSeats,
        TripsCols.isPopular: 1,
        TripsCols.isActive: 1,
      },
      <String, Object?>{
        TripsCols.id: 'trip_dac_cgp_d$day',
        TripsCols.operatorId: _opDemoExpressId,
        TripsCols.routeId: _routeDacCgp,
        TripsCols.originStopId: _stopDhaka,
        TripsCols.destinationStopId: _stopChattogram,
        TripsCols.busNameEn: 'Demo Coastal Non-AC',
        TripsCols.busNameBn: 'ডেমো কোস্টাল নন-এসি',
        TripsCols.busType: 'non_ac',
        TripsCols.departureAt: atHour(10, 0),
        TripsCols.arrivalAt: atHour(16, 30),
        TripsCols.boardingPointEn: 'Sayedabad Demo Counter',
        TripsCols.boardingPointBn: 'সায়েদাবাদ ডেমো কাউন্টার',
        TripsCols.dropOffPointEn: 'Dampara Demo Counter',
        TripsCols.dropOffPointBn: 'দামপাড়া ডেমো কাউন্টার',
        TripsCols.facilitiesJson: '["water","reclining_seat"]',
        TripsCols.fareMinor: 75000,
        TripsCols.totalSeats: totalSeats,
        TripsCols.isPopular: 1,
        TripsCols.isActive: 1,
      },
      // Connecting pair (Dhaka -> Rangpur -> Bogura on the same operator, 60-min transfer wait)
      <String, Object?>{
        TripsCols.id: 'trip_dac_rnp_d$day',
        TripsCols.operatorId: _opDemoExpressId,
        TripsCols.routeId: _routeDacRnp,
        TripsCols.originStopId: _stopDhaka,
        TripsCols.destinationStopId: _stopRangpur,
        TripsCols.busNameEn: 'Demo Northbound Leg 1',
        TripsCols.busNameBn: 'ডেমো নর্থবাউন্ড লেগ ১',
        TripsCols.busType: 'ac_business',
        TripsCols.departureAt: atHour(7, 0),
        TripsCols.arrivalAt: atHour(13, 0),
        TripsCols.boardingPointEn: 'Kallyanpur Demo Counter',
        TripsCols.boardingPointBn: 'কল্যাণপুর ডেমো কাউন্টার',
        TripsCols.dropOffPointEn: 'Rangpur Demo Hub Terminal',
        TripsCols.dropOffPointBn: 'রংপুর ডেমো হাব টার্মিনাল',
        TripsCols.facilitiesJson: '["ac","charging_point","water"]',
        TripsCols.fareMinor: 95000,
        TripsCols.totalSeats: totalSeats,
        TripsCols.isPopular: 0,
        TripsCols.isActive: 1,
      },
      <String, Object?>{
        TripsCols.id: 'trip_rnp_bgr_d$day',
        TripsCols.operatorId: _opDemoExpressId,
        TripsCols.routeId: _routeRnpBgr,
        TripsCols.originStopId: _stopRangpur,
        TripsCols.destinationStopId: _stopBogura,
        TripsCols.busNameEn: 'Demo Hub Shuttle Leg 2',
        TripsCols.busNameBn: 'ডেমো হাব শাটল লেগ ২',
        TripsCols.busType: 'ac_business',
        TripsCols.departureAt: atHour(14, 0),
        TripsCols.arrivalAt: atHour(16, 30),
        TripsCols.boardingPointEn: 'Rangpur Demo Hub Terminal (Bay 2)',
        TripsCols.boardingPointBn: 'রংপুর ডেমো হাব টার্মিনাল (বে-২)',
        TripsCols.dropOffPointEn: 'Satmatha Demo Stand',
        TripsCols.dropOffPointBn: 'সাতমাথা ডেমো স্ট্যান্ড',
        TripsCols.facilitiesJson: '["ac","water"]',
        TripsCols.fareMinor: 40000,
        TripsCols.totalSeats: totalSeats,
        TripsCols.isPopular: 0,
        TripsCols.isActive: 1,
      },
    ];
  }
}
