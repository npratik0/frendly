import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Frendly';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int postsPerPage = 10;
  static const int maxRetryAttempts = 3;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Image Constants
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const double imageQuality = 0.8;

  // Colors - Matching your web app
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryIndigo],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF9FAFB), Color(0xFFEFF6FF), Color(0xFFFAF5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(fontSize: 14, color: textPrimary);

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Default profile picture
  static const String defaultProfilePicture =
      'https://api.dicebear.com/7.x/avataaars/svg?seed=default';
}
