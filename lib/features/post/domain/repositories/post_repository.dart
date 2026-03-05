import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  // Get feed posts
  Future<Either<Failure, List<PostEntity>>> getFeed({int page = 1});

  // Get user posts
  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId);

  // Create post
  Future<Either<Failure, PostEntity>> createPost({
    required XFile image,
    required String caption,
  });

  // Like/Unlike post
  Future<Either<Failure, PostEntity>> likePost(String postId);

  // Add comment
  Future<Either<Failure, PostEntity>> addComment({
    required String postId,
    required String text,
  });

  // Delete comment
  Future<Either<Failure, PostEntity>> deleteComment({
    required String postId,
    required String commentId,
  });

  // Delete post
  Future<Either<Failure, void>> deletePost(String postId);

  // Bookmark operations
  Future<Either<Failure, void>> bookmarkPost(String postId);
  Future<Either<Failure, void>> unbookmarkPost(String postId);
  Future<Either<Failure, List<String>>> getBookmarkedPostIds();

  // Cache operations
  Future<Either<Failure, List<PostEntity>>> getCachedFeed();
  Future<Either<Failure, void>> cacheFeed(List<PostEntity> posts);

  // Offline operations
  Future<Either<Failure, void>> queueOfflineAction({
    required String actionType,
    required String postId,
    Map<String, dynamic>? data,
  });
  Future<Either<Failure, void>> syncOfflineActions();
}
