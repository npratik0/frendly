import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? password;
  final String dateOfBirth;
  final String gender;
  final String? profilePicture;
  final String? bio;

  AuthEntity({
    this.authId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.password,
    required this.dateOfBirth,
    required this.gender,
    this.profilePicture,
    this.bio,
  });

  @override
  List<Object?> get props => [
    authId,
    username,
    email,
    fullName,
    phoneNumber,
    password,
    dateOfBirth,
    gender,
    profilePicture,
    bio,
  ];
}
