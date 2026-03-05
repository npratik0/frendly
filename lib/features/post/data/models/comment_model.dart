import '../../domain/entities/comment_entity.dart';
import 'post_api_model.dart';

class CommentModel {
  final String? id;
  final UserInfoModel user;
  final String text;
  final String createdAt;

  CommentModel({
    this.id,
    required this.user,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? json['id'],
      user: UserInfoModel.fromJson(json['user']),
      text: json['text'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'user': user.toJson(),
      'text': text,
      'createdAt': createdAt,
    };
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      user: user.toEntity(),
      text: text,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
