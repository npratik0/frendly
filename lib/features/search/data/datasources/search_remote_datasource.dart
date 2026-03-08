import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/search_user_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchUserModel>> searchUsers(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient dioClient;

  SearchRemoteDataSourceImpl({required this.dioClient});

  // @override
  // Future<List<SearchUserModel>> searchUsers(String query) async {
  //   try {
  //     final response = await dioClient.get('/api/auth/search?query=$query');

  //     if (response.data['success'] == true) {
  //       final List<dynamic> usersData = response.data['data'] ?? [];
  //       return usersData.map((json) => SearchUserModel.fromJson(json)).toList();
  //     } else {
  //       throw ServerException(
  //         message: response.data['message'] ?? 'Failed to search users',
  //       );
  //     }
  //   } catch (e) {
  //     print('❌ Search Users Error: $e');
  //     throw ServerException(message: e.toString());
  //   }
  // }

  @override
  Future<List<SearchUserModel>> searchUsers(String query) async {
    // Only call API if query has 2 or more characters
    if (query.trim().length < 2) return [];

    try {
      final response = await dioClient.get(
        '/api/auth/search',
        queryParameters: {'q': query.trim()}, // must match backend
      );

      if (response.data['success'] == true) {
        final List<dynamic> usersData = response.data['data'] ?? [];
        return usersData.map((json) => SearchUserModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to search users',
        );
      }
    } catch (e) {
      print('❌ Search Users Error: $e');
      throw ServerException(message: e.toString());
    }
  }
}
