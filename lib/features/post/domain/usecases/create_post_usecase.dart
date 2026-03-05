import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    return await repository.createPost(
      image: params.image,
      caption: params.caption,
    );
  }
}

class CreatePostParams {
  final XFile image;
  final String caption;

  CreatePostParams({
    required this.image,
    required this.caption,
  });
}
