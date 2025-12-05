import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import '../widgets/divider_with_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // LOGO
              const Text("Frendly", style: AppStyles.logoTitle),
              const SizedBox(height: 20),

              // TITLE
              const Text("LOGIN", style: AppStyles.screenTitle),
              const SizedBox(height: 10),
              const Text("Welcome to Frendly!", style: AppStyles.subtitle),

              const SizedBox(height: 32),

              /// ---------------- FORM ----------------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      /// EMAIL FIELD
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

                      /// PASSWORD FIELD
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

              const SizedBox(height: 26),

              /// --------------- SIGN IN BUTTON (FULL WIDTH) ---------------
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
                  onPressed: () {
                    if (_form.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 18, // ★ Larger font size
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              /// ---------------- CREATE NEW ACCOUNT ----------------
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  "Create new account",
                  style: TextStyle(fontSize: 15),
                ),
              ),

              const SizedBox(height: 20),

              /// ---------------- DIVIDER ----------------
              const DividerWithText(text: "Or continue with"),

              const SizedBox(height: 18),

              /// ---------------- SOCIAL MEDIA LOGIN ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(label: "G", onTap: () {}),
                  const SizedBox(width: 12),
                  SocialButton(icon: Icons.facebook, onTap: () {}),
                  const SizedBox(width: 12),
                  SocialButton(icon: Icons.apple, onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
