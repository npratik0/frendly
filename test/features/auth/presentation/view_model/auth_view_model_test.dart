// import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/features/auth/domain/usecases/login_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/register_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:frendly/features/auth/presentation/state/auth_state.dart';
import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../fixtures/auth_fixtures.dart';
import 'auth_view_model_test.mocks.dart';

@GenerateMocks([LoginUsecase, RegisterUsecase, UploadPhotoUsecase])
void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late ProviderContainer container;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();

    container = ProviderContainer(
      overrides: [
        LoginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        RegisterUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel - Initial State', () {
    test('should have initial state on build', () {
      // Act
      final state = container.read(authViewModelProvider);

      // Assert
      expect(state.status, AuthStatus.initial);
      expect(state.errorMessage, null);
      expect(state.authEntity, null);
      expect(state.uploadedPhotoUrl, null);
    });
  });

  group('AuthViewModel - Login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tAuthEntity = AuthFixtures.testAuthEntity;

    test('should emit loading then error when login fails', () async {
      // Arrange
      final tFailure = ApiFailure(
        message: 'Invalid credentials',
        statusCode: 401,
      );
      when(mockLoginUsecase.call(any)).thenAnswer((_) async => Left(tFailure));

      // Act
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final finalState = container.read(authViewModelProvider);
      expect(finalState.status, AuthStatus.error);
      expect(finalState.errorMessage, 'Invalid credentials');
      expect(finalState.authEntity, null);
    });

    test('should emit loading then error with LocalDatabaseFailure', () async {
      // Arrange
      final tFailure = LocalDatabaseFailure(
        message: 'Invalid email or password',
      );
      when(mockLoginUsecase.call(any)).thenAnswer((_) async => Left(tFailure));

      // Act
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final finalState = container.read(authViewModelProvider);
      expect(finalState.status, AuthStatus.error);
      expect(finalState.errorMessage, 'Invalid email or password');
    });
  });

  group('AuthViewModel - Register', () {
    test(
      'should emit loading then registered when registration succeeds',
      () async {
        // Arrange
        when(
          mockRegisterUsecase.call(any),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.register(
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
        final finalState = container.read(authViewModelProvider);
        expect(finalState.status, AuthStatus.registered);
        expect(finalState.errorMessage, null);

        verify(
          mockRegisterUsecase.call(
            argThat(
              isA<RegisterUsecaseParam>()
                  .having((p) => p.username, 'username', 'testuser')
                  .having((p) => p.email, 'email', 'test@example.com')
                  .having((p) => p.fullName, 'fullName', 'Test User')
                  .having((p) => p.password, 'password', 'password123'),
            ),
          ),
        );
      },
    );

    test('should emit loading then error when registration fails', () async {
      // Arrange
      final tFailure = ApiFailure(
        message: 'Email already exists',
        statusCode: 400,
      );
      when(
        mockRegisterUsecase.call(any),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.register(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
      );

      // Assert
      final finalState = container.read(authViewModelProvider);
      expect(finalState.status, AuthStatus.error);
      expect(finalState.errorMessage, 'Email already exists');
    });

    test('should handle registration with optional fields as null', () async {
      // Arrange
      when(
        mockRegisterUsecase.call(any),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.register(
        username: 'testuser',
        email: 'test@example.com',
        fullName: 'Test User',
        phoneNumber: '+977-9876543210',
        password: 'password123',
        confirmPassword: 'password123',
        dateOfBirth: '1990-01-01',
        gender: 'male',
      );

      // Assert
      verify(
        mockRegisterUsecase.call(
          argThat(
            isA<RegisterUsecaseParam>()
                .having((p) => p.profilePicture, 'profilePicture', null)
                .having((p) => p.bio, 'bio', null),
          ),
        ),
      );
    });
  });

  group('AuthViewModel - Reset State', () {
    test('should reset state to initial', () async {
      // Arrange - First login to change state
      when(
        mockLoginUsecase.call(any),
      ).thenAnswer((_) async => Right(AuthFixtures.testAuthEntity));

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: 'test@example.com', password: 'password123');

      // Verify state changed
      expect(
        container.read(authViewModelProvider).status,
        AuthStatus.authenticated,
      );

      // Act - Reset state
      viewModel.resetState();

      // Assert
      final finalState = container.read(authViewModelProvider);
      expect(finalState.status, AuthStatus.initial);
      expect(finalState.errorMessage, null);
      expect(finalState.authEntity, null);
      expect(finalState.uploadedPhotoUrl, null);
    });
  });
}
