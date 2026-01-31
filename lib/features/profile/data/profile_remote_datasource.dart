import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frendly/features/profile/data/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSource(this.dio);

  Future<UserModel> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final response = await dio.get(
      "/api/auth/whoami",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return UserModel.fromJson(response.data["data"]);
  }

  Future<UserModel> uploadImage(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(image.path),
    });

    final response = await dio.put(
      "/api/auth/update-profile",
      data: formData,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return UserModel.fromJson(response.data["data"]);
  }
}
