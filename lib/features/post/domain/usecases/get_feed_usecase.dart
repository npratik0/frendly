import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetFeedUseCase implements UseCase<List<PostEntity>, GetFeedParams> {
  final PostRepository repository;

  GetFeedUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetFeedParams params) async {
    return await repository.getFeed(page: params.page);
  }
}

class GetFeedParams {
  final int page;

  GetFeedParams({this.page = 1});
}
