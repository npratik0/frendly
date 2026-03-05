import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/local/post_local_datasource.dart';
import '../../data/datasources/remote/post_remote_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/bookmark_post_usecase.dart';
import '../../domain/usecases/comment_post_usecase.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/usecases/like_post_usecase.dart';

// Providers for dependencies
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(Connectivity()),
);

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

final postLocalDataSourceProvider = Provider<PostLocalDataSource>((ref) {
  return PostLocalDataSourceImpl();
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    remoteDataSource: ref.read(postRemoteDataSourceProvider),
    localDataSource: ref.read(postLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use cases
final getFeedUseCaseProvider = Provider<GetFeedUseCase>((ref) {
  return GetFeedUseCase(ref.read(postRepositoryProvider));
});

final likePostUseCaseProvider = Provider<LikePostUseCase>((ref) {
  return LikePostUseCase(ref.read(postRepositoryProvider));
});

final commentPostUseCaseProvider = Provider<CommentPostUseCase>((ref) {
  return CommentPostUseCase(ref.read(postRepositoryProvider));
});

final bookmarkPostUseCaseProvider = Provider<BookmarkPostUseCase>((ref) {
  return BookmarkPostUseCase(ref.read(postRepositoryProvider));
});

// Post Feed State
class PostFeedState {
  final List<PostEntity> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  PostFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  PostFeedState copyWith({
    List<PostEntity>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return PostFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Post Feed Notifier - UPDATED FOR RIVERPOD 3.x
class PostFeedNotifier extends Notifier<PostFeedState> {
  @override
  PostFeedState build() {
    return PostFeedState();
  }

  GetFeedUseCase get _getFeedUseCase => ref.read(getFeedUseCaseProvider);
  LikePostUseCase get _likePostUseCase => ref.read(likePostUseCaseProvider);
  CommentPostUseCase get _commentPostUseCase =>
      ref.read(commentPostUseCaseProvider);
  BookmarkPostUseCase get _bookmarkPostUseCase =>
      ref.read(bookmarkPostUseCaseProvider);
  PostRepository get _repository => ref.read(postRepositoryProvider);

  // Fetch feed
  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      state = PostFeedState(isLoading: true);
    } else if (state.isLoadingMore || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final result = await _getFeedUseCase(
      GetFeedParams(page: refresh ? 1 : state.currentPage),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (posts) {
        if (refresh) {
          state = PostFeedState(
            posts: posts,
            isLoading: false,
            currentPage: 2,
            hasMore: posts.length >= 10,
          );
        } else {
          state = state.copyWith(
            posts: [...state.posts, ...posts],
            isLoading: false,
            isLoadingMore: false,
            currentPage: state.currentPage + 1,
            hasMore: posts.length >= 10,
          );
        }
      },
    );
  }

  // Load more posts
  Future<void> loadMore() async {
    if (!state.isLoadingMore && state.hasMore) {
      await fetchFeed();
    }
  }

  // Refresh feed
  Future<void> refresh() async {
    await fetchFeed(refresh: true);
    // Sync offline actions
    await _repository.syncOfflineActions();
  }

  // Like/Unlike post
  Future<void> likePost(String postId) async {
    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        final isLiked = post.isLiked;
        final newLikes = isLiked
            ? post.likes.where((id) => id != post.user.id).toList()
            : [...post.likes, post.user.id];

        return post.copyWith(isLiked: !isLiked, likes: newLikes);
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    // Make API call
    final result = await _likePostUseCase(postId);

    result.fold(
      (failure) {
        // Revert on failure
        state = state.copyWith(posts: state.posts);
      },
      (updatedPost) {
        // Update with server response
        final posts = state.posts.map((post) {
          if (post.id == postId) {
            return updatedPost;
          }
          return post;
        }).toList();

        state = state.copyWith(posts: posts);
      },
    );
  }

  // Add comment
  Future<bool> addComment(String postId, String text) async {
    final result = await _commentPostUseCase(
      CommentPostParams(postId: postId, text: text),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedPost) {
        final posts = state.posts.map((post) {
          if (post.id == postId) {
            return updatedPost;
          }
          return post;
        }).toList();

        state = state.copyWith(posts: posts);
        return true;
      },
    );
  }

  // Bookmark post
  Future<void> bookmarkPost(String postId, bool isBookmarked) async {
    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(isBookmarked: !isBookmarked);
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    // Make API call
    final result = await _bookmarkPostUseCase(
      BookmarkPostParams(postId: postId, isBookmarked: isBookmarked),
    );

    result.fold(
      (failure) {
        // Revert on failure (except for network failures - offline mode)
        if (failure.message != 'No internet connection') {
          final revertedPosts = state.posts.map((post) {
            if (post.id == postId) {
              return post.copyWith(isBookmarked: isBookmarked);
            }
            return post;
          }).toList();

          state = state.copyWith(posts: revertedPosts);
        }
      },
      (_) {
        // Success - state already updated optimistically
      },
    );
  }

  // Add new post (from create post screen)
  void addNewPost(PostEntity post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    final result = await _repository.deletePost(postId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        final updatedPosts = state.posts
            .where((post) => post.id != postId)
            .toList();
        state = state.copyWith(posts: updatedPosts);
        return true;
      },
    );
  }
}

// Provider for the post feed - UPDATED FOR RIVERPOD 3.x
final postFeedProvider = NotifierProvider<PostFeedNotifier, PostFeedState>(() {
  return PostFeedNotifier();
});

// Network connectivity provider
final connectivityProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.read(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});
