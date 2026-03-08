import 'package:flutter_test/flutter_test.dart';
import 'package:frendly/features/auth/data/models/auth_api_model.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import '../../fixtures/auth_fixtures.dart';

void main() {
  group('AuthApiModel', () {
    test('should be a subtype of AuthEntity when converted', () {
      // Arrange
      final model = AuthFixtures.testAuthApiModel;

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<AuthEntity>());
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Arrange
        final jsonMap = AuthFixtures.testAuthJson;

        // Act
        final result = AuthApiModel.fromJson(jsonMap);

        // Assert
        expect(result.authId, '123456');
        expect(result.username, 'testuser');
        expect(result.email, 'test@example.com');
        expect(result.fullName, 'Test User');
        expect(result.phoneNumber, '+977-9876543210');
        expect(result.dateOfBirth, '1990-01-01');
        expect(result.gender, 'male');
        expect(result.profilePicture, 'https://example.com/profile.jpg');
      });

      test('should handle missing optional fields', () {
        // Arrange
        final jsonMap = {
          '_id': '123456',
          'username': 'testuser',
          'email': 'test@example.com',
          'fullName': 'Test User',
          'phoneNumber': '+977-9876543210',
          'dateOfBirth': '1990-01-01',
          'gender': 'male',
        };

        // Act
        final result = AuthApiModel.fromJson(jsonMap);

        // Assert
        expect(result.authId, '123456');
        expect(result.profilePicture, null);
        expect(result.password, null);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        // Arrange
        final model = AuthFixtures.testAuthApiModel;

        // Act
        final result = model.toJson();

        // Assert
        expect(result['username'], 'testuser');
        expect(result['email'], 'test@example.com');
        expect(result['fullName'], 'Test User');
        expect(result['phoneNumber'], '+977-9876543210');
        expect(result['password'], 'password123');
        expect(result['dateOfBirth'], '1990-01-01');
        expect(result['gender'], 'male');
        expect(result['profilePicture'], 'https://example.com/profile.jpg');
      });

      test('should not include authId in JSON', () {
        // Arrange
        final model = AuthFixtures.testAuthApiModel;

        // Act
        final result = model.toJson();

        // Assert
        expect(result.containsKey('authId'), false);
        expect(result.containsKey('_id'), false);
      });
    });

    group('toEntity', () {
      test('should convert model to entity with all fields', () {
        // Arrange
        final model = AuthFixtures.testAuthApiModel;

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.authId, model.authId);
        expect(entity.username, model.username);
        expect(entity.email, model.email);
        expect(entity.fullName, model.fullName);
        expect(entity.phoneNumber, model.phoneNumber);
        expect(entity.dateOfBirth, model.dateOfBirth);
        expect(entity.gender, model.gender);
        expect(entity.profilePicture, model.profilePicture);
      });
    });

    group('fromEntity', () {
      test('should convert entity to model with all fields', () {
        // Arrange
        final entity = AuthFixtures.testAuthEntity;

        // Act
        final model = AuthApiModel.fromEntity(entity);

        // Assert
        expect(model.authId, entity.authId);
        expect(model.username, entity.username);
        expect(model.email, entity.email);
        expect(model.fullName, entity.fullName);
        expect(model.phoneNumber, entity.phoneNumber);
        expect(model.password, entity.password);
        expect(model.dateOfBirth, entity.dateOfBirth);
        expect(model.gender, entity.gender);
        expect(model.profilePicture, entity.profilePicture);
      });
    });

    group('toEntityList', () {
      test('should convert list of models to list of entities', () {
        // Arrange
        final models = [
          AuthFixtures.testAuthApiModel,
          AuthApiModel(
            authId: '789',
            username: 'user2',
            email: 'user2@example.com',
            fullName: 'User Two',
            phoneNumber: '+977-1234567890',
            dateOfBirth: '1995-05-05',
            gender: 'female',
          ),
        ];

        // Act
        final entities = AuthApiModel.toEntityList(models);

        // Assert
        expect(entities, isA<List<AuthEntity>>());
        expect(entities.length, 2);
        expect(entities[0].username, 'testuser');
        expect(entities[1].username, 'user2');
      });

      test('should return empty list when given empty list', () {
        // Arrange
        final models = <AuthApiModel>[];

        // Act
        final entities = AuthApiModel.toEntityList(models);

        // Assert
        expect(entities, isEmpty);
      });
    });
  });
}
