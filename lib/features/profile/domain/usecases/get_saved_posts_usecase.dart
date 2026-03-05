import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../repositories/profile_repository.dart';

class GetSavedPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final ProfileRepository repository;

  GetSavedPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) async {
    return await repository.getSavedPosts();
  }
}
