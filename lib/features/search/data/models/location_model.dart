import '../../../../core/database/db_tables.dart';
import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.id,
    required super.nameEn,
    required super.nameBn,
    required super.code,
    super.isActive = true,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map[LocationColumns.id] as String,
      nameEn: map[LocationColumns.nameEn] as String,
      nameBn: map[LocationColumns.nameBn] as String,
      code: map[LocationColumns.code] as String,
      isActive: (map[LocationColumns.isActive] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      LocationColumns.id: id,
      LocationColumns.nameEn: nameEn,
      LocationColumns.nameBn: nameBn,
      LocationColumns.code: code,
      LocationColumns.isActive: isActive ? 1 : 0,
    };
  }
}
