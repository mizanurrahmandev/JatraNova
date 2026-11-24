import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../entities/filter_criteria_entity.dart';
import '../entities/trip_entity.dart';
import '../repositories/i_search_repository.dart';

abstract class ISearchTripsUsecase {
  Future<Either<Failure, List<TripEntity>>> call({
    required String originId,
    required String destinationId,
    required int dateEpochMs,
    FilterCriteriaEntity? filters,
  });
}

@Injectable(as: ISearchTripsUsecase)
class SearchTripsUsecase implements ISearchTripsUsecase {
  final ISearchRepository _repository;

  SearchTripsUsecase(this._repository);

  @override
  Future<Either<Failure, List<TripEntity>>> call({
    required String originId,
    required String destinationId,
    required int dateEpochMs,
    FilterCriteriaEntity? filters,
  }) {
    if (originId == destinationId) {
      return Future.value(
        const Left(Failure(
          type: FailureType.validation,
          debugMessage: 'Origin and destination cannot be identical',
        )),
      );
    }
    return _repository.searchTrips(
      originId: originId,
      destinationId: destinationId,
      dateEpochMs: dateEpochMs,
      filters: filters,
    );
  }
}
