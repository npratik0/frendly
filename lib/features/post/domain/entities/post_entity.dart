import 'package:equatable/equatable.dart';
import 'comment_entity.dart';

class PostEntity extends Equatable {
  final String id;
  final UserInfo user;
  final String caption;
  final String imageUrl;
  final List<String> likes;
  final List<CommentEntity> comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;
  final bool isBookmarked;

  const PostEntity({
    required this.id,
    required this.user,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  PostEntity copyWith({
    String? id,
    UserInfo? user,
    String? caption,
    String? imageUrl,
    List<String>? likes,
    List<CommentEntity>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return PostEntity(
      id: id ?? this.id,
      user: user ?? this.user,
      caption: caption ?? this.caption,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        user,
        caption,
        imageUrl,
        likes,
        comments,
        createdAt,
        updatedAt,
        isLiked,
        isBookmarked,
      ];
}

class UserInfo extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String? profilePicture;

  const UserInfo({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [id, username, fullName, profilePicture];
}
