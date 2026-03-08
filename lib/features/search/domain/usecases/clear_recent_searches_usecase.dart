import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

class ClearRecentSearchesUseCase implements UseCase<void, NoParams> {
  final SearchRepository repository;

  ClearRecentSearchesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearRecentSearches();
  }
}
