import 'package:equatable/equatable.dart';

class TripEntity extends Equatable {
  final String id;
  final String busId;
  final String operatorId;
  final String operatorNameEn;
  final String operatorNameBn;
  final String? operatorLogo;
  final String busName;
  final String busType;
  final String acType;
  final String originId;
  final String originNameEn;
  final String originNameBn;
  final String destinationId;
  final String destinationNameEn;
  final String destinationNameBn;
  final int departureAt;
  final int arrivalAt;
  final String boardingPoint;
  final String dropOffPoint;
  final int fareAmount;
  final int totalSeats;
  final int availableSeats;
  final List<String> facilities;

  const TripEntity({
    required this.id,
    required this.busId,
    required this.operatorId,
    required this.operatorNameEn,
    required this.operatorNameBn,
    this.operatorLogo,
    required this.busName,
    required this.busType,
    required this.acType,
    required this.originId,
    required this.originNameEn,
    required this.originNameBn,
    required this.destinationId,
    required this.destinationNameEn,
    required this.destinationNameBn,
    required this.departureAt,
    required this.arrivalAt,
    required this.boardingPoint,
    required this.dropOffPoint,
    required this.fareAmount,
    required this.totalSeats,
    required this.availableSeats,
    required this.facilities,
  });

  String localizedOperatorName(String localeCode) =>
      localeCode == 'bn' ? operatorNameBn : operatorNameEn;

  String localizedOriginName(String localeCode) =>
      localeCode == 'bn' ? originNameBn : originNameEn;

  String localizedDestinationName(String localeCode) =>
      localeCode == 'bn' ? destinationNameBn : destinationNameEn;

  int get durationMinutes => (arrivalAt - departureAt) ~/ 60000;

  bool get isAc => acType.toUpperCase() == 'AC';

  @override
  List<Object?> get props => [
        id,
        busId,
        operatorId,
        operatorNameEn,
        operatorNameBn,
        busName,
        busType,
        acType,
        originId,
        destinationId,
        departureAt,
        arrivalAt,
        fareAmount,
        availableSeats,
      ];
}
