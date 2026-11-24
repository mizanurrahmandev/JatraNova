import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String id;
  final String nameEn;
  final String nameBn;
  final String code;
  final bool isActive;

  const LocationEntity({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.code,
    this.isActive = true,
  });

  String localizedName(String localeCode) {
    return localeCode == 'bn' ? nameBn : nameEn;
  }

  @override
  List<Object?> get props => [id, nameEn, nameBn, code, isActive];
}
