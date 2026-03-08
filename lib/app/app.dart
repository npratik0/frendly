import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/constants/hive_constants.dart';
import '../core/services/socket_service.dart';
import 'routes/app_routes.dart';

class FrendlyApp extends ConsumerWidget {
  const FrendlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Socket.IO after app is built
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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
