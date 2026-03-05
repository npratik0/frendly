import 'package:hive/hive.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/comment_entity.dart';
import 'post_api_model.dart';

part 'post_hive_model.g.dart';

// IMPORTANT: Using type IDs 10 and 11 to avoid conflict with your auth model (type ID 0)
@HiveType(typeId: 10)
class PostHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final String? profilePicture;

  @HiveField(5)
  final String caption;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final List<String> likes;

  @HiveField(8)
  final List<CommentHiveModel> comments;

  @HiveField(9)
  final String createdAt;

  @HiveField(10)
  final String updatedAt;

  PostHiveModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePicture,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostHiveModel.fromApiModel(PostApiModel apiModel) {
    return PostHiveModel(
      id: apiModel.id,
      userId: apiModel.user.id,
      username: apiModel.user.username,
      fullName: apiModel.user.fullName,
      profilePicture: apiModel.user.profilePicture,
      caption: apiModel.caption,
      imageUrl: apiModel.imageUrl,
      likes: apiModel.likes,
      comments: apiModel.comments
          .map((c) => CommentHiveModel.fromCommentModel(c))
          .toList(),
      createdAt: apiModel.createdAt,
      updatedAt: apiModel.updatedAt,
    );
  }

  PostEntity toEntity({String? currentUserId, List<String>? bookmarkedIds}) {
    return PostEntity(
      id: id,
      user: UserInfo(
        id: userId,
        username: username,
        fullName: fullName,
        profilePicture: profilePicture,
      ),
      caption: caption,
      imageUrl: imageUrl,
      likes: likes,
      comments: comments
          .map(
            (c) => CommentEntity(
              id: c.id,
              user: UserInfo(
                id: c.userId,
                username: c.username,
                fullName: c.fullName,
                profilePicture: c.profilePicture,
              ),
              text: c.text,
              createdAt: DateTime.parse(c.createdAt),
            ),
          )
          .toList(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isLiked: currentUserId != null && likes.contains(currentUserId),
      isBookmarked: bookmarkedIds?.contains(id) ?? false,
    );
  }
}

@HiveType(typeId: 11)
class CommentHiveModel extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String fullName;

  @HiveField(4)
  final String? profilePicture;

  @HiveField(5)
  final String text;

  @HiveField(6)
  final String createdAt;

  CommentHiveModel({
    this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePicture,
    required this.text,
    required this.createdAt,
  });

  factory CommentHiveModel.fromCommentModel(dynamic commentModel) {
    return CommentHiveModel(
      id: commentModel.id,
      userId: commentModel.user.id,
      username: commentModel.user.username,
      fullName: commentModel.user.fullName,
      profilePicture: commentModel.user.profilePicture,
      text: commentModel.text,
      createdAt: commentModel.createdAt,
    );
  }
}
