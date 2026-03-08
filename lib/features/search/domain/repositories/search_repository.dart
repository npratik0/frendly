import 'package:dartz/dartz.dart';
import 'package:frendly/features/search/domain/entities/search_user_entity.dart';
import '../../../../core/error/failures.dart';

import '../entities/recent_search_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchUserEntity>>> searchUsers(String query);
  Future<Either<Failure, List<RecentSearchEntity>>> getRecentSearches();
  Future<Either<Failure, void>> saveRecentSearch(String query);
  Future<Either<Failure, void>> deleteRecentSearch(String query);
  Future<Either<Failure, void>> clearRecentSearches();
}
