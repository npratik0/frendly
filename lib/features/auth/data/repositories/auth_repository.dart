import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/core/services/connectivity/network_info.dart';
import 'package:frendly/features/auth/data/datasources/auth_datasource.dart';
import 'package:frendly/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:frendly/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:frendly/features/auth/data/models/auth_api_model.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import 'package:frendly/features/auth/domain/repositories/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      } else {
        return Left(LocalDatabaseFailure(message: "No current user found"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return Right(true);
      } else {
        return Left(LocalDatabaseFailure(message: "Logout failed"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    if (await _networkInfo.isConnected) {
      try {
        // remote
        final apiModel = AuthApiModel.fromEntity(entity);
        await _authRemoteDatasource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // local
      try {
        final model = AuthHiveModels.fromEntity(entity);
        final result = await _authDatasource.register(model);
        if (result) {
          return Right(true);
        } else {
          return Left(LocalDatabaseFailure(message: "Registration failed"));
        }
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _authRemoteDatasource.uploadPhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        // final apiModel = await _authRemoteDatasource.login(email,password);
        final apiModel = await _authRemoteDatasource.login(
          email: email,
          password: password,
        );
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: "Login failed"));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authDatasource.login(
          email: email,
          password: password,
        );
        if (user != null) {
          return Right(user.toEntity());
        } else {
          return Left(
            LocalDatabaseFailure(message: "Invalid email or password"),
          );
        }
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
