import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import 'package:frendly/features/auth/data/models/auth_api_model.dart';
// import 'package:frendly/features/auth/data/models/auth_hive_models.dart';

class AuthFixtures {
  // Test Auth Entity
  static AuthEntity testAuthEntity = AuthEntity(
    authId: '123456',
    username: 'testuser',
    email: 'test@example.com',
    fullName: 'Test User',
    phoneNumber: '+977-9876543210',
    password: 'password123',
    confirmPassword: 'password123',
    dateOfBirth: '1990-01-01',
    gender: 'male',
    profilePicture: 'https://example.com/profile.jpg',
    bio: 'Test bio',
  );

  // Test Auth API Model
  static AuthApiModel testAuthApiModel = AuthApiModel(
    authId: '123456',
    username: 'testuser',
    email: 'test@example.com',
    fullName: 'Test User',
    phoneNumber: '+977-9876543210',
    password: 'password123',
    confirmPassword: 'password123',
    dateOfBirth: '1990-01-01',
    gender: 'male',
    profilePicture: 'https://example.com/profile.jpg',
  );

  // Test JSON
  static Map<String, dynamic> testAuthJson = {
    '_id': '123456',
    'username': 'testuser',
    'email': 'test@example.com',
    'fullName': 'Test User',
    'phoneNumber': '+977-9876543210',
    'password': 'password123',
    'confirmPassword': 'password123',
    'dateOfBirth': '1990-01-01',
    'gender': 'male',
    'profilePicture': 'https://example.com/profile.jpg',
  };

  // Login credentials
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String invalidEmail = 'invalid@example.com';
  static const String invalidPassword = 'wrongpassword';
}
