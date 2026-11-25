import 'package:equatable/equatable.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';

enum HomeStatus { initial, loading, loaded, failure }

enum HomeValidationError { sameOriginDestination, pastDate }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.stops = const <StopEntity>[],
    this.popularRoutes = const <PopularRouteEntity>[],
    this.popularBuses = const <PopularBusEntity>[],
    this.passengerName,
    this.originStop,
    this.destinationStop,
    this.journeyDate,
    this.passengerCount = 1,
    this.failure,
    this.validationError,
    this.searchCriteria,
  });

  final HomeStatus status;
  final List<StopEntity> stops;
  final List<PopularRouteEntity> popularRoutes;
  final List<PopularBusEntity> popularBuses;
  final String? passengerName;
  final StopEntity? originStop;
  final StopEntity? destinationStop;
  final DateTime? journeyDate;
  final int passengerCount;
  final Failure? failure;
  final HomeValidationError? validationError;
  final HomeSearchCriteria? searchCriteria;

  HomeState copyWith({
    HomeStatus? status,
    List<StopEntity>? stops,
    List<PopularRouteEntity>? popularRoutes,
    List<PopularBusEntity>? popularBuses,
    String? Function()? passengerName,
    StopEntity? Function()? originStop,
    StopEntity? Function()? destinationStop,
    DateTime? journeyDate,
    int? passengerCount,
    Failure? Function()? failure,
    HomeValidationError? Function()? validationError,
    HomeSearchCriteria? Function()? searchCriteria,
  }) {
    return HomeState(
      status: status ?? this.status,
      stops: stops ?? this.stops,
      popularRoutes: popularRoutes ?? this.popularRoutes,
      popularBuses: popularBuses ?? this.popularBuses,
      passengerName:
          passengerName != null ? passengerName() : this.passengerName,
      originStop: originStop != null ? originStop() : this.originStop,
      destinationStop:
          destinationStop != null ? destinationStop() : this.destinationStop,
      journeyDate: journeyDate ?? this.journeyDate,
      passengerCount: passengerCount ?? this.passengerCount,
      failure: failure != null ? failure() : this.failure,
      validationError:
          validationError != null ? validationError() : this.validationError,
      searchCriteria:
          searchCriteria != null ? searchCriteria() : this.searchCriteria,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        stops,
        popularRoutes,
        popularBuses,
        passengerName,
        originStop,
        destinationStop,
        journeyDate,
        passengerCount,
        failure,
        validationError,
        searchCriteria,
      ];
}
