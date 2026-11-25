import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';
import 'package:jatra_nova/features/home/domain/usecases/i_get_home_data_usecase.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_bloc.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_event.dart';
import 'package:jatra_nova/features/home/presentation/bloc/home_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetHomeDataUsecase extends Mock implements IGetHomeDataUsecase {}

void main() {
  late _MockGetHomeDataUsecase mockUsecase;
  late HomeBloc homeBloc;

  const stopDac = StopEntity(
    id: 'stop_dac',
    cityCode: 'DAC',
    name: 'Dhaka',
    isPopular: true,
    isTransferHub: false,
  );
  const stopCgp = StopEntity(
    id: 'stop_cgp',
    cityCode: 'CGP',
    name: 'Chattogram',
    isPopular: true,
    isTransferHub: false,
  );
  const stopZyl = StopEntity(
    id: 'stop_zyl',
    cityCode: 'ZYL',
    name: 'Sylhet',
    isPopular: true,
    isTransferHub: false,
  );

  final sampleData = HomeDataEntity(
    stops: const <StopEntity>[stopDac, stopCgp, stopZyl],
    popularRoutes: const <PopularRouteEntity>[
      PopularRouteEntity(
        id: 'route_dac_zyl',
        originStop: stopDac,
        destinationStop: stopZyl,
        name: 'Dhaka - Sylhet',
        minFareMinor: 120000,
      ),
    ],
    popularBuses: <PopularBusEntity>[
      PopularBusEntity(
        tripId: 'trip_1',
        busName: 'Demo Express AC',
        operatorName: 'JatraNova Demo Coach',
        originName: 'Dhaka',
        destinationName: 'Chattogram',
        departureAt: DateTime(2026, 12, 1, 8, 0),
        fareMinor: 100000,
        availableSeats: 15,
        busType: 'ac_business',
      ),
    ],
    passengerName: 'Rahim',
  );

  setUp(() {
    mockUsecase = _MockGetHomeDataUsecase();
    homeBloc = HomeBloc(mockUsecase);
  });

  tearDown(() async {
    await homeBloc.close();
  });

  group('HomeBloc', () {
    test('loads stops, popular routes, popular buses, and defaults on HomeStarted',
        () async {
      when(
        () => mockUsecase(languageCode: 'en', userId: 'u1'),
      ).thenAnswer((_) async => Right<Failure, HomeDataEntity>(sampleData));

      homeBloc.add(const HomeStarted(languageCode: 'en', userId: 'u1'));

      await expectLater(
        homeBloc.stream,
        emitsInOrder(<Matcher>[
          isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
          isA<HomeState>()
              .having((s) => s.status, 'status', HomeStatus.loaded)
              .having((s) => s.originStop, 'originStop', stopDac)
              .having((s) => s.destinationStop, 'destinationStop', stopCgp)
              .having((s) => s.passengerName, 'passengerName', 'Rahim')
              .having((s) => s.popularRoutes.length, 'popularRoutes', 1)
              .having((s) => s.popularBuses.length, 'popularBuses', 1),
        ]),
      );
    });

    test('emits failure state when usecase returns Left(Failure)', () async {
      when(
        () => mockUsecase(languageCode: 'en', userId: null),
      ).thenAnswer(
        (_) async => const Left<Failure, HomeDataEntity>(
          Failure(type: FailureType.database),
        ),
      );

      homeBloc.add(const HomeStarted(languageCode: 'en'));

      await expectLater(
        homeBloc.stream,
        emitsInOrder(<Matcher>[
          isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
          isA<HomeState>().having((s) => s.status, 'status', HomeStatus.failure),
        ]),
      );
    });

    test('swaps origin and destination on HomeLocationsSwapped', () async {
      when(
        () => mockUsecase(languageCode: 'en', userId: null),
      ).thenAnswer((_) async => Right<Failure, HomeDataEntity>(sampleData));

      homeBloc.add(const HomeStarted(languageCode: 'en'));
      await homeBloc.stream.firstWhere((s) => s.status == HomeStatus.loaded);

      homeBloc.add(const HomeLocationsSwapped());
      await expectLater(
        homeBloc.stream,
        emits(
          isA<HomeState>()
              .having((s) => s.originStop, 'originStop', stopCgp)
              .having((s) => s.destinationStop, 'destinationStop', stopDac),
        ),
      );
    });

    test('rejects past date and clamps passenger count to 1..4', () async {
      when(
        () => mockUsecase(languageCode: 'en', userId: null),
      ).thenAnswer((_) async => Right<Failure, HomeDataEntity>(sampleData));

      homeBloc.add(const HomeStarted(languageCode: 'en'));
      await homeBloc.stream.firstWhere((s) => s.status == HomeStatus.loaded);

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      homeBloc.add(HomeDateSelected(yesterday));

      await expectLater(
        homeBloc.stream,
        emits(
          isA<HomeState>().having(
            (s) => s.validationError,
            'validationError',
            HomeValidationError.pastDate,
          ),
        ),
      );

      homeBloc
        ..add(const HomePassengerCountChanged(3))
        ..add(const HomePassengerCountChanged(0))
        ..add(const HomePassengerCountChanged(9));

      await expectLater(
        homeBloc.stream,
        emitsInOrder(<Matcher>[
          isA<HomeState>().having((s) => s.passengerCount, 'passengerCount', 3),
          isA<HomeState>().having((s) => s.passengerCount, 'passengerCount', 1),
          isA<HomeState>().having((s) => s.passengerCount, 'passengerCount', 4),
        ]),
      );
    });

    test('validates same origin/destination and emits searchCriteria when valid',
        () async {
      when(
        () => mockUsecase(languageCode: 'en', userId: null),
      ).thenAnswer((_) async => Right<Failure, HomeDataEntity>(sampleData));

      homeBloc.add(const HomeStarted(languageCode: 'en'));
      await homeBloc.stream.firstWhere((s) => s.status == HomeStatus.loaded);

      homeBloc
        ..add(const HomeDestinationSelected(stopDac))
        ..add(const HomeSearchSubmitted());

      await expectLater(
        homeBloc.stream,
        emitsThrough(
          isA<HomeState>().having(
            (s) => s.validationError,
            'validationError',
            HomeValidationError.sameOriginDestination,
          ),
        ),
      );

      homeBloc
        ..add(const HomeDestinationSelected(stopZyl))
        ..add(const HomeSearchSubmitted());

      await expectLater(
        homeBloc.stream,
        emitsThrough(
          isA<HomeState>().having(
            (s) => s.searchCriteria?.destinationStop,
            'searchCriteria.destinationStop',
            stopZyl,
          ),
        ),
      );
    });
  });
}
