import 'dart:convert';
import '../../domain/entities/trip_entity.dart';

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.busId,
    required super.operatorId,
    required super.operatorNameEn,
    required super.operatorNameBn,
    super.operatorLogo,
    required super.busName,
    required super.busType,
    required super.acType,
    required super.originId,
    required super.originNameEn,
    required super.originNameBn,
    required super.destinationId,
    required super.destinationNameEn,
    required super.destinationNameBn,
    required super.departureAt,
    required super.arrivalAt,
    required super.boardingPoint,
    required super.dropOffPoint,
    required super.fareAmount,
    required super.totalSeats,
    required super.availableSeats,
    required super.facilities,
  });

  factory TripModel.fromRow(Map<String, dynamic> row) {
    List<String> parsedFacilities = [];
    final facilitiesRaw = row['facilities_json'] as String?;
    if (facilitiesRaw != null && facilitiesRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(facilitiesRaw) as List;
        parsedFacilities = decoded.map((e) => e.toString()).toList();
      } catch (_) {
        parsedFacilities = [];
      }
    }

    return TripModel(
      id: row['trip_id'] as String,
      busId: row['bus_id'] as String,
      operatorId: row['operator_id'] as String,
      operatorNameEn: row['operator_name_en'] as String,
      operatorNameBn: row['operator_name_bn'] as String,
      operatorLogo: row['operator_logo'] as String?,
      busName: row['bus_name'] as String,
      busType: row['bus_type'] as String,
      acType: row['ac_type'] as String,
      originId: row['origin_location_id'] as String,
      originNameEn: row['origin_name_en'] as String,
      originNameBn: row['origin_name_bn'] as String,
      destinationId: row['destination_location_id'] as String,
      destinationNameEn: row['destination_name_en'] as String,
      destinationNameBn: row['destination_name_bn'] as String,
      departureAt: row['departure_at'] as int,
      arrivalAt: row['arrival_at'] as int,
      boardingPoint: row['boarding_point'] as String,
      dropOffPoint: row['drop_off_point'] as String,
      fareAmount: row['fare_amount'] as int,
      totalSeats: row['total_seats'] as int,
      availableSeats: row['available_seats'] as int? ?? 0,
      facilities: parsedFacilities,
    );
  }
}
