import '../../domain/entities/search_user_entity.dart';

class SearchUserModel {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? profilePicture;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;

  SearchUserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.profilePicture,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'profilePicture': profilePicture,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
    };
  }

  SearchUserEntity toEntity() {
    return SearchUserEntity(
      id: id,
      username: username,
      fullName: fullName,
      email: email,
      profilePicture: profilePicture,
      followersCount: followersCount,
      followingCount: followingCount,
      isFollowing: isFollowing,
    );
  }

  factory SearchUserModel.fromEntity(SearchUserEntity entity) {
    return SearchUserModel(
      id: entity.id,
      username: entity.username,
      fullName: entity.fullName,
      email: entity.email,
      profilePicture: entity.profilePicture,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      isFollowing: entity.isFollowing,
    );
  }
}
