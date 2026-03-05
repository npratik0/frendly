import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/api/api_client.dart';
import 'package:frendly/core/api/api_endpoints.dart';
import 'package:frendly/core/services/storage/token_service.dart';
import 'package:frendly/core/services/storage/user_session_service.dart';
import 'package:frendly/features/auth/data/datasources/auth_datasource.dart';
import 'package:frendly/features/auth/data/models/auth_api_model.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:hive/hive.dart';

// Create a provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

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

      final authBox = await Hive.openBox('auth_box');
      await authBox.put('token', response.data['token']);
      await authBox.put('current_user', response.data['data']);
      print(
        '✅ Token saved to Hive: ${response.data['token'].substring(0, 30)}...',
      );

      // Save session
      await _userSessionService.saveUserSession(
        userId: user.authId!,
        email: user.email,
        fullName: user.fullName,
        username: user.username,
      );

      return user;
    }

    // save token
    final token = response.data['token'] as String?;
    await _tokenService.saveToken(token!);

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

  @override
  Future<String> uploadPhoto(File photo) async {
    final fileName = photo.path.split('/').last;
    final formData = FormData.fromMap({
      'itemPhoto': await MultipartFile.fromFile(photo.path, filename: fileName),
    });
    // Get token from token service
    final token = await _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      '/api/auth/upload-photo',
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'];
  }
}
