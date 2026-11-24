import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/features/search/domain/entities/location_entity.dart';
import 'package:jatra_nova/features/search/domain/entities/trip_entity.dart';
import 'package:jatra_nova/features/search/domain/usecases/get_locations_usecase.dart';
import 'package:jatra_nova/features/search/domain/usecases/get_popular_routes_usecase.dart';
import 'package:jatra_nova/features/search/domain/usecases/search_trips_usecase.dart';
import 'package:jatra_nova/features/search/presentation/bloc/search_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockGetLocationsUsecase extends Mock implements IGetLocationsUsecase {}

class MockSearchTripsUsecase extends Mock implements ISearchTripsUsecase {}

class MockGetPopularRoutesUsecase extends Mock implements IGetPopularRoutesUsecase {}

void main() {
  late MockGetLocationsUsecase mockGetLocationsUsecase;
  late MockSearchTripsUsecase mockSearchTripsUsecase;
  late MockGetPopularRoutesUsecase mockGetPopularRoutesUsecase;

  const locDhaka = LocationEntity(id: 'loc_dhaka', nameEn: 'Dhaka', nameBn: 'ঢাকা', code: 'DAC');
  const locCtg = LocationEntity(id: 'loc_chattogram', nameEn: 'Chattogram', nameBn: 'চট্টগ্রাম', code: 'CTG');

  const sampleTrip = TripEntity(
    id: 'trip_1',
    busId: 'bus_1',
    operatorId: 'op_greenline',
    operatorNameEn: 'Green Line',
    operatorNameBn: 'গ্রীন লাইন',
    busName: 'Scania',
    busType: 'Executive',
    acType: 'AC',
    originId: 'loc_dhaka',
    originNameEn: 'Dhaka',
    originNameBn: 'ঢাকা',
    destinationId: 'loc_chattogram',
    destinationNameEn: 'Chattogram',
    destinationNameBn: 'চট্টগ্রাম',
    departureAt: 1000000,
    arrivalAt: 2000000,
    boardingPoint: 'Gulshan',
    dropOffPoint: 'Dampara',
    fareAmount: 1300,
    totalSeats: 36,
    availableSeats: 35,
    facilities: ['AC'],
  );

  setUp(() {
    mockGetLocationsUsecase = MockGetLocationsUsecase();
    mockSearchTripsUsecase = MockSearchTripsUsecase();
    mockGetPopularRoutesUsecase = MockGetPopularRoutesUsecase();
  });

  group('SearchBloc', () {
    blocTest<SearchBloc, SearchState>(
      'loads locations and sets defaults on SearchLoadInitialData',
      build: () {
        when(() => mockGetLocationsUsecase()).thenAnswer((_) async => const Right([locDhaka, locCtg]));
        when(() => mockGetPopularRoutesUsecase()).thenAnswer((_) async => const Right([]));
        return SearchBloc(
          getLocationsUsecase: mockGetLocationsUsecase,
          searchTripsUsecase: mockSearchTripsUsecase,
          getPopularRoutesUsecase: mockGetPopularRoutesUsecase,
        );
      },
      act: (bloc) => bloc.add(SearchLoadInitialData()),
      expect: () => [
        isA<SearchState>().having((s) => s.isLoadingLocations, 'isLoadingLocations', isTrue),
        isA<SearchState>()
            .having((s) => s.isLoadingLocations, 'isLoadingLocations', isFalse)
            .having((s) => s.locations.length, 'locations', 2)
            .having((s) => s.selectedOrigin, 'selectedOrigin', locDhaka)
            .having((s) => s.selectedDestination, 'selectedDestination', locCtg),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'swaps origin and destination properly',
      build: () => SearchBloc(
        getLocationsUsecase: mockGetLocationsUsecase,
        searchTripsUsecase: mockSearchTripsUsecase,
        getPopularRoutesUsecase: mockGetPopularRoutesUsecase,
      ),
      seed: () => SearchState(
        selectedDate: DateTime.now().toUtc(),
        selectedOrigin: locDhaka,
        selectedDestination: locCtg,
      ),
      act: (bloc) => bloc.add(SearchSwapLocations()),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.selectedOrigin, 'origin', locCtg)
            .having((s) => s.selectedDestination, 'destination', locDhaka),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'clamps passenger count between 1 and 4',
      build: () => SearchBloc(
        getLocationsUsecase: mockGetLocationsUsecase,
        searchTripsUsecase: mockSearchTripsUsecase,
        getPopularRoutesUsecase: mockGetPopularRoutesUsecase,
      ),
      act: (bloc) {
        bloc.add(const SearchUpdatePassengers(5)); // over limit -> clamp 4
        bloc.add(const SearchUpdatePassengers(0)); // under limit -> clamp 1
      },
      expect: () => [
        isA<SearchState>().having((s) => s.passengerCount, 'passengerCount', 4),
        isA<SearchState>().having((s) => s.passengerCount, 'passengerCount', 1),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'executes search and emits trips on SearchExecuteTrips',
      build: () {
        when(() => mockSearchTripsUsecase(
              originId: any(named: 'originId'),
              destinationId: any(named: 'destinationId'),
              dateEpochMs: any(named: 'dateEpochMs'),
              filters: any(named: 'filters'),
            )).thenAnswer((_) async => const Right([sampleTrip]));
        return SearchBloc(
          getLocationsUsecase: mockGetLocationsUsecase,
          searchTripsUsecase: mockSearchTripsUsecase,
          getPopularRoutesUsecase: mockGetPopularRoutesUsecase,
        );
      },
      seed: () => SearchState(
        selectedDate: DateTime.now().toUtc(),
        selectedOrigin: locDhaka,
        selectedDestination: locCtg,
      ),
      act: (bloc) => bloc.add(SearchExecuteTrips()),
      expect: () => [
        isA<SearchState>().having((s) => s.isSearchingTrips, 'isSearchingTrips', isTrue),
        isA<SearchState>()
            .having((s) => s.isSearchingTrips, 'isSearchingTrips', isFalse)
            .having((s) => s.trips.length, 'trips', 1)
            .having((s) => s.hasSearched, 'hasSearched', isTrue),
      ],
    );
  });
}
