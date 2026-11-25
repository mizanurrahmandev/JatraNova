import 'package:equatable/equatable.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeStarted extends HomeEvent {
  const HomeStarted({
    required this.languageCode,
    this.userId,
  });

  final String languageCode;
  final String? userId;

  @override
  List<Object?> get props => <Object?>[languageCode, userId];
}

class HomeOriginSelected extends HomeEvent {
  const HomeOriginSelected(this.stop);

  final StopEntity stop;

  @override
  List<Object?> get props => <Object?>[stop];
}

class HomeDestinationSelected extends HomeEvent {
  const HomeDestinationSelected(this.stop);

  final StopEntity stop;

  @override
  List<Object?> get props => <Object?>[stop];
}

class HomeLocationsSwapped extends HomeEvent {
  const HomeLocationsSwapped();
}

class HomeDateSelected extends HomeEvent {
  const HomeDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
}

class HomePassengerCountChanged extends HomeEvent {
  const HomePassengerCountChanged(this.count);

  final int count;

  @override
  List<Object?> get props => <Object?>[count];
}

class HomePopularRouteSelected extends HomeEvent {
  const HomePopularRouteSelected(this.route);

  final PopularRouteEntity route;

  @override
  List<Object?> get props => <Object?>[route];
}

class HomeSearchSubmitted extends HomeEvent {
  const HomeSearchSubmitted();
}

class HomeSearchNavigationHandled extends HomeEvent {
  const HomeSearchNavigationHandled();
}

class HomeValidationCleared extends HomeEvent {
  const HomeValidationCleared();
}
