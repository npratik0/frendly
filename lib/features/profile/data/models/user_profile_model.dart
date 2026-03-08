import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel {
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
  final String createdAt;

  UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert list to List<String>
    List<String> _parseStringList(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    }

    return UserProfileModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      bio: json['bio']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      // ✅ FIXED: Safely parse lists
      followers: _parseStringList(json['followers']),
      following: _parseStringList(json['following']),
      savedPosts: _parseStringList(json['savedPosts']),
      postsCount: (json['postsCount'] is int)
          ? json['postsCount']
          : int.tryParse(json['postsCount']?.toString() ?? '0') ?? 0,
      createdAt:
          json['createdAt']?.toString() ??
          json['updatedAt']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'bio': bio,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'followers': followers,
      'following': following,
      'savedPosts': savedPosts,
      'postsCount': postsCount,
      'createdAt': createdAt,
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      username: username,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      bio: bio,
      gender: gender,
      dateOfBirth: dateOfBirth,
      followers: followers,
      following: following,
      savedPosts: savedPosts,
      postsCount: postsCount,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
