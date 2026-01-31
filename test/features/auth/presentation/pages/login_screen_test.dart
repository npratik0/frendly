import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/auth/presentation/pages/login_screen.dart';
import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
import '../../../../fake/fake_auth_view_model.dart';

void main() {
  Widget loadLoginScreen() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('Should show LOGIN title', (tester) async {
    await tester.pumpWidget(loadLoginScreen());

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Welcome to Frendly!'), findsOneWidget);
  });

  testWidgets('Should show Email and Password fields', (tester) async {
    await tester.pumpWidget(loadLoginScreen());

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Should show validation error on empty submit', (tester) async {
    await tester.pumpWidget(loadLoginScreen());

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('Should navigate to register screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
        ],
        child: MaterialApp(
          routes: {
            '/register': (_) => const Scaffold(body: Text('Register Screen')),
          },
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Create new account'));
    await tester.pumpAndSettle();

    expect(find.text('Register Screen'), findsOneWidget);
  });
}
