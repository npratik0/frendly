import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(
    String userId,
  ) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final profileModel = await remoteDataSource.getUserProfile(userId);
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final postModels = await remoteDataSource.getUserPosts(userId);

      // Convert to entities (you'll need current user ID for isLiked)
      final posts = postModels.map((model) {
        return model.toEntity(
          currentUserId: null, // Get from your auth
          bookmarkedIds: [], // Get from your cache if needed
        );
      }).toList();

      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getSavedPosts() async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final postModels = await remoteDataSource.getSavedPosts();

      final posts = postModels.map((model) {
        return model.toEntity(currentUserId: null, bookmarkedIds: []);
      }).toList();

      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> followUser(String userId) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final profileModel = await remoteDataSource.followUser(userId);
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> unfollowUser(String userId) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final profileModel = await remoteDataSource.unfollowUser(userId);
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
