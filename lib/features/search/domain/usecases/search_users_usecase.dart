import 'package:dartz/dartz.dart';
import 'package:frendly/features/search/domain/entities/search_user_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

class SearchUsersUseCase implements UseCase<List<SearchUserEntity>, String> {
  final SearchRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<SearchUserEntity>>> call(String query) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }
    return await repository.searchUsers(query.trim());
  }
}
