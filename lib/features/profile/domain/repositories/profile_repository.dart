import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId);
  Future<Either<Failure, List<PostEntity>>> getUserPosts(String userId);
  Future<Either<Failure, List<PostEntity>>> getSavedPosts();
  Future<Either<Failure, UserProfileEntity>> followUser(String userId);
  Future<Either<Failure, UserProfileEntity>> unfollowUser(String userId);
}
