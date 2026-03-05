import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../../../post/data/models/post_api_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<List<PostApiModel>> getUserPosts(String userId);
  Future<List<PostApiModel>> getSavedPosts();
  Future<UserProfileModel> followUser(String userId);
  Future<UserProfileModel> unfollowUser(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final response = await dioClient.get('/api/auth/$userId');

      if (response.data['success'] == true) {
        return UserProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get profile',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PostApiModel>> getUserPosts(String userId) async {
    try {
      final response = await dioClient.get('/api/posts/user/$userId');

      if (response.data['success'] == true) {
        final List<dynamic> postsData = response.data['data'] ?? [];
        return postsData.map((json) => PostApiModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get posts',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PostApiModel>> getSavedPosts() async {
    try {
      // Adjust endpoint based on your backend
      final response = await dioClient.get('/api/posts/saved');

      if (response.data['success'] == true) {
        final List<dynamic> postsData = response.data['data'] ?? [];
        return postsData.map((json) => PostApiModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get saved posts',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileModel> followUser(String userId) async {
    try {
      final response = await dioClient.post('/api/auth/$userId/follow');

      if (response.data['success'] == true) {
        return UserProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to follow user',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserProfileModel> unfollowUser(String userId) async {
    try {
      final response = await dioClient.post('/api/auth/$userId/unfollow');

      if (response.data['success'] == true) {
        return UserProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to unfollow user',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
