import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/search/domain/entities/trip_entity.dart';
import 'package:jatra_nova/features/search/domain/repositories/i_search_repository.dart';
import 'package:jatra_nova/features/search/domain/usecases/search_trips_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements ISearchRepository {}

void main() {
  late SearchTripsUsecase usecase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    usecase = SearchTripsUsecase(mockRepository);
  });

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
    facilities: ['AC', 'WiFi'],
  );

  test('returns validation failure when origin and destination are identical', () async {
    final result = await usecase(
      originId: 'loc_dhaka',
      destinationId: 'loc_dhaka',
      dateEpochMs: 1000000,
    );

    expect(result, isA<Left>());
    result.fold(
      (failure) => expect(failure.type, equals(FailureType.validation)),
      (_) => fail('Should have failed'),
    );
  });

  test('delegates to repository when parameters are valid', () async {
    when(() => mockRepository.searchTrips(
          originId: 'loc_dhaka',
          destinationId: 'loc_chattogram',
          dateEpochMs: 1000000,
          filters: null,
        )).thenAnswer((_) async => const Right([sampleTrip]));

    final result = await usecase(
      originId: 'loc_dhaka',
      destinationId: 'loc_chattogram',
      dateEpochMs: 1000000,
    );

    expect(result, equals(const Right([sampleTrip])));
    verify(() => mockRepository.searchTrips(
          originId: 'loc_dhaka',
          destinationId: 'loc_chattogram',
          dateEpochMs: 1000000,
          filters: null,
        )).called(1);
  });
}
