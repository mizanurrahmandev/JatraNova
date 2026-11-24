part of 'search_bloc.dart';

class SearchState extends Equatable {
  final List<LocationEntity> locations;
  final List<Map<String, dynamic>> popularRoutes;
  final LocationEntity? selectedOrigin;
  final LocationEntity? selectedDestination;
  final DateTime selectedDate;
  final int passengerCount;
  final FilterCriteriaEntity filters;
  final bool isLoadingLocations;
  final bool isSearchingTrips;
  final List<TripEntity> trips;
  final Failure? failure;
  final bool hasSearched;

  const SearchState({
    this.locations = const [],
    this.popularRoutes = const [],
    this.selectedOrigin,
    this.selectedDestination,
    required this.selectedDate,
    this.passengerCount = 1,
    this.filters = const FilterCriteriaEntity(),
    this.isLoadingLocations = false,
    this.isSearchingTrips = false,
    this.trips = const [],
    this.failure,
    this.hasSearched = false,
  });

  SearchState copyWith({
    List<LocationEntity>? locations,
    List<Map<String, dynamic>>? popularRoutes,
    LocationEntity? selectedOrigin,
    LocationEntity? selectedDestination,
    DateTime? selectedDate,
    int? passengerCount,
    FilterCriteriaEntity? filters,
    bool? isLoadingLocations,
    bool? isSearchingTrips,
    List<TripEntity>? trips,
    Failure? failure,
    bool clearFailure = false,
    bool? hasSearched,
  }) {
    return SearchState(
      locations: locations ?? this.locations,
      popularRoutes: popularRoutes ?? this.popularRoutes,
      selectedOrigin: selectedOrigin ?? this.selectedOrigin,
      selectedDestination: selectedDestination ?? this.selectedDestination,
      selectedDate: selectedDate ?? this.selectedDate,
      passengerCount: passengerCount ?? this.passengerCount,
      filters: filters ?? this.filters,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isSearchingTrips: isSearchingTrips ?? this.isSearchingTrips,
      trips: trips ?? this.trips,
      failure: clearFailure ? null : (failure ?? this.failure),
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props => [
        locations,
        popularRoutes,
        selectedOrigin,
        selectedDestination,
        selectedDate,
        passengerCount,
        filters,
        isLoadingLocations,
        isSearchingTrips,
        trips,
        failure,
        hasSearched,
      ];
}
