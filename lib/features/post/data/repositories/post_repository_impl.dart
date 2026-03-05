import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local/post_local_datasource.dart';
import '../datasources/remote/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<String?> get _currentUserId async {
    try {
      final authBox = await Hive.openBox(HiveConstants.authBox);
      final userData = authBox.get(HiveConstants.currentUserKey);
      if (userData != null && userData is Map) {
        return userData['_id'] ?? userData['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getFeed({int page = 1}) async {
    try {
      final isConnected = await networkInfo.isConnected;
      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();

      if (isConnected) {
        try {
          // Fetch from API
          final posts = await remoteDataSource.getFeed(page: page);

          // Cache the posts
          if (page == 1) {
            await localDataSource.cacheFeed(posts);
          }

          // Convert to entities
          return Right(
            posts
                .map(
                  (post) => post.toEntity(
                    currentUserId: currentUserId,
                    bookmarkedIds: bookmarkedIds,
                  ),
                )
                .toList(),
          );
        } catch (e) {
          // If API fails, try to return cached data
          return await _getCachedFeedWithBookmarks(
            currentUserId,
            bookmarkedIds,
          );
        }
      } else {
        // No internet - return cached data
        return await _getCachedFeedWithBookmarks(currentUserId, bookmarkedIds);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<PostEntity>>> _getCachedFeedWithBookmarks(
    String? currentUserId,
    List<String> bookmarkedIds,
  ) async {
    try {
      final cachedPosts = await localDataSource.getCachedFeed();

      if (cachedPosts.isEmpty) {
        return const Left(CacheFailure('No cached posts available'));
      }

      return Right(
        cachedPosts
            .map(
              (post) => post.toEntity(
                currentUserId: currentUserId,
                bookmarkedIds: bookmarkedIds,
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
      final posts = await remoteDataSource.getUserPosts(userId);

      return Right(
        posts
            .map(
              (post) => post.toEntity(
                currentUserId: currentUserId,
                bookmarkedIds: bookmarkedIds,
              ),
            )
            .toList(),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required XFile image,
    required String caption,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        // Queue offline action
        await queueOfflineAction(
          actionType: HiveConstants.actionTypeCreatePost,
          postId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          data: {'imagePath': image.path, 'caption': caption},
        );
        return const Left(
          NetworkFailure('Post will be created when you\'re back online'),
        );
      }

      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
      final post = await remoteDataSource.createPost(
        image: image,
        caption: caption,
      );

      // Cache the new post
      await localDataSource.cachePost(post);

      return Right(
        post.toEntity(
          currentUserId: currentUserId,
          bookmarkedIds: bookmarkedIds,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> likePost(String postId) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        // Queue offline action
        await queueOfflineAction(
          actionType: HiveConstants.actionTypeLike,
          postId: postId,
        );
        return const Left(
          NetworkFailure('Like will be synced when you\'re back online'),
        );
      }

      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
      final post = await remoteDataSource.likePost(postId);

      // Update cache
      await localDataSource.updatePost(post);

      return Right(
        post.toEntity(
          currentUserId: currentUserId,
          bookmarkedIds: bookmarkedIds,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> addComment({
    required String postId,
    required String text,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        // Queue offline action
        await queueOfflineAction(
          actionType: HiveConstants.actionTypeComment,
          postId: postId,
          data: {'text': text},
        );
        return const Left(
          NetworkFailure('Comment will be posted when you\'re back online'),
        );
      }

      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
      final post = await remoteDataSource.addComment(
        postId: postId,
        text: text,
      );

      // Update cache
      await localDataSource.updatePost(post);

      return Right(
        post.toEntity(
          currentUserId: currentUserId,
          bookmarkedIds: bookmarkedIds,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
      final post = await remoteDataSource.deleteComment(
        postId: postId,
        commentId: commentId,
      );

      // Update cache
      await localDataSource.updatePost(post);

      return Right(
        post.toEntity(
          currentUserId: currentUserId,
          bookmarkedIds: bookmarkedIds,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.deletePost(postId);

      // Delete from cache
      await localDataSource.deletePost(postId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bookmarkPost(String postId) async {
    try {
      // Save locally first (optimistic update)
      await localDataSource.addBookmarkedPostId(postId);

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        // Queue offline action
        await queueOfflineAction(
          actionType: HiveConstants.actionTypeBookmark,
          postId: postId,
        );
        return const Right(null);
      }

      await remoteDataSource.bookmarkPost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      // Revert local change
      await localDataSource.removeBookmarkedPostId(postId);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return const Right(null); // Already saved locally
    } catch (e) {
      await localDataSource.removeBookmarkedPostId(postId);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unbookmarkPost(String postId) async {
    try {
      // Remove locally first (optimistic update)
      await localDataSource.removeBookmarkedPostId(postId);

      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        // Queue offline action
        await queueOfflineAction(
          actionType: HiveConstants.actionTypeUnbookmark,
          postId: postId,
        );
        return const Right(null);
      }

      await remoteDataSource.unbookmarkPost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      // Revert local change
      await localDataSource.addBookmarkedPostId(postId);
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return const Right(null); // Already removed locally
    } catch (e) {
      await localDataSource.addBookmarkedPostId(postId);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBookmarkedPostIds() async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          // Try to sync with server
          final bookmarkedIds = await remoteDataSource.getBookmarkedPostIds();

          // Update local cache
          final box = await Hive.openBox(HiveConstants.bookmarkedPostsBox);
          await box.put(HiveConstants.bookmarkedPostIdsKey, bookmarkedIds);

          return Right(bookmarkedIds);
        } catch (e) {
          // Fall back to local cache
          final localIds = await localDataSource.getBookmarkedPostIds();
          return Right(localIds);
        }
      } else {
        // Return local cache
        final localIds = await localDataSource.getBookmarkedPostIds();
        return Right(localIds);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getCachedFeed() async {
    try {
      final currentUserId = await _currentUserId;
      final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
      final cachedPosts = await localDataSource.getCachedFeed();

      return Right(
        cachedPosts
            .map(
              (post) => post.toEntity(
                currentUserId: currentUserId,
                bookmarkedIds: bookmarkedIds,
              ),
            )
            .toList(),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cacheFeed(List<PostEntity> posts) async {
    try {
      // This would need to convert entities back to API models
      // For now, caching is handled in getFeed
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> queueOfflineAction({
    required String actionType,
    required String postId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final action = {
        'actionType': actionType,
        'postId': postId,
        if (data != null) 'data': data,
      };

      await localDataSource.queueOfflineAction(action);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineActions() async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final actions = await localDataSource.getOfflineActions();

      for (var action in actions) {
        final actionType = action['actionType'];
        final postId = action['postId'];

        try {
          switch (actionType) {
            case HiveConstants.actionTypeLike:
            case HiveConstants.actionTypeUnlike:
              await remoteDataSource.likePost(postId);
              break;
            case HiveConstants.actionTypeComment:
              final text = action['data']['text'];
              await remoteDataSource.addComment(postId: postId, text: text);
              break;
            case HiveConstants.actionTypeBookmark:
              await remoteDataSource.bookmarkPost(postId);
              break;
            case HiveConstants.actionTypeUnbookmark:
              await remoteDataSource.unbookmarkPost(postId);
              break;
            case HiveConstants.actionTypeCreatePost:
              // Handle create post action if needed
              break;
          }
        } catch (e) {
          print('Failed to sync action: $actionType for post: $postId');
        }
      }

      // Clear synced actions
      await localDataSource.clearOfflineActions();

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
