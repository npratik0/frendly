import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

class SaveRecentSearchUseCase implements UseCase<void, String> {
  final SearchRepository repository;

  SaveRecentSearchUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right(null);
    }
    return await repository.saveRecentSearch(query.trim());
  }
}
