import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_styles.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 15), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircleAvatar(
            //   radius: 48,
            //   backgroundColor: AppColors.lightBlue,
            //   child: Text(
            //     'F',
            //     style: TextStyle(
            //       fontSize: 44,
            //       fontWeight: FontWeight.bold,
            //       color: AppColors.primary,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),
            Text('Frendly', style: AppStyles.logoTitle.copyWith(fontSize: 36)),
          ],
        ),
      ),
    );
  }
}
