import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/search_user_entity.dart';
import '../../domain/entities/recent_search_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../datasources/search_local_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers(
    String query,
  ) async {
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final users = await remoteDataSource.searchUsers(query);
      return Right(users.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<RecentSearchEntity>>> getRecentSearches() async {
    try {
      final searches = await localDataSource.getRecentSearches();
      return Right(searches.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to get recent searches'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRecentSearch(String query) async {
    try {
      await localDataSource.saveRecentSearch(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save recent search'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecentSearch(String query) async {
    try {
      await localDataSource.deleteRecentSearch(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete recent search'));
    }
  }

  @override
  Future<Either<Failure, void>> clearRecentSearches() async {
    try {
      await localDataSource.clearRecentSearches();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear recent searches'));
    }
  }
}
