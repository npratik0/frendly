import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;
  final String? gender;
  final String? dateOfBirth;
  final List<String> followers;
  final List<String> following;
  final List<String> savedPosts;
  final int postsCount;
  final DateTime createdAt;

  const UserProfileEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
    this.gender,
    this.dateOfBirth,
    required this.followers,
    required this.following,
    required this.savedPosts,
    required this.postsCount,
    required this.createdAt,
  });

  int get followersCount => followers.length;
  int get followingCount => following.length;
  int get savedPostsCount => savedPosts.length;

  bool isFollowing(String userId) => followers.contains(userId);

  UserProfileEntity copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? bio,
    String? gender,
    String? dateOfBirth,
    List<String>? followers,
    List<String>? following,
    List<String>? savedPosts,
    int? postsCount,
    DateTime? createdAt,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      savedPosts: savedPosts ?? this.savedPosts,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    email,
    phoneNumber,
    profilePicture,
    bio,
    gender,
    dateOfBirth,
    followers,
    following,
    savedPosts,
    postsCount,
    createdAt,
  ];
}
