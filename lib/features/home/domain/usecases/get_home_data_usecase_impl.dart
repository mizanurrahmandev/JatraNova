import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:jatra_nova/core/error/failure.dart';
import 'package:jatra_nova/features/home/domain/entities/home_entities.dart';
import 'package:jatra_nova/features/home/domain/repositories/i_home_repository.dart';
import 'package:jatra_nova/features/home/domain/usecases/i_get_home_data_usecase.dart';

@Injectable(as: IGetHomeDataUsecase)
class GetHomeDataUsecaseImpl implements IGetHomeDataUsecase {
  GetHomeDataUsecaseImpl(this._repository);

  final IHomeRepository _repository;

  @override
  Future<Either<Failure, HomeDataEntity>> call({
    required String languageCode,
    String? userId,
  }) {
    return _repository.loadHomeData(
      languageCode: languageCode,
      userId: userId,
    );
  }
}
