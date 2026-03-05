import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class FollowUserParams extends Equatable {
  final String userId;
  final bool shouldFollow; // true = follow, false = unfollow

  const FollowUserParams({required this.userId, required this.shouldFollow});

  @override
  List<Object?> get props => [userId, shouldFollow];
}

class FollowUserUseCase
    implements UseCase<UserProfileEntity, FollowUserParams> {
  final ProfileRepository repository;

  FollowUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(
    FollowUserParams params,
  ) async {
    if (params.shouldFollow) {
      return await repository.followUser(params.userId);
    } else {
      return await repository.unfollowUser(params.userId);
    }
  }
}
