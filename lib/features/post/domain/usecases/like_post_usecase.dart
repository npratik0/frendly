import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class LikePostUseCase implements UseCase<PostEntity, String> {
  final PostRepository repository;

  LikePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(String postId) async {
    return await repository.likePost(postId);
  }
}
