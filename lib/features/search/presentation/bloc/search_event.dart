part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchLoadInitialData extends SearchEvent {}

class SearchSwapLocations extends SearchEvent {}

class SearchSelectOrigin extends SearchEvent {
  final LocationEntity origin;
  const SearchSelectOrigin(this.origin);

  @override
  List<Object?> get props => [origin];
}

class SearchSelectDestination extends SearchEvent {
  final LocationEntity destination;
  const SearchSelectDestination(this.destination);

  @override
  List<Object?> get props => [destination];
}

class SearchSelectDate extends SearchEvent {
  final DateTime date;
  const SearchSelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SearchUpdatePassengers extends SearchEvent {
  final int count;
  const SearchUpdatePassengers(this.count);

  @override
  List<Object?> get props => [count];
}

class SearchExecuteTrips extends SearchEvent {}

class SearchApplyFilters extends SearchEvent {
  final FilterCriteriaEntity filters;
  const SearchApplyFilters(this.filters);

  @override
  List<Object?> get props => [filters];
}
