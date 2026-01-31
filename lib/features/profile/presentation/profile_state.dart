import 'package:frendly/features/profile/domain/user_entity.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final UserEntity? user;
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.error,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    String? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}
