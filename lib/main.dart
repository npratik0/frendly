import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/constants/hive_table_constant.dart';
import 'package:frendly/core/services/storage/user_session_service.dart';
import 'package:frendly/features/auth/data/models/auth_hive_models.dart';
import 'package:frendly/screens/bottom_screen/home_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/register_screen.dart';
import 'screens/bottom_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///  HIVE INITIALIZATION
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/${HiveTableConstant.dbName}';
  Hive.init(path);

  if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
    Hive.registerAdapter(AuthHiveModelsAdapter());
  }

  await Hive.openBox<AuthHiveModels>(HiveTableConstant.authTable);
  final sharedPreferences = await SharedPreferences.getInstance();

  // runApp(const FrendlyApp());
  // runApp(const ProviderScope(child: FrendlyApp()));
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FrendlyApp(),
    ),
  );
}

class FrendlyApp extends StatelessWidget {
  const FrendlyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        '/bottom_navigation': (c) => const BottomNavigationScreen(),
      },
    );
  }
}
