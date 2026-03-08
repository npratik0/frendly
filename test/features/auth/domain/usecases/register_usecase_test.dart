import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';
import 'package:frendly/features/auth/domain/repositories/auth_repository.dart';
import 'package:frendly/features/auth/domain/usecases/register_usecase.dart';

import 'register_usecase_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  late RegisterUsecase usecase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    usecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  group('RegisterUsecase', () {
    final tParams = RegisterUsecaseParam(
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

    test('should register user successfully through repository', () async {
      // Arrange
      when(
        mockAuthRepository.register(any),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase.call(tParams);

      // Assert
      expect(result, const Right(true));
      verify(mockAuthRepository.register(any));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when registration fails', () async {
      // Arrange
      final tFailure = ApiFailure(
        message: 'Email already exists',
        statusCode: 400,
      );
      when(
        mockAuthRepository.register(any),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase.call(tParams);

      // Assert
      expect(result, Left(tFailure));
      verify(mockAuthRepository.register(any));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return LocalDatabaseFailure when offline registration fails',
      () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(message: 'Registration failed');
        when(
          mockAuthRepository.register(any),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase.call(tParams);

        // Assert
        expect(result, Left(tFailure));
        verify(mockAuthRepository.register(any));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should convert params to AuthEntity correctly', () async {
      // Arrange
      AuthEntity? capturedEntity;
      when(mockAuthRepository.register(any)).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return const Right(true);
      });

      // Act
      await usecase.call(tParams);

      // Assert
      expect(capturedEntity, isNotNull);
      expect(capturedEntity!.username, tParams.username);
      expect(capturedEntity!.email, tParams.email);
      expect(capturedEntity!.fullName, tParams.fullName);
      expect(capturedEntity!.phoneNumber, tParams.phoneNumber);
      expect(capturedEntity!.password, tParams.password);
      expect(capturedEntity!.dateOfBirth, tParams.dateOfBirth);
      expect(capturedEntity!.gender, tParams.gender);
      expect(capturedEntity!.profilePicture, tParams.profilePicture);
      expect(capturedEntity!.bio, tParams.bio);
    });

    test('should handle optional fields correctly', () async {
      // Arrange
      final paramsWithoutOptional = RegisterUsecaseParam(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
      );

      AuthEntity? capturedEntity;
      when(mockAuthRepository.register(any)).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments[0] as AuthEntity;
        return const Right(true);
      });

      // Act
      await usecase.call(paramsWithoutOptional);

      // Assert
      expect(capturedEntity!.profilePicture, null);
      expect(capturedEntity!.bio, null);
    });
  });

  group('RegisterUsecaseParam', () {
    test('should have correct properties', () {
      // Arrange & Act
      final params = RegisterUsecaseParam(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
        profilePicture: 'profile.jpg',
        bio: 'Test bio',
      );

      // Assert
      expect(params.username, 'testuser');
      expect(params.email, 'test@example.com');
      expect(params.fullName, 'Test User');
      expect(params.phoneNumber, '+977-9876543210');
      expect(params.password, 'password123');
      expect(params.confirmPassword, 'password123');
      expect(params.dateOfBirth, '1990-01-01');
      expect(params.gender, 'male');
      expect(params.profilePicture, 'profile.jpg');
      expect(params.bio, 'Test bio');
    });

    test('should support equality comparison', () {
      // Arrange
      final params1 = RegisterUsecaseParam(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
      );

      final params2 = RegisterUsecaseParam(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
      );

      final params3 = RegisterUsecaseParam(
        username: 'otheruser',
        email: 'other@example.com',
        fullName: 'Other User',
        phoneNumber: '+977-1234567890',
        password: 'password456',
        confirmPassword: 'password456',
        dateOfBirth: '1995-05-05',
        gender: 'female',
      );

      // Assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should include all fields in props', () {
      // Arrange
      final params = RegisterUsecaseParam(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
        profilePicture: 'profile.jpg',
        bio: 'Test bio',
      );

      // Assert
      expect(params.props.length, 10);
      expect(params.props, contains('testuser'));
      expect(params.props, contains('test@example.com'));
      expect(params.props, contains('Test User'));
    });
  });
}
