import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';
import 'package:jatra_nova/features/home/domain/usecases/i_get_home_data_usecase.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_event.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_state.dart';

/// Manages Passenger Home Screen data loading, search card state, and
/// validation.
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._getHomeDataUsecase) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeOriginSelected>(_onOriginSelected);
    on<HomeDestinationSelected>(_onDestinationSelected);
    on<HomeLocationsSwapped>(_onLocationsSwapped);
    on<HomeDateSelected>(_onDateSelected);
    on<HomePassengerCountChanged>(_onPassengerCountChanged);
    on<HomePopularRouteSelected>(_onPopularRouteSelected);
    on<HomeSearchSubmitted>(_onSearchSubmitted);
    on<HomeSearchNavigationHandled>(_onSearchNavigationHandled);
    on<HomeValidationCleared>(_onValidationCleared);
  }

  final IGetHomeDataUsecase _getHomeDataUsecase;

  static const int minPassengers = 1;
  static const int maxPassengers = 4;

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        failure: () => null,
        validationError: () => null,
      ),
    );

    final result = await _getHomeDataUsecase(
      languageCode: event.languageCode,
      userId: event.userId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          failure: () => failure,
        ),
      ),
      (data) {
        final stops = data.stops;
        final defaultOrigin = _pickStop(
          stops,
          preferredId: 'stop_dac',
          fallbackIndex: 0,
        );
        final defaultDest = _pickStop(
          stops,
          preferredId: 'stop_cgp',
          fallbackIndex: stops.length > 1 ? 1 : 0,
        );

        final today = _dateOnly(DateTime.now());
        final defaultDate = state.journeyDate ?? today.add(const Duration(days: 1));

        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            stops: stops,
            popularRoutes: data.popularRoutes,
            popularBuses: data.popularBuses,
            passengerName: () => data.passengerName,
            originStop: () => _matchUpdatedStop(stops, state.originStop) ?? defaultOrigin,
            destinationStop: () =>
                _matchUpdatedStop(stops, state.destinationStop) ?? defaultDest,
            journeyDate: defaultDate,
            failure: () => null,
          ),
        );
      },
    );
  }

  StopEntity? _pickStop(
    List<StopEntity> stops, {
    required String preferredId,
    required int fallbackIndex,
  }) {
    if (stops.isEmpty) {
      return null;
    }
    for (final stop in stops) {
      if (stop.id == preferredId) {
        return stop;
      }
    }
    return stops[fallbackIndex.clamp(0, stops.length - 1)];
  }

  StopEntity? _matchUpdatedStop(List<StopEntity> stops, StopEntity? current) {
    if (current == null) {
      return null;
    }
    for (final stop in stops) {
      if (stop.id == current.id) {
        return stop;
      }
    }
    return null;
  }

  void _onOriginSelected(
    HomeOriginSelected event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        originStop: () => event.stop,
        validationError: () => null,
      ),
    );
  }

  void _onDestinationSelected(
    HomeDestinationSelected event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        destinationStop: () => event.stop,
        validationError: () => null,
      ),
    );
  }

  void _onLocationsSwapped(
    HomeLocationsSwapped event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        originStop: () => state.destinationStop,
        destinationStop: () => state.originStop,
        validationError: () => null,
      ),
    );
  }

  void _onDateSelected(
    HomeDateSelected event,
    Emitter<HomeState> emit,
  ) {
    final selected = _dateOnly(event.date);
    final today = _dateOnly(DateTime.now());
    if (selected.isBefore(today)) {
      emit(
        state.copyWith(
          validationError: () => HomeValidationError.pastDate,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        journeyDate: selected,
        validationError: () => null,
      ),
    );
  }

  void _onPassengerCountChanged(
    HomePassengerCountChanged event,
    Emitter<HomeState> emit,
  ) {
    final clamped = event.count.clamp(minPassengers, maxPassengers);
    emit(state.copyWith(passengerCount: clamped));
  }

  void _onPopularRouteSelected(
    HomePopularRouteSelected event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        originStop: () => event.route.originStop,
        destinationStop: () => event.route.destinationStop,
        validationError: () => null,
      ),
    );
  }

  void _onSearchSubmitted(
    HomeSearchSubmitted event,
    Emitter<HomeState> emit,
  ) {
    final origin = state.originStop;
    final dest = state.destinationStop;
    final date = state.journeyDate ?? _dateOnly(DateTime.now());
    final today = _dateOnly(DateTime.now());

    if (origin == null || dest == null || origin.id == dest.id) {
      emit(
        state.copyWith(
          validationError: () => HomeValidationError.sameOriginDestination,
        ),
      );
      return;
    }

    if (date.isBefore(today)) {
      emit(
        state.copyWith(
          validationError: () => HomeValidationError.pastDate,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        validationError: () => null,
        searchCriteria: () => HomeSearchCriteria(
          originStop: origin,
          destinationStop: dest,
          journeyDate: date,
          passengerCount: state.passengerCount,
        ),
      ),
    );
  }

  void _onSearchNavigationHandled(
    HomeSearchNavigationHandled event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(searchCriteria: () => null));
  }

  void _onValidationCleared(
    HomeValidationCleared event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(validationError: () => null));
  }
}
