import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/presentation/providers/post_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/get_saved_posts_usecase.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSourceImpl(dioClient: ref.read(dioClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Cases
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.read(profileRepositoryProvider));
});

final getUserPostsUseCaseProvider = Provider<GetUserPostsUseCase>((ref) {
  return GetUserPostsUseCase(ref.read(profileRepositoryProvider));
});

final getSavedPostsUseCaseProvider = Provider<GetSavedPostsUseCase>((ref) {
  return GetSavedPostsUseCase(ref.read(profileRepositoryProvider));
});

final followUserUseCaseProvider = Provider<FollowUserUseCase>((ref) {
  return FollowUserUseCase(ref.read(profileRepositoryProvider));
});

class ProfileState {
  final UserProfileEntity? profile;
  final List<PostEntity> userPosts;
  final List<PostEntity> savedPosts;
  final bool isLoading;
  final bool isLoadingPosts;
  final bool isLoadingSaved;
  final String? error;
  final bool isCurrentUser;

  ProfileState({
    this.profile,
    this.userPosts = const [],
    this.savedPosts = const [],
    this.isLoading = false,
    this.isLoadingPosts = false,
    this.isLoadingSaved = false,
    this.error,
    this.isCurrentUser = false,
  });

  ProfileState copyWith({
    UserProfileEntity? profile,
    List<PostEntity>? userPosts,
    List<PostEntity>? savedPosts,
    bool? isLoading,
    bool? isLoadingPosts,
    bool? isLoadingSaved,
    String? error,
    bool? isCurrentUser,
    bool clearError = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      userPosts: userPosts ?? this.userPosts,
      savedPosts: savedPosts ?? this.savedPosts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isLoadingSaved: isLoadingSaved ?? this.isLoadingSaved,
      error: clearError ? null : (error ?? this.error),
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  String? _currentUserId;
  bool _isLoadingProfile = false;

  @override
  ProfileState build() {
    return ProfileState();
  }

  GetUserProfileUseCase get _getUserProfileUseCase =>
      ref.read(getUserProfileUseCaseProvider);
  GetUserPostsUseCase get _getUserPostsUseCase =>
      ref.read(getUserPostsUseCaseProvider);
  GetSavedPostsUseCase get _getSavedPostsUseCase =>
      ref.read(getSavedPostsUseCaseProvider);
  FollowUserUseCase get _followUserUseCase =>
      ref.read(followUserUseCaseProvider);

  // Load profile data
  // Future<void> loadProfile(String userId, String? currentUserId) async {
  //   _currentUserId = currentUserId;
  //   state = state.copyWith(
  //     isLoading: true,
  //     clearError: true,
  //     isCurrentUser: userId == currentUserId,
  //   );

  //   final result = await _getUserProfileUseCase(userId);

  //   result.fold(
  //     (failure) {
  //       state = state.copyWith(isLoading: false, error: failure.message);
  //     },
  //     (profile) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         profile: profile,
  //         clearError: true,
  //       );

  //       // Auto-load posts
  //       loadUserPosts(userId);

  //       // Load saved posts if current user
  //       if (state.isCurrentUser) {
  //         loadSavedPosts();
  //       }
  //     },
  //   );
  // }

  Future<void> loadProfile(String userId, String? currentUserId) async {
    // ✅ Prevent multiple simultaneous loads
    if (_isLoadingProfile) {
      print('⚠️ Profile already loading, skipping...');
      return;
    }

    _isLoadingProfile = true;
    _currentUserId = currentUserId;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isCurrentUser: userId == currentUserId,
    );

    final result = await _getUserProfileUseCase(userId);

    _isLoadingProfile = false; // ✅ Reset guard

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (profile) {
        state = state.copyWith(
          isLoading: false,
          profile: profile,
          clearError: true,
        );

        // Auto-load posts
        loadUserPosts(userId);

        // Load saved posts if current user
        if (state.isCurrentUser) {
          loadSavedPosts();
        }
      },
    );
  }

  // Load user posts
  Future<void> loadUserPosts(String userId) async {
    state = state.copyWith(isLoadingPosts: true, clearError: true);

    final result = await _getUserPostsUseCase(userId);

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingPosts: false, error: failure.message);
      },
      (posts) {
        state = state.copyWith(
          isLoadingPosts: false,
          userPosts: posts,
          profile: state.profile?.copyWith(postsCount: posts.length),
          clearError: true,
        );
      },
    );
  }

  // Load saved posts
  Future<void> loadSavedPosts() async {
    state = state.copyWith(isLoadingSaved: true, clearError: true);

    final result = await _getSavedPostsUseCase(NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(isLoadingSaved: false, error: failure.message);
      },
      (posts) {
        state = state.copyWith(
          isLoadingSaved: false,
          savedPosts: posts,
          clearError: true,
        );
      },
    );
  }

  // Follow/Unfollow user
  Future<void> toggleFollow(String userId) async {
    if (state.profile == null || _currentUserId == null) return;

    final isFollowing = state.profile!.followers.contains(_currentUserId);

    // Optimistic update
    final updatedProfile = state.profile!.copyWith(
      followers: isFollowing
          ? state.profile!.followers
                .where((id) => id != _currentUserId)
                .toList()
          : [...state.profile!.followers, _currentUserId!],
    );

    state = state.copyWith(profile: updatedProfile);

    // API call
    final result = await _followUserUseCase(
      FollowUserParams(userId: userId, shouldFollow: !isFollowing),
    );

    result.fold(
      (failure) {
        // Revert on failure
        state = state.copyWith(profile: state.profile);
        state = state.copyWith(error: failure.message);
      },
      (profile) {
        state = state.copyWith(profile: profile, clearError: true);
      },
    );
  }

  // Refresh all data
  Future<void> refresh(String userId, String? currentUserId) async {
    await loadProfile(userId, currentUserId);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});
