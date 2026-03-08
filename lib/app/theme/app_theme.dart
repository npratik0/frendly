// // lib/app/theme/app_theme.dart
// // Centralized theme configuration

// import 'package:flutter/material.dart';
// import '../../core/constants/app_constants.dart';

// class AppTheme {
//   // Private constructor to prevent instantiation
//   AppTheme._();

//   /// Light theme configuration
//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
      
//       // Primary color scheme
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: AppConstants.primaryBlue,
//         brightness: Brightness.light,
//       ),
      
//       // App bar theme
//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         centerTitle: false,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         iconTheme: IconThemeData(color: Colors.black),
//       ),
      
//       // // Card theme
//       // cardTheme: CardTheme(
//       //   elevation: 2,
//       //   shape: RoundedRectangleBorder(
//       //     borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
//       //   ),
//       // ),
      
//       // Elevated button theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           backgroundColor: AppConstants.primaryBlue,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//       ),
      
//       // Text button theme
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppConstants.primaryBlue,
//         ),
//       ),
      
//       // Input decoration theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Colors.grey[100],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppConstants.primaryBlue, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
      
//       // Floating action button theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: AppConstants.primaryBlue,
//         foregroundColor: Colors.white,
//         elevation: 4,
//       ),
      
//       // Bottom navigation bar theme
//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         selectedItemColor: AppConstants.primaryBlue,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
      
//       // Scaffold background color
//       scaffoldBackgroundColor: AppConstants.backgroundGray,
      
//       // Divider theme
//       dividerTheme: DividerThemeData(
//         color: Colors.grey[300],
//         thickness: 1,
//       ),
//     );
//   }

//   /// Dark theme configuration
//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
      
//       // Primary color scheme
//       colorScheme: ColorScheme.fromSeed(
//         seedColor: AppConstants.primaryBlue,
//         brightness: Brightness.dark,
//       ),
      
//       // App bar theme
//       appBarTheme: AppBarTheme(
//         elevation: 0,
//         centerTitle: false,
//         backgroundColor: Colors.grey[900],
//         foregroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
      
//       // // Card theme
//       // cardTheme: CardTheme(
//       //   elevation: 2,
//       //   color: Colors.grey[850],
//       //   shape: RoundedRectangleBorder(
//       //     borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
//       //   ),
//       // ),
      
//       // Elevated button theme
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           elevation: 0,
//           backgroundColor: AppConstants.primaryBlue,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//       ),
      
//       // Text button theme
//       textButtonThemeData: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppConstants.primaryBlue,
//         ),
//       ),
      
//       // Input decoration theme
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: Colors.grey[800],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppConstants.primaryBlue, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
      
//       // Floating action button theme
//       floatingActionButtonTheme: FloatingActionButtonThemeData(
//         backgroundColor: AppConstants.primaryBlue,
//         foregroundColor: Colors.white,
//         elevation: 4,
//       ),
      
//       // Bottom navigation bar theme
//       bottomNavigationBarThemeData: BottomNavigationBarThemeData(
//         selectedItemColor: AppConstants.primaryBlue,
//         unselectedItemColor: Colors.grey[400],
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.grey[900],
//         elevation: 8,
//       ),
      
//       // Scaffold background color
//       scaffoldBackgroundColor: Colors.grey[900],
      
//       // Divider theme
//       dividerTheme: DividerThemeData(
//         color: Colors.grey[700],
//         thickness: 1,
//       ),
//     );
//   }
// }