import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frendly/core/error/failures.dart';
import 'package:frendly/core/services/connectivity/network_info.dart';
import 'package:frendly/features/auth/data/datasources/auth_datasource.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:frendly/features/auth/data/repositories/auth_repository.dart';
import 'package:frendly/features/auth/domain/entities/auth_entity.dart';

import '../../fixtures/auth_fixtures.dart';
import 'auth_repository_test.mocks.dart';

@GenerateMocks([IAuthDatasource, IAuthRemoteDatasource, NetworkInfo])
void main() {
  late AuthRepository repository;
  late MockIAuthDatasource mockLocalDatasource;
  late MockIAuthRemoteDatasource mockRemoteDatasource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDatasource = MockIAuthDatasource();
    mockRemoteDatasource = MockIAuthRemoteDatasource();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepository(
      authDatasource: mockLocalDatasource,
      authRemoteDatasource: mockRemoteDatasource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    final tAuthApiModel = AuthFixtures.testAuthApiModel;
    final tAuthEntity = AuthFixtures.testAuthEntity;

    test('should check if device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDatasource.login(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => tAuthApiModel);

      // Act
      await repository.login(email: tEmail, password: tPassword);

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => tAuthApiModel);

          // Act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          verify(
            mockRemoteDatasource.login(email: tEmail, password: tPassword),
          );
          expect(result, isA<Right<Failure, AuthEntity>>());
          result.fold((failure) => fail('Should return Right'), (entity) {
            expect(entity.email, tEmail);
            expect(entity.username, tAuthApiModel.username);
          });
        },
      );

      test(
        'should return ApiFailure when remote data source returns null',
        () async {
          // Arrange
          when(
            mockRemoteDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => null);

          // Act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          expect(result, isA<Left<Failure, AuthEntity>>());
          result.fold((failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, 'Login failed');
          }, (entity) => fail('Should return Left'));
        },
      );

      test('should return ApiFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
        );

        when(
          mockRemoteDatasource.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(dioException);

        // Act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, isA<Left<Failure, AuthEntity>>());
        result.fold((failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, 'Invalid credentials');
          expect((failure as ApiFailure).statusCode, 401);
        }, (entity) => fail('Should return Left'));
      });

      test(
        'should return ApiFailure with generic message when DioException has no response',
        () async {
          // Arrange
          final dioException = DioException(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            error: 'Network error',
          );

          when(
            mockRemoteDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(dioException);

          // Act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          expect(result, isA<Left<Failure, AuthEntity>>());
          result.fold((failure) {
            expect(failure, isA<ApiFailure>());
            expect(failure.message, 'Login failed');
          }, (entity) => fail('Should return Left'));
        },
      );

      test('should return ApiFailure when other exception occurs', () async {
        // Arrange
        when(
          mockRemoteDatasource.login(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.login(
          email: tEmail,
          password: tPassword,
        );

        // Assert
        expect(result, isA<Left<Failure, AuthEntity>>());
        result.fold((failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Exception: Unexpected error'));
        }, (entity) => fail('Should return Left'));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return local data when call to local data source is successful',
        () async {
          // Arrange
          final mockHiveModel = MockAuthHiveModel();
          when(
            mockLocalDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => mockHiveModel);
          when(mockHiveModel.toEntity()).thenReturn(tAuthEntity);

          // Act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          verify(mockLocalDatasource.login(email: tEmail, password: tPassword));
          verifyNever(
            mockRemoteDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          );
          expect(result, isA<Right<Failure, AuthEntity>>());
        },
      );

      test(
        'should return LocalDatabaseFailure when local data source returns null',
        () async {
          // Arrange
          when(
            mockLocalDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => null);

          // Act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          expect(result, isA<Left<Failure, AuthEntity>>());
          result.fold((failure) {
            expect(failure, isA<LocalDatabaseFailure>());
            expect(failure.message, 'Invalid email or password');
          }, (entity) => fail('Should return Left'));
        },
      );

      test(
        'should return LocalDatabaseFailure when local data source throws exception',
        () async {
          // Arrange
          when(
            mockLocalDatasource.login(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenThrow(Exception('Database error'));

          // Act
          final result = await repository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          expect(result, isA<Left<Failure, AuthEntity>>());
          result.fold((failure) {
            expect(failure, isA<LocalDatabaseFailure>());
            expect(failure.message, contains('Exception: Database error'));
          }, (entity) => fail('Should return Left'));
        },
      );
    });
  });

  group('register', () {
    final tAuthEntity = AuthFixtures.testAuthEntity;
    final tAuthApiModel = AuthFixtures.testAuthApiModel;

    test('should check if device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDatasource.register(any),
      ).thenAnswer((_) async => tAuthApiModel);

      // Act
      await repository.register(tAuthEntity);

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return true when remote registration is successful',
        () async {
          // Arrange
          when(
            mockRemoteDatasource.register(any),
          ).thenAnswer((_) async => tAuthApiModel);

          // Act
          final result = await repository.register(tAuthEntity);

          // Assert
          verify(mockRemoteDatasource.register(any));
          expect(result, const Right(true));
        },
      );

      test('should return ApiFailure when DioException occurs', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/api/auth/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/register'),
            statusCode: 400,
            data: {'message': 'Email already exists'},
          ),
        );

        when(mockRemoteDatasource.register(any)).thenThrow(dioException);

        // Act
        final result = await repository.register(tAuthEntity);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        result.fold((failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, 'Email already exists');
          expect((failure as ApiFailure).statusCode, 400);
        }, (success) => fail('Should return Left'));
      });

      test('should return ApiFailure when other exception occurs', () async {
        // Arrange
        when(
          mockRemoteDatasource.register(any),
        ).thenThrow(Exception('Server error'));

        // Act
        final result = await repository.register(tAuthEntity);

        // Assert
        expect(result, isA<Left<Failure, bool>>());
        result.fold((failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Exception: Server error'));
        }, (success) => fail('Should return Left'));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return true when local registration is successful',
        () async {
          // Arrange
          when(mockLocalDatasource.register(any)).thenAnswer((_) async => true);

          // Act
          final result = await repository.register(tAuthEntity);

          // Assert
          verify(mockLocalDatasource.register(any));
          verifyNever(mockRemoteDatasource.register(any));
          expect(result, const Right(true));
        },
      );

      test(
        'should return LocalDatabaseFailure when local registration fails',
        () async {
          // Arrange
          when(
            mockLocalDatasource.register(any),
          ).thenAnswer((_) async => false);

          // Act
          final result = await repository.register(tAuthEntity);

          // Assert
          expect(result, isA<Left<Failure, bool>>());
          result.fold((failure) {
            expect(failure, isA<LocalDatabaseFailure>());
            expect(failure.message, 'Registration failed');
          }, (success) => fail('Should return Left'));
        },
      );

      test(
        'should return LocalDatabaseFailure when exception occurs',
        () async {
          // Arrange
          when(
            mockLocalDatasource.register(any),
          ).thenThrow(Exception('Hive error'));

          // Act
          final result = await repository.register(tAuthEntity);

          // Assert
          expect(result, isA<Left<Failure, bool>>());
          result.fold((failure) {
            expect(failure, isA<LocalDatabaseFailure>());
            expect(failure.message, contains('Exception: Hive error'));
          }, (success) => fail('Should return Left'));
        },
      );
    });
  });

  group('getCurrentUser', () {
    final tAuthEntity = AuthFixtures.testAuthEntity;

    test('should return user from local datasource when user exists', () async {
      // Arrange
      final mockHiveModel = MockAuthHiveModel();
      when(
        mockLocalDatasource.getCurrentUser(),
      ).thenAnswer((_) async => mockHiveModel);
      when(mockHiveModel.toEntity()).thenReturn(tAuthEntity);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      verify(mockLocalDatasource.getCurrentUser());
      expect(result, isA<Right<Failure, AuthEntity>>());
      result.fold((failure) => fail('Should return Right'), (entity) {
        expect(entity.authId, tAuthEntity.authId);
        expect(entity.email, tAuthEntity.email);
      });
    });

    test('should return LocalDatabaseFailure when no user found', () async {
      // Arrange
      when(mockLocalDatasource.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isA<Left<Failure, AuthEntity>>());
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
        expect(failure.message, 'No current user found');
      }, (entity) => fail('Should return Left'));
    });

    test('should return LocalDatabaseFailure when exception occurs', () async {
      // Arrange
      when(
        mockLocalDatasource.getCurrentUser(),
      ).thenThrow(Exception('Database error'));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isA<Left<Failure, AuthEntity>>());
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
        expect(failure.message, contains('Exception: Database error'));
      }, (entity) => fail('Should return Left'));
    });
  });

  group('logout', () {
    test('should return true when logout is successful', () async {
      // Arrange
      when(mockLocalDatasource.logout()).thenAnswer((_) async => true);

      // Act
      final result = await repository.logout();

      // Assert
      verify(mockLocalDatasource.logout());
      expect(result, const Right(true));
    });

    test('should return LocalDatabaseFailure when logout fails', () async {
      // Arrange
      when(mockLocalDatasource.logout()).thenAnswer((_) async => false);

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, isA<Left<Failure, bool>>());
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
        expect(failure.message, 'Logout failed');
      }, (success) => fail('Should return Left'));
    });

    test('should return LocalDatabaseFailure when exception occurs', () async {
      // Arrange
      when(mockLocalDatasource.logout()).thenThrow(Exception('Logout error'));

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, isA<Left<Failure, bool>>());
      result.fold((failure) {
        expect(failure, isA<LocalDatabaseFailure>());
        expect(failure.message, contains('Exception: Logout error'));
      }, (success) => fail('Should return Left'));
    });
  });

  group('uploadPhoto', () {
    final tFile = File('test_photo.jpg');
    const tPhotoUrl = 'https://example.com/uploaded_photo.jpg';

    test('should check if device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockRemoteDatasource.uploadPhoto(any),
      ).thenAnswer((_) async => tPhotoUrl);

      // Act
      await repository.uploadPhoto(tFile);

      // Assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return photo URL when upload is successful', () async {
        // Arrange
        when(
          mockRemoteDatasource.uploadPhoto(any),
        ).thenAnswer((_) async => tPhotoUrl);

        // Act
        final result = await repository.uploadPhoto(tFile);

        // Assert
        verify(mockRemoteDatasource.uploadPhoto(tFile));
        expect(result, Right(tPhotoUrl));
      });

      test('should return ApiFailure when upload fails', () async {
        // Arrange
        when(
          mockRemoteDatasource.uploadPhoto(any),
        ).thenThrow(Exception('Upload failed'));

        // Act
        final result = await repository.uploadPhoto(tFile);

        // Assert
        expect(result, isA<Left<Failure, String>>());
        result.fold((failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Exception: Upload failed'));
        }, (url) => fail('Should return Left'));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when device is offline', () async {
        // Act
        final result = await repository.uploadPhoto(tFile);

        // Assert
        verifyNever(mockRemoteDatasource.uploadPhoto(any));
        expect(result, isA<Left<Failure, String>>());
        result.fold((failure) {
          expect(failure, isA<NetworkFailure>());
        }, (url) => fail('Should return Left'));
      });
    });
  });
}

// Mock class for AuthHiveModels
class MockAuthHiveModel extends Mock implements AuthHiveModels {
  @override
  AuthEntity toEntity() {
    return super.noSuchMethod(
      Invocation.method(#toEntity, []),
      returnValue: AuthFixtures.testAuthEntity,
    );
  }
}
