import 'package:equatable/equatable.dart';

class SearchUserEntity extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? profilePicture;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  const SearchUserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.profilePicture,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  SearchUserEntity copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? profilePicture,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
  }) {
    return SearchUserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    email,
    profilePicture,
    followersCount,
    followingCount,
    isFollowing,
  ];
}
