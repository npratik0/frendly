import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/api/api_client.dart';
import 'package:frendly/core/api/api_endpoints.dart';
import 'package:frendly/core/services/storage/user_session_service.dart';
import 'package:frendly/features/auth/data/datasources/auth_datasource.dart';
import 'package:frendly/features/auth/data/models/auth_api_model.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';

// Create a provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<AuthApiModel?> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data["data"] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(data);

      // Save session
      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
      );

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel model) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      // ApiEndpoints.students,
      data: model.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return model;
  }
}
