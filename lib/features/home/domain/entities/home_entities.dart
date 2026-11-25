import 'package:equatable/equatable.dart';

/// Normalized bus stop entity used for origin/destination selection on Home.
class StopEntity extends Equatable {
  const StopEntity({
    required this.id,
    required this.cityCode,
    required this.name,
    required this.isPopular,
    required this.isTransferHub,
  });

  final String id;
  final String cityCode;
  final String name;
  final bool isPopular;
  final bool isTransferHub;

  @override
  List<Object?> get props => <Object?>[
        id,
        cityCode,
        name,
        isPopular,
        isTransferHub,
      ];
}

/// Popular point-to-point route entity with optional indicative min fare in poisha.
class PopularRouteEntity extends Equatable {
  const PopularRouteEntity({
    required this.id,
    required this.originStop,
    required this.destinationStop,
    required this.name,
    this.minFareMinor,
  });

  final String id;
  final StopEntity originStop;
  final StopEntity destinationStop;
  final String name;
  final int? minFareMinor;

  @override
  List<Object?> get props => <Object?>[
        id,
        originStop,
        destinationStop,
        name,
        minFareMinor,
      ];
}

/// Popular demo bus trip summary displayed on the Passenger Home Screen.
class PopularBusEntity extends Equatable {
  const PopularBusEntity({
    required this.tripId,
    required this.busName,
    required this.operatorName,
    required this.originName,
    required this.destinationName,
    required this.departureAt,
    required this.fareMinor,
    required this.availableSeats,
    required this.busType,
  });

  final String tripId;
  final String busName;
  final String operatorName;
  final String originName;
  final String destinationName;
  final DateTime departureAt;
  final int fareMinor;
  final int availableSeats;
  final String busType;

  @override
  List<Object?> get props => <Object?>[
        tripId,
        busName,
        operatorName,
        originName,
        destinationName,
        departureAt,
        fareMinor,
        availableSeats,
        busType,
      ];
}

/// Aggregated payload returned by [IGetHomeDataUsecase] for the Home Screen.
class HomeDataEntity extends Equatable {
  const HomeDataEntity({
    required this.stops,
    required this.popularRoutes,
    required this.popularBuses,
    this.passengerName,
  });

  final List<StopEntity> stops;
  final List<PopularRouteEntity> popularRoutes;
  final List<PopularBusEntity> popularBuses;
  final String? passengerName;

  @override
  List<Object?> get props => <Object?>[
        stops,
        popularRoutes,
        popularBuses,
        passengerName,
      ];
}

/// Search criteria passed from the Home search card to the Search route.
class HomeSearchCriteria extends Equatable {
  const HomeSearchCriteria({
    required this.originStop,
    required this.destinationStop,
    required this.journeyDate,
    required this.passengerCount,
  });

  final StopEntity originStop;
  final StopEntity destinationStop;
  final DateTime journeyDate;
  final int passengerCount;

  @override
  List<Object?> get props => <Object?>[
        originStop,
        destinationStop,
        journeyDate,
        passengerCount,
      ];
}
