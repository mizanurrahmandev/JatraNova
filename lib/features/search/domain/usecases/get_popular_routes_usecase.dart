import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failure.dart';
import '../repositories/i_search_repository.dart';

abstract class IGetPopularRoutesUsecase {
  Future<Either<Failure, List<Map<String, dynamic>>>> call();
}

@Injectable(as: IGetPopularRoutesUsecase)
class GetPopularRoutesUsecase implements IGetPopularRoutesUsecase {
  final ISearchRepository _repository;

  GetPopularRoutesUsecase(this._repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _repository.getPopularRoutes();
  }
}
