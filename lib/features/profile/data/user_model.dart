import 'package:frendly/features/profile/domain/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    super.fullName,
    super.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      username: json['username'],
      fullName: json['fullName'],
      imageUrl: json['imageUrl'],
    );
  }
}
