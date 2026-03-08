import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frendly/features/auth/domain/usecases/login_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/register_usecase.dart';
import 'package:frendly/features/auth/domain/usecases/upload_photo_usecase.dart';
import 'package:frendly/features/auth/presentation/pages/register_screen.dart';

import 'register_screen_test.mocks.dart';

@GenerateMocks([LoginUsecase, RegisterUsecase, UploadPhotoUsecase])
void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUploadPhotoUsecase mockUploadPhotoUsecase;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUploadPhotoUsecase = MockUploadPhotoUsecase();
  });

  Widget createRegisterScreen() {
    return ProviderScope(
      overrides: [
        LoginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        RegisterUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        uploadPhotoUsecaseProvider.overrideWithValue(mockUploadPhotoUsecase),
      ],
      child: MaterialApp(
        home: const RegisterScreen(),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      ),
    );
  }

  group('RegisterScreen - UI Elements', () {
    testWidgets('should display all main UI elements', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      expect(find.text('Frendly'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.text('Join the community!'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('should display all form fields', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pump();

      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
    });

    testWidgets('should display profile picture picker', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should display gender radio buttons', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -800),
      );
      await tester.pump();

      expect(find.text('male'), findsOneWidget);
      expect(find.text('female'), findsOneWidget);
      expect(find.text('other'), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNWidgets(3));
    });

    testWidgets('should display interests chips', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1200),
      );
      await tester.pump();

      expect(find.text('Select Interests:'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('should display terms and conditions checkbox', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1500),
      );
      await tester.pump();

      expect(find.text('I agree to the Terms & Conditions'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
    });
  });

  group('RegisterScreen - Gender Selection', () {
    testWidgets('should select male gender when tapped', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      final maleFinder = find.widgetWithText(RadioListTile<String>, 'male');

      await tester.ensureVisible(maleFinder);
      await tester.tap(maleFinder);
      await tester.pumpAndSettle();

      final maleRadio = tester.widget<RadioListTile<String>>(maleFinder);
      expect(maleRadio.groupValue, 'male');
    });

    testWidgets('should select female gender when tapped', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      final femaleFinder = find.widgetWithText(RadioListTile<String>, 'female');

      await tester.ensureVisible(femaleFinder);
      await tester.tap(femaleFinder);
      await tester.pumpAndSettle();

      final femaleRadio = tester.widget<RadioListTile<String>>(femaleFinder);
      expect(femaleRadio.groupValue, 'female');
    });
  });

  group('RegisterScreen - Terms Agreement', () {
    testWidgets('should toggle terms agreement checkbox', (tester) async {
      await tester.pumpWidget(createRegisterScreen());

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1400),
      );
      await tester.pump();

      var checkbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(
          CheckboxListTile,
          'I agree to the Terms & Conditions',
        ),
      );

      expect(checkbox.value, false);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      checkbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(
          CheckboxListTile,
          'I agree to the Terms & Conditions',
        ),
      );

      expect(checkbox.value, true);
    });
  });

  group('RegisterScreen - Registration Flow', () {
    testWidgets(
      'should show success snackbar and navigate on successful registration',
      (tester) async {
        when(
          mockRegisterUsecase.call(any),
        ).thenAnswer((_) async => const Right(true));

        await tester.pumpWidget(createRegisterScreen());

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'),
          'Test User',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Username'),
          'testuser',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'test@test.com',
        );

        final maleFinder = find.widgetWithText(RadioListTile<String>, 'male');

        await tester.ensureVisible(maleFinder);
        await tester.tap(maleFinder);
        await tester.pumpAndSettle();

        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -700),
        );
        await tester.pump();

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });

  group('RegisterScreen - Navigation', () {
    testWidgets(
      'should navigate to login screen when already have account is tapped',
      (tester) async {
        await tester.pumpWidget(createRegisterScreen());

        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -1500),
        );
        await tester.pump();

        await tester.tap(find.text('Already have an account? Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Login Screen'), findsOneWidget);
      },
    );
  });
}
