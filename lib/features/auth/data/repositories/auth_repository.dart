import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/features/auth/data/datasources/auth_datasource.dart';
import 'package:frendly/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import 'package:frendly/features/auth/domain/repositories/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authDatasource: ref.read(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepository({required IAuthDatasource authDatasource})
    : _authDatasource = authDatasource;

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

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authDatasource.login(
        email: email,
        password: password,
      );
      if (user != null) {
        return Right(user.toEntity());
      } else {
        return Left(LocalDatabaseFailure(message: "Invalid email or password"));
      }
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
