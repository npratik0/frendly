import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CommentPostUseCase implements UseCase<PostEntity, CommentPostParams> {
  final PostRepository repository;

  CommentPostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(CommentPostParams params) async {
    return await repository.addComment(
      postId: params.postId,
      text: params.text,
    );
  }
}

class CommentPostParams {
  final String postId;
  final String text;

  CommentPostParams({
    required this.postId,
    required this.text,
  });
}
