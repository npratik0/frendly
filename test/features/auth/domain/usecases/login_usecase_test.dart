import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/features/auth/domain/repositories/auth_repository.dart';
import 'package:frendly/features/auth/domain/usecases/login_usecase.dart';

import '../../fixtures/auth_fixtures.dart';
import 'login_usecase_test.mocks.dart';

@GenerateMocks([IAuthRepository])
void main() {
  late LoginUsecase usecase;
  late MockIAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockIAuthRepository();
    usecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  group('LoginUsecase', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tAuthEntity = AuthFixtures.testAuthEntity;
    final tParams = LoginUsecaseParams(email: tEmail, password: tPassword);

    test('should get AuthEntity from the repository', () async {
      // Arrange
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(tAuthEntity));

      // Act
      final result = await usecase.call(tParams);

      // Assert
      expect(result, Right(tAuthEntity));
      verify(mockAuthRepository.login(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ApiFailure when login fails', () async {
      // Arrange
      final tFailure = ApiFailure(
        message: 'Invalid credentials',
        statusCode: 401,
      );
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase.call(tParams);

      // Assert
      expect(result, Left(tFailure));
      verify(mockAuthRepository.login(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test(
      'should return LocalDatabaseFailure when offline login fails',
      () async {
        // Arrange
        final tFailure = LocalDatabaseFailure(
          message: 'Invalid email or password',
        );
        when(
          mockAuthRepository.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => Left(tFailure));

        // Act
        final result = await usecase.call(tParams);

        // Assert
        expect(result, Left(tFailure));
        verify(mockAuthRepository.login(email: tEmail, password: tPassword));
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test('should pass correct email and password to repository', () async {
      // Arrange
      when(
        mockAuthRepository.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Right(tAuthEntity));

      // Act
      await usecase.call(tParams);

      // Assert
      verify(mockAuthRepository.login(email: tEmail, password: tPassword));
    });
  });

  group('LoginUsecaseParams', () {
    test('should have correct properties', () {
      // Arrange
      const tEmail = 'test@example.com';
      const tPassword = 'password123';

      // Act
      final params = LoginUsecaseParams(email: tEmail, password: tPassword);

      // Assert
      expect(params.email, tEmail);
      expect(params.password, tPassword);
    });

    test('should support equality comparison', () {
      // Arrange
      final params1 = LoginUsecaseParams(
        email: 'test@example.com',
        password: 'pass123',
      );
      final params2 = LoginUsecaseParams(
        email: 'test@example.com',
        password: 'pass123',
      );
      final params3 = LoginUsecaseParams(
        email: 'other@example.com',
        password: 'pass123',
      );

      // Assert
      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should include email and password in props', () {
      // Arrange
      const tEmail = 'test@example.com';
      const tPassword = 'password123';
      final params = LoginUsecaseParams(email: tEmail, password: tPassword);

      // Assert
      expect(params.props, [tEmail, tPassword]);
    });
  });
}
