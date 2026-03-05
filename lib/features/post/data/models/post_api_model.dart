import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import 'comment_model.dart';

class PostApiModel {
  final String id;
  final UserInfoModel user;
  final String caption;
  final String imageUrl;
  final List<String> likes;
  final List<CommentModel> comments;
  final String createdAt;
  final String updatedAt;

  PostApiModel({
    required this.id,
    required this.user,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostApiModel.fromJson(Map<String, dynamic> json) {
    return PostApiModel(
      id: json['_id'] ?? json['id'] ?? '',
      user: UserInfoModel.fromJson(json['user']),
      caption: json['caption'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      likes: json['likes'] != null
          ? List<String>.from(json['likes'].map((like) {
              if (like is String) return like;
              if (like is Map) return like['_id'] ?? like['id'] ?? '';
              return '';
            }))
          : [],
      comments: json['comments'] != null
          ? List<CommentModel>.from(
              json['comments'].map((x) => CommentModel.fromJson(x)))
          : [],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments.map((x) => x.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PostEntity toEntity({String? currentUserId, List<String>? bookmarkedIds}) {
    return PostEntity(
      id: id,
      user: user.toEntity(),
      caption: caption,
      imageUrl: imageUrl,
      likes: likes,
      comments: comments.map((c) => c.toEntity()).toList(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isLiked: currentUserId != null && likes.contains(currentUserId),
      isBookmarked: bookmarkedIds?.contains(id) ?? false,
    );
  }
}

class UserInfoModel {
  final String id;
  final String username;
  final String fullName;
  final String? profilePicture;

  UserInfoModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicture,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'profilePicture': profilePicture,
    };
  }

  UserInfo toEntity() {
    return UserInfo(
      id: id,
      username: username,
      fullName: fullName,
      profilePicture: profilePicture,
    );
  }
}
