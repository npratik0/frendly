import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/services/hive/hive_service.dart';
import 'package:frendly/features/auth/data/datasources/auth_datasource.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';

// Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<AuthHiveModels?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  // @override
  // Future<AuthHiveModels?> login({String email, String password}) async {
  //   try {
  //     final user = await _hiveService.loginUser(email, password);
  //     return Future.value(user);
  //   } catch (e) {
  //     return Future.value(null);
  //   }
  // }

  @override
  Future<AuthHiveModels?> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModels model) async {
    try {
      await _hiveService.registerUser(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> isEmailExist(String email) {
    try {
      final exists = _hiveService.isEmailExist(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }
}
