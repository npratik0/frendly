import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/post_repository.dart';

class BookmarkPostUseCase implements UseCase<void, BookmarkPostParams> {
  final PostRepository repository;

  BookmarkPostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(BookmarkPostParams params) async {
    if (params.isBookmarked) {
      return await repository.unbookmarkPost(params.postId);
    } else {
      return await repository.bookmarkPost(params.postId);
    }
  }
}

class BookmarkPostParams {
  final String postId;
  final bool isBookmarked;

  BookmarkPostParams({
    required this.postId,
    required this.isBookmarked,
  });
}
