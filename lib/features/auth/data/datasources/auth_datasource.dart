import 'dart:io';

import 'package:frendly/features/auth/data/models/auth_api_model.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';

abstract interface class IAuthDatasource {
  Future<bool> register(AuthHiveModels model);
  Future<AuthHiveModels?> login({
    required String email,
    required String password,
  });
  Future<AuthHiveModels?> getCurrentUser();
  Future<bool> logout();

  // get email exist
  Future<bool> isEmailExist(String email);
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> register(AuthApiModel model);
  Future<AuthApiModel?> login({
    required String email,
    required String password,
  });
  Future<String> uploadPhoto(File photo);
}
