// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/core/constants/hive_table_constant.dart';
// import 'package:frendly/core/services/storage/user_session_service.dart';
// import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
// import 'package:frendly/screens/bottom_screen/home_screen.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/splash_screen.dart';
// import 'screens/onboarding_screen.dart';
// import 'features/auth/presentation/pages/login_screen.dart';
// import 'features/auth/presentation/pages/register_screen.dart';
// import 'screens/bottom_navigation_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   ///  HIVE INITIALIZATION
//   final directory = await getApplicationDocumentsDirectory();
//   final path = '${directory.path}/${HiveTableConstant.dbName}';
//   Hive.init(path);

//   if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
//     Hive.registerAdapter(AuthHiveModelsAdapter());
//   }

//   await Hive.openBox<AuthHiveModels>(HiveTableConstant.authTable);
//   final sharedPreferences = await SharedPreferences.getInstance();

//   // runApp(const FrendlyApp());
//   // runApp(const ProviderScope(child: FrendlyApp()));
//   runApp(
//     ProviderScope(
//       overrides: [
//         sharedPreferencesProvider.overrideWithValue(sharedPreferences),
//       ],
//       child: const FrendlyApp(),
//     ),
//   );
// }

// class FrendlyApp extends StatelessWidget {
//   const FrendlyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Frendly',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true),
//       initialRoute: '/',
//       routes: {
//         '/': (c) => const SplashScreen(),
//         '/onboarding': (c) => const OnboardingScreen(),
//         '/login': (c) => const LoginScreen(),
//         '/register': (c) => const RegisterScreen(),
//         '/home': (c) => const HomeScreen(),
//         '/bottom_navigation': (c) => const BottomNavigationScreen(),
//       },
//     );
//   }
// }
// FIXED main.dart for your existing app with correct type IDs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/constants/hive_table_constant.dart';
import 'package:frendly/core/services/socket_service.dart';
import 'package:frendly/core/services/storage/user_session_service.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:frendly/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:frendly/features/search/data/models/recent_search_hive_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NEW IMPORTS for post feature
import 'features/post/data/models/post_hive_model.dart';
import 'core/constants/hive_constants.dart';

// Existing screen imports
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'screens/bottom_screen/home_screen.dart';
// import 'screens/bottom_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// HIVE INITIALIZATION
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/${HiveTableConstant.dbName}';
  Hive.init(path);

  // Register existing auth adapter (type ID 0 from HiveTableConstant.authTypeId)
  if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
    Hive.registerAdapter(AuthHiveModelsAdapter());
  }

  // NEW: Register post adapters for feed feature
  // Using type IDs 10 and 11 to avoid conflict with your auth (type ID 0)
  if (!Hive.isAdapterRegistered(HiveConstants.postHiveModelTypeId)) {
    Hive.registerAdapter(PostHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveConstants.commentHiveModelTypeId)) {
    Hive.registerAdapter(CommentHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveConstants.recentSearchHiveModelTypeId)) {
    Hive.registerAdapter(RecentSearchHiveModelAdapter());
  }

  // Open existing auth box
  await Hive.openBox<AuthHiveModels>(HiveTableConstant.authTable);
  await Hive.openBox<RecentSearchHiveModel>(HiveConstants.recentSearchesBox);

  // NEW: Open post feature boxes
  await Hive.openBox(HiveConstants.authBox);
  await Hive.openBox(HiveConstants.bookmarkedPostsBox);
  await Hive.openBox(HiveConstants.offlineActionsBox);

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FrendlyApp(),
    ),
  );
}

class FrendlyApp extends ConsumerWidget {
  const FrendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authBox = Hive.box(HiveConstants.authBox);
        final token = authBox.get('token');

        if (token != null && token.isNotEmpty) {
          print('🔌 Initializing Socket.IO connection...');
          SocketService().connect();
        } else {
          print('⚠️ No token found, skipping socket connection');
        }
      } catch (e) {
        print('❌ Error initializing socket: $e');
      }
    });
    return MaterialApp(
      title: 'Frendly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (c) => const SplashScreen(),
        '/onboarding': (c) => const OnboardingScreen(),
        '/login': (c) => const LoginScreen(),
        '/register': (c) => const RegisterScreen(),
        '/home': (c) => const HomeScreen(),
        // '/bottom_navigation': (c) => const BottomNavigationScreen(),
        '/bottom_navigation': (c) => const DashboardScreen(),
      },
    );
  }
}
