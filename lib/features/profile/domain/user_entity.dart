class UserEntity {
  final String id;
  final String username;
  final String? fullName;
  final String? imageUrl;

  UserEntity({
    required this.id,
    required this.username,
    this.fullName,
    this.imageUrl,
  });
}
