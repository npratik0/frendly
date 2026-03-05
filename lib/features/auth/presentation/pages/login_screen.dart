import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/services/storage/token_service.dart';
import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:hive/hive.dart';

import '../../../../theme/app_styles.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/password_field.dart';
import '../../../../widgets/divider_with_text.dart';
import '../state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) async {
      if (next.status == AuthStatus.authenticated) {
        // NEW: Save token to Hive before navigation
        try {
          final tokenService = ref.read(tokenServiceProvider);
          final token = await tokenService.getToken();

          if (token != null && next.authEntity != null) {
            final authBox = await Hive.openBox('auth_box');
            await authBox.put('token', token);
            await authBox.put('current_user', {
              '_id': next.authEntity!.authId,
              'email': next.authEntity!.email,
              'username': next.authEntity!.username,
              'fullName': next.authEntity!.fullName,
              'phoneNumber': next.authEntity!.phoneNumber,
              'gender': next.authEntity!.gender,
              'dateOfBirth': next.authEntity!.dateOfBirth,
              'profilePicture': next.authEntity!.profilePicture,
              'bio': next.authEntity!.bio,
            });
            print('✅ Token synced from login screen');
          }
        } catch (e) {
          print('❌ Error syncing token: $e');
        }

        Navigator.pushReplacementNamed(context, '/bottom_navigation');
      }

      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    ///  LISTEN FOR AUTH STATE CHANGES
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, '/bottom_navigation');
      }

      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // LOGO
              Align(
                alignment: Alignment.center,
                child: const Text("Frendly", style: AppStyles.logoTitle),
              ),
              const SizedBox(height: 50),

              // TITLE
              const Text("LOGIN", style: AppStyles.screenTitle),
              const SizedBox(height: 10),
              const Text("Welcome to Frendly!", style: AppStyles.subtitle),

              const SizedBox(height: 32),

              // Form
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      // EMAIL FIELD
                      CustomTextField(
                        controller: _email,
                        hint: "Email",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your email";
                          }
                          if (!value.contains("@") || !value.contains(".")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD FIELD
                      PasswordField(
                        controller: _pw,
                        hint: "Password",
                        obscure: _obscure,
                        onToggle: () => setState(() => _obscure = !_obscure),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Signin Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () {
                          if (_form.currentState!.validate()) {
                            ref
                                .read(authViewModelProvider.notifier)
                                .login(
                                  email: _email.text.trim(),
                                  password: _pw.text.trim(),
                                );
                          }
                        },
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // Create new account
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  "Create new account",
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 20),

              const DividerWithText(text: "Or continue with"),

              const SizedBox(height: 18),

              // Google login button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google_logo.jpg',
                      height: 30,
                      width: 30,
                    ),
                    label: const Text(
                      "Login with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
