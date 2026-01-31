import 'package:frendly/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? authId;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? password;
  final String? confirmPassword;
  final String dateOfBirth;
  final String gender;
  final String? profilePicture;
  // final String? bio;

  AuthApiModel({
    this.authId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.password,
    this.confirmPassword,
    required this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    // this.bio,
  });

  // to JSON
  Map<String, dynamic> toJson() {
    return {
      // 'authId': authId,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      'confirmPassword': confirmPassword,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'profilePicture': profilePicture,
      // 'bio': bio,
    };
  }

  // from JSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: json['_id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      confirmPassword: json['confirmPassword'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      profilePicture: json['profilePicture'],
      // bio: json['bio'],
    );
  }

  // to Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      username: username,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      dateOfBirth: dateOfBirth,
      gender: gender,
      profilePicture: profilePicture,
      // bio: bio,
    );
  }

  // from Entity

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.authId,
      username: entity.username,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      profilePicture: entity.profilePicture,
      // bio: entity.bio,
    );
  }
  // toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
