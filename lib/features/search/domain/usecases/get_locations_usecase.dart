import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../entities/location_entity.dart';
import '../repositories/i_search_repository.dart';

abstract class IGetLocationsUsecase {
  Future<Either<Failure, List<LocationEntity>>> call();
}

@Injectable(as: IGetLocationsUsecase)
class GetLocationsUsecase implements IGetLocationsUsecase {
  final ISearchRepository _repository;

  GetLocationsUsecase(this._repository);

  @override
  Future<Either<Failure, List<LocationEntity>>> call() {
    return _repository.getLocations();
  }
}
