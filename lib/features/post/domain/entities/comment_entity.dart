import 'package:equatable/equatable.dart';
import 'post_entity.dart';

class CommentEntity extends Equatable {
  final String? id;
  final UserInfo user;
  final String text;
  final DateTime createdAt;

  const CommentEntity({
    this.id,
    required this.user,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, user, text, createdAt];
}
