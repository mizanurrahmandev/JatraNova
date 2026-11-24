import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/filter_criteria_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/usecases/get_locations_usecase.dart';
import '../../domain/usecases/get_popular_routes_usecase.dart';
import '../../domain/usecases/search_trips_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final IGetLocationsUsecase _getLocationsUsecase;
  final ISearchTripsUsecase _searchTripsUsecase;
  final IGetPopularRoutesUsecase _getPopularRoutesUsecase;

  SearchBloc({
    required IGetLocationsUsecase getLocationsUsecase,
    required ISearchTripsUsecase searchTripsUsecase,
    required IGetPopularRoutesUsecase getPopularRoutesUsecase,
  })  : _getLocationsUsecase = getLocationsUsecase,
        _searchTripsUsecase = searchTripsUsecase,
        _getPopularRoutesUsecase = getPopularRoutesUsecase,
        super(SearchState(selectedDate: DateTime.now().toUtc())) {
    on<SearchLoadInitialData>(_onLoadInitialData);
    on<SearchSwapLocations>(_onSwapLocations);
    on<SearchSelectOrigin>(_onSelectOrigin);
    on<SearchSelectDestination>(_onSelectDestination);
    on<SearchSelectDate>(_onSelectDate);
    on<SearchUpdatePassengers>(_onUpdatePassengers);
    on<SearchExecuteTrips>(_onExecuteTrips);
    on<SearchApplyFilters>(_onApplyFilters);
  }

  Future<void> _onLoadInitialData(
    SearchLoadInitialData event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(isLoadingLocations: true, clearFailure: true));

    final locationsResult = await _getLocationsUsecase();
    final routesResult = await _getPopularRoutesUsecase();

    List<LocationEntity> locations = [];
    List<Map<String, dynamic>> popularRoutes = [];

    locationsResult.fold(
      (failure) => emit(state.copyWith(failure: failure, isLoadingLocations: false)),
      (locs) => locations = locs,
    );

    routesResult.fold(
      (_) {},
      (routes) => popularRoutes = routes,
    );

    LocationEntity? defaultOrigin;
    LocationEntity? defaultDestination;

    if (locations.isNotEmpty) {
      defaultOrigin = locations.firstWhere(
        (l) => l.code == 'DAC',
        orElse: () => locations[0],
      );
      if (locations.length > 1) {
        defaultDestination = locations.firstWhere(
          (l) => l.code == 'CTG',
          orElse: () => locations[1],
        );
      }
    }

    emit(state.copyWith(
      locations: locations,
      popularRoutes: popularRoutes,
      selectedOrigin: state.selectedOrigin ?? defaultOrigin,
      selectedDestination: state.selectedDestination ?? defaultDestination,
      isLoadingLocations: false,
    ));
  }

  void _onSwapLocations(
    SearchSwapLocations event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(
      selectedOrigin: state.selectedDestination,
      selectedDestination: state.selectedOrigin,
      clearFailure: true,
    ));
  }

  void _onSelectOrigin(
    SearchSelectOrigin event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(selectedOrigin: event.origin, clearFailure: true));
  }

  void _onSelectDestination(
    SearchSelectDestination event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(selectedDestination: event.destination, clearFailure: true));
  }

  void _onSelectDate(
    SearchSelectDate event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date, clearFailure: true));
  }

  void _onUpdatePassengers(
    SearchUpdatePassengers event,
    Emitter<SearchState> emit,
  ) {
    final clamped = event.count.clamp(1, 4);
    emit(state.copyWith(passengerCount: clamped));
  }

  Future<void> _onExecuteTrips(
    SearchExecuteTrips event,
    Emitter<SearchState> emit,
  ) async {
    if (state.selectedOrigin == null || state.selectedDestination == null) {
      emit(state.copyWith(
        failure: const Failure(
          type: FailureType.validation,
          debugMessage: 'Origin and destination are required',
        ),
      ));
      return;
    }

    if (state.selectedOrigin!.id == state.selectedDestination!.id) {
      emit(state.copyWith(
        failure: const Failure(
          type: FailureType.validation,
          debugMessage: 'Origin and destination cannot be identical',
        ),
      ));
      return;
    }

    emit(state.copyWith(isSearchingTrips: true, clearFailure: true));

    final dateMs = state.selectedDate.millisecondsSinceEpoch;
    final result = await _searchTripsUsecase(
      originId: state.selectedOrigin!.id,
      destinationId: state.selectedDestination!.id,
      dateEpochMs: dateMs,
      filters: state.filters,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        failure: failure,
        isSearchingTrips: false,
        hasSearched: true,
      )),
      (trips) => emit(state.copyWith(
        trips: trips,
        isSearchingTrips: false,
        hasSearched: true,
      )),
    );
  }

  Future<void> _onApplyFilters(
    SearchApplyFilters event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(filters: event.filters));
    add(SearchExecuteTrips());
  }
}
