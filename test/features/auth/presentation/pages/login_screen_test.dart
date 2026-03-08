import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frendly/features/auth/domain/usecases/login_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/register_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:frendly/features/auth/presentation/pages/login_screen.dart';
import 'package:frendly/core/services/storage/token_service.dart';
import 'package:frendly/core/error/failures.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([
  LoginUsecase,
  RegisterUsecase,
  UploadPhotoUsecase,
  TokenService,
])
void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;
  late MockTokenService mockTokenService;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
    mockTokenService = MockTokenService();

    // Default token service behavior
    when(mockTokenService.getToken()).thenAnswer((_) async => 'mock_token');
  });

  Widget createLoginScreen() {
    return ProviderScope(
      overrides: [
        LoginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        RegisterUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
        tokenServiceProvider.overrideWithValue(mockTokenService),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/register': (context) =>
              const Scaffold(body: Text('Register Screen')),
          '/bottom_navigation': (context) =>
              const Scaffold(body: Text('Home Screen')),
        },
      ),
    );
  }

  group('LoginScreen - UI Elements', () {
    testWidgets('should display all UI elements', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Assert
      expect(find.text('Frendly'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Welcome to Frendly!'), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Email and Password
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create new account'), findsOneWidget);
      expect(find.text('Or continue with'), findsOneWidget);
      expect(find.text('Login with Google'), findsOneWidget);
    });

    testWidgets('should have email field with correct hint', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Assert
      final emailField = find.widgetWithText(TextFormField, 'Email');
      expect(emailField, findsOneWidget);
    });

    testWidgets('should have password field with correct hint', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Assert
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      expect(passwordField, findsOneWidget);
    });
  });

  group('LoginScreen - Form Validation', () {
    testWidgets('should show error when email is empty', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalidemail',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error when password is empty', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Enter your password'), findsOneWidget);
    });

    testWidgets('should show error when password is less than 6 characters', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show error snackbar when login fails', (tester) async {
      // Arrange
      when(mockLoginUsecase.call(any)).thenAnswer(
        (_) async => Left(
          const ApiFailure(message: 'Invalid credentials', statusCode: 401),
        ),
      );

      await tester.pumpWidget(createLoginScreen());

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'wrongpassword',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('LoginScreen - Navigation', () {
    testWidgets(
      'should navigate to register screen when create account is tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());

        // Act
        await tester.tap(find.text('Create new account'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Register Screen'), findsOneWidget);
      },
    );
  });
}
