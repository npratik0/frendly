import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserPostsUseCase implements UseCase<List<PostEntity>, String> {
  final ProfileRepository repository;

  GetUserPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(String userId) async {
    return await repository.getUserPosts(userId);
  }
}
