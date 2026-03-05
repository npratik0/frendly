import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/api/api_endpoints.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/api/api_response.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/post_api_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostApiModel>> getFeed({int page = 1});
  Future<List<PostApiModel>> getUserPosts(String userId);
  Future<PostApiModel> createPost({
    required XFile image,
    required String caption,
  });
  Future<PostApiModel> likePost(String postId);
  Future<PostApiModel> addComment({
    required String postId,
    required String text,
  });
  Future<PostApiModel> deleteComment({
    required String postId,
    required String commentId,
  });
  Future<void> deletePost(String postId);
  Future<void> bookmarkPost(String postId);
  Future<void> unbookmarkPost(String postId);
  Future<List<String>> getBookmarkedPostIds();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient dioClient;

  PostRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PostApiModel>> getFeed({int page = 1}) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.feed,
        queryParameters: {'page': page, 'limit': 10},
      );

      final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> postsJson = apiResponse.data as List<dynamic>;
        return postsJson.map((json) => PostApiModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch feed: $e');
    }
  }

  @override
  Future<List<PostApiModel>> getUserPosts(String userId) async {
    try {
      final response = await dioClient.get(ApiEndpoints.userPosts(userId));

      final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

      if (apiResponse.success && apiResponse.data != null) {
        final List<dynamic> postsJson = apiResponse.data as List<dynamic>;
        return postsJson.map((json) => PostApiModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch user posts: $e');
    }
  }

  @override
  Future<PostApiModel> createPost({
    required XFile image,
    required String caption,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'caption': caption,
        'image': await MultipartFile.fromFile(image.path, filename: image.name),
      });

      final response = await dioClient.postMultipart(
        ApiEndpoints.posts,
        formData: formData,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => PostApiModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to create post: $e');
    }
  }

  @override
  Future<PostApiModel> likePost(String postId) async {
    try {
      final response = await dioClient.post(ApiEndpoints.likePost(postId));

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => PostApiModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to like post: $e');
    }
  }

  @override
  Future<PostApiModel> addComment({
    required String postId,
    required String text,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.addComment(postId),
        data: {'text': text},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => PostApiModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to add comment: $e');
    }
  }

  @override
  Future<PostApiModel> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await dioClient.delete(
        ApiEndpoints.deleteComment(postId, commentId),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => PostApiModel.fromJson(data),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to delete comment: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final response = await dioClient.delete(ApiEndpoints.deletePost(postId));

      final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

      if (!apiResponse.success) {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to delete post: $e');
    }
  }

  @override
  Future<void> bookmarkPost(String postId) async {
    try {
      final response = await dioClient.post(ApiEndpoints.savePost(postId));

      final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

      if (!apiResponse.success) {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to bookmark post: $e');
    }
  }

  @override
  Future<void> unbookmarkPost(String postId) async {
    try {
      final response = await dioClient.post(ApiEndpoints.unsavePost(postId));

      final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

      if (!apiResponse.success) {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to unbookmark post: $e');
    }
  }

  @override
  Future<List<String>> getBookmarkedPostIds() async {
    try {
      final response = await dioClient.get(ApiEndpoints.getSavedPosts);

      final apiResponse = ApiResponse.fromJson(response.data, (data) => data);

      if (apiResponse.success && apiResponse.data != null) {
        return List<String>.from(apiResponse.data);
      } else {
        throw ServerException(
          message: apiResponse.message,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch bookmarked posts: $e');
    }
  }
}
